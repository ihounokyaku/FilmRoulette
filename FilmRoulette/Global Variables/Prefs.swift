//
//  Prefs.swift
//  FilmSwipe
//
//  Created by Dylan Southard on 2018/06/12.
//  Copyright © 2018 Dylan Southard. All rights reserved.
//

import UIKit
import RealmSwift

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
            UserDefaults.standard.set(newValue, forKey: "spinFilterType")
        }
    }
    
    static var MostRecentFilterID:String {
        get {
            return UserDefaults.standard.value(forKey: "mostRecentFilterID") as? String ?? "\(NSDate().timeIntervalSince1970)"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "mostRecentFilterID")
        }
    }
    
    //MARK: - == MODES ==
    static var kidsMode:Bool {
        get {
            return UserDefaults.standard.value(forKey: "kidsMode") as? Bool ?? false
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "kidsMode")
        }
    }
    
    
    
    static var directorsCut:Bool {
        get {
            return UserDefaults.standard.value(forKey: "directorsCut") as? Bool ?? false
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "directorsCut")
        }
    }
    
    func resetAll() {
        for key in ["selectorPosition",  "spinPickerSelectorPosition", "spinSelectorPosition", "spinFilterType", "mostRecentFilterID", "selectedGenres", "startYear", "kidsMode", "endYear"] {
            UserDefaults.standard.set(nil, forKey: key)
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

