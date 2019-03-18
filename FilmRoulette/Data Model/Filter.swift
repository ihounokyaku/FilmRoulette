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
    
    let tagsMustInclude = List<String>()
    let tagsMayInclude = List<String>()
    let tagsMustExclude = List<String>()
    
    let genresMustInclude = List<String>()
    let genresMayInclude = List<String>()
    let genresMustExclude = List<String>()
    
    func apply(to results:Results<Movie>, delegate:FilterDelegate)->Results<Movie> {
        var filteredResults =  results
        filteredResults = filteredResults.filter(self.compoundTagPredicate(genreFilters: self.genresMustInclude, tagFilters: self.tagsMustInclude, delegate: delegate, condition: .and)).filter(self.compoundTagPredicate(genreFilters: self.genresMayInclude, tagFilters: tagsMayInclude, delegate: delegate, condition: .or))
        
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
        
        if self.endYear != 0 && self.startYear != 0 {
            filteredResults = filteredResults.withReleaseDatesBetween(self.startYear, and: self.endYear)
        }
        
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
        return NSCompoundPredicate(orPredicateWithSubpredicates: predicates)
    }
    
    
}
