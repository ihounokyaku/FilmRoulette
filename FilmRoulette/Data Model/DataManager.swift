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
    var likedMoviesToDisplay:Results<Movie>!
    
//MARK - =================== Other vars =================
    let realm = try! Realm()
    
    override init () {
        super.init()
        self.likedMoviesToDisplay = self.realm.objects(Movie.self)
    }
    
    //MARK: - ========== CREATE ==========
    
    //MARK: - ==Save==
    func saveToFavorites(movie:Movie, thumbnail:UIImage, love:Bool, watched:Bool) {
        movie.thumbnail = thumbnail
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
