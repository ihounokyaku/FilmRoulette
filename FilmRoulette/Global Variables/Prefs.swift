//
//  Prefs.swift
//  FilmSwipe
//
//  Created by Dylan Southard on 2018/06/12.
//  Copyright © 2018 Dylan Southard. All rights reserved.
//

import UIKit

class Prefs: NSObject {
    
    
    //MARK: - ==========ROULETTE DISPLAY PARAMS===========
    static var mustBeIncluded:[String] {
        get {
            return UserDefaults.standard.value(forKey: "mustBeIncluded") as? [String] ?? []
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "mustBeIncluded")
        }
    }
    
    static var canBeIncluded:[String] {
        get {
            return UserDefaults.standard.value(forKey: "mayBeIncluded") as? [String] ?? []
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "mayBeIncluded")
        }
    }
    
    static var excluded:[String] {
        get {
            return UserDefaults.standard.value(forKey: "excluded") as? [String] ?? []
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "excluded")
        }
    }
    
        
    
    
    
    
    
    
    
    
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
    
    static var SpinPickerSelectorPosition:Int {
        get {
            return UserDefaults.standard.value(forKey: "spinPickerSelectorPosition") as? Int ?? 0
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "spinPickerSelectorPosition")
        }
    }
    
    static var SpinSelectorPosition:Int {
        get {
            return UserDefaults.standard.value(forKey: "spinSelectorPosition") as? Int ?? 0
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "spinSelectorPosition")
        }
    }
    
    static var SpinFilterType:Int {
        get {
            return UserDefaults.standard.value(forKey: "spinFilterType") as? Int ?? 0
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "SpinFilterType")
        }
    }
    
    
//    static var lastPageWithResults:Int {
//        get {
//            return UserDefaults.standard.value(forKey: "lastPageWithResults") as? Int ?? 1
//        }
//        set {
//            UserDefaults.standard.set(newValue, forKey: "lastPageWithResults")
//        }
//    }
    
    
    

}

