//
//  DataSharingManager.swift
//  FilmSwipe
//
//  Created by Dylan Southard on 2018/10/24.
//  Copyright © 2018 Dylan Southard. All rights reserved.
//

import UIKit
import RealmSwift



class DataSharingManager: NSObject {
    let dataManager =  DataManager()
    var sender:UIViewController?
   
    init(sender:UIViewController) {
        super.init()
        self.sender = sender
    }
    
    var exportWindow:UIActivityViewController? {
        get {
            
            let data = try? Data(contentsOf: FilmRouletteRealm)
            return self.createExportWindow(forType:.frl, data:data)
        }
    }
    
    var exportWindowCSV: UIActivityViewController? {
        get {
            let data = self.csvData()
            return self.createExportWindow(forType:.csv, data:data)
        }
    }
    
    
    private func csvData()->Data? {
        
        let header = " ,Title,Release Date,Genres,Tags\n"
        let text = header + self.moviesToText(movies: dataManager.allMovies)
        return text.data(using: .utf8)
    }
    
    private func moviesToText(movies:Results<Movie>)-> String {
        var text = ""
        for movie in movies {
            let loved = movie.love ? "★" : " "
            var genres = ""
            for genre in movie.genres {
                genres += (genre + " ")
            }
            
            var tags = ""
            for tag in movie.tags {
                tags += tag.name
            }
           text += "\"\(loved)\",\"\(movie.title)\",\"\(movie.releaseDate.year())\",\"\(genres)\",\"\(tags)\"\n"
        }
        return text
    }
    
    private func createExportWindow(forType type: ExportDataType, data:Data?)->UIActivityViewController? {
            let path = NSTemporaryDirectory() + type.rawValue
            let url = URL(fileURLWithPath: path)
            do {
                try data?.write(to: url, options: .atomicWrite)
                let firstActivityItem = URL(fileURLWithPath: path)
                let activityViewController : UIActivityViewController = UIActivityViewController(activityItems: [firstActivityItem], applicationActivities: nil)
                
                activityViewController.excludedActivityTypes = [
                    UIActivity.ActivityType.postToVimeo,
                    UIActivity.ActivityType.postToFlickr,
                    UIActivity.ActivityType.assignToContact,
                    UIActivity.ActivityType.saveToCameraRoll,
                    UIActivity.ActivityType.postToTencentWeibo,
                ]
                if UIDevice.current.userInterfaceIdiom == .pad {
                    if activityViewController.responds(to: #selector(getter: UIViewController.popoverPresentationController)) {
                        activityViewController.popoverPresentationController?.sourceView = self.sender?.view
                    }
                }
                
                return activityViewController
            } catch let error {
                print(error)
                return nil
            }
    }
    
    func importData(data:Data, sender:NavContainer){
//        let path = NSTemporaryDirectory() + "filmswipe.realm"
//        let url = URL(fileURLWithPath: path)
//        do {
//
//
//            try data.write(to: url, options: .atomicWrite)
//            let realmConfig = Realm.Configuration(fileURL: url)
//            let realm = try Realm(configuration: realmConfig)
//            let dataManager = DataManager()
//            dataManager.realm = realm
//
//            if dataManager.allMovies().count > 0 {
//                sender.dataManager.realm.invalidate()
//                sender.dataManager.deleteAll()
//
//                if let saveData = dataManager.savedData() {
//                    Prefs.swipedMovies = Array(saveData.swipedMovies)
//                } else {
//                    Prefs.swipedMovies.removeAll()
//                }
//
//                sender.dataManager.deleteAll()
//                for movie in dataManager.allMovies() {
//                    let movieCopy = Movie(value:movie)
//                    sender.dataManager.addObject(movieCopy)
//                }
////                sender.dataManager.copyData(fromDatabase: realm)
//
//                if let vc = sender.currentSubview as? ViewController {
//                    vc.reloadAll()
//                }
//            } else {
//                showError(error: "No movies in database", controller: sender)
//            }
//
//        } catch let error {
//            self.showError(error: error.localizedDescription, controller:sender)
//            return
//        }
    }
    
    func showError(error:String, controller:UIViewController) {
        Conveniences().presentErrorAlert(withTitle: "Error!", message: error, sender: controller)
    }
    
}
