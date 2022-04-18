//
//  MovieListViewController.swift
//  MovieInfo
//
//  Created by Alfian Losari on 10/03/19.
//  Copyright © 2019 Alfian Losari. All rights reserved.
//

import UIKit
import Kingfisher
import RxSwift
import RxCocoa

class MovieListViewController: UIViewController {
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
  @IBOutlet weak var infoLabel: UILabel!
  @IBOutlet weak var segmentedControl: UISegmentedControl!
  
  //  let dateFormatter: DateFormatter = {
  //    $0.dateStyle = .medium
  //    $0.timeStyle = .none
  //    return $0
  //  }(DateFormatter())
  //
  //  let movieService: MovieService = MovieStore.shared
  //  var movies = [Movie]() {
  //    didSet {
  //      tableView.reloadData()
  //    }
  //  }
  //
  //  var endpoint = Endpoint.nowPlaying {
  //    didSet {
  //      fetchMovies()
  //    }
  //  }
  //
  //  override func viewDidLoad() {
  //    super.viewDidLoad()
  //
  //    segmentedControl.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
  //    setupTableView()
  //    fetchMovies()
  //  }
  
  var movieListViewViewModel: MovieListViewViewModel!
  let disposeBag = DisposeBag()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    movieListViewViewModel = MovieListViewViewModel(endpoint: segmentedControl.rx.selectedSegmentIndex
      .map { Endpoint(index: $0) ?? .nowPlaying }
      .asDriver(onErrorJustReturn: .nowPlaying)
                                                    , movieService: MovieStore.shared)
    
    movieListViewViewModel.movies.drive(onNext: {[unowned self] (_) in
      self.tableView.reloadData()
    }).disposed(by: disposeBag)
    
    movieListViewViewModel
      .isFetching
      .drive(activityIndicatorView.rx.isAnimating)
      .disposed(by: disposeBag)
    
    movieListViewViewModel
      .error
      .drive(onNext: {[unowned self] (error) in
        self.infoLabel.isHidden = !self.movieListViewViewModel.hasError
        self.infoLabel.text = error
      }).disposed(by: disposeBag)
    
    setupTableView()
  }
  
  //  private func fetchMovies() {
  //    self.movies = []
  //    activityIndicatorView.startAnimating()
  //    infoLabel.isHidden = true
  //
  //    movieService.fetchMovies(from: endpoint, params: nil, successHandler: {[unowned self] (response) in
  //      self.activityIndicatorView.stopAnimating()
  //      self.movies = response.results
  //    }) { [unowned self] (error) in
  //      self.activityIndicatorView.stopAnimating()
  //      self.infoLabel.text = error.localizedDescription
  //      self.infoLabel.isHidden = false
  //    }
  //  }
  //
    private func setupTableView() {
      tableView.tableFooterView = UIView()
      tableView.rowHeight = UITableView.automaticDimension
      tableView.estimatedRowHeight = 100
      tableView.register(UINib(nibName: "MovieCell", bundle: nil), forCellReuseIdentifier: "MovieCell")
    }
  //
  //  @objc func segmentChanged(_ sender: UISegmentedControl) {
  //    endpoint = sender.endpoint
  //  }
}

//extension MovieListViewController: UITableViewDataSource, UITableViewDelegate {
//
//  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//    return movies.count
//  }
//
//  //  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//  //    let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
//  //    let movie = movies[indexPath.row]
//  //
//  //
//  //    cell.titleLabel.text = movie.title
//  //    cell.releaseDateLabel.text = dateFormatter.string(from: movie.releaseDate)
//  //    cell.overviewLabel.text = movie.overview
//  //    cell.posterImageView.kf.setImage(with: movie.posterURL)
//  //
//  //    let rating = Int(movie.voteAverage)
//  //    let ratingText = (0..<rating).reduce("") { (acc, _) -> String in
//  //      return acc + "⭐️"
//  //    }
//  //    cell.ratingLabel.text = ratingText
//  //
//  //    return cell
//  //  }
//
//  /*
//   steps:
//   1. create view model with "Model" types as its parameter
//   2. embedd view model using configure in cells properties
//   3. assign called data model to view model
//   */
//
//  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//    let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
//    let movie = movies[indexPath.row]
//    //2
//    let viewModel = MovieViewViewModel(movie: movie)
//    //3
//    cell.configure(viewModel: viewModel)
//    return cell
//  }
//
//}

//MARK: TableView ViewModel Ver 2
extension MovieListViewController: UITableViewDataSource, UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return movieListViewViewModel.numberOfMovies
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
    if let viewModel = movieListViewViewModel.viewModelForMovie(at: indexPath.row) {
      cell.configure(viewModel: viewModel)
    }
    return cell
  }
}
