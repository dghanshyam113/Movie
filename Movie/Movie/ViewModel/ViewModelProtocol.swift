//
//  ViewModelProtocol.swift
//  Movie
//
//  Created by Ghanshyam Doifode on 15/06/22.
//

import Foundation

protocol ViewModelProtocol {
    var movies: [Movie]? { get set }
    var isPaginating: Bool { get set }
    var didFetchMoviesSucceed: (()->Void)? { get set }
    var didFetchMoviesFail: ((Error?)->Void)? { get set }
    func fetchMovies(for searchText: String?, pageNumber: Int)
    func getMovie(at index: Int) -> Movie
}
