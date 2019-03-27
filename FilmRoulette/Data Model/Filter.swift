//
//  Filter.swift
//  FilmRoulette
//
//  Created by Dylan Southard on 2019/03/18.
//  Copyright © 2019 Dylan Southard. All rights reserved.
//

import Foundation
import RealmSwift

enum FilterCondition:Int {
    case and = 0
    case or = 1
    case not = 2
    case none = 3
}

enum FilterObjectType {
    case genre
    case tag
}

protocol FilterDelegate {
    func genre(named:String)->Genre?
    func tag(named:String)->Tag?
    
}

class Filter:Object {
    
    @objc dynamic var id = ""
    @objc dynamic var name = ""
    @objc dynamic var startYear = 0
    @objc dynamic var endYear = 0
    
    var tagsMustInclude = List<String>()
    var tagsMayInclude = List<String>()
    var tagsMustExclude = List<String>()
    
    var genresMustInclude = List<String>()
    var genresMayInclude = List<String>()
    var genresMustExclude = List<String>()
    
    private func requiresPredicate(for condition:FilterCondition)-> Bool {
        if condition == .and {
            return self.genresMustInclude.count + self.tagsMustInclude.count > 0
        } else if condition == .or {
            return self.genresMayInclude.count + self.tagsMayInclude.count > 0
        }
        return false
    }
    
    func apply(to results:Results<Movie>, delegate:FilterDelegate)->Results<Movie> {
        print("\(results.count) movies to filter")
        var filteredResults =  results
        
        if requiresPredicate(for: .and) {
            filteredResults = filteredResults.filter(self.compoundTagPredicate(genreFilters: self.genresMustInclude, tagFilters: self.tagsMustInclude, delegate: delegate, condition: .and))
        }
        
        if requiresPredicate(for: .or) {
            filteredResults = filteredResults.filter(self.compoundTagPredicate(genreFilters: self.genresMayInclude, tagFilters: tagsMayInclude, delegate: delegate, condition: .or))
        }
        
        print("\(filteredResults.count) movies left after and/or filters")
        
        for genreName in self.genresMustExclude {
            if let genre = delegate.genre(named: genreName) {
                filteredResults = filteredResults.filter("NOT (%@ IN genreList)", genre)
            }
        }
        
        for tagName in self.tagsMustExclude {
            if let tag = delegate.tag(named: tagName) {
                filteredResults = filteredResults.filter("NOT (%@ IN tags)", tag)
            }
        }
         print("\(filteredResults.count) movies left after not filters")
        
        if self.endYear != 0 && self.startYear != 0 {
            filteredResults = filteredResults.withReleaseDatesBetween(self.startYear, and: self.endYear)
        }
        
        print("\(filteredResults.count) movies left after year filter")
        return filteredResults
    }
    
    func compoundTagPredicate(genreFilters:List<String>, tagFilters:List<String>, delegate:FilterDelegate, condition:FilterCondition)-> NSCompoundPredicate {
        var predicates = [NSPredicate]()
        
        for filter in genreFilters {
            if let genre = delegate.genre(named: filter) {
                predicates.append(NSPredicate(format: "%@ IN genreList", genre))
            }
        }
        
        for filter in tagFilters {
            if let tag = delegate.tag(named: filter) {
                predicates.append(NSPredicate(format: "%@ IN tags", tag))
            }
        }
        
    
        if condition == .and {
            return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        }
        print("predicates are \(predicates)")
        return NSCompoundPredicate(orPredicateWithSubpredicates: predicates)
    }
    
    func addFilter(title:String, type:FilterObjectType, condition:FilterCondition) {
        do {
            try GlobalDataManager.realm.write {
                if type == .genre {
                    
                    self.genresMustInclude = condition == .and ? genresMustInclude.appending(title) : genresMustInclude.removing(title)
                    self.genresMayInclude = condition == .or ? genresMayInclude.appending(title) : genresMayInclude.removing(title)
                    self.genresMustExclude = condition == .not ? genresMustExclude.appending(title) : genresMustExclude.removing(title)
                    
                } else if type == .tag {
                    
                    self.tagsMustInclude = condition == .and ? tagsMustInclude.appending(title) : tagsMustInclude.removing(title)
                    self.tagsMayInclude = condition == .or ? tagsMayInclude.appending(title) : tagsMayInclude.removing(title)
                    self.tagsMustExclude = condition == .not ? tagsMustExclude.appending(title) : tagsMustExclude.removing(title)
                }
            }
        } catch let error {
            print("error writing to filter object \(error.localizedDescription)")
        }
    }
    
    
}
