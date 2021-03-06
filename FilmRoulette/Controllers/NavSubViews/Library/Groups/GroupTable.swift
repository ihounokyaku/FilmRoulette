//
//  GroupTable.swift
//  FilmRoulette
//
//  Created by Dylan Southard on 2019/04/03.
//  Copyright © 2019 Dylan Southard. All rights reserved.
//

import UIKit

import SwipeCellKit


class GroupTable: TableVC {
    
    //MARK: - =============== VARS ===============
    
    //MARK: - === DATASOURCE ===
    var dataSource:[Group] {
        print("going to retrun groups")
        print("going to retrun groups \(SQLDataManager.AllGroups.count)")
        return self.filteredGroups ?? SQLDataManager.AllGroups }
    var filteredGroups:[Group]?

    
    //MARK: - === UNDO ===
    var deletedGroup:Group?
    
    //MARK: - =============== SETUP ===============
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
       
    }
    
  
    
    //MARK: - =============== UNDO ===============
    
    override func undo(){
        
        guard let group = self.deletedGroup else {return}
        group.resuurect()
        self.view.makeToast("Undo")
        self.deletedGroup = nil
        self.tableView.reloadData()
    }
    
    //MARK: - =============== TABLEVIEW ===============
    
    //MARK: - === DATASOURCE ===
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellType.rawValue) as! GroupCell
        
        let group = self.dataSource[indexPath.row]
        
        cell.setImages(fromMovies: Array(group.movies))
        cell.cellLabel?.text = group.name
        cell.delegate = self
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    
    //MARK: - ==SwipeControl==
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        var actions = [SwipeAction]()
        
            actions.append(SwipeAction(style: .destructive, title: "delete") { (action, indexPath) in
                let group = self.dataSource[indexPath.row]
                self.deletedGroup =  Group(value:group)
                SQLDataManager.Delete(object: group)
                self.view.makeToast("Group Deleted (shake to undo)")
            })
        
        return actions
    }
//
    override func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        if self.tableType == .library {
            options.expansionStyle = .selection
        } else {
            options.expansionStyle = .destructive
        }

        options.transitionStyle = .border
        return options
    }

    
    
    //MARK: - === DELEGATE ===
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let group = dataSource[indexPath.row]
        
        self.controller.loadTableVC(ofType: .groupContents, direction: .left, group: group)
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    //MARK: - ==========SEARCH BAR==========
    
    override func search(text:String) {
        
        self.filteredGroups = SQLDataManager.AllGroups.filteredBy(text: text)
        
        self.tableView.reloadData()
    }
    override func clearSearch(){
        self.filteredGroups = nil
        self.tableView.reloadData()
    }
    
    
}


