//
//  LibaryContainer.swift
//  FilmRoulette
//
//  Created by Dylan Southard on 2019/04/02.
//  Copyright © 2019 Dylan Southard. All rights reserved.
//

import UIKit
import RealmSwift

enum LibraryDisplayType:String, CaseIterable {
    case library = "My Library"
    case filmSwipe = "FilmSwipe"
    case groups = "Groups"
}

class LibraryContainer: NavSubview, VCContainerDelegate, SingleMovieDelegate, SpinFiltersDelegate {
    
    
    //MARK: - =============== IBOUTLETS ===============
    var subview:LibrarySubview {
        return self.containerView.currentSubview as! LibrarySubview
    }
    
    //MARK: - === VIEWS ===
    @IBOutlet weak var containerView: VCContainer!
    @IBOutlet weak var topView: UIView!
    
    //MARK: - === COMPONENTS ===
    @IBOutlet weak var searchBar: SearchBar!
    
    
    
    //MARK: - =============== VARS ===============

    
    //MARK: - === STATE VARIABLES ===
    var libraryType:LibraryDisplayType {
        return LibraryDisplayType.allCases[self.navContainer.selector.indexOfSelectedItem]
    }
    
    var filterObject: Object? {
        didSet {
            if let groupVC = self.containerView.currentSubview as? GroupListVC {
                groupVC.filterObject = self.filterObject
            }
        }
    }
    
    var firstLoad = true
    
    
    
    //MARK: - =============== SETUP ===============
    
    
    //MARK: - === VIEWS ===
    override func viewDidLoad() {
        super.viewDidLoad()
        self.subViewType = .library
        self.searchBar.delegate = self
        self.setColors()
        
    }

    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(true)
        if self.firstLoad {
            self.containerView.transition(toVCWithIdentifier: self.navContainer.selector.indexOfSelectedItem == 2 ? .groups : .movieList, animated:false, sender: self)
            self.firstLoad = false
        }
        
    }

    
    
    //MARK: - == UI CONFIG ==
    override func configureSelector() {
        self.setSelector(buttonCount: 3, color: UIColor.SelectorWhite, label1: "My Library", label2:"FilmSwipe", label3: "Groups")
    }
    
    
    func setColors() {
        self.topView.backgroundColor = UIColor().blackBackgroundPrimary()
        self.searchBar.backgroundColor = UIColor().blackBackgroundPrimary()
        self.searchBar.barTintColor = UIColor().blackBackgroundPrimary()
    }
    
    //MARK: - === SET MOTIONS ===
    override func shake() { self.subview.shake() }
    
    //MARK: - =============== ACTION HANDLERS ===============
    override func selectionDidChange(sender: Selector) {
        super.selectionDidChange(sender: sender)
        
        if sender.indexOfSelectedItem == 2 {
            self.containerView.transition(toVCWithIdentifier: .groups, sender: self)
        } else {
            if self.subview as? MovieListVC != nil {
                self.subview.toggleDisplay()
            } else {
                self.containerView.transition(toVCWithIdentifier: .movieList, sender: self)
            }
        }
        
    }
    
    
    
    //MARK: - =============== NAVIGATION ===============
    
    func backFromSingleMovie(changed: Bool) {
        let contentOffset = self.subview.currentTableView.contentOffset
        self.subview.currentTableView.reloadData()
        self.subview.currentTableView.setContentOffset(contentOffset, animated: false)
    }
}



//MARK: - =============== SEARCHBAR ===============

extension LibraryContainer : UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        guard self.searchBar.text! != "" else {return}
        self.subview.search(text: self.searchBar.text!)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchBar.text?.count == 0 {
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
                self.subview.clearSearch()
            }
        }
        
        self.subview.search(text: searchBar.text!)
    }
    
    func clearSearchbar() {
        self.searchBar.text = ""
    }
}

