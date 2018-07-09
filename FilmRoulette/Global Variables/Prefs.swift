//
//  Prefs.swift
//  FilmSwipe
//
//  Created by Dylan Southard on 2018/06/12.
//  Copyright © 2018 Dylan Southard. All rights reserved.
//

import UIKit

class Prefs: NSObject {
    
    
    //MARK: - =========QUERY PARAMS==========
    
    
    //MARK: - ==GENRES==
    
    static var selectedGenres:[String] {
        get {
            return UserDefaults.standard.value(forKey: "selectedGenres") as? [String] ?? Genres
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "selectedGenres")
        }
    }


    //MARK: - ==RELEASE YEAR VARS==
    
    static var startYear:Int {
        get {
            return UserDefaults.standard.value(forKey: "startYear") as? Int ?? 1900
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "startYear")
        }
    }
    
    static var endYear:Int {
        get {
            return UserDefaults.standard.value(forKey: "endYear") as? Int ?? Date().year()
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "endYear")
        }
    }
    
    
    //MARK: - ==SORT TYPE ==
    static var sortType:String {
        get {
            return UserDefaults.standard.value(forKey: "sortType") as? String ?? "Popularity"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "sortType")
        }
    }
    
    static var sortOrder:String {
        get {
            return UserDefaults.standard.value(forKey: "sortOrder") as? String ?? ".desc"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "sortOrder")
        }
    }
    
    
    
    
    //MARK: - =========SWIPED MOVIES==========
    
    static var swipedMovies:[Int] {
        get {
            return UserDefaults.standard.value(forKey: "swipedMovies") as? [Int] ?? []
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "swipedMovies")
        }
    }
    
    
    
    //MARK: - =========PREVIOUS SESSION DATA==========
    
    static var selectorPosition:Int {
        get {
            return UserDefaults.standard.value(forKey: "selectorPosition") as? Int ?? 0
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "selectorPosition")
        }
    }
    
    static var lastPageWithResults:Int {
        get {
            return UserDefaults.standard.value(forKey: "lastPageWithResults") as? Int ?? 1
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "lastPageWithResults")
        }
    }

}

