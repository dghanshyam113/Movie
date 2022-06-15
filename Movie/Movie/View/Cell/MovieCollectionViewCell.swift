//
//  MovieCollectionViewCell.swift
//  Movie
//
//  Created by Ghanshyam Doifode on 15/06/22.
//

import UIKit

class MovieCollectionViewCell: UICollectionViewCell {

    // MARK: - Outlets

    @IBOutlet weak var movieImageView: MovieImageView!
    @IBOutlet weak var movieNameLabel: UILabel!
    
    // MARK: - Constants

    static var identifier = "MovieCollectionViewCell"
    
    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.movieImageView.image = nil
    }
    
    // MARK: - Public Method

    static func nib() -> UINib {
        return UINib(nibName: "MovieCollectionViewCell", bundle: nil)
    }
    
    // MARK: - Private Method

    private func setup() {
        movieImageView.clipsToBounds = true
        movieImageView.layer.cornerRadius = 5
    }

}
