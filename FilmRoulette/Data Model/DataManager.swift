//
//  DataManager.swift
//  FilmSwipe
//
//  Created by Dylan Southard on 2018/06/11.
//  Copyright © 2018 Dylan Southard. All rights reserved.
//

import Foundation
import RealmSwift


enum RealmObjectType {
    case group
    case movie
}

//MARK: - =========Datamodel Value Keys=========

let Moviekeys = ["id", "title", "thumbnailName", "imageUrl", "desc", "rtScore", "imdbScore", "metacriticScore", "trailerUrl", "love", "watched", "releaseDate", "releaseYear", "imdbID", "genres"]

class DataManager:NSObject, FilterDelegate {
    
    
//MARK - =================== RealmDBs =================
    let realm = try! Realm(configuration: RealmConfig)
    let fsRealm = try! Realm(configuration: FilmswipeRealmConfig)
    
    
    
    
//MARK - =================== Arrays =================
    
    var moviesDisplayed:Results<Movie>!
    //var uniqueMoviesDisplayed = List<Movie>()
    var movieList:Results<Movie>!
    var groupList:Results<Group>!
    
    var allMovies:Results<Movie> {
        get {
           return self.realm.objects(Movie.self).sorted(byKeyPath: "title", ascending: true)
        }
    }
    
    var fsMovies:Results<Movie> {
        get {
            return fsRealm.objects(Movie.self).filter("watched == %@", false)
        }
    }
    
    var allGenres:Results<Genre> {
        get {
            return self.realm.objects(Genre.self)
        }
    }
    
    var allTags:Results<Tag> {
        get {
            return self.realm.objects(Tag.self)
        }
    }
    
    var allGroups:Results<Group> {
        get {
            return self.realm.objects(Group.self).sorted(byKeyPath: "name")
        }
    }
    
    var tags:List<Tag> {
        get {
            let tags = List<Tag>()
            tags.append(objectsIn: self.realm.objects(Tag.self).sorted(byKeyPath: "name", ascending: true) )
            return tags
        }
    }
    var groups:List<Group> {
        get {
            let groups = List<Group>()
            groups.append(objectsIn: self.realm.objects(Group.self).sorted(byKeyPath: "name", ascending: true) )
            return groups
        }
    }
    
    var genres:List<Genre> {
        get {
            let genres = List<Genre>()
            genres.append(objectsIn: self.realm.objects(Genre.self).sorted(byKeyPath: "name", ascending: true) )
            return genres
        }
    }
    
    var allGenresAndTags:Results<Object> {
        get {
            let list = List<Object>()
            for genre in self.realm.objects(Genre.self).sorted(byKeyPath: "name", ascending: true) {
                list.append(genre)
            }
            
            for tag in self.realm.objects(Tag.self){
                list.append(tag)
            }
            return list.sorted(byKeyPath: "name", ascending: true)
            
        }
    }
    

    

//*********************************************************************************************
    
    
    //MARK: - ========== CREATE ==========
    
    //MARK: - ==Save==
    
    func save(object:Object)->String? {
        do {
            try self.realm.write {
                realm.add(object)
            }
            return nil
        } catch {
            return error.localizedDescription
        }
    }
    
    func importMovie(movie:Movie)->String? {
        
        if !databaseContains(movieWithId: movie.id) {
            let newMovie = Movie()
            for key in Moviekeys {
                newMovie.setValue(movie.value(forKey: key), forKey: key)
            }
            for genre in newMovie.genres {
                newMovie.genreList.append(self.genre(named: genre) ?? self.newGenre(named: genre))
            }
            
            do {
                try self.realm.write {
                    realm.add(newMovie)
                }
                return nil
            } catch {
                return error.localizedDescription
            }
        } else {
            return "Movie already in library!"
        }
        
    }
    
    
    
    
    
    func save(movie:Movie, imageData:Data?, love:Bool, watched:Bool, tags:[String] = []) {
        movie.setPoster(withData:imageData)
        movie.love = love
        movie.watched = watched
        for genre in movie.genres {
            movie.genreList.append(self.genre(named: genre) ?? self.newGenre(named: genre))
        }
        
        for tag in tags {
            movie.tags.append(self.tag(named: tag) ?? self.newTag(named: tag))
        }
        
        do {
            try self.realm.write {
                realm.add(movie)
            }
        } catch {
            print("Error saving object \(error)")
        }
    }
    
    func newGenre(named name:String)-> Genre {
        let genre = Genre()
        genre.name = name
        do {
            try self.realm.write {
                realm.add(genre)
            }
        } catch {
            print("Error saving object \(error)")
        }
        return genre
    }
    
    func newTag(named name:String)-> Tag {
        let tag = Tag()
        tag.name = name
        do {
            try self.realm.write {
                realm.add(tag)
            }
        } catch {
            print("Error saving object \(error)")
        }
        return tag
    }

    
    
    
    //MARK: - ========== READ ==========
    func movie(withId id:Int)-> Movie? {
        return self.realm.objects(Movie.self).filter("id == %i", id).first
    }
    
    func fsMovie(withID id:Int)-> Movie? {
        return self.fsRealm.objects(Movie.self).filter("id == %i", id).first
    }
    
    func folder(withName name:String)-> Group? {
        return self.realm.objects(Group.self).filter("name == %@", name).first
    }
    
    func databaseContains(movieWithId id:Int)->Bool {
        return self.movie(withId: id) != nil
    }
    
    func databaseContains(movieWithGenre genre:Genre)->Bool {
        return self.realm.objects(Movie.self).filter("%@ IN genreList", genre).first != nil
    }
    
    func genre(named name:String)-> Genre? {
        return self.realm.objects(Genre.self).filter("name == %@", name).first
    }
    
    func tag(named name:String)-> Tag? {
        return self.realm.objects(Tag.self).filter("name == %@", name).first
    }
    func group(named name:String)-> Group? {
        return self.realm.objects(Group.self).filter("name == %@", name).first
    }
    
    func filter(named name:String)-> Filter? {
        return self.realm.objects(Filter.self).filter("name == %@", name).first
    }
    func filter(withID id:String)-> Filter? {
        return self.realm.objects(Filter.self).filter("id == %@", id).first
    }
    
    func moviesInGroup(_ group:Group, filteredBy filter:Results<Movie>)->Results<Movie> {
        var predicates = [NSPredicate]()
        
        
        for movie in group.movies {
          predicates.append(NSPredicate(format: "id == %i", movie.id))
        }
        
        let compoundPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: predicates)
        
        
        return filter.filter(compoundPredicate)
    }
    
    //MARK: - ==GET MOVIES WITH TAG==
    func movies(withTag tag:Tag, fromResults results:Results<Movie>? = nil)-> Results<Movie> {
        if let r = results {
            return r.filter("%@ IN tags", tag)
        }
        return self.realm.objects(Movie.self).filter("%@ IN tags", tag)
    }
    
    func movies(withGenre genre:Genre, fromResults results:Results<Movie>? = nil)-> Results<Movie> {
        if let r = results {
            return r.filter("%@ IN genreList", genre)
        }
        return self.realm.objects(Movie.self).filter("%@ IN genreList", genre)
    }
    
    func movies(_ results:Results<Movie>, filteredBy option:MovieOption?)-> Results<Movie>{
        guard let realOption = option else {return results}
        
        var filter = "watched == NO"
        switch realOption {
        case .watched:
            filter = "watched == YES"
        case .loved:
            filter = "love == YES"
        default:
            break
        }
        return results.filter(filter)
    }
    
    func movies(_ movies:Results<Movie>, filteredBy filter:Object?, libraryType:LibraryType, allInCategory:Bool = true)-> Results<Movie> {
        if let genre = filter as? Genre {
            return self.movies(withGenre: genre, fromResults: allInCategory ? nil : movies)
        } else if let group = filter as? Group {
            return allInCategory ? group.movies.filter("TRUEPREDICATE") : self.moviesInGroup(group, filteredBy: movies)
        } else if let tag = filter as? Tag {
            return GlobalDataManager.movies(withTag: tag, fromResults: allInCategory ? nil : movies)
        } else if let fil = filter as? Filter, libraryType == .library {
            return fil.apply(to: movies, delegate: self)
        }
        return movies
    }
    
    
    
    
    
    
    //MARK: - ========== UPDATE ==========
    func updateMovie(movie:Movie, updatedValues:[String:Any]) {
        do {
            try self.realm.write {
                for (key, value) in updatedValues {
                    movie.setValue(value, forKey: key)
                }
            }
        } catch {
            print("Error saving object \(error)")
        }
    }
    
    func add(_ movie:Movie, toGroup group:Group)-> String? {
        do {
           try self.realm.write {
                group.movies.append(movie)
            }
        } catch {
            return error.localizedDescription
        }
        return nil
    }
    
    func updateTags(newTags:[String], forMovie movie:Movie){
        var tags = [Tag]()
        for tagName in newTags {
            let tag = self.tag(named: tagName) ?? self.newTag(named: tagName)
            tags.append(tag)
            if let error = self.addTag(tag, toMovie: movie) {
                print(error)
            }
        }
        
        for tag in movie.tags {
            if !tags.contains(tag) {
                if let error = self.removeTag(tag, fromMovie: movie) {
                    print(error)
                }
            }
        }
        
    }
    
    func addTag(_ tag:Tag, toMovie movie:Movie)->String? {
        
        if !movie.tags.contains(tag){
            do {
                try self.realm.write {
                    if tag.name == "to watch" {
                        movie.watched = false
                    }
                    movie.tags.append(tag)
                }
            } catch {
               return error.localizedDescription
            }
        }
        return nil
    }
    
    func removeTag(_ tag:Tag, fromMovie movie:Movie)-> String? {
        if movie.tags.contains(tag) {
            
            do {
                try self.realm.write {
                    if tag.name == "to watch" {
                        movie.watched = true
                    }
                    movie.tags.remove(at: movie.tags.index(of: tag)!)
                }
            } catch {
                return error.localizedDescription
            }
        }
        return nil
    }
    
    func updatePoster(forMovie movie:Movie, posterData:Data?) {
        print("going to set poster")
        do {
            try self.realm.write {
                movie.setPoster(withData: posterData)
            }
        } catch let error {
            print(error)
        }
    }
    
    
    //MARK: - ========== DESTROY ==========
    func deleteObject(object:Object) {
        do {
            try self.realm.write {
                realm.delete(object)
            }
        } catch {
            print("error deleting \(object) \n \(error)")
        }
    }
    
    //MARK: - ========== CONVENIENCE ==========
   //MARK: - === Predicate ===
    func predicate(forType type:RealmObjectType, text:String)->NSPredicate {
        switch type {
        case .group:
            return NSPredicate(format: "name CONTAINS[cd] %@", text)
        default:
            return NSPredicate(format: "title CONTAINS[cd] %@", text)
        }
    }
}
