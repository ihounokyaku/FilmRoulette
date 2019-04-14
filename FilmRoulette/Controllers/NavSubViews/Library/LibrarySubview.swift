//
//  LibrarySubview.swift
//  FilmRoulette
//
//  Created by Dylan Southard on 2019/04/02.
//  Copyright © 2019 Dylan Southard. All rights reserved.
//

import UIKit

enum TableCellType:String {
    case movie = "MovieListCell"
    case group = "GroupCell"
}

class LibrarySubview: UIViewController, ContainerSubview {
    

    //MARK: - =============== IBOUTLETS ===============
    var currentTableView:UITableView!
    
    
    
    //MARK: - =============== VARS ===============
    
    
    //MARK: - === OBJECTS ===
    var container: VCContainerDelegate!
    
    var libContainer: LibraryContainer {
        return self.container as! LibraryContainer
    }
    
    //MARK: - === Other Vars ===
    
    
    //MARK: - =============== SETUP ===============
    override func viewDidLoad() {
        super.viewDidLoad()
        self.libContainer.clearSearchbar()

        // Do any additional setup after loading the view.
    }
    
    func shake(){}
    
    
    //MARK: - === CONFIGURE UI ===
    func configure(tableView:UITableView, withCellOftype cellType:TableCellType) {
        self.currentTableView = tableView
        tableView.register(UINib(nibName: cellType.rawValue, bundle: nil), forCellReuseIdentifier: cellType.rawValue)
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
    }
    
    func toggleDisplay() {}
    
    
    //MARK: - SEARCHBAR FUNCTIONS
    
    func search(text:String) {}
    
    func clearSearch() {}

//MARK: - =============== TABLEVIEW ===============
func tableCellHeight(forTableView tableView:UITableView)->CGFloat {
    
    let frameWidth = Float(tableView.frame.width)
    
    if DeviceIsIpad {
        return 150
    }
    
    let number = Conveniences().valueFromRatio(ratioWidth: 375, ratioHeight: 81.5, width:frameWidth)
    
    return CGFloat(number)
    }
}
