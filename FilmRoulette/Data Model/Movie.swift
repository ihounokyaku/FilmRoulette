//
//  Movie.swift
//  FilmSwipe
//
//  Created by Dylan Southard on 2018/06/10.
//  Copyright © 2018 Dylan Southard. All rights reserved.
//

import Foundation
import RealmSwift

class Movie : Object {
    @objc dynamic var id = 0
    @objc dynamic var title = "No Title"
    @objc dynamic var thumbnailName = "noImage.png"
    @objc dynamic var imageUrl = ""
    @objc dynamic var desc = ""
    @objc dynamic var rtScore = ""
    @objc dynamic var imdbScore = ""
    @objc dynamic var metacriticScore = ""
    @objc dynamic var trailerUrl:String = ""
    @objc dynamic var love = false
    @objc dynamic var watched = false
    @objc dynamic var releaseDate =  "unknown"
    @objc dynamic var imdbID = ""
    
    let tags = List<Tag>()
    var genres = List<String>()
    let genreList = List<Genre>()
    
    //MARK: - allow access to the thumbnail image from the database
    var poster : UIImage {
        get {
            return self.thumbnailName.image()
        }
    }
    
    func setPoster(withData data:Data?) {
        guard let realData = data else {return}
        guard UIImage(data:realData) != nil else {return}
        self.thumbnailName = self.title + self.releaseDate
        
        if !self.imageExists{
            try? realData.write(to: self.fullImageURL)
        }
    }
    
    var fullImageURL:URL {
        get {
            return ImageDirectory.appendingPathComponent(self.thumbnailName)
        }
    }
    
    var imageExists:Bool {
        get {
            return FileManager.default.fileExists(atPath: self.fullImageURL.path)
        }
    }
    
}
