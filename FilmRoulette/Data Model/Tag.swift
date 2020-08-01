//
//  File.swift
//  MoviePicker
//
//  Created by Dylan Southard on 2018/04/21.
//  Copyright © 2018 Dylan Southard. All rights reserved.
//

import Foundation
import SQLite

class Tag : SQLiteObject, FilterObject {
    var filterType: FilterObjectType {return .tag}
    
    
    
    
    private var _name:String
    var movieExpression:Expression<Int> {return DataProperties.TagID.expression }
    var movieRelationshipType:SQLRelationshipType {return .movieTag }
    
    
    var name:String {return _name}

    var moviesIDs:[Int] {
        //TODO: - link movies
        
        return SQLDataManager.FetchRelationship(ofType: self.movieRelationshipType, primaryExpression:self.movieExpression, value: self.id, libraryType:.library).ids(forExpression: DataProperties.MovieID.expression)
    
    }
    
    
    init(id:Int?, name:String) {
        self._name = name
        
        super.init(id: id, type: .tag)
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
    
    override var insertExpression: [Setter] {
        return [DataProperties.Id <- self.id,
                DataProperties.Name <- self._name]
        
    }
    
    func filter(movies: [Movie]) -> [Movie] {
        
        return movies.filter({$0.tagIDs.contains(self.id)})
        
    }

    
}
