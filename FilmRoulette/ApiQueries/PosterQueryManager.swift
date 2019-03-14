//
//  PosterQueryManager.swift
//  FilmSwipe
//
//  Created by Dylan Southard on 2018/10/25.
//  Copyright © 2018 Dylan Southard. All rights reserved.
//

import UIKit

class PosterQueryManager: NSObject, PosterQueryDelegate {
    
    var completion:()->() = {}
    
    func queryPoster(forMovie movie:Movie, onCompletion completion:@escaping ()->()) {
        self.completion = completion
        PosterQuery(delegate: self).execute(movies:[movie])
    }
    
    func addPoster(_ posterData: Data?, forMovie movie: Movie, error: String?) {
        if let e = error {print(e)}
        
        if let data = posterData, UIImage(data:data) != nil {
            if let existingMovie = GlobalDataManager.movie(withId: movie.id) {
               GlobalDataManager.updatePoster(forMovie:existingMovie, posterData: data)
            }
        }
    }
    
    func completeQueries() {
        self.completion()
    }
    
    func updateProgressBar(by progress: Float) {
    }
    

}
