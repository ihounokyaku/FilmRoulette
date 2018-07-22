//
//  TableVC.swift
//  
//
//  Created by Dylan Southard on 2018/07/22.
//

import UIKit




class TableVC: UITableViewController {
    var container:NavContainer!
    var folderList = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }



    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.folderList ? self.container.dataManager.allGroups.count : 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        if self.folderList {
            cell.textLabel?.text = self.container.dataManager.allGroups[indexPath.row].name
            cell.accessoryType = .disclosureIndicator
        }
        
        return cell
    }

}
