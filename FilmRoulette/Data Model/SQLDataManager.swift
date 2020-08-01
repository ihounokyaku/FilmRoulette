//
//  SQLiteDataManager.swift
//  MaximumEnglish
//
//  Created by Dylan Southard on 7/8/20.
//  Copyright © 2020 Dylan Southard. All rights reserved.
//

import Foundation
import SQLite




class SQLDataManager: NSObject {
    
    
    //MARK: - =============== DATABASE ===============
    
    
    static var Importing = false
    
    static var dbPath:String = {
        let _path = DocumentsDirectory.path
        
        try? FileManager.default.createDirectory( atPath: _path, withIntermediateDirectories: true, attributes: nil )
        
        print(_path)
        return "\(_path)/filmroulette.sqlite3"
    }()
    
    
    
    static private var filmswipePath:String = {
        let _path = DocumentsDirectory.path
        
        try? FileManager.default.createDirectory( atPath: _path, withIntermediateDirectories: true, attributes: nil )
        
        print(_path)
        return "\(_path)/filmswipe.sqlite3"
    }()
    
    static var TempPath:String = { return NSTemporaryDirectory() + "filmswipe.sqlite3" }()
    
    //    static var CurrentDBURL:URL {
    //        return URL(fileURLWithPath: Prefs.kidsMode ? kidsPath : dbPath)
    //    }
    
    
    static var fsDB:Connection? = {
        if FileManager().fileExists(atPath: filmswipePath) {
            let connection = try! Connection(filmswipePath)
            
            try! connection.execute("PRAGMA foreign_keys = ON;")
            
            return connection
        } else {
            return nil
        }
        
        
    }()
    
    static var normalDB:Connection = {
        
        let connection = try! Connection(dbPath)
        
        try! connection.execute("PRAGMA foreign_keys = ON;")
        
        return connection
        
    }()
    
    static var tempDB:Connection = {
        
        
        
        let connection = try! Connection(TempPath)
        
        try! connection.execute("PRAGMA foreign_keys = ON;")
        
        return connection
        
    }()
    
    static var db:Connection { return normalDB }
    

    
    
    
    
    //MARK: - =============== CREATE ===============
    
    static func CreateTables() {
        for type in SQLDataType.allCases {
            
            let properties = type.properties
            
            let table = Table(type.rawValue)
            
            let create = table.create { (t) in
                print("creating table \(table)")
                t.column(DataProperties.Id, primaryKey: true)
                
                for expression in properties.stringProperties {t.column(expression)}
                
                for expression in properties.intProperties {t.column(expression)}
                
                for key in properties.linkedProperties {t.column(key.expression) }
                
                for key in properties.linkedProperties {
                    
                    t.foreignKey(key.expression, references: key.references, DataProperties.Id, delete: key.onDelete)
                    
                }
            }
            do {
                try db.run(create)
            } catch {
                print("error creating yo")
                print(error)
            }
        }
    }
    
    static func Insert(object:SQLiteObject, presentError:Bool = false) {
       
        do {
            
            try self.db.run(object.insert)
            
            RefreshAll()
        } catch {
            print("Error saving object \(error)")
            //            if presentError { AlertManager.PresentErrorAlert(withTitle: "Error!", message: "Could not add object to database!") }
            
        }
    }
    
    static func Insert(movie:Movie, imageData:Data?) {
        
        print("going to insert movie")
        movie.setPoster(withData:imageData)
        
        Insert(object: movie)
        
        for genre in movie.tempGenreIDs {
            
            InsertGenreMovieRelationship(genreID: genre, movieID: movie.id)
        }
        
        for tag in movie.tempTagIDs {
            
            InsertTagMovieRelationship(tagID: tag, movieID: movie.id)
            
        }
        
        
        
        RefreshMovies()
    }
    
    static func Insert(dataOfType type:SQLDataType, setters:[Setter]) {
        
        let expression = type.table.insert(setters)
        
        do {
            try self.db.run(expression)
        } catch {
            print("error inserting \(type.rawValue)")
            print(error)
        }
    }
    
    static func InsertGenreMovieRelationship(genreID:Int, movieID:Int) {
        
        Insert(dataOfType: .movieGenre, setters: [DataProperties.Id <- Int(String(genreID) + String(movieID))!, DataProperties.GenreID <- genreID, DataProperties.MovieID.expression <- movieID])
        
    }
    
    static func InsertGroupMovieRelationship(groupID:Int, movieID:Int) {
        
        
        Insert(dataOfType: .movieGroup, setters: [DataProperties.Id <- Int(String(groupID).suffix(5) + String(movieID))!, DataProperties.GroupID.expression <- groupID, DataProperties.MovieID.expression <- movieID])
        
    }
    
    static func InsertTagMovieRelationship(tagID:Int, movieID:Int) {
        
        Insert(dataOfType: .movieTag, setters: [DataProperties.Id <- Int(String(tagID) + String(movieID))!, DataProperties.TagID.expression <- tagID, DataProperties.MovieID.expression <- movieID])
        
    }
    
    
    static func InsertFilterRelationship(ofType type:SQLFilterRelationshipType, filterID:Int, relObjectID:Int, condition:FilterCondition) {
        
        Insert(dataOfType: type.dataType, setters: [DataProperties.Id <- Int(String(filterID).suffix(5) + String(relObjectID).suffix(5))!,
                                                    DataProperties.FilterID.expression <- filterID,
                                                    type.relObjectExpression <- relObjectID,
                                                    DataProperties.FilterCondition <- condition.rawValue])
        
    }
    
    static func Import(movie:Movie) {
        if FetchMovie(withID: movie.id) == nil {
            Insert(movie: Movie(value: movie), imageData: nil)
        }
    }
    
    
    //MARK: - =============== READ ===============
    
    //MARK: - ===  Movie Lists  ===
    
    static var AllMovies:[Movie] = FetchAllObjects(ofType: .movie) as? [Movie] ?? []
    
    static var FSMovies:[Movie] = {
       
       return FetchAllObjects(ofType: .movie, inLibrary: .filmSwipe) as? [Movie] ?? []
    }()
        
    
    static var AllGroups:[Group] = {FetchAllObjects(ofType: .group) as? [Group] ?? []}()
    
    static var AllTags:[Tag] = FetchAllObjects(ofType: .tag) as? [Tag] ?? []
    
    
    static func FetchAllObjects(ofType type:SQLObjectType, inLibrary libraryType:LibraryType = .library)-> [SQLiteObject] {
        return FetchObjects(fromTable: type.dataType.table, ofType: type, inLibrary: libraryType)
    }
    
    
    
    static func FetchObjects(ofType type:SQLObjectType, withStringProperty property:Expression<String>, value:String)->[SQLiteObject] {
        
        return FetchObjects(fromTable: type.dataType.table.filter(property == value), ofType: type)
        
    }
    
    static func FetchObjects(ofType type:SQLObjectType, withIntProperty property:Expression<Int>, value:Int)->[SQLiteObject] {
        
        return FetchObjects(fromTable: type.dataType.table.filter(property == value), ofType: type)
        
    }
    
    static func FetchObjects(fromTable table:Table, ofType type:SQLObjectType, inLibrary libraryType:LibraryType = .library)->[SQLiteObject] {
        var results = [SQLiteObject]()
        var db = self.db
        if libraryType == .filmSwipe {
            guard let fsDB = self.fsDB else { return [] }
            db = fsDB
        }
        do {
            
            let rows = try db.prepare(table)
            
            for row in rows {
                if let obj = type.newObject(fromRow: row) {
                    
                    if let movie = obj as? Movie {
                        movie.library = libraryType
                    }
                    
                    results.append(obj)
                    
                }
            }
            
            return results
        } catch {
            print("error fetching yo from \(db)")
            print(error)
            
            return []
            
        }
        
    }
    
    static func FetchAllRows(ofType type:SQLDataType, inLibrary libraryType:LibraryType)->[Row] { FetchRows(inTable: type.table, inLibrary:libraryType) }
    
    static func FetchRows(inTable table:Table, inLibrary libraryType:LibraryType)->[Row] {
        do {
            var db = self.db
            if libraryType == .filmSwipe {
                guard let fsDB = self.fsDB else { return []}
                db = fsDB
            }
            
            return try Array(db.prepare(table))
            
        } catch {
            
            return []
            
        }
    }
    
    static func FetchObject(ofType type:SQLObjectType, withID id:Int)->SQLiteObject? {
        
        return FetchObjects(ofType: type, withIntProperty: DataProperties.Id, value: id).first
        
    }
    
    static func FetchMovie(withID id:Int)->Movie? {
        
        
        return FetchObject(ofType: .movie, withID: id) as? Movie
        
    }
    
    static func Movies(fromRows rows:[Row])->[Movie] { return Objects(ofType: .movie, fromRows: rows) as? [Movie] ?? [] }
    
    static func Objects(ofType type:SQLObjectType, fromRows rows:[Row])->[SQLiteObject]{
        var _objects = [SQLiteObject]()
        
        for row in rows {
            guard let objectID = try? row.get(type.foreignKey.expression), let object = SQLDataManager.FetchObject(ofType: type, withID: objectID) else {continue}
            
            _objects.append(object)
        }
        
        return _objects
    }
    
    
    static func FetchRelationship(ofType type:SQLRelationshipType, primaryExpression:Expression<Int>, value:Int, libraryType:LibraryType = .library)->[Row] {
        
        return FetchRows(inTable:type.dataType.table.filter(primaryExpression == value), inLibrary: libraryType)
        
    }
    
    static func FetchRelationship(ofType type:SQLRelationshipType, primaryExpression:Expression<Int>, primaryValue:Int, secondaryExpression:Expression<Int>, secondaryValue:Int, inLibrary libraryType:LibraryType = .library)->[Row] {
        
        return FetchRows(inTable: type.dataType.table.filter(primaryExpression == primaryValue && secondaryExpression == secondaryValue), inLibrary: libraryType)
        
    }
    
    static func FetchFilterRelationship(ofType type:SQLFilterRelationshipType, filterID:Int, relObjectID:Int, inLibrary libraryType:LibraryType = .library)->Row? {
        
        return FetchRows(inTable:type.dataType.table.filter(DataProperties.FilterID.expression == filterID && type.relObjectExpression == relObjectID), inLibrary: libraryType).first
        
    }
    
    static func FetchFilterRelationship(ofType type:SQLFilterRelationshipType, filterID:Int, condition:FilterCondition, inLibrary libraryType:LibraryType)->[Row] {
        
        return FetchRows(inTable:type.dataType.table.filter(DataProperties.FilterID.expression == filterID && DataProperties.FilterCondition == condition.rawValue), inLibrary: libraryType)
        
    }
    
    static func FetchMovieRelationship(ofType type:SQLMovieRelationshipType, movieID:Int, relObjectID:Int, inLibrary libraryType:LibraryType = .library) -> Row? {
        
        return FetchRows(inTable:type.dataType.table.filter(DataProperties.MovieID.expression == movieID && type.relObjectExpression == relObjectID), inLibrary: libraryType).first
        
    }
    
    static func FetchObjects(ofType type:SQLObjectType, withIDs ids:[Int]) -> [SQLiteObject] {
        
        var arr = [SQLiteObject]()
        
        for id in ids {
            if let object = FetchObject(ofType: type, withID: id) {
                arr.append(object)
            }
        }
        
        
        return arr
        
    }
    
    static func Tags(withIDs ids:[Int])->[Tag] { return FetchObjects(ofType: .tag, withIDs: ids) as? [Tag] ?? [] }
    
    static func Tag(named name:String)-> Tag? {
        return FetchObjects(ofType: .tag, withStringProperty: DataProperties.Name.lowercaseString, value: name.lowercased()).first as? Tag
    }
    
    //MARK: - =============== UPDATE ===============
    
    static func Update(object:SQLiteObject, commands:[Setter]) {
        
        Update(dataOfType: object.type.dataType, withID: object.id, commands: commands)
        
    }
    
    static func Update(dataOfType type:SQLDataType, withID id:Int, commands:[Setter]) {
        
        let table = type.table.filter(DataProperties.Id == id)
        let update = table.update(commands)
        do {
            try db.run(update)
        } catch {
            print("error updating yo")
            print(error)
        }
        
    }
    
    
    
    //MARK: - =============== DESTROY ===============
    
    static func Delete(object:SQLiteObject) {
        Delete(dataItemOfType: object.type.dataType, withID: object.id)
        if let movie = object as? Movie {
            
            Conveniences().deleteFile(atURL: ImageDirectory.appendingPathComponent(movie.thumbnailName))
            RefreshMovies()
        }
    }
    
    static func Delete(dataItemOfType type:SQLDataType, withID id:Int) {
        let dbObject = type.table.filter(DataProperties.Id == id)
        let delete = dbObject.delete()
        do {
            try db.run(delete)
        } catch {
            print("error deleting yo")
            print(error)
        }
    }
    
    
    
    //MARK: - =============== REFRESH LISTS ===============
    
    static func RefreshMovies() {
        
        AllMovies = FetchAllObjects(ofType: .movie) as? [Movie] ?? []
        
        FSMovies = FetchAllObjects(ofType: .movie, inLibrary: .filmSwipe) as? [Movie] ?? []
        
        AllGroups = FetchAllObjects(ofType: .group) as? [Group] ?? []
        
        AllTags = FetchAllObjects(ofType: .tag) as? [Tag] ?? []
    }
    

    
    
    static func RefreshAll() {
        
        RefreshMovies()
        
        AllGroups = FetchAllObjects(ofType: .group) as? [Group] ?? []
        
        AllTags = FetchAllObjects(ofType: .tag) as? [Tag] ?? []
        
    }
    
}


extension Array where Element == Row {
    
    
    func ids(forExpression expression:Expression<Int>)->[Int] {
        
        var _ids = [Int]()
        
        for row in self {
            if let id = try? row.get(expression) {
                _ids.append(id)
            }
        }
        return _ids
    }
}
