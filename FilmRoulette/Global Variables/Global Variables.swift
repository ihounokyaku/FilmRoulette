//
//  Global Variables.swift
//  FilmSwipe
//
//  Created by Dylan Southard on 2018/06/12.
//  Copyright © 2018 Dylan Southard. All rights reserved.
//

import Foundation
import RealmSwift

//MARK: - =========DIRECTORIES==========

//MARK: - ==DOCUMENTS==
var DocumentsDirectory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.brokenkeyboard.filmapps")!

var ImageDirectory:URL {
    let directory = DocumentsDirectory.appendingPathComponent("Images")
    if !FileManager.default.fileExists(atPath: directory.path) {
        do {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        } catch {
            print(error)
        }
    }
    return directory
}


//MARK: - ==REALM CONFIG==
let GroupRealmFolder = DocumentsDirectory.appendingPathComponent("default.realm")
let RealmConfig = Realm.Configuration(fileURL: GroupRealmFolder)




//MARK: - =========GENRES=========
let GenreIDs = ["Action":"28",
                "Adventure":"12",
                "Animation":"16",
                "Comedy":"35",
                "Crime":"80",
                "Documentary":"99",
                "Drama":"18",
                "Family":"10751",
                "Fantasy":"14",
                "History":"36",
                "Horror":"27",
                "Music":"10402",
                "Mystery":"9648",
                "Romance":"10749",
                "Science Fiction":"878",
                "TV Movie":"10770",
                "Thriller":"53",
                "War":"10752",
                "Western":"37"]

let Genres = ["Action",
              "Adventure",
              "Animation",
              "Comedy",
              "Crime",
              "Documentary",
              "Drama",
              "Family",
              "Fantasy",
              "History",
              "Horror",
              "Music",
              "Mystery",
              "Romance",
              "Science Fiction",
              "TV Movie",
              "Thriller",
              "War",
              "Western"]

//MARK: - =========REGIONS=========

//TODO: - FINISH THE SHITTY TASK OF  FILLING OUT ALL THE COUNTRIES. Maybe someone has already made a similar dictionary we can just tweak??

let Regions = [
    "North America/UK/Australia":["US", "CA", "IE", "IM", "GB","AU"],
    "East/Southeast Asia":["JA"],
    "South Asia/India": ["IN"],
    "Europe": ["FR"],
    "Africa": ["ZA"],
    "Latin America": ["MX"]
]

let RegionKeys = ["North America/UK/Australia",
                  "East/Southeast Asia",
                  "South Asia/India",
                  "Europe",
                  "Africa",
                  "Latin America"]

//MARK: - =========SORT TYPES=========
let SortTypes = [
    "Popularity":"popularity",
    "Release Date":"primary_release_date",
    "Box Office Revenue":"revenue",
    "Title":"original_title",
    "Number of User Ratings":"vote_count",
    "Average User Rating":"vote_average"
]
let SortTypeKeys = [
    "Popularity",
    "Release Date",
    "Box Office Revenue",
    "Title",
    "Number of User Ratings",
    "Average User Rating"
]

