//
//  LikedMoviesVC.swift
//  FilmSwipe
//
//  Created by Dylan Southard on 2018/06/11.
//  Copyright © 2018 Dylan Southard. All rights reserved.
//

import UIKit
import Toast_Swift



class MovieListVC: LibrarySubview, SelectorDelegate, UITableViewDataSource, UITableViewDelegate, DropboxDelegate, PosterGetterDelegate {

    

    
    //MARK: - =========IBOUTLETS==========
    @IBOutlet weak var movieTable: UITableView!
    
    //MARK: - === BUTTONS ===
    @IBOutlet weak var filterSelector: Selector!
    @IBOutlet weak var bottomButton: UIButton!
    
    @IBOutlet weak var allButtton: UIButton!
    @IBOutlet weak var unwatchedButton: UIButton!
    @IBOutlet weak var starredButton: UIButton!
    
    
    
    //MARK: - =============== VARS ===============
    
    
    //MARK: - === OBJECTS ===
    var dropboxManager: DropboxManager = DropboxManager()
    var posterGetter:PosterGetter!
   
    //MARK: - === DATASOURCES ===
    
    var searchText:String?
    
    var dataSource:[Movie]{
        
        if searchText == nil || searchText == "" {
            return self.moviesOnDisplay
        } else {
            return self.moviesOnDisplay.filteredBy(text: searchText!)
        }
        
//        return self.filteredMovies ?? self.moviesOnDisplay
        
        
    }
    
   
    
    var moviesOnDisplay:[Movie] {
        
        let baseResults = self.libContainer.libraryType == .library ? SQLDataManager.AllMovies : SQLDataManager.FSMovies
        if let option = self.displayOption {
            return baseResults.filteredBy(option: option)
        }
        
        return baseResults
        
    }
    
    var queryList = [Movie]()
    
    
    //MARK: - === STATE VARIABLES ===
    
    var displayOption:MovieOption? {
        get {
            let options:[Int:MovieOption] = [1:.unwatched, 2:.loved]
            return options[self.filterSelector.indexOfSelectedItem]
        }
    }
    
   
    
    
   //MARK: - =============== SETUP ===============
    
    
    //MARK: - === VC SETUP ===
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configure(tableView: self.movieTable, withCellOftype: .movie)
        self.movieTable.dataSource = self
        self.movieTable.delegate = self
        self.posterGetter = PosterGetter(delegate: self)
        self.configureSelector()
    
        self.hideKeyboardWhenTapped()
        
        self.toggleDisplay()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.completeMissingPosters()
    }
    
    //MARK: - === UI SETUP ===
    
    func configureSelector() {
        self.filterSelector.configure(buttons: [self.allButtton, self.unwatchedButton, self.starredButton], highlightColor: UIColor().colorSecondaryLight(alpha: 0.4), delegate: self)
    }
    
   override func toggleDisplay() {
    
    let buttonText:[LibraryDisplayType:String] = [.library:"Import", .filmSwipe:"Add All"]
    
    self.bottomButton.setTitle(buttonText[self.libContainer.libraryType], for: .normal)

    self.movieTable.reloadData()
    
    }
    
    func selectorPressed(sender: Selector) {
        self.movieTable.reloadData()
    }
    
 
    //MARK: - ==== QUERY ANY POSTERS ====
    
    
    func completeMissingPosters() { self.posterGetter.completeMissingPosters(forMovies: self.dataSource) }
    
    func loadedPoster(_ toRequery:[Movie]) {
        
        self.movieTable.reloadData()
        
        self.posterGetter.completeErrorPosters(forMovies: toRequery)
        
        
    }
    
    
    
    
    //MARK: - =============== NAVIGATION ===============
    
    
    
    
    
    //MARK: - ===========ALERTS===========
    func delete(movie:Movie, indexPath:IndexPath) {
        let alert = UIAlertController(title: "Remove from favorites??", message: "♫ Nooooo backsieees ♫", preferredStyle: .alert)
        
        //Mark: Define Delete/Cancel Actions
        let action = UIAlertAction(title: "DO IT!!!", style: .default) { (action) in
            //TODO: DELETE
           
            SQLDataManager.Delete(object: movie)
            self.animateCellChange(atIndexPath: indexPath)
        }
       
        let action2 = UIAlertAction(title:"Cancel", style:.cancel)
        
        //MARK: - Add elements and present
        alert.addAction(action)
        alert.addAction(action2)
        present(alert, animated: true, completion: nil)
        
    }
    

    
    //MARK: - ======OTHER ACTIONS==========
    
    
   
    
    //MARK: - == Add from FS ==
    func addAll() {
        
        for movie in self.dataSource {
            
            SQLDataManager.Import(movie: movie)
            self.view.makeToast("Movie added to library", duration:3.0, position: .center)
            
        }
    }
    
    
    @IBAction func bottomButtonPressed(_ sender: Any) {
        switch self.libContainer.libraryType {
        case .library:
            self.syncFromDropbox()
        case .filmSwipe:
            self.addAll()
        default:
            break
        }
    }

    func dropboxSyncComleted() {
        print("sync completed!!")
        self.movieTable.reloadData()
    }
    

//MARK: - =============== TABLEVIEW ===============

    
    //MARK: - === DELEGATE ===

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        var button:UITableViewRowAction!
        
        if self.libContainer.libraryType == .library {
            button = UITableViewRowAction(style: .normal, title: "Delete") { (action, indexPath) in
                
                self.delete(movie: self.dataSource[indexPath.row], indexPath:indexPath)
            }
            button.backgroundColor = UIColor(hexString: "#A5484A").withAlphaComponent(0.8)
        } else {
            button = UITableViewRowAction(style: .normal, title: "Add") { (action, indexPath) in
                
                let movie = self.dataSource[indexPath.row]
                
                SQLDataManager.Import(movie: movie)
                
                self.view.makeToast("Saved to library", duration:3.0, position: .center)
                
                button.backgroundColor = UIColor(hexString: "#34A853").withAlphaComponent(0.8)
                
            }
            
            
        }
        return [button]
    }
        
    func animateCellChange(atIndexPath indexPath: IndexPath, remove:Bool = true) {
        CATransaction.begin()
        self.movieTable.beginUpdates()
        CATransaction.setCompletionBlock {
            self.movieTable.reloadData()
        }
        if remove {
            self.movieTable.deleteRows(at: [indexPath], with: .automatic)
        }
        
        self.movieTable.endUpdates()
        CATransaction.commit()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.libContainer.presentSingleMovieView(movie: self.dataSource[indexPath.row], imageData: nil, filmSwipe: self.libContainer.libraryType == .filmSwipe, sender: self.libContainer)
        
    }

    //MARK: - === DATASOURCE ===
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.tableCellHeight(forTableView: tableView)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return self.dataSource.count
    }
    

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieListCell") as! MovieListCell
        
        
            let movie = self.dataSource[indexPath.row]
            cell.indexPath = indexPath
        cell.configure(movie:movie, poster:movie.poster, loadingPosters: self.posterGetter.loading)
        
        return cell
    }

    
    //MARK: - =============== SEARCH BAR ===============
    
    override func search(text: String) {
       
        self.searchText = text
        
        self.movieTable.reloadData()
    }
    
    override func clearSearch() {
        self.searchText = nil
        self.toggleDisplay()
        self.movieTable.reloadData()
    }
    
    
    
}



//MARK: - =============== SYNC ===============





