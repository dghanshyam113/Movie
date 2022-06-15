//
//  NetworkManager.swift
//  Movie
//
//  Created by Ghanshyam Doifode on 15/06/22.
//

import Foundation

protocol NetworkManagerProtocol {
    func downloadMovies(for searchTerm: String?, pageNumber: Int, success: @escaping (Result)->Void, failure: @escaping (Error?)->Void)
}

class NetworkManager: NetworkManagerProtocol {
    
    // MARK: - Constants
    
    private let API_KEY = "b9bd48a6"
    private let baseUrl = "http://www.omdbapi.com/?apikey="
    private let session = URLSession.shared
    
    // MARK: - Private Method
    
    private func getUrl(for searchTerm: String?, pageNumber: Int?) -> URL {
        var string = baseUrl + API_KEY
        if let text = searchTerm?.addingPercentEncoding(withAllowedCharacters: .alphanumerics) {
            string += "&s=\(text)"
        }
        
        string += "&type=movie"

        if let page = pageNumber {
            string += "&page=\(page)"
        }
        
        guard let url = URL(string: string) else {
            fatalError("Cannot create url from string: \(string)")
        }
        
        return url
    }
    
    // MARK: - Public Method

    func downloadMovies(for searchTerm: String?, pageNumber: Int, success: @escaping (Result)->Void, failure: @escaping (Error?)->Void) {
        let url = getUrl(for: searchTerm, pageNumber: pageNumber)
        session.dataTask(with: url) { data, response, error in
            if let error = error {
                failure(error)
                return
            }
            
            if let json = data {
                do {
                    let result = try JSONDecoder().decode(Result.self, from: json)
                    success(result)
                } catch (let error) {
                    failure(error)
                }
            } else {
                failure(error)
            }
            
        }.resume()
    }
}
