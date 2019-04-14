//
//  PosterGetter.swift
//  FilmRoulette
//
//  Created by Dylan Southard on 2019/04/14.
//  Copyright © 2019 Dylan Southard. All rights reserved.
//

import UIKit
import RealmSwift

protocol PosterGetterDelegate {
    func loadedPoster()
}


class PosterGetter: NSObject {

    var loading:Bool {
        return self.queryList.count > self.queryIndex
    }
   
    var queryList = [Movie]()
    var queryIndex = 0
    var delegate:PosterGetterDelegate!
    
    required init(delegate:PosterGetterDelegate) {
        super.init()
        self.delegate = delegate
    }
    
    func reset() {
        self.queryList.removeAll()
        self.queryIndex = 0
    }
    
    func completeMissingPosters(forMovies movieList:Results<Movie>) {
        self.reset()
        
        for movie in movieList {
            if !movie.imageExists && movie.imageUrl != "" {
                //                print("going to get poster for \(movie.title)")
                self.queryList.append(Movie(value:movie))
            }
        }
        
        self.loadNextPoster()
    }
    
    func loadNextPoster(){
        guard self.loading == true else {return}
        let movie = self.queryList[self.queryIndex]
        PosterQueryManager().queryPoster(forMovie: movie, onCompletion: self.completeQueries)
    }
    
    
    func completeQueries() {
        self.queryIndex += 1
        self.delegate.loadedPoster()
        self.loadNextPoster()
    }
}
