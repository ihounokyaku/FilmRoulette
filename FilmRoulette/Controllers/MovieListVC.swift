//
//  LikedMoviesVC.swift
//  FilmSwipe
//
//  Created by Dylan Southard on 2018/06/11.
//  Copyright © 2018 Dylan Southard. All rights reserved.
//

import UIKit
import RealmSwift
import Toast_Swift

enum LibraryDisplayType:String, CaseIterable {
    case all = "My Library"
    case filmSwipe = "FilmSwipe"
}

class MovieListVC: NavSubview, SingleMovieDelegate {

    //MARK: - =========IBOUTLETS==========
    
    //MARK: - == Views ===
    @IBOutlet weak var topView: UIView!

    @IBOutlet weak var movieTable: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    //MARK: - =========BUTTONS============
    @IBOutlet weak var filterSelector: Selector!
    @IBOutlet weak var bottomButton: UIButton!
    
    @IBOutlet weak var allButtton: UIButton!
    @IBOutlet weak var unwatchedButton: UIButton!
    @IBOutlet weak var starredButton: UIButton!
    
    
    //MARK: - =========Variables==========
    var moviesOnDisplay:Results<Movie> {
        return self.libraryType == .library ? GlobalDataManager.realm.objects(Movie.self) : GlobalDataManager.fsRealm.objects(Movie.self)
    }
    
    var displayOption:MovieOption? {
        get {
            let options:[Int:MovieOption] = [1:.unwatched, 2:.loved]
            return options[self.filterSelector.indexOfSelectedItem]
        }
    }
    
    var libraryType:LibraryType {
        return LibraryType.allCases[self.container.selector.indexOfSelectedItem]
    }
    
    var queryList = [Movie]()
    
    let dropboxManager = DropboxManager()
    
    //MARK: - ==STATUS VARIABLES ==
    var posterQueryIndex = 0
    
    
    //MARK: - ==========VIEW SETUP==========
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK: Delegates/Datasources
        self.movieTable.delegate = self
        self.movieTable.dataSource = self
        self.searchBar.delegate = self
        self.configureSelector()
        
        //MARK: Register tablecells and set selector
        self.movieTable.register(UINib(nibName: "MovieListCell", bundle: nil), forCellReuseIdentifier: "MovieListCell")
        self.movieTable.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
       
        
        //MARK: Update UI
        
        self.toggleDisplay()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.configureSelector()
        self.completeMissingPosters()
    }
    
    func configureSelector() {
         self.setSelector(buttonCount: 2, color: UIColor.SelectorWhite, label2: "My Library", label3:"FilmSwipe")
        self.filterSelector.configure(buttons: [self.allButtton, self.unwatchedButton, self.starredButton], highlightColor: UIColor().colorSecondaryLight(alpha: 0.4), delegate: self)
        
    }
    
    
    //MARK: - ===========Set Display===========
    
    func setColors() {
        self.topView.backgroundColor = UIColor().blackBackgroundPrimary()
        self.searchBar.backgroundColor = UIColor().blackBackgroundPrimary()
        self.searchBar.barTintColor = UIColor().blackBackgroundPrimary()
        
    }
    
    @IBAction func displayControlPressed(_ sender: Any) {
        
        self.toggleDisplay()
        
    }
    
    func toggleDisplay() {
        self.bottomButton.setTitle(self.libraryType == .library ? "Import" : "Add All", for: .normal)
        GlobalDataManager.movieList = GlobalDataManager.movies(self.moviesOnDisplay, filteredBy: self.displayOption)
        
//        self.addButton.isHidden = self.displayControl.selectedSegmentIndex == 0
        self.movieTable.reloadData()
    }
    
    override func selectionDidChange(sender: Selector) {
        self.toggleDisplay()
    }
    
 
    //MARK: - ==== QUERY ANY POSTERS ====
    
    func completeMissingPosters() {
        for movie in self.moviesOnDisplay {
            if !movie.imageExists && movie.imageUrl != "" {
                print("going to get poster for \(movie.title)")
                self.queryList.append(Movie(value:movie))
            }
        }
        self.loadNextPoster()
    }
    
    func loadNextPoster(){
        guard self.queryList.count > self.posterQueryIndex else {return}
        let movie = self.queryList[self.posterQueryIndex]
        PosterQueryManager().queryPoster(forMovie: movie, onCompletion: self.completeQueries)
    }
    
    
    func completeQueries() {
        print("got poster")
        self.movieTable.reloadData()
        self.posterQueryIndex += 1
        self.loadNextPoster()
    }
    
    
    //MARK: - ===========SINGLE VIEW===========
    
    func backFromSingleMovie(changed: Bool) {
        self.movieTable.reloadData()
    }
    
    
    
    
    //MARK: - ===========ALERTS===========
    func delete(movie:Movie, indexPath:IndexPath) {
        let alert = UIAlertController(title: "Remove from favorites??", message: "♫ Nooooo backsieees ♫", preferredStyle: .alert)
        
        //Mark: Define Delete/Cancel Actions
        let action = UIAlertAction(title: "DO IT!!!", style: .default) { (action) in
            //TODO: DELETE
           
            GlobalDataManager.deleteObject(object: movie)
            self.animateCellChange(atIndexPath: indexPath)
        }
       
        let action2 = UIAlertAction(title:"Cancel", style:.cancel)
        
        //MARK: - Add elements and present
        alert.addAction(action)
        alert.addAction(action2)
        present(alert, animated: true, completion: nil)
        
    }
    
    //MARK: - =============== Navigation ===============
    
    
    
    //MARK: - ======OTHER ACTIONS==========
    
   
    
    //MARK: - == Add from FS ==
    func addAll() {
        for movie in GlobalDataManager.movieList{
           
                if  let error = GlobalDataManager.importMovie(movie: movie) {
                    self.view.makeToast(error, duration:3.0, position: .center)
                } else {
                   self.view.makeToast("Movie added to library", duration:3.0, position: .center)
            }
            
        }
    }
    
    
    @IBAction func bottomButtonPressed(_ sender: Any) {
        if self.libraryType == .library {
            self.syncFromDropbox()
        } else {
            self.addAll()
        }
    }
}
    

//MARK: - ==========TABLE VIEW==========
//MARK: - ==DElEGATE==
extension MovieListVC : UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        var button:UITableViewRowAction!
        
        if self.libraryType == .library {
        button = UITableViewRowAction(style: .normal, title: "Delete") { (action, indexPath) in
            //TODO: show warning
            self.delete(movie: GlobalDataManager.movieList[indexPath.row], indexPath:indexPath)
            }
            button.backgroundColor = UIColor(hexString: "#A5484A").withAlphaComponent(0.8)
        } else {
            button = UITableViewRowAction(style: .normal, title: "Add") { (action, indexPath) in
                //TODO: show warning
                let movie = GlobalDataManager.movieList[indexPath.row]
                if !GlobalDataManager.databaseContains(movieWithId: movie.id) {
                   let error = GlobalDataManager.importMovie(movie: movie)
                    self.view.makeToast(error ?? "Saved to library", duration:3.0, position: .center)
                } else {
                    self.view.makeToast("Already in library.", duration:3.0, position: .center)
                }
            }
            button.backgroundColor = UIColor(hexString: "#34A853").withAlphaComponent(0.8)
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
        self.presentSingleMovieView(movie: GlobalDataManager.movieList[indexPath.row], imageData: nil, filmSwipe:self.libraryType == .filmSwipe, sender: self)
    }
    
}

//MARK: - ==DATASOURCE==
extension MovieListVC : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return GlobalDataManager.movieList.count
    }
    

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieListCell") as! MovieListCell
        
            let movie = GlobalDataManager.movieList[indexPath.row]
        cell.indexPath = indexPath
       cell.config(title: movie.title, releaseYear: movie.releaseDate.year(), poster: movie.poster)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let frameWidth = Float(self.movieTable.frame.width)
        if DeviceIsIpad {
            return 150
        }
        let number = Conveniences().valueFromRatio(ratioWidth: 375, ratioHeight: 81.5, width:frameWidth)
        
        return CGFloat(number)
    }
}

//MARK: - ==========SEARCH BAR==========
extension MovieListVC : UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        guard self.searchBar.text! != "" else {return}
        
        self.movieTable.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchBar.text?.count == 0 {
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
                self.toggleDisplay()
                self.movieTable.reloadData()
            }
        }
        
        var predicates = [NSPredicate]()
        
        predicates.append(NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!))
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        
        GlobalDataManager.movieList = self.moviesOnDisplay.filter(compoundPredicate)
        self.movieTable.reloadData()
        
    }
}

//MARK: - =============== SYNC ===============
extension MovieListVC : DropboxDelegate {
    
    
    func syncFromDropbox(){
        
        if self.dropboxManager.client == nil {
            self.dropboxManager.authorize(sender: self)
        } else {
            self.dropboxManager.importFile(sender: self)
        }
        
    }
    
    func requestComplete(error: String?, data: Data?) {
        if let realError = error {
            self.view.makeToast(realError)
        } else if let realData = data {
            JSONHandler().sync(fromData: realData)
            print("got the goods")
        } else {
            self.view.makeToast("No data found")
        }
    }
    
    func completedAuthorization(success: Bool, error: String?) {
        if let realError = error {
            self.view.makeToast(realError)
        } else if success {
            self.view.makeToast("successfully logged in to Dropbox")
        }
    }
}




