//
//  Genre.swift
//  FilmRoulette
//
//  Created by Dylan Southard on 7/27/20.
//  Copyright © 2020 Dylan Southard. All rights reserved.
//

import Foundation
import SQLite


enum GenreType:Int, CaseIterable {
    case action = 28
    case adventure = 12
    case animation = 16
    case comedy = 35
    case crime = 80
    case documentary = 99
    case drama = 18
    case family = 10751
    case fantasy = 14
    case history = 36
    case horror = 27
    case music = 10402
    case mystery = 9648
    case romance = 10749
    case scifi = 878
    case tvMovie = 10770
    case thriller = 53
    case war = 10752
    case western = 37
    
    var name:String {
        switch self {
        case .action:
            return "Action"
        case .adventure:
           return "Adventure"
        case .animation:
           return "Animation"
        case .comedy:
            return "Comedy"
        case .crime:
           return "Crime"
        case .documentary:
           return "Documentary"
        case .drama:
            return "Drama"
        case .family:
            return "Family"
        case .fantasy:
            return "Fantasy"
        case .history:
            return "History"
        case .horror:
            return "Horror"
        case .music:
            return "Music"
        case .mystery:
            return "Mystery"
        case .romance:
            return "Romance"
        case .scifi:
            return "Science Fiction"
        case .tvMovie:
            return "TV Movie"
        case .thriller:
            return "Thriller"
        case .war:
            return "War"
        case .western:
            return "Western"
        }
        
    }
    
    var genre:Genre { return Genre.WithID(self.rawValue)! }
}


class Genre:NSObject, FilterObject {
    var filterType: FilterObjectType {return .genre}
    
    
    
    var id:Int
    var name:String
    var genreType:GenreType
    var movieRelationshipType:SQLRelationshipType {return .movieGenre }
    var movieExpression:Expression<Int> {return DataProperties.GenreID }
    
    init(id:Int, name:String, type:GenreType) {
        self.id = id
        self.name = name
        self.genreType = type
    }
    
    var movieIDs:[Int] {
        return SQLDataManager.FetchRelationship(ofType: self.movieRelationshipType, primaryExpression:self.movieExpression, value: self.id, libraryType:.library).ids(forExpression: DataProperties.MovieID.expression)
    }
    
    static func WithID(_ id:Int)->Genre? { return All.filter({$0.id == id}).first }
    
    static func WithIDs(_ ids:[Int] )->[Genre] {
        var _genres = [Genre]()
        for id in ids {
            if let genre = Genre.WithID(id) {
                _genres.append(genre)
            }
        }
        
        return _genres
    }
    
    static func WithName(_ name:String)->Genre? {return All.filter({$0.name.lowercased() == name.lowercased()}).first}
    
    static var All:[Genre] = {
        
        GenreType.allCases.map({
            Genre(id: $0.rawValue, name: $0.name, type: $0)
        })
    }()
    
    
    func filter(movies: [Movie]) -> [Movie] {
        let mIDs = self.movieIDs
        return movies.filter({mIDs.contains($0.id)})
    }
    
}
