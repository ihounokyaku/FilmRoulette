//
//  MovieTable.swift
//  FilmRoulette
//
//  Created by Dylan Southard on 2019/04/04.
//  Copyright © 2019 Dylan Southard. All rights reserved.
//

import UIKit
import RealmSwift

class MovieTable: TableVC, SelectorDelegate, MovieCellDelegate {
    
    //MARK: - =============== IBOUTLETS ===============
    @IBOutlet weak var displaySelector: Selector!
    
    //MARK: - === BUTTONS ===
    @IBOutlet weak var allButton: UIButton!
    @IBOutlet weak var unwatchedButton: UIButton!
    @IBOutlet weak var starredButton: UIButton!
    

    //MARK: - =============== VARS ===============
    
    //MARK: - === DATASOURCES ===
    var dataSource:Results<Movie> {
        let movies = self.filteredMovies ?? self.moviesOnDisplay
        return movies.sorted(byKeyPath: "title", ascending: true)
    }
    
    var filteredMovies:Results<Movie>?
    
    var moviesOnDisplay:Results<Movie> {
        
        let baseResults = self.tableType == .library ? GlobalDataManager.movies(self.moviesNotInGroup, filteredBy: self.controller.filterObject, libraryType: .library,  allInCategory: false) : self.group!.movies.filter("TRUEPREDICATE")
        
       return GlobalDataManager.movies(baseResults, filteredBy: self.displayOption)
        
    }
    
    var moviesNotInGroup:Results<Movie> {
        
        get {
            var movies = GlobalDataManager.realm.objects(Movie.self)
            for movie in self.group!.movies {
                movies = movies.filter("id != %i", movie.id)
            }
        
            return movies
        }
    }
    
    var displayOption:MovieOption? {
        get {
            let options:[Int:MovieOption] = [1:.unwatched, 2:.loved]
            return options[self.displaySelector.indexOfSelectedItem]
        }
    }
    
    //MARK: - === Other ===
    var removedMovie:Int?
    
    //MARK: - =============== SETUP ===============
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.configureSelector()
    }
    
    func selectorPressed(sender: Selector) {
        self.tableView.reloadData()
    }
    
    
    //MARK: - === UI CONFIGURATION ===
    func configureSelector() {
        self.displaySelector.configure(buttons: [self.allButton, self.unwatchedButton, self.starredButton], highlightColor: UIColor().colorSecondaryLight(alpha: 0.4), delegate: self)
    }
    
    //MARK: - =============== OTHER ===============
    
    //MARK: - === UNDO ===
    override func undo() {
        guard self.tableType == .groupContents, let id = self.removedMovie, let movie = GlobalDataManager.movie(withId: id) else {return}
        do {
            try GlobalDataManager.realm.write {
                if !self.group!.movies.contains(movie){self.group!.movies.append(movie)}
                self.removedMovie = nil
                self.tableView.reloadData()
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    //MARK: - =============== TABLEVIEW ===============
    
    //MARK: - === DataSource ===
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return self.dataSource.count }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellType.rawValue) as! MovieListCell
        let movie = self.dataSource[indexPath.row]
        cell.delegate = self
        cell.indexPath = indexPath
        cell.buttonRightImage?.image = self.tableType == .library ? Images.AddToGroup : Images.RemoveFromGroup
        cell.config(title: movie.title, releaseYear: movie.releaseYear, poster: movie.poster)
        return cell
    }
    
    
    
     //MARK: - === Delegate ===
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let movie = self.dataSource[indexPath.row]
        self.controller.libContainer.presentSingleMovieView(movie: movie, imageData: nil, filmSwipe: false, sender: self.controller.libContainer)
    }
    
    
    func buttonTapped(at index: IndexPath) {
        let movie = self.dataSource[index.row]
        do {
            try GlobalDataManager.realm.write {
                if !self.group!.movies.contains(movie) {
                    if self.tableType == .library {
                        self.group!.movies.append(movie)
                        
                    } else {
                        self.group!.movies.remove(at:self.group!.movies.index(of: movie)!)
                        self.removedMovie = movie.id
                        self.view.makeToast("Movie Removed (shake to undo)")
                    }
                    self.tableView.reloadData()
                } else {print("\(movie.title) not in group!")}
            }
        } catch {print(error.localizedDescription)}
    }
    
    
    
    //MARK: - ==========SEARCH BAR==========
    
    override func search(text:String) {
        self.filteredMovies = self.moviesOnDisplay.filter(GlobalDataManager.predicate(forType: .movie, text: text))
        self.tableView.reloadData()
    }
    override func clearSearch(){
        self.filteredMovies = nil
        self.tableView.reloadData()
    }
    
   
    
    
    

    //MARK: - ==SwipeControl==
//    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
//        var actions = [SwipeAction]()
//
//        if self.tableType == .library {
//            guard let group = self.group else {return nil}
//            actions.append(SwipeAction(style: .default, title: "Add") { (action, indexPath) in
//                if let error = GlobalDataManager.add(self.movieDataSource[indexPath.row], toGroup: group) {
//                    self.view.makeToast(error)
//                } else {
//                    self.updateDataSource()
//                }
//
//            })
//        } else {
//            guard let group = self.group else {return nil}
//            actions.append(SwipeAction(style: .destructive, title: "delete") { (action, indexPath) in
//                guard group.movies.count > indexPath.row else {return}
//                do {
//                    try GlobalDataManager.realm.write {
//                        group.movies.remove(at: indexPath.row)
//                        self.setTableData()
//                    }
//
//                } catch let error {
//                    print("error deleting \(error.localizedDescription)")
//                }
//
//            })
//        }
//        return actions
//    }
//
//    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
//        var options = SwipeOptions()
//        if self.tableType == .library {
//            options.expansionStyle = .selection
//        } else {
//            options.expansionStyle = .destructive
//        }
//
//        options.transitionStyle = .border
//        return options
//    }
//}
}
