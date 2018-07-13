//
//  DataManager.swift
//  FilmSwipe
//
//  Created by Dylan Southard on 2018/06/11.
//  Copyright © 2018 Dylan Southard. All rights reserved.
//

import Foundation
import RealmSwift

class DataManager:NSObject {
    
    
//MARK - =================== RealmDBs =================
    let realm = try! Realm(configuration: RealmConfig)
    let fsRealm = try! Realm(configuration: FilmswipeRealmConfig)
    
//MARK - =================== Arrays =================
    
    var moviesDisplayed = List<Movie>()
    
    var allMovies:List<Movie> {
        get {
            let movies = List<Movie>()
            movies.append(objectsIn: self.realm.objects(Movie.self))
            return movies
        }
    }
    
    var fsMovies:List<Movie> {
        get {
            let movies = List<Movie>()
            movies.append(objectsIn: self.fsRealm.objects(Movie.self).filter("watched == %@", false))
            return movies
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
    func saveToFavorites(movie:Movie, imageData:Data?, love:Bool, watched:Bool) {
        movie.setPoster(withData:imageData)
        movie.love = love
        movie.watched = watched
        do {
            try self.realm.write {
                realm.add(movie)
            }
        } catch {
            print("Error saving object \(error)")
        }
    }
    
    //MARK: - ========== READ ==========
    func movie(withId id:Int)-> Movie? {
        return self.realm.objects(Movie.self).filter("id == %i", id).first
    }
    
    func databaseContains(movieWithId id:Int)->Bool {
        return self.movie(withId: id) != nil
    }
    
    func databaseContains(movieWithGenre genre:Genre)->Bool {
        return self.realm.objects(Movie.self).filter("%@ IN genreList", genre).first != nil
    }
    
    //MARK: - ==GET MOVIES WITH TAG==
    func movies(withTag tag:Tag)-> List<Movie> {
        let movies = List<Movie>()
        
        for movie in Array(tag.movies) {
            movies.append(movie)
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
    
}
