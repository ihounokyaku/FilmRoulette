//
//  Filter.swift
//  FilmRoulette
//
//  Created by Dylan Southard on 2019/03/18.
//  Copyright © 2019 Dylan Southard. All rights reserved.
//

import Foundation
import SQLite



enum FilterCondition:String, CaseIterable {
    case and = "and"
    case or = "or"
    case not = "not"
    case none = "none"
}

enum FilterObjectType {
    case genre
    case tag
    case filter
    case group
}

protocol FilterDelegate {
    func genre(named:String)->Genre?
    func tag(named:String)->Tag?
    
}

class Filter:SQLiteObject, FilterObject {
    
    var filterType: FilterObjectType {return .filter}
    
    private var _name:String
    private var _startYear:Int
    private var _endYear:Int
    
    var name:String {
        get {
           return self._name
        }
        
        set {
            self._name = newValue
            self.update([DataProperties.Name <- newValue])
        }
        
    }
    
    var startYear:Int {
        get {
            return self._startYear
        }
    }
    
    var endYear:Int {
        get {
            return self._endYear
        }
    }
    
    
    var tagsMustInclude:[Int] {return self.filterObjects(ofType: .tag, withCondition: .and)}
    var tagsMayInclude:[Int] {return self.filterObjects(ofType: .tag, withCondition: .or)}
    var tagsMustExclude:[Int] {return self.filterObjects(ofType: .tag, withCondition: .not)}
    
    
    var genresMustInclude:[Int] {return self.filterObjects(ofType: .genre, withCondition: .and)}
    var genresMayInclude:[Int] {return self.filterObjects(ofType: .genre, withCondition: .or)}
    var genresMustExclude:[Int] {return self.filterObjects(ofType: .genre, withCondition: .not)}

    
    func filterObjects(ofType type:SQLFilterRelationshipType, withCondition condition:FilterCondition)->[Int] {
        

        
        return SQLDataManager.FetchFilterRelationship(ofType: type, filterID: self.id, condition: condition, inLibrary:.library).ids(forExpression: type == .genre ? DataProperties.GenreID : DataProperties.TagID.expression)
        
    }
    
    
    //MARK: - =============== INIT ===============
    
    init(id:Int?, name:String, startYear:Int, endYear:Int){
        self._name = name
        self._startYear = startYear
        self._endYear = endYear
        super.init(id: id, type: .filter)
    }
    
    convenience init(name:String, startYear:Int, endYear:Int) {
        self.init(id: nil, name: name, startYear: startYear, endYear: endYear)
    }
    
    convenience init?(fromRow row:Row) {
        do {
            self.init(id:  try row.get(DataProperties.Id),
                      name: try row.get(DataProperties.Name),
                      startYear: try row.get(DataProperties.StartYear),
                      endYear: try row.get(DataProperties.EndYear))
                      
        } catch {
            print(error)
            return nil
        }
    }
    
    
    //MARK: - =============== TABLE STUFF ===============
    
    
    override var insertExpression: [Setter] {
        return [
            DataProperties.Id <- self.id,
            DataProperties.Name <- self.name,
                DataProperties.StartYear <- self.startYear,
                DataProperties.EndYear <- self.endYear
            
        ]
    }
    
    
    
    
    private func requiresPredicate(for condition:FilterCondition)-> Bool {
        if condition == .and {
            return self.genresMustInclude.count + self.tagsMustInclude.count > 0
        } else if condition == .or {
            return self.genresMayInclude.count + self.tagsMayInclude.count > 0
        } else if condition == .not {
            return self.genresMustExclude.count + self.tagsMustExclude.count > 0
        }
        return false
    }

    func setDates(start:Int, end:Int) {
        
        self._startYear = start
        self._endYear = end
        
        self.update([
            DataProperties.StartYear <- self._startYear,
            DataProperties.EndYear <- self._endYear
        ])
    }
    
    func filter(movies:[Movie])->[Movie] {
        
        var filteredMovies = movies

        
        if requiresPredicate(for: .and) {
            print(self.tagsMustInclude)
            let predicate = self.compoundTagPredicate(genreFilters: self.genresMustInclude, tagFilters: self.tagsMustInclude, condition:.and)
            
            filteredMovies = filteredMovies.filter({ predicate.evaluate(with: $0)})
        
        }
        
        if requiresPredicate(for: .or) {
            
            let predicate = self.compoundTagPredicate(genreFilters: self.genresMayInclude, tagFilters: self.tagsMayInclude, condition:.or)
            
            filteredMovies = filteredMovies.filter({ predicate.evaluate(with: $0) })
            
        }
        
        if requiresPredicate(for: .not) {
            
            let predicate = self.compoundTagPredicate(genreFilters: self.genresMustExclude, tagFilters: self.tagsMustExclude, condition:.not)
            
            filteredMovies = filteredMovies.filter({ predicate.evaluate(with: $0) })
            
        }
        
        
        if self.endYear != 0 && self.startYear != 0 {
            
            filteredMovies = filteredMovies.filter({$0.releaseYear >= self.startYear && $0.releaseYear <= self.endYear})
            
        }
    
        return filteredMovies
    }
    
    
    
    func compoundTagPredicate(genreFilters:[Int], tagFilters:[Int], condition:FilterCondition)-> NSCompoundPredicate {
        var predicates = [NSPredicate]()
                
        for genre in genreFilters { predicates.append(NSPredicate(format: filterArgs(forArrayNamed: "genreIDs", condition: condition), genre)) }
        
        print(tagFilters)
        for tag in tagFilters {
        
            let predicate = NSPredicate(format: filterArgs(forArrayNamed: "tagIDs", condition: condition), tag )
            print("predicate = \(predicate)")
            predicates.append(predicate)
           
        }
        
    
        if condition == .or { return NSCompoundPredicate(orPredicateWithSubpredicates: predicates) }
        
        let pred = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        
        print(pred)
        
        return pred
        
    }
    
    func filterArgs(forArrayNamed arrayName:String, condition:FilterCondition)-> String{
        
        if condition == .not {
            return "NOT (%i IN \(arrayName))"
        } else {
            return "%i IN \(arrayName)"
        }
        
    }
    
    func addOrRemoveFilter(type:SQLFilterRelationshipType, objectID:Int, condition:FilterCondition) {
      print("adding \(objectID)")
        self.saveFilterCondition(relationshipType: type, relatedObjectID: objectID, condition: condition)
        
    }
    

    func saveFilterCondition(relationshipType type:SQLFilterRelationshipType, relatedObjectID:Int, condition:FilterCondition) {
        
        if let row = SQLDataManager.FetchFilterRelationship(ofType: type, filterID: self.id, relObjectID: relatedObjectID, inLibrary: .library) {
            
            guard let id = try? row.get(DataProperties.Id) else {return}
            
            if condition == .none {
                
                SQLDataManager.Delete(dataItemOfType: type.dataType, withID: id)
                
            } else {
                print("updating")
                SQLDataManager.Update(dataOfType: type.dataType, withID: id, commands: [DataProperties.FilterCondition <- condition.rawValue])
                
            }
        
        } else {
            print("inserting filter")
            SQLDataManager.InsertFilterRelationship(ofType: type, filterID: self.id, relObjectID: relatedObjectID, condition: condition)
            
        }
}
    
    
    
    
}
