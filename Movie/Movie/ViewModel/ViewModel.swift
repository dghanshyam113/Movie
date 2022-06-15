//
//  ViewModel.swift
//  Movie
//
//  Created by Ghanshyam Doifode on 15/06/22.
//

import Foundation

class ViewModel: ViewModelProtocol {

    // MARK: - Properties

    var didFetchMoviesSucceed: (() -> Void)?
    var didFetchMoviesFail: ((Error?) -> Void)?
    var isPaginating: Bool = false
    var movies: [Movie]?
    var movieService: NetworkManagerProtocol
    
    // MARK: - Initilizar
    
    init(movieService: NetworkManagerProtocol = NetworkManager()) {
        self.movieService = movieService
    }
    
    // MARK: - Public Methods

    func fetchMovies(for searchText: String?, pageNumber: Int) {
        self.movieService.downloadMovies(for: searchText, pageNumber: pageNumber) { result in
            guard !(result.Search?.isEmpty ?? true) else { return }
            if self.isPaginating {
                self.movies?.append(contentsOf: result.Search ?? [])
            } else {
                self.movies = result.Search ?? []
            }
            self.didFetchMoviesSucceed?()
        } failure: { error in
            self.didFetchMoviesFail?(error)
        }
    }

    func getMovie(at index: Int) -> Movie {
        guard let movieCount = self.movies?.count, index < movieCount, let movie = self.movies?[index] else {
            fatalError("Movie index out of range. Please check the datasource count.")
        }
        return movie
    }
    
}
