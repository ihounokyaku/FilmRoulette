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

enum TableType {
    case group
    case groupContents
    case library
}


class TableVC: UIViewController, UITableViewDataSource, UITableViewDelegate, SwipeTableViewCellDelegate {
    
    //MARK: - =========IBOUTLET============
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - ==========CONSTRAINTS==========
    @IBOutlet weak var tableViewTopConstraint: NSLayoutConstraint!
    
    //MARK: - =========VARS============
    var delegate:GroupVC!
    var group:Group?
    var tableType:TableType = .group
    var movieResults:Results<Movie>!
    var movieDataSource = List<Movie>()
   
    //MARK: ===========SETUP==============
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.tableType == .library {
            self.searchBar.delegate = self
        }
        
    }
    
    //MARK: ==FILL ARRAYS==
    override func viewWillAppear(_ animated: Bool) {
        if self.tableType != .library {
            self.searchBar.isHidden = true
            self.tableViewTopConstraint.constant -= self.searchBar.frame.height
            
        }
        self.setTableData()
        
        super.viewWillAppear(true)
    }
    
    func setTableData(){
        switch self.tableType {
        case .groupContents:
            guard let group = self.group else {return}
            self.movieDataSource = group.movies
        case .library:
            self.movieResults = GlobalDataManager.allMovies
            self.updateDataSource()
            let _ = self.movieResults.observe{notification in
                self.updateDataSource()
            }
            
        default:
            break
        }
    }
    
    
    //MARK: - ========= UPDATE LIST FROM RESULTS=========
    func updateDataSource() {
        let movies = List<Movie>()
        guard let group = self.group else {return}
        
        for result in self.movieResults {
            
            if !group.movies.map({return $0.id}).contains(result.id) {
                print("movies does not contain \(result.title)")
                movies.append(result)
            }
        }
        
        self.movieDataSource = movies
        self.tableView.reloadData()
    }
    
    //MARK: - =========NAVIGATION============
    
    
    func presentView(withIdentifier identifier:String, group:Group) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                guard let controller = storyboard.instantiateViewController(withIdentifier: identifier) as? TableVC else {return}
        
                //MARK: Configure and Present VC
                controller.group = group
        controller.tableType = .groupContents
        controller.delegate = self.delegate
                controller.modalTransitionStyle = .coverVertical
        controller.modalPresentationStyle = .fullScreen
        
                self.present(controller, animated:true, completion:nil)
    }
    
    // MARK: - Table view data source

   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.tableType == .group {return GlobalDataManager.allGroups.count}
        print("table type is \(self.tableType)")
        return self.movieDataSource.count

    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! SwipeTableViewCell
        cell.delegate = self
        if self.tableType == .group {
            cell.textLabel?.text = GlobalDataManager.allGroups[indexPath.row].name
            cell.accessoryType = .disclosureIndicator
            return cell
        }
        
        let movie = self.movieDataSource[indexPath.row]
        cell.textLabel?.text = movie.title
        cell.imageView?.image = movie.poster
        
        return cell
    }
    
    
    
    //MARK: - ========TABLEVIEW DELEGATE===========
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if self.tableType == .group {
            let group = GlobalDataManager.allGroups[indexPath.row]
            self.delegate.loadTableVC(ofType: .groupContents, direction: .left, group: group)
        }
    }
    
    //MARK: - ==SwipeControl==
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        var actions = [SwipeAction]()
        
        if self.tableType == .library {
           guard let group = self.group else {return nil}
            actions.append(SwipeAction(style: .default, title: "Add") { (action, indexPath) in
                if let error = GlobalDataManager.add(self.movieDataSource[indexPath.row], toGroup: group) {
                    self.view.makeToast(error)
                } else {
                    self.updateDataSource()
                }
                
            })
        } else {
            guard let group = self.group else {return nil}
            actions.append(SwipeAction(style: .destructive, title: "delete") { (action, indexPath) in
                guard group.movies.count > indexPath.row else {return}
                do {
                    try GlobalDataManager.realm.write {
                        group.movies.remove(at: indexPath.row)
                        self.setTableData()
                    }
                    
                } catch let error {
                    print("error deleting \(error.localizedDescription)")
                }
                
            })
        }
        return actions
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        if self.tableType == .library {
            options.expansionStyle = .selection
        } else {
            options.expansionStyle = .destructive
        }
        
        options.transitionStyle = .border
        return options
    }
}


//MARK: - ==========SEARCH BAR==========
extension TableVC: UISearchBarDelegate {
//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//
//        guard self.searchBar.text! != "" else {return}
//
//        self.tableView.reloadData()
//    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard self.tableType == .library else {return}
        if searchBar.text?.count == 0 {
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
                self.movieResults = GlobalDataManager.allMovies
                self.updateDataSource()
    
            }
        }
        
        var predicates = [NSPredicate]()
        
        predicates.append(NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!))
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        
        self.movieResults = GlobalDataManager.allMovies.filter(compoundPredicate)
        print("searching")
        self.updateDataSource()
        
    }
}
