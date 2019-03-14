//
//  IndividualMovieQuery.swift
//  FilmSwipe
//
//  Created by Dylan Southard on 2018/10/07.
//  Copyright © 2018 Dylan Southard. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

protocol IndividualQueryDelegate {
    var apiKey:String {get}
    func individualQueryComplete(results:[Movie]?, error:String?)
    func updateProgressBar(by progress:Float)
}

class IndividualMovieQuery: NSObject {
    let querySingleURL = "https://api.themoviedb.org/3/movie/"
    var delegate:IndividualQueryDelegate!
    var movies = [Movie]()
    var failedMovies = 0
    
    required init(delegate:IndividualQueryDelegate) {
        self.delegate = delegate
    }
    
    
    func execute(movieIDs:[Int]) {
//        print("querying individual \(movieIDs.count) movies")
        var index = 0
        self.delegate.updateProgressBar(by:0.1)
        for id in movieIDs {
            
            
            Alamofire.request(self.querySingleURL + "\(id)", method:.get, parameters:["api_key":self.delegate.apiKey,"append_to_response":"videos"]).responseJSON { (response) in
                index += 1
//                print("querying \(index) of individual \(movieIDs.count) movies")
                self.delegate.updateProgressBar(by: (0.9 / Float(movieIDs.count)))
                
                if response.result.isSuccess {
                    
                    let movieData:JSON =  JSON(response.result.value!)
                    
                    //MARK: CREATE MOVIE OBJECT AND GET TRAILER
                    if let movie = movieData.toMovie() {
                        
                        self.movies.append(movie)
                        
                        //MARK: CHECK IF MOVIE ARRAY IS FULL AND GET POSTERS IF SO
                        self.checkForCompletion(totalNumber:movieIDs.count)
                        
                    } else {
                        //MARK: IF FAILED MARK AS SUCH
                        self.failedMovies += 1
                        self.checkForCompletion(totalNumber: movieIDs.count)
                    }
                } else {
                    self.delegate.individualQueryComplete(results: nil, error: String(describing: response.result.error))
                }
            }
        }
    }
    
    func checkForCompletion(totalNumber:Int) {
        if self.movies.count + self.failedMovies >= totalNumber {
            if movies.count > 0 {
//                print("going to get poster")
                self.delegate.individualQueryComplete(results: movies, error: nil)
            } else {
                self.delegate.individualQueryComplete(results: nil, error: "No Results!")
            }
        }
    }
    
    
    func singleMovieParams()->[String:String] {
        var params = [String:String]()
        params["api_key"] = self.delegate.apiKey
        params["append_to_response"] = "videos"
        
        return params
    }
}
