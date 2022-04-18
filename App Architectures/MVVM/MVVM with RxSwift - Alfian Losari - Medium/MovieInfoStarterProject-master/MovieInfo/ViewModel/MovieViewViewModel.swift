//
//  MovieViewViewModel.swift
//  MovieInfo
//
//  Created by Hilmy Veradin on 16/04/22.
//  Copyright © 2022 Alfian Losari. All rights reserved.
//

import Foundation

struct MovieViewViewModel {
  private var movie: Movie
  
  //  private static let dateFormatter: DateFormatter = {
  //    $0.dateStyle = .medium
  //    $0.timeStyle = .none
  //    return $0
  //  }(DateFormatter())
  
  private static let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .none
    return formatter
  }()
  
  init(movie: Movie) {
    self.movie = movie
  }
  
  var title: String {
    return movie.title
  }
  
  var overview: String {
    return movie.overview
  }
  
  var posterURL: URL {
    return movie.posterURL
  }
  
  var releaseDate: String {
    return MovieViewViewModel.dateFormatter.string(from: movie.releaseDate)
  }
  
  var rating: String {
    let rating = Int(movie.voteAverage)
    let ratingText = (0..<rating).reduce("") { (acc, _) -> String in
      return acc + "⭐️"
    }
    return ratingText
  }
}
