//
//  PosterQueryManager.swift
//  FilmSwipe
//
//  Created by Dylan Southard on 2018/10/25.
//  Copyright © 2018 Dylan Southard. All rights reserved.
//

import UIKit

class PosterQueryManager: NSObject, PosterQueryDelegate, IndividualQueryDelegate {
    
    
    var completion:(_ toRequery:[Movie])->() = {_ in }
    var errors = [Movie]()
    
    func queryPoster(forMovie movie:Movie, onCompletion completion:@escaping (_ toRequery:[Movie])->()) {
        self.completion = completion
        
        PosterQuery(delegate: self).execute(movies:[movie])
    }
    
    func addPoster(_ posterData: Data?, forMovie movie: Movie, error: String?) {
        if let e = error {print(e)}
       
        if let data = posterData, UIImage(data:data) != nil {
            
            movie.setPoster(withData: data)
            
        } else if posterData != nil {
            
            self.errors.append(movie)
            
        }
    }
    func completeQueries() {
        if self.errors.count < 1 {
            
            self.completion([])
            
            return
        }
         
        IndividualMovieQuery(delegate: self).execute(movieIDs: errors.map{$0.id})
        
    }
    
    func individualQueryComplete(results: [Movie]?, error: String?) {
       
        guard let realResults = results else {
            
            return}
        var moviesToRequery = [Movie]()
        for result in realResults {
            guard let existingMovie = self.errors.filter({$0.id == result.id}).first else {continue}
            
            if existingMovie.imageURL != result.imageURL {
                
                existingMovie.imageURL = result.imageURL
                
                moviesToRequery.append(existingMovie)
                
            }

        }
        
        self.completion(moviesToRequery)
        
     }
    
    
    
func updateProgressBar(by progress: Float) {}
    

}
