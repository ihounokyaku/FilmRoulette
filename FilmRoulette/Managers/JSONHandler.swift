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
            
            if let existingMovie = GlobalDataManager.movie(withId: id) {
                
                guard let tags = movie.1["tags"].arrayObject as? [String] else {continue}
                if !existingMovie.tagList.containsSameElements(as: tags) {
                    DispatchQueue.main.async {
                        SVProgressHUD.showProgress(index / Float(json.count), status: "Updating tags for \(existingMovie.title)")
                        
                    }
                    GlobalDataManager.updateTags(newTags: tags, forMovie: existingMovie)
                }
                
            } else {
                let tags:[String] = movie.1["tags"].arrayObject as? [String] ?? []
                
                guard let newMovie = movie.1["movieData"].toMovie() else {continue}
                DispatchQueue.main.async {
                    SVProgressHUD.showProgress(index / Float(json.count), status: "Adding \(newMovie.title)")
    
                }
                GlobalDataManager.save(movie: newMovie, imageData: nil, love: false, watched: !tags.contains("to watch"), tags: tags)
            }
        }
        DispatchQueue.main.async {
            
            SVProgressHUD.showSuccess(withStatus: "Finished!")
            SVProgressHUD.dismiss(withDelay: 0.5)
        }
    }
}
