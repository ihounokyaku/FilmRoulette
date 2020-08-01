//
//  Movie.swift
//  FilmSwipe
//
//  Created by Dylan Southard on 2018/06/10.
//  Copyright © 2018 Dylan Southard. All rights reserved.
//

import Foundation
import SQLite



class Movie : SQLiteObject {
    
    @objc let title:String
    
    let desc:String
    
    var releaseDate:String
    
    let imdbID:String?
    
    let trailerURL:String
    
    private var _imageURL:String
    
    var thumbnailName:String
    
    var library:LibraryType = .library
    
    
    
    private var _love:Bool
    
    private var _watched:Bool
    
    
    var love:Bool {
        get { return self._love }
        set {
            self._love = newValue
            if newValue == true {self._watched = false}
            self.updateWatchedAndLove()
        }
    }
    
    var watched:Bool{
        get { return self._watched }
        set {
            self._watched = newValue
            if newValue == true {self._love = false}
            self.updateWatchedAndLove()
        }
    }
    
    var imageURL:String {
        get {return self._imageURL}
        set {
            self._imageURL = newValue
            self.update([DataProperties.ImageURL <- newValue])
            
        }
    }
    
    func updateWatchedAndLove() {
        self.update([
            DataProperties.Watched <- self._watched.asInt,
            DataProperties.Love <- self._love.asInt
        ])
    }
    
    var genres:[Genre] {
        
        var genreArray = [Genre]()
        
        for genreID in self.genreIDs {
            guard let genre = Genre.WithID(genreID) else {continue}
            genreArray.append(genre)
        }
        
        return genreArray
    }
    
    @objc var genreIDs:[Int] {
       
        let _ids = SQLDataManager.FetchRelationship(ofType: .movieGenre, primaryExpression: DataProperties.MovieID.expression, value: self.id, libraryType: self.library).ids(forExpression: DataProperties.GenreID)
        
        return _ids.count > 0 ? _ids:self.tempGenreIDs
    
    }
    
    var tags:[Tag] {
        return SQLDataManager.FetchObjects(ofType: .tag, withIDs: self.tagIDs) as? [Tag] ?? []
    }
    
    @objc var tagIDs:[Int] {
        
        let _ids = SQLDataManager.FetchRelationship(ofType: .movieTag, primaryExpression: DataProperties.MovieID.expression, value: self.id, libraryType: .library).ids(forExpression: DataProperties.TagID.expression)
        
        return _ids.count > 0 ? _ids:self.tempTagIDs
    }
    
    var releaseYear:Int { return Int(self.releaseDate.year()) ?? 1981 }
    
    var tempGenreIDs = [Int]()
    
    var tempTagIDs = [Int]()
    
    
    //MARK: - allow access to the thumbnail image from the database
    var poster : UIImage { get { return self.thumbnailName.image() } }
    
    func setPoster(withData data:Data?) {
        
        guard let realData = data else { return}
        
        guard UIImage(data:realData) != nil else { return}
        
        self.thumbnailName = self.title.replacingOccurrences(of: "/", with: "-") + self.releaseDate
        print(self.title + self.releaseDate)
        if !self.imageExists{
            try? realData.write(to: self.fullImageURL)
        }
        
        self.update([DataProperties.ThumbnailName <- self.thumbnailName])
        
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
    
    
    
    init(id:Int, title:String, desc:String, releaseDate:String, trailerURL:String, imageURL:String, imdbID:String?, thumbnailName:String, love:Bool, watched:Bool){
        
       
        self.title = title
        self.desc = desc
        self.releaseDate = releaseDate
        self.trailerURL = trailerURL
        self._imageURL = imageURL
        self.imdbID = imdbID
        self.thumbnailName = thumbnailName
        self._love = love
        self._watched = watched
        
        super.init(id: id, type: .movie)
        
    }
    
    convenience init(id:Int, title:String, desc:String, releaseDate:String, trailerURL:String, imageURL:String, imdbID:String?) {
        
        self.init(id: id, title: title, desc: desc, releaseDate: releaseDate, trailerURL: trailerURL, imageURL: imageURL, imdbID: imdbID, thumbnailName:"noImage.png", love:false, watched:false)
        
    }
    
    convenience init?(fromRow row:Row) {
        do {
             self.init(id: try row.get(DataProperties.Id),
                       title: try row.get(DataProperties.Title),
                       desc: try row.get(DataProperties.Desc),
                       releaseDate: try row.get(DataProperties.ReleaseDate),
                       trailerURL: try row.get(DataProperties.TrailerURL),
                       imageURL: try row.get(DataProperties.ImageURL),
                       imdbID: try row.get(DataProperties.IMDBID),
                       thumbnailName: try row.get(DataProperties.ThumbnailName),
                       love: try row.get(DataProperties.Love).asBool,
                       watched: try row.get(DataProperties.Watched).asBool)
        } catch {
            print(error)
            return nil
        }
    }
    
    
    convenience init(value:Movie) {
        self.init(id: value.id, title: value.title, desc: value.desc, releaseDate: value.releaseDate, trailerURL: value.trailerURL, imageURL: value.imageURL, imdbID: value.imdbID, thumbnailName: value.thumbnailName, love: value.love, watched: value.watched)
        
        self.tempGenreIDs = value.genreIDs
        
        self.tempTagIDs = value.tagIDs
    }
    
    override var insertExpression: [Setter] {
        return [
            DataProperties.Id <- self.id,
            DataProperties.Title <- self.title,
            DataProperties.Desc <- self.desc,
            DataProperties.ReleaseDate <- self.releaseDate,
            DataProperties.TrailerURL <- self.trailerURL,
            DataProperties.ImageURL <- self._imageURL,
            DataProperties.IMDBID <- self.imdbID ?? "",
            DataProperties.ThumbnailName <- self.thumbnailName,
            DataProperties.Love <- self._love.asInt,
            DataProperties.Watched <- self.watched.asInt,
            
        ]
    }
    
    func addTag(named name:String){
        if let genre = Genre.WithName(name) {
            self.addGenre(genre: genre)
            return
        }
        //see if tag exists
        if let tag = SQLDataManager.Tag(named: name) {
            
             //see if rel exists
            if SQLDataManager.FetchMovieRelationship(ofType: .tag, movieID: self.id, relObjectID: tag.id) == nil {
                
                SQLDataManager.InsertTagMovieRelationship(tagID: tag.id, movieID: self.id)
                
            }
        } else {
            print("creating new tag \(name)")
            //doesn't exist - create and add tag
            let newTag = Tag(name: name)
            SQLDataManager.Insert(object: newTag)
            SQLDataManager.InsertTagMovieRelationship(tagID: newTag.id, movieID: self.id)
            
        }
        
    }
    
    func removeTag(named name:String){
        
        guard let tag = SQLDataManager.Tag(named: name) else {return}
        
        guard let id = SQLDataManager.FetchMovieRelationship(ofType: .tag, movieID: self.id, relObjectID: tag.id)?.id else {return}
        
        SQLDataManager.Delete(dataItemOfType: .movieTag, withID: id)
        
        if tag.moviesIDs.count < 1 {
            
            SQLDataManager.Delete(object: tag)
            
        }
        
        
    }
    
    func addGenre(genre:Genre) {
        
        
        if SQLDataManager.FetchMovieRelationship(ofType: .genre, movieID: self.id, relObjectID: genre.id) == nil {
            
            SQLDataManager.InsertGenreMovieRelationship(genreID: genre.id, movieID: self.id)
            
        }
        
        
    }
}
