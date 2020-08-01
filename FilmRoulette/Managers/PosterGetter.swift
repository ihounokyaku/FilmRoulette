//
//  PosterGetter.swift
//  FilmRoulette
//
//  Created by Dylan Southard on 2019/04/14.
//  Copyright © 2019 Dylan Southard. All rights reserved.
//

import UIKit

protocol PosterGetterDelegate {
    func loadedPoster(_ toRequery:[Movie])
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
    
    func completeMissingPosters(forMovies movieList:[Movie]) {
        if movieList.count < 1 { return }
        self.reset()
        self.getPosters(forMovies: movieList)
        
    }
    
    func completeErrorPosters(forMovies movieList:[Movie]) {
        if movieList.count < 1 { return }
        
        self.getPosters(forMovies: movieList)
        
       
    }
    
    private func getPosters(forMovies movieList:[Movie]) {
        
        for movie in movieList {
            if !movie.imageExists && movie.imageURL != "" {
                
                print("going to get poster for \(movie.title)")
                self.queryList.append(movie)
            }
        }
         self.loadNextPoster()
        
    }
    
    func loadNextPoster(){
        print("loading")
        guard self.loading == true else {
            print("loading is \(self.loading)")
            return}
        let movie = self.queryList[self.queryIndex]
        print("loading for \(movie.title)")
        PosterQueryManager().queryPoster(forMovie: movie, onCompletion: self.completeQueries)

    }
    
    
    func completeQueries(_ toRequery:[Movie]) {
        
        self.queryIndex += 1
        self.delegate.loadedPoster(toRequery)
        self.loadNextPoster()
    }
}
