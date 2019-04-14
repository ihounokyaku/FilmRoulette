//
//  TableVC.swift
//  
//
//  Created by Dylan Southard on 2018/07/22.
//

import UIKit
import RealmSwift
import SwipeCellKit
import Toast_Swift



class TableVC: UIViewController, UITableViewDataSource, UITableViewDelegate, SwipeTableViewCellDelegate {
    
    
    
    //MARK: - =========IBOUTLET============
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - ==========CONSTRAINTS==========
    @IBOutlet weak var tableViewTopConstraint: NSLayoutConstraint!
    
    //MARK: - =========VARS============
    
    //MARK: - === OBJECTS ===
    var controller:GroupListVC!
    var group:Group?
    
    //MARK: - === STATUS VARS ===
    var tableType:TableType = .group
    var cellType:TableCellType { return self.tableType == .group ? .group : .movie }
    
   
    //MARK: ===========SETUP==============
    override func viewDidLoad() {
        super.viewDidLoad()
        self.controller.libContainer.clearSearchbar()
        self.configureTable()
        
    }
    
    func configureTable() {
        self.controller.configure(tableView: self.tableView, withCellOftype: self.cellType)
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    
    //MARK: - =========NAVIGATION============
    
    
    func presentView(withIdentifier identifier:String, group:Group) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                guard let controller = storyboard.instantiateViewController(withIdentifier: identifier) as? TableVC else {return}
        
                //MARK: Configure and Present VC
                controller.group = group
        controller.tableType = .groupContents
        controller.controller = self.controller
                controller.modalTransitionStyle = .coverVertical
        controller.modalPresentationStyle = .fullScreen
        
                self.present(controller, animated:true, completion:nil)
    }
    
    //MARK: - =============== other ===============
    func undo(){}
    
    //MARK: - =============== TABLEVIEW ===============
    
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{return 0}

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell { return tableView.dequeueReusableCell(withIdentifier: self.cellType.rawValue)! }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions { return SwipeOptions()}
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {return []}
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {return self.controller.tableCellHeight(forTableView: tableView)}
    
    //MARK: - ==========SEARCH BAR==========
    
    func search(text:String) {}
    func clearSearch(){}
}
    
    
    //MARK: - ========TABLEVIEW DELEGATE===========
   






//extension TableVC: UISearchBarDelegate {
//
//
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        guard self.tableType == .library else {return}
//        if searchBar.text?.count == 0 {
//            DispatchQueue.main.async {
//                searchBar.resignFirstResponder()
//                self.movieResults = GlobalDataManager.allMovies
//                self.updateDataSource()
//            }
//        }
//
//        var predicates = [NSPredicate]()
//
//        predicates.append(NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!))
//        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
//
//        self.movieResults = GlobalDataManager.allMovies.filter(compoundPredicate)
//        print("searching")
//        self.updateDataSource()
//
//    }
//}
