//
//  SearchVC.swift
//  FilmSwipe
//
//  Created by Dylan Southard on 2018/06/24.
//  Copyright © 2018 Dylan Southard. All rights reserved.
//

import UIKit

class SearchVC: NavSubview, SingleMovieDelegate{
    

    //MARK: - ==========IBOUTLETS===========
    
    @IBOutlet weak var searchBar: SearchBar!
    @IBOutlet weak var tableView: CustomTableView!
    @IBOutlet weak var progressBar: UIProgressView!
    
    
    //MARK: - ==========VARIABLES===========
    let queryType:QueryType = .search
    let queryManager = QueryManager()
    
    
    
    //MARK: - == ARRAYS ==
    var moviesToDisplay = [Movie]()
    
    //MARK: - ==========SETUP===========
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK: DELEGATES
        self.searchBar.delegate = self
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.queryManager.delegate = self
        //MARK: TableSetup
        self.tableView.register(UINib(nibName: "MovieListCell", bundle: nil), forCellReuseIdentifier: "MovieListCell")
        self.tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        //self.container.selector.isHidden = true
        
        self.setColors()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.tableView.displayImage(ofType: .search)
    }
    
    func setColors() {
        self.progressBar.tintColor = UIColor().colorTextEmphasis()
        self.searchBar.backgroundColor = UIColor().blackBackgroundPrimary()
        self.searchBar.barTintColor = UIColor().blackBackgroundPrimary()
        
    }
    
    

   //MARK: ================Update UI======================
    func updateUI() {
        self.tableView.reloadData()
    }
    
    //MARK: ==Hide Keyboard==
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func updateProgressBar(by progress:Float) {
        self.progressBar.progress += progress
    }
    
    func setProgressBar(to location: Float) {
        self.progressBar.progress = location
    }

}


//MARK: ================SearchBar methods======================

extension SearchVC : UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        guard self.searchBar.text! != "" else {return}
        self.queryManager.cancelAllCurrentQueries()
        self.tableView.reloadData()
        self.moviesToDisplay.removeAll()
        self.tableView.reloadData()
        self.queryManager.beginSearch(forTerm: self.searchBar.text!)
        self.view.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
                self.view.endEditing(true)
                
            }
        }
    }
}

//MARK: ================Tableview methods======================

extension SearchVC : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.moviesToDisplay.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let frameWidth = Float(self.tableView.frame.width)
        let number = Conveniences().valueFromRatio(ratioWidth: 375, ratioHeight: 81.5, width:frameWidth)
        return CGFloat(number)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieListCell") as! MovieListCell
        
        let movie = self.moviesToDisplay[indexPath.row]
        
        cell.showButton = false
        cell.indexPath = indexPath
        cell.config(title: movie.title, releaseYear: movie.releaseDate.year(), poster: Conveniences().imageFromData(data: SessionData.Posters[movie.id]))
        
        return cell
    }
}

extension SearchVC : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let movie = self.moviesToDisplay[indexPath.row]
        Conveniences().presentSingleMovieView(movie: movie, imageData: SessionData.Posters[movie.id], sender: self)
        
    }
}

extension SearchVC : QueryDelegate {
    

    
    func refreshDisplay() {
        if self.moviesToDisplay.count == 0 {
            self.tableView.displayImage(ofType: .noResults)
        } else {
            self.tableView.removeImage()
        }
        self.tableView.reloadData()
    }
    
    func handleNoResults() {
        self.refreshDisplay()
    }
    
    
    var navContainer: NavContainer {
        get {
            return self.container
        }
    }
}
