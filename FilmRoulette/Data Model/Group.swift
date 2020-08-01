//
//  File.swift
//  MoviePicker
//
//  Created by Dylan Southard on 2018/04/21.
//  Copyright © 2018 Dylan Southard. All rights reserved.
//s

import Foundation
import SQLite

class Group : SQLiteObject, FilterObject {
    var filterType: FilterObjectType {return .group}
    
    
    
    
    private var _name:String
    var movieExpression:Expression<Int> {return DataProperties.GroupID.expression }
    var movieRelationshipType:SQLRelationshipType {return .movieGroup }
    
    var name:String {return _name}

   var movies:[Movie] {

        let rows = SQLDataManager.FetchRelationship(ofType: self.movieRelationshipType, primaryExpression:self.movieExpression, value: self.id, libraryType: .library)

        return SQLDataManager.Movies(fromRows: rows)

    }
    
    var movieIDs:[Int] {
        return SQLDataManager.FetchRelationship(ofType: self.movieRelationshipType, primaryExpression:self.movieExpression, value: self.id, libraryType: .library).ids(forExpression: DataProperties.MovieID.expression)
    }
    
    private lazy var tempMovies = [Int]()
    
    
    //MARK: - =============== INIT ===============
    
    init(id:Int?, name:String) {
        self._name = name
        
        super.init(id: id, type: .group)
    }
    
    convenience init(name:String) { self.init(id:nil, name: name) }
    
    convenience init?(fromRow row:Row) {
        do {
            
          self.init(id: try row.get(DataProperties.Id),
                      name: try row.get(DataProperties.Name))
            
        } catch {
            print(error)
            return nil
        }
    }
    
    convenience init(value:Group) {
        self.init(id: value.id, name: value.name)
        self.tempMovies = value.movieIDs
    }
    
    override var insertExpression: [Setter] {
        return [DataProperties.Id <- self.id,
                DataProperties.Name <- self._name]
        
    }
   
    func filter(movies: [Movie]) -> [Movie] {
        
        return movies.filter({self.movieIDs.contains($0.id)})
        
    }
    
    func add(movieWithID movieID:Int) {
        if !self.movieIDs.contains(movieID) {
            SQLDataManager.InsertGroupMovieRelationship(groupID: self.id, movieID: movieID)
        }
        
    }
    
    func remove(movieWithID movieID:Int) {
        
        guard let movieRow = SQLDataManager.FetchMovieRelationship(ofType: .group, movieID: movieID, relObjectID: self.id), let rowID = movieRow.id else { return }
        
        SQLDataManager.Delete(dataItemOfType: .movieGroup, withID: rowID)

    }
    
    
    
    func resuurect() {
        SQLDataManager.Insert(object: self)
        for movieID in self.tempMovies {
            SQLDataManager.InsertGroupMovieRelationship(groupID: self.id, movieID: movieID)
        }
    }
    
    
    static func Named(_ name:String)->Group? {
        return SQLDataManager.FetchObjects(ofType: .group, withStringProperty: DataProperties.Name, value: name).first as? Group
    }
  
}
