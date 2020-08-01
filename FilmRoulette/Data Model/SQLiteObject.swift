//
//  SQLiteObject.swift
//  MaximumEnglish
//
//  Created by Dylan Southard on 7/8/20.
//  Copyright © 2020 Dylan Southard. All rights reserved.
//

import UIKit
import SQLite


enum SQLDataType:String, CaseIterable {
    case movie = "movies"
    case filter = "filters"
     case group = "groups"
    case tag = "tags"
    
    case movieGenre = "movies_genres"
    case movieGroup = "movies_groups"
    case movieTag = "movies_tags"
    
    case filterGenre = "filters_genres"
    case filterTag = "filters_tags"
    
    var properties:PropertySet {
        
        switch self {
        case .movie:
            return DataProperties.Movie
        case .filter:
            return DataProperties.Filter
        case .group:
            return DataProperties.Group
        case .tag:
            return DataProperties.Tag
        case .movieGenre:
            return DataProperties.MovieGenre
        case .movieGroup:
            return DataProperties.MovieGroup
        case .movieTag:
            return DataProperties.MovieTag
        case .filterGenre:
            return DataProperties.FilterGenre
        case .filterTag:
            return DataProperties.FilterTag
        
        }
        
    }
    
    var table:Table {return Table(self.rawValue)}
}


enum SQLObjectType:String {
    case movie = "movies"
    case tag = "tags"
    case group = "groups"
    case filter = "filters"
    
    var dataType:SQLDataType { return SQLDataType(rawValue: self.rawValue)! }
    
    func newObject(fromRow row:Row)->SQLiteObject? {
        switch self {
        case .movie:
            return Movie(fromRow: row)
           case .tag:
            return Tag(fromRow: row)
        case .group:
            return Group(fromRow: row)
        case .filter:
            return Filter(fromRow: row)

        }
    }
    
    var foreignKey:ForeignKey {
        switch self {
            case .movie:
            return DataProperties.MovieID
            case .tag:
                return DataProperties.TagID
        case .group:
            return DataProperties.GroupID
        case .filter:
            return DataProperties.FilterID
        }
    }
}

enum SQLRelationshipType:String {
    case movieGenre = "movies_genres"
    case movieTag = "movies_tags"
    case movieGroup = "movies_groups"
    case filterTag = "filters_tags"
    case filterGenre = "filters_genres"
    
    var dataType:SQLDataType { return SQLDataType(rawValue: self.rawValue)! }
    
}

enum SQLFilterRelationshipType:String {
    case tag = "filters_tags"
    case genre = "filters_genres"
    
    var relationshiptype:SQLRelationshipType { return SQLRelationshipType(rawValue: self.rawValue)! }
    var dataType:SQLDataType { return SQLDataType(rawValue: self.rawValue)! }
    var relObjectExpression:Expression<Int> {
        switch self {
        case .tag:
            return DataProperties.TagID.expression
        case .genre:
            return DataProperties.GenreID
    
        }
    }
    
}

enum SQLMovieRelationshipType:String {
    case tag = "movies_tags"
    case genre = "movies_genres"
    case group = "movies_groups"
    
    var relationshiptype:SQLRelationshipType { return SQLRelationshipType(rawValue: self.rawValue)! }
    var dataType:SQLDataType { return SQLDataType(rawValue: self.rawValue)! }
    
    var relObjectExpression:Expression<Int> {
        switch self {
        case .tag:
            return DataProperties.TagID.expression
        case .genre:
            return DataProperties.GenreID
        case .group:
            return DataProperties.GroupID.expression
    
        }
    }
    
}




class DataProperties {
    
    //MARK: - =============== PROPERTIES ===============
    
    //MARK: - ===  PROPERTIES  ===
    
    static let Id = Expression<Int>("id")
    static let Love = Expression<Int>("love")
    static let Watched = Expression<Int>("watched")
    static let GenreID = Expression<Int>("genre_id")
    static let StartYear = Expression<Int>("start_year")
    static let EndYear = Expression<Int>("end_year")
    
    static let Title = Expression<String>("title")
    static let ThumbnailName = Expression<String>("thumbnail_name")
    static let Desc = Expression<String>("desc")
    static let ImageURL = Expression<String>("image_url")
    static let IMDBID = Expression<String>("imdb_id")
    static let TrailerURL = Expression<String>("trailer_url")
    static let ReleaseDate = Expression<String>("release_date")
    static let Name = Expression<String>("name")
    static let FilterCondition = Expression<String>("filter_condition")
    
    
    
    //MARK: - ===  LINKED PROPERTIES  ===
    
    static let MovieID = ForeignKey(keyName: "movie_id", referenceType: .movie, onDelete: .cascade)
    
    static let TagID = ForeignKey(keyName: "tag_id", referenceType: .tag, onDelete: .cascade)
    
    static let GroupID = ForeignKey(keyName: "group_id", referenceType: .group, onDelete: .cascade)
    
    static let FilterID = ForeignKey(keyName: "filter_id", referenceType: .filter, onDelete: .cascade)
    
    //MARK: - =============== OBJECT PROPERTY SETS ===============
    
    static let Movie = PropertySet(stringProperties: [Title, ThumbnailName, Desc, ImageURL, IMDBID, TrailerURL, ReleaseDate], intProperties: [Love, Watched], linkedProperties: [])
    
    static let Tag = PropertySet(stringProperties: [Name], intProperties: [], linkedProperties: [])
    
    static let Group = PropertySet(stringProperties: [Name], intProperties: [], linkedProperties: [])
    
    static let Filter = PropertySet(stringProperties: [Name], intProperties: [StartYear, EndYear], linkedProperties: [])
    
    //MARK: - =============== RELATIONSHIP PROPERTY SETS ===============
    
    static let MovieGenre = PropertySet(stringProperties: [], intProperties: [GenreID], linkedProperties: [MovieID])
    
    static let MovieTag = PropertySet(stringProperties: [], intProperties: [], linkedProperties: [MovieID, TagID])
    
    static let MovieGroup = PropertySet(stringProperties: [], intProperties: [], linkedProperties: [MovieID, GroupID])
    
    static let FilterTag = PropertySet(stringProperties: [FilterCondition], intProperties: [], linkedProperties: [FilterID, TagID])
    
    static let FilterGenre = PropertySet(stringProperties: [FilterCondition], intProperties: [GenreID], linkedProperties: [FilterID])
    
}

class ForeignKey {
    
    var expression:Expression<Int>
    var references:Table
    var foreignExpression:Expression<Int> {return DataProperties.Id}
    var onDelete:TableBuilder.Dependency
    
    init(keyName:String, referenceType:SQLDataType, onDelete:TableBuilder.Dependency) {
        self.expression = Expression<Int>(keyName)
        self.references = Table(referenceType.rawValue)
        self.onDelete = onDelete
    }
    
}

struct PropertySet {
    var stringProperties:[Expression<String>]
    var intProperties:[Expression<Int>]
    var linkedProperties:[ForeignKey]
}


class SQLiteObject: NSObject {
    
    let id:Int
    let type:SQLObjectType
    
    var table:Table { return self.type.dataType.table } 
    
    //MARK: - ===  DB COMMANDS  ===
    
    var insert:Insert {return self.type.dataType.table.insert(self.insertExpression)}
    var insertExpression:[Setter] {return []}
    
    init(id:Int?, type:SQLObjectType) {
        
        self.id = id ?? Int(String(Int(Date().timeIntervalSince1970)).suffix(5) + String(Int.random(in: 1..<99999)))!
        self.type = type
        super.init()
    }
    
    func update(_ setters:[Setter]) { SQLDataManager.Update(object:self, commands:setters) }
}


extension Array where Element == String {
    var asDBString:String {
        return self.joined(separator: kArrayBreak)
    }
}

extension String {
    var asDBArray:[String] {
        return self.components(separatedBy: kArrayBreak)
    }
}

extension Bool {
    var asInt:Int {
        return self ? 1 : 0
    }
}

extension Int {
    var asBool:Bool {
        return self == 0 ? false : true
    }
}

let kArrayBreak = "|||"




