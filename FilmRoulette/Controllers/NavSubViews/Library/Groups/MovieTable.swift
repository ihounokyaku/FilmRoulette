//
//  MovieTable.swift
//  FilmRoulette
//
//  Created by Dylan Southard on 2019/04/04.
//  Copyright © 2019 Dylan Southard. All rights reserved.
//

import UIKit

class MovieTable: TableVC, SelectorDelegate, MovieCellDelegate, PosterGetterDelegate {
    
    //MARK: - =============== IBOUTLETS ===============
    @IBOutlet weak var displaySelector: Selector!
    
    //MARK: - === BUTTONS ===
    @IBOutlet weak var allButton: UIButton!
    @IBOutlet weak var unwatchedButton: UIButton!
    @IBOutlet weak var starredButton: UIButton!
    

    //MARK: - =============== VARS ===============
    
    //MARK: - === DATASOURCES ===
    var dataSource:[Movie] {
        let movies = self.filteredMovies ?? self.moviesOnDisplay
        return movies.sorted(by: {$0.title < $1.title})
    }
    
    var filteredMovies:[Movie]?
    
    var moviesOnDisplay:[Movie] {
        
        var baseResults:[Movie]!
        
        if self.tableType == .library {
            let ids = self.group!.movieIDs
            baseResults = SQLDataManager.AllMovies.filter({!ids.contains($0.id)})
        } else {
            baseResults = self.group!.movies
        }
        
        if let option = self.displayOption {
            return baseResults.filteredBy(option: option)
            
        }
        
        return baseResults
        
        
    }
    
    var moviesNotInGroup:[Movie] {
        
        get {
            
            let movies = SQLDataManager.AllMovies
            guard let group = self.group else { return movies}
        
            return movies.filter({!group.movieIDs.contains($0.id)})
        }
    }
    
    var displayOption:MovieOption? {
        get {
            let options:[Int:MovieOption] = [1:.unwatched, 2:.loved]
            return options[self.displaySelector.indexOfSelectedItem]
        }
    }
    
    //MARK: - === OBJECTS ===
    
    var posterGetter:PosterGetter!
    
    //MARK: - === Other ===
    var removedMovie:Int?
    
    //MARK: - =============== SETUP ===============
    override func viewDidLoad() {
        super.viewDidLoad()
        self.posterGetter = PosterGetter(delegate: self)
        self.posterGetter.completeMissingPosters(forMovies: self.moviesOnDisplay)
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
    
    //MARK: - ==== QUERY ANY POSTERS ====
    
    
    func completeMissingPosters() { self.posterGetter.completeMissingPosters(forMovies: self.dataSource) }
    
    func loadedPoster(_ toRequery:[Movie]) {
        
        self.posterGetter.completeErrorPosters(forMovies: toRequery)
        
        self.tableView.reloadData()
        
    }
    
    
    //MARK: - =============== OTHER ===============
    
    //MARK: - === UNDO ===
    override func undo() {
        
        guard self.tableType == .groupContents, let id = self.removedMovie, let movie = SQLDataManager.FetchMovie(withID: id) else {return}
      
            
            self.group?.add(movieWithID: movie.id)
            
            self.removedMovie = nil
        
        self.tableView.reloadData(with:.automatic)
            
    }
    
    //MARK: - =============== TABLEVIEW ===============
    
    //MARK: - === DataSource ===
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return self.dataSource.count }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellType.rawValue) as! MovieListCell
        let movie = self.dataSource[indexPath.row]
        cell.delegate = self
        cell.indexPath = indexPath
        print("table type is \(self.tableType.rawValue)")
        cell.buttonRightImage?.image = self.tableType == .library ? Images.AddToGroup : Images.RemoveFromGroup
        cell.configure(movie: movie, poster: movie.poster, loadingPosters: false)
        
        return cell
    }
    
    
    
     //MARK: - === Delegate ===
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let movie = self.dataSource[indexPath.row]
        self.controller.libContainer.presentSingleMovieView(movie: movie, imageData: nil, filmSwipe: false, sender: self.controller.libContainer)
    }
    
    
    func buttonTapped(at index: IndexPath) {
        let movie = self.dataSource[index.row]
        
            if self.tableType == .library {
                self.group!.add(movieWithID: movie.id)
                
            } else {
                self.group!.remove(movieWithID: movie.id)
                self.removedMovie = movie.id
                self.view.makeToast("Movie Removed (shake to undo)")
                
            }
            
            if self.tableType == .library {
                self.group!.add(movieWithID: movie.id)
            }
        
        self.tableView.reloadData(with: .automatic)
    }
    
    
    
    //MARK: - ==========SEARCH BAR==========
    
    override func search(text:String) {
        
        self.filteredMovies = self.moviesOnDisplay.filteredBy(text: text)
        
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
