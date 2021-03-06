//
//  MovieSearchViewController.swift
//  MovieInfo
//
//  Created by Alfian Losari on 10/03/19.
//  Copyright © 2019 Alfian Losari. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class MovieSearchViewController: UIViewController {
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var infoLabel: UILabel!
  @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
  //
  //  let dateFormatter: DateFormatter = {
  //    $0.dateStyle = .medium
  //    $0.timeStyle = .none
  //    return $0
  //  }(DateFormatter())
  //
  //  var service: MovieService = MovieStore.shared
  //  var movies = [Movie]() {
  //    didSet {
  //      tableView.reloadData()
  //    }
  //  }
  //
  //  override func viewDidLoad() {
  //    super.viewDidLoad()
  //
  //    setupNavigationBar()
  //    setupTableView()
  //  }
  //
  //
  //  private func setupTableView() {
  //    tableView.tableFooterView = UIView()
  //    tableView.rowHeight = UITableView.automaticDimension
  //    tableView.estimatedRowHeight = 100
  //    tableView.register(UINib(nibName: "MovieCell", bundle: nil), forCellReuseIdentifier: "MovieCell")
  //  }
  //
  //
  //  }
  
  var movieSearchViewViewModel: MovieSearchViewViewModel!
  let disposeBag = DisposeBag()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupNavigationBar()
    
    let searchBar = self.navigationItem.searchController!.searchBar
    
    movieSearchViewViewModel = MovieSearchViewViewModel(query: searchBar.rx.text.orEmpty.asDriver(), movieService: MovieStore.shared)
    movieSearchViewViewModel
      .movies.drive(onNext: {[unowned self] (_) in
        self.tableView.reloadData()
      }).disposed(by: disposeBag)
    
    movieSearchViewViewModel
      .isFetching
      .drive(activityIndicatorView.rx.isAnimating)
      .disposed(by: disposeBag)
    
    movieSearchViewViewModel.info.drive(onNext: {[unowned self] (info) in
      self.infoLabel.isHidden = !self.movieSearchViewViewModel.hasInfo
      self.infoLabel.text = info
    }).disposed(by: disposeBag)
    
    searchBar.rx.searchButtonClicked
      .asDriver(onErrorJustReturn: ())
      .drive(onNext: { [unowned searchBar] in
        searchBar.resignFirstResponder()
      }).disposed(by: disposeBag)
    
    searchBar.rx.cancelButtonClicked
      .asDriver(onErrorJustReturn: ())
      .drive(onNext: { [unowned searchBar] in
        searchBar.resignFirstResponder()
      }).disposed(by: disposeBag)
    
    setupTableView()
  }
  
  private func setupNavigationBar() {
    navigationItem.searchController = UISearchController(searchResultsController: nil)
    self.definesPresentationContext = true
    navigationItem.searchController?.dimsBackgroundDuringPresentation = false
    navigationItem.searchController?.hidesNavigationBarDuringPresentation = false
    
    navigationItem.searchController?.searchBar.sizeToFit()
    navigationItem.hidesSearchBarWhenScrolling = false
    navigationController?.navigationBar.prefersLargeTitles = true
  }
  
  private func setupTableView() {
    tableView.tableFooterView = UIView()
    tableView.rowHeight = UITableView.automaticDimension
    tableView.estimatedRowHeight = 100
    tableView.register(UINib(nibName: "MovieCell", bundle: nil), forCellReuseIdentifier: "MovieCell")
  }
  
}

//extension MovieSearchViewController: UITableViewDataSource, UITableViewDelegate {
//
//  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//    return movies.count
//  }
//
//  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//    let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
//    let movie = movies[indexPath.row]
//
//    cell.titleLabel.text = movie.title
//    cell.releaseDateLabel.text = dateFormatter.string(from: movie.releaseDate)
//    cell.overviewLabel.text = movie.overview
//    cell.posterImageView.kf.setImage(with: movie.posterURL)
//
//    let rating = Int(movie.voteAverage)
//    let ratingText = (0..<rating).reduce("") { (acc, _) -> String in
//      return acc + "⭐️"
//    }
//    cell.ratingLabel.text = ratingText
//
//    return cell
//  }
//
//}

extension MovieSearchViewController: UITableViewDataSource, UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return movieSearchViewViewModel.numberOfMovies
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
    if let viewModel = movieSearchViewViewModel.viewModelForMovie(at: indexPath.row) {
      cell.configure(viewModel: viewModel)
    }
    return cell
  }
  
}


