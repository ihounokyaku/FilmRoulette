//
//  TableVC.swift
//  
//
//  Created by Dylan Southard on 2018/07/22.
//

import UIKit




class TableVC: UITableViewController {
    var delegate:GroupVC!
    var group:Group?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }



    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.group == nil ? self.delegate.container.dataManager.allGroups.count : self.group!.movies.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        if let group = self.group {
            let movie = group.movies[indexPath.row]
            cell.textLabel?.text = movie.title
            cell.imageView?.image = movie.poster
        } else {
            cell.textLabel?.text = self.delegate.container.dataManager.allGroups[indexPath.row].name
            cell.accessoryType = .disclosureIndicator
        }
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let group = self.group {
            
        } else {
            let group = self.delegate.container.dataManager.allGroups[indexPath.row]
            self.delegate.transition(toVCWithIdentifier: "TableVC", group: group, animated: true)
        }
    }

}
