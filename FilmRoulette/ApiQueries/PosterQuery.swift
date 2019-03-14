//
//  PosterQuery.swift
//  FilmSwipe
//
//  Created by Dylan Southard on 2018/10/07.
//  Copyright © 2018 Dylan Southard. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

protocol PosterQueryDelegate {
    func addPoster(_ posterData: Data?, forMovie movie:Movie, error:String?)
    func completeQueries()
    func updateProgressBar(by progress:Float)
}

class PosterQuery: NSObject {
    
    var posterSize:String {
        return DeviceIsIpad ? "500" : "200"
    }
    
    var delegate:PosterQueryDelegate!
    var completedQueries = 0
    
    required init(delegate:PosterQueryDelegate) {
        self.delegate = delegate
    }
    
    func execute(movies:[Movie]) {
        
        for movie in movies {
            
            Alamofire.request("https://image.tmdb.org/t/p/w\(self.posterSize)" + movie.imageUrl).responseData { (response) in
                //MARK: attempt to get image data
               self.delegate.updateProgressBar(by: 0.4 / Float(movies.count))
                
                if response.result.isSuccess {
                    
                    self.delegate.addPoster(response.data, forMovie: movie, error:nil)
                    self.checkForCompletion(total: movies.count)
                    
                } else {
                    self.delegate.addPoster(nil, forMovie: movie, error: String(describing: response.result.error))
                    self.checkForCompletion(total: movies.count)
                }
            }
        }
    }
    
    private func checkForCompletion(total:Int) {
        self.completedQueries += 1
        if self.completedQueries == total {
            self.delegate.completeQueries()
        }
    }
}
