//
//  Movie.swift
//  Movie
//
//  Created by Ghanshyam Doifode on 15/06/22.
//

import Foundation

struct Result: Codable {
    var Search: [Movie]?
}

struct Movie: Codable {
    var Title: String?
    var Year: String?
    var imdbID: String?
    var `Type`: String?
    var Poster: String?
}
