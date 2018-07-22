//
//  File.swift
//  MoviePicker
//
//  Created by Dylan Southard on 2018/04/21.
//  Copyright © 2018 Dylan Southard. All rights reserved.
//s

import Foundation
import RealmSwift

class Group : Object {
    
    @objc dynamic var name:String = ""
    
    var movies = List<Movie>()
}
