//
//  DataManager.swift
//  FilmSwipe
//
//  Created by Dylan Southard on 2018/06/11.
//  Copyright © 2018 Dylan Southard. All rights reserved.
//

import Foundation
import RealmSwift


//MARK: - =========Datamodel Value Keys=========

let Moviekeys = ["id", "title", "thumbnailName", "imageUrl", "desc", "rtScore", "imdbScore", "metacriticScore", "trailerUrl", "love", "watched", "releaseDate", "imdbID", "genres"]

class DataManager:NSObject {
    
    
//MARK - =================== RealmDBs =================
    let realm = try! Realm(configuration: RealmConfig)
    let fsRealm = try! Realm(configuration: FilmswipeRealmConfig)
    
//MARK - =================== Arrays =================
    
    var moviesDisplayed:Results<Movie>!
    //var uniqueMoviesDisplayed = List<Movie>()
    var movieList:Results<Movie>!
    
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
    
    var genres:List<Genre> {
        get {
            let genres = List<Genre>()
            genres.append(objectsIn: self.realm.objects(Genre.self).sorted(byKeyPath: "name", ascending: true) )
            return genres
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
    }
    
    
    func save(movie:Movie, imageData:Data?, love:Bool, watched:Bool) {
        movie.setPoster(withData:imageData)
        movie.love = love
        movie.watched = watched
        for genre in movie.genres {
            movie.genreList.append(self.genre(named: genre) ?? self.newGenre(named: genre))
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
    
    
    
    //MARK: - ========== READ ==========
    func movie(withId id:Int)-> Movie? {
        return self.realm.objects(Movie.self).filter("id == %i", id).first
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
    
    //MARK: - ==GET MOVIES WITH TAG==
    func movies(withTag tag:Tag)-> Results<Movie> {
        return self.realm.objects(Movie.self).filter("%@ IN tags", tag)
    }
    
    func movies(withGenre genre:Genre)-> Results<Movie> {
        return self.realm.objects(Movie.self).filter("%@ IN genreList", genre)
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
    
    func updatePoster(forMovie movie:Movie, posterData:Data?) {
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
    
    
    
}
