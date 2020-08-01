//
//  Global Variables.swift
//  FilmSwipe
//
//  Created by Dylan Southard on 2018/06/12.
//  Copyright © 2018 Dylan Southard. All rights reserved.
//


import UIKit

//MARK: - =========DIRECTORIES==========

//MARK: - ==DOCUMENTS==
var DocumentsDirectory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.brokenkeyboard.movieApps")!

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

var TestDirectory:URL {
    let directory = DocumentsDirectory.appendingPathComponent("Tests")
    if !FileManager.default.fileExists(atPath: directory.path) {
        do {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        } catch {
            print(error)
        }
    }
    return directory
}

let CatalogueFileName = "FilmLibrary.json"








//MARK: - =========GENRES=========


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

let kAPIKey = "7f8097fbd3d28753af1c79372d180dd4"




//MARK: - =========CONVENIENCE FUNCTIONS=========
func RandomInt(upTo max:Int)->Int {
    return Int(arc4random_uniform(UInt32(max + 1)))
}

//MARK: - =========DEVICE SPECS=========
var DeviceIsIpad:Bool {
    return UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad
}

var DeviceIsIphoneX:Bool {
    return UIDevice.current.screenType == .iPhone_XR || UIDevice.current.screenType == .iPhone_XSMax || UIDevice.current.screenType == .iPhones_X_XS
}
