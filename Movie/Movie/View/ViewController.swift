//
//  ViewController.swift
//  Movie
//
//  Created by Ghanshyam Doifode on 15/06/22.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: - Constant
    
    enum UIConstants {
        static let FOOTER_ID = "footer"
        static let FOOTER_SIZE: CGFloat = 60
        static let INSET: CGFloat = 10
        static let numberOfRows = 2
    }
    
    // MARK: - Outlets
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var emptyView: UIView!
    
    // MARK: - Properties

    var debounce_timer: Timer?
    var searchController: UISearchController!
    var paginationActivity = UIActivityIndicatorView(style: .large)
    var fetchingMore = false
    var currentPage = 1
   
    var viewModel: ViewModelProtocol! {

        didSet {
            viewModel.didFetchMoviesSucceed = { [weak self] in
                
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    self.paginationActivity.stopAnimating()
                    self.refreshUI()
                    self.fetchingMore = false
                }
            }
            
            viewModel.didFetchMoviesFail = { [weak self] error in
                
                guard let self = self else { return }
                self.fetchingMore = false

                DispatchQueue.main.async {
                    self.paginationActivity.stopAnimating()
                    let errorString = error?.localizedDescription ?? "Something went wrong."
                    let alert = UIAlertController(title: "Error", message: errorString, preferredStyle: .alert)
                    let button = UIAlertAction(title: "Okay", style: .default, handler: nil)
                    alert.addAction(button)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = ViewModel()
        setupCollectionView()
        configureSearch()
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationController?.navigationBar.backgroundColor = .systemGray6
    }
    
    // MARK: - Private Method

    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(MovieCollectionViewCell.nib(), forCellWithReuseIdentifier: MovieCollectionViewCell.identifier)
        collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: UIConstants.FOOTER_ID)
    }
    
    private func configureSearch() {
        let search = UISearchController(searchResultsController: nil)
        search.searchResultsUpdater = self
        search.obscuresBackgroundDuringPresentation = false
        search.searchBar.placeholder = "Type movie name here to search"
        search.searchBar.delegate = self
        navigationItem.searchController = search
        self.searchController = search
    }

    private func refreshUI() {
        emptyView.isHidden = !(viewModel.movies?.count == 0)
        collectionView.reloadSections(IndexSet.init(integer: 0))
    }
    
    private func beginBatchFetch() {
        self.paginationActivity.startAnimating()
        self.fetchingMore = true
        viewModel.isPaginating = true
        currentPage = currentPage + 1
        viewModel.fetchMovies(for: searchController.searchBar.searchTextField.text, pageNumber: currentPage)
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.movies?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieCollectionViewCell.identifier, for: indexPath) as? MovieCollectionViewCell else {
            fatalError("Cannot dequeue cell of type \(MovieCollectionViewCell.description())")
        }
        configure(cell, for: indexPath)
        return cell
    }
    
    private func configure(_ cell: MovieCollectionViewCell, for indexPath: IndexPath) {
        let movie = viewModel.getMovie(at: indexPath.row)
        cell.movieImageView.fetchImage(for: movie.Poster ?? "")
        cell.movieNameLabel.text = movie.Title
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: UIConstants.INSET, left: UIConstants.INSET, bottom: UIConstants.INSET, right: UIConstants.INSET);
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = (view.frame.size.width / CGFloat(UIConstants.numberOfRows)) - 15
        return CGSize(width: cellWidth, height: (223.0))
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionFooter:
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: UIConstants.FOOTER_ID, for: indexPath)
            footerView.addSubview(paginationActivity)
            paginationActivity.translatesAutoresizingMaskIntoConstraints = false
            paginationActivity.centerXAnchor.constraint(equalTo: footerView.centerXAnchor).isActive = true
            paginationActivity.centerYAnchor.constraint(equalTo: footerView.centerYAnchor).isActive = true
            return footerView
            
        default:
            fatalError("Unexpected element kind")
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: UIConstants.FOOTER_SIZE, height: UIConstants.FOOTER_SIZE)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let moviesCount = viewModel.movies?.count else {
            return
        }
        if (indexPath.row == moviesCount - 1) && (moviesCount > 9) { //last cell
          //Load more data & reload collection view
           if !fetchingMore {
               beginBatchFetch()
           }
        }
    }
}

// MARK: - UISearchBarDelegate

extension ViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        cache.removeAllObjects()
        self.currentPage = 1
        viewModel.isPaginating = false
        guard let text = searchController.searchBar.text, !text.isEmpty else { return }
        debounce_timer?.invalidate()
        debounce_timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { _ in
            self.viewModel.fetchMovies(for: text, pageNumber: self.currentPage)
        }
    }
    
}
