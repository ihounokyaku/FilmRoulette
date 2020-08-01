//
//  JSONHandler.swift
//  FilmRoulette
//
//  Created by Dylan Southard on 2019/03/25.
//  Copyright © 2019 Dylan Southard. All rights reserved.
//

import UIKit
import SwiftyJSON
import SVProgressHUD

class JSONHandler: NSObject {
    
    func readJSON(atURL url: URL ) -> JSON? {
        guard let data = try? Data(contentsOf: url), let json = try? JSON(data:data) else {return nil}
        return json
    }
    
    func sync(fromData data: Data) {
        
        guard let json = try? JSON(data: data) else {return}
        
        var index:Float = 1
       
        
        
        for (movie) in json {
            DispatchQueue.main.async {
                SVProgressHUD.showProgress(index / Float(json.count), status: "Checking movies \(index)/\(json.count)")
                
                index += 1
            }
            
            guard let id = Int(movie.0) else {continue}
           
            if let existingMovie = SQLDataManager.FetchMovie(withID: id) {
                
                
                let existingTags = existingMovie.tags.map({$0.name})
                
                if let tags = movie.1["tags"].arrayObject as? [String], existingTags.containsSameElements(as: tags){
                        
                            DispatchQueue.main.async {
                                
                                let tagsToAdd = tags.filter({!existingTags.contains($0)})
                                let tagsToRemove = existingTags.filter({!tags.contains($0)})
                                
                                for tag in tagsToAdd { existingMovie.addTag(named: tag) }
                                
                                for tag in tagsToRemove { existingMovie.removeTag(named: tag) }
                                
                        }
                    }
                
            } else {
                
                let tags:[String] = movie.1["tags"].arrayObject as? [String] ?? []
                
                    if let newMovie = movie.1["movieData"].toMovie() {
                DispatchQueue.main.async {
                    
                    
                    SQLDataManager.Insert(movie: newMovie, imageData: nil)
                    if !tags.contains("to watch") {
                       
                        newMovie.watched = true
                    }
                    
                    for tag in tags {
                       
                        newMovie.addTag(named: tag)
                    }
//                    SVProgressHUD.showProgress(index / Float(json.count), status: "Adding \(newMovie.title)")
                    
                    }
                }
            }
        }
        DispatchQueue.main.async {
            
            SVProgressHUD.showSuccess(withStatus: "Finished!")
            SVProgressHUD.dismiss(withDelay: 0.5)
        }
        }
    
        
}
