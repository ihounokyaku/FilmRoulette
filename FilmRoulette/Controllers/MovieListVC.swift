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

class MovieListVC: NavSubview {

    //MARK: - =========IBOUTLETS==========
    
    @IBOutlet weak var movieTable: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    //MARK: - =========BUTTONS============
    
    @IBOutlet weak var displayControl: UISegmentedControl!
    
    
    
    //MARK: - =========Variables==========
    var moviesOnDisplay:Results<Movie> {
        return self.displayControl.selectedSegmentIndex == 0 ? self.container.dataManager.realm.objects(Movie.self) : self.container.dataManager.fsRealm.objects(Movie.self)
    }
    
    
    //MARK: - ==========VIEW SETUP==========
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK: Delegates/Datasources
        self.movieTable.delegate = self
        self.movieTable.dataSource = self
        self.searchBar.delegate = self
        
        //MARK: Update UI
        self.toggleDisplay()
    }
    
    
    //MARK: - ===========Set Display===========
    
    @IBAction func displayControlPressed(_ sender: Any) {
        self.toggleDisplay()
    }
    
    func toggleDisplay() {
        self.container.dataManager.movieList = self.moviesOnDisplay
        self.movieTable.reloadData()
    }
    
    
    
    
    
    //MARK: - ===========PRESENTVIEW===========
    func presentView(withIdentifier identifier:String, movie:Movie) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        guard let controller = storyboard.instantiateViewController(withIdentifier: identifier) as? SingleMovieVC else {return}
//
//        //MARK: Configure and Present VC
//        controller.movie = movie
//        self.container.newQueryManager.cancelAllCurrentQueries()
//        controller.modalPresentationStyle = .popover
//        self.present(controller, animated:true, completion:nil)
    }
    
    //MARK: - ===========ALERTS===========
    func delete(movie:Movie) {
        let alert = UIAlertController(title: "Remove from favorites??", message: "♫ Nooooo backsieees ♫", preferredStyle: .alert)
        
        //Mark: Define Delete/Cancel Actions
        let action = UIAlertAction(title: "DO IT!!!", style: .default) { (action) in
            //TODO: DELETE
           
            self.container.dataManager.deleteObject(object: movie)
            
            self.movieTable.reloadData()
        }
       
        let action2 = UIAlertAction(title:"Cancel", style:.cancel)
        
        //MARK: - Add elements and present
        alert.addAction(action)
        alert.addAction(action2)
        present(alert, animated: true, completion: nil)
        
    }
}

//MARK: - ==========TABLE VIEW==========
//MARK: - ==DElEGATE==
extension MovieListVC : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let movie = self.container.dataManager.movieList[indexPath.row]
        //self.presentView(withIdentifier: "SingleMovie", movie: movie)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        var button:UITableViewRowAction!
        
        if self.displayControl.selectedSegmentIndex == 0 {
        button = UITableViewRowAction(style: .normal, title: "Delete") { (action, indexPath) in
            //TODO: show warning
            self.delete(movie: self.container.dataManager.movieList[indexPath.row])
            }
            button.backgroundColor = UIColor(hexString: "#A5484A").withAlphaComponent(0.8)
        } else {
            button = UITableViewRowAction(style: .normal, title: "Add") { (action, indexPath) in
                //TODO: show warning
                let movie = self.container.dataManager.movieList[indexPath.row]
                if !self.container.dataManager.databaseContains(movieWithId: movie.id) {
                   let error = self.container.dataManager.importMovie(movie: movie)
                    self.view.makeToast(error ?? "Saved to library", duration:3.0, position: .center)
                } else {
                    self.view.makeToast("Already in library.", duration:3.0, position: .center)
                }
            }
            button.backgroundColor = UIColor(hexString: "#34A853").withAlphaComponent(0.8)
        }
        tableView.reloadData()
        return [button]
    }
    
    
}

//MARK: - ==DATASOURCE==
extension MovieListVC : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.container.dataManager.movieList.count
    }
    

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        
            let movie = self.container.dataManager.movieList[indexPath.row]
            cell.imageView!.image = movie.poster
            cell.textLabel!.text = movie.title
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
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
        
        self.container.dataManager.movieList = self.moviesOnDisplay.filter(compoundPredicate)
        self.movieTable.reloadData()
        
    }
}




