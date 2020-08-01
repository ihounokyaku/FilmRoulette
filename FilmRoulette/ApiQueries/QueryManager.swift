//
//  QueryManager.swift
//  FilmSwipe
//
//  Created by Dylan Southard on 2018/10/07.
//  Copyright © 2018 Dylan Southard. All rights reserved.
//

import UIKit
import Alamofire

enum QueryType {
    case search
}

protocol QueryDelegate {
    var moviesToDisplay:[Movie] {get set}
    var navContainer:NavContainer {get}
    func updateProgressBar(by progress:Float)
    func handleNoResults()
    func setProgressBar(to location: Float)
    
    func refreshDisplay()
}

class QueryManager: NSObject, PosterQueryDelegate, MainQueryDelegate, IndividualQueryDelegate {
    
    
    
    
    //MARK: - ======================VARS===============================
    
    //MARK: ==API VARIABLES==
    

    //MARK: ==STATE VARIABLES==
    var page = 0
    var currentQuery:QueryType?
    
    //MARK: ==DELEGATES==
    var delegate:QueryDelegate!

    
    
    //MARK: - ======================SETUP===============================
    override init() {
        super.init()
        
    }
    
    
    //MARK: - =====================QUERY METHODS================================
    
    //MARK: - ==MAIN QUERY ==
    
    //MARK: SEARCH
    func beginSearch(forTerm searchTerm:String){
        
        self.setProgressBar(to: 0)
        SearchQuery(delegate:self).execute(searchTerm: searchTerm)
    }
    
    //MARK: INITIAL COMPLETE
    func initialQueryComplete(results: [Int]?, error: String?) {
        if let ids = results {
            self.queryIndividualMovies(ids: ids)
        } else {
            self.cPrint(error ?? "unknown error")
        }
    }
    
    //MARK: - ==QUERY INDIVIDUAL==
    private func queryIndividualMovies(ids:[Int]) {
        if ids.count == 0 {
            print("no results!")
            self.setProgressBar(to: 0)
            self.delegate.handleNoResults()
            return
            
        }
        IndividualMovieQuery(delegate: self).execute(movieIDs: ids)
    }
    
    func individualQueryComplete(results: [Movie]?, error: String?) {
        if let movies = results {
            self.queryPosters(forMovies: movies)
        } else {
            self.cPrint(error ?? "unknown error")
        }
    }
    
    //MARK: - ==QUERY POSTERS==
    func queryPosters(forMovies movies:[Movie]) {
        PosterQuery(delegate: self).execute(movies: movies)
    }
    
    func addPoster(_ posterData: Data?, forMovie movie: Movie, error: String?) {
        if let e = error { self.cPrint(e)}
        
        if let data = posterData, UIImage(data:data) != nil {
            SessionData.Posters[movie.id] = data
        }
        self.delegate.moviesToDisplay.append(movie)
        self.delegate.refreshDisplay()
    }
    
     //MARK: ==QUERIES COMPLETE ==
    func completeQueries() {
       
    }
    
    //MARK: - =====================QUERY MANAGERS ================================
    
    //MARK: - ==CANCEL==
    func cancelAllCurrentQueries() {
        Alamofire.SessionManager.default.session.getTasksWithCompletionHandler { (sessionDataTask, uploadData, downloadData) in
            sessionDataTask.forEach { $0.cancel() }
            uploadData.forEach { $0.cancel() }
            downloadData.forEach { $0.cancel() }
        }
        self.currentQuery = nil
    }
    
    
    
    //MARK: - ======PROGRESS BAR========
    
    func updateProgressBar(by progress:Float) {
        
        self.delegate.updateProgressBar(by: progress)
    }
    
    func setProgressBar(to location: Float) {
        self.delegate.setProgressBar(to: location)
    }
    
    
    //MARK: - =====================CONVENIENCES ================================
    
    func cPrint(_ message:Any) {
        print(message)
    }
    
    
    
}
