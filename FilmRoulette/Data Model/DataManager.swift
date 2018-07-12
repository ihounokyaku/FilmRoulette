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
//MARK - =================== Arrays =================
    var moviesToDisplay = List<Movie>()
    
//MARK - =================== Other vars =================
    let realm = try! Realm(configuration: RealmConfig)
    let fsRealm = try! Realm(configuration: FilmswipeRealmConfig)
   
    override init () {
        super.init()
        self.moviesToDisplay.append(objectsIn: self.realm.objects(Movie.self))
        self.moviesToDisplay.append(objectsIn: self.fsRealm.objects(Movie.self).filter("watched == %@", false))
        print("the number of results are \(self.fsRealm.objects(Movie.self).count)\(self.moviesToDisplay.map({return $0.title}))")
    }
    
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
    
    func allMovies()->Results<Movie> {
        return self.realm.objects(Movie.self)
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
