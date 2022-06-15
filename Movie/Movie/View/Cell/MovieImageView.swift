//
//  MovieImageView.swift
//  Movie
//
//  Created by Ghanshyam Doifode on 15/06/22.
//

import UIKit

let cache = NSCache<NSString, UIImage>()

class MovieImageView: UIImageView {
    
    // MARK: - Constants
    
    var urlString: String?
    let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // MARK: - Private Method

    private func addLoader() {
        self.addSubview(activityIndicator)
        activityIndicator.frame = self.frame
        activityIndicator.startAnimating()
    }
    
    private func removeLoader() {
        activityIndicator.stopAnimating()
        activityIndicator.removeFromSuperview()
    }
    
    // MARK: - Public Method

    func fetchImage(for urlString: String) {
        self.urlString = urlString
        // If image present in cache, no need to download.
        if let imageFromCache = cache.object(forKey: urlString as NSString) {
            self.image = imageFromCache
            return
        }
        
        addLoader()
        
        if let url =  URL(string: urlString) {
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                DispatchQueue.main.async {
                    self.removeLoader()
                    guard let data = data, error == nil else {
                        // show alert or retry
                        self.image = UIImage(named: "placeholder")
                        return
                    }
                    if urlString == self.urlString {
                        let downloadedImage = UIImage(data: data)
                        self.image = downloadedImage
                        if let dImage = downloadedImage {
                            cache.setObject(dImage, forKey: urlString as NSString)
                        }
                    }
                }
                
            }.resume()
            
        } else {
            removeLoader()
            self.image = UIImage(named: "placeholder")
        }
    }

}
