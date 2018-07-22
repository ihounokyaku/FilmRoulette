//
//  foldersVC.swift
//  FilmRoulette
//
//  Created by Dylan Southard on 2018/07/22.
//  Copyright © 2018 Dylan Southard. All rights reserved.
//

import UIKit

class GroupVC: NavSubview {
    
    //MARK - ==========IBOUTLETS===========
    
    @IBOutlet weak var tableContainer: UIView!
    
    
    //MARK: - ========= VARS ============
    var tableView:TableVC!
    
    
    //MARK: - ========== SETUP ============
    override func viewDidLoad() {
        super.viewDidLoad()
        self.transition(toVCWithIdentifier: "TableVC", animated: false)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: - =========PRESENT TABLE===========
    
    //MARK: - ==ANIMATE TRANSITION==
    func transition(toVCWithIdentifier identifier: String, animated:Bool = true) {
        
        //MARK: Get destination VC and assign container
        let destinationVC = self.getSubview(identifier) as! TableVC
        //destinationVC.container = self
        
        //MARK: Set alpha and position
        destinationVC.view.alpha = animated ? 0 : 1
        destinationVC.container = self.container
        self.addAndPosition(viewController:destinationVC, toParent:self, inContainer: self.tableContainer)
        self.tableView = destinationVC
        
        //MARK: If not animated, remove subviews and return
        if !animated {
            return
        }
        
        //MARK: Animate Transition
        UIView.animate(withDuration:0.3, animations:{
            destinationVC.view.alpha = 1
            self.tableContainer.subviews[0].alpha = 0
        }, completion: {(finished: Bool) in
            
        })
    }
    
    //MARK: - ==GET VC==
    func getSubview (_ identifier:String)-> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: identifier)
    }
    
    //MARK: - ==CALL THAT VC UP==
    func addAndPosition(viewController:UIViewController, toParent parent:UIViewController, inContainer container:UIView) {
        parent.addChildViewController(viewController)
        container.addSubview(viewController.view)
        viewController.didMove(toParentViewController: self)
        viewController.view.frame = CGRect(x: 0, y: 0, width: container.frame.size.width, height:container.frame.size.height)
    }


    //MARK: - ========== NEW ============
    
    @IBAction func addPressed(_ sender: Any) {
        if self.tableView.folderList {
            self.newFolder()
        }
    }
    
    func newFolder() {
        var newField:UITextField!
        let alert = UIAlertController(title: "Add New Group", message: "", preferredStyle: .alert)
        alert.addTextField {
            (textField) in
            newField = textField
        }
        
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { (action) in
            if newField.text! != "" && self.container.dataManager.folder(withName: newField.text!) == nil{
                let folder = Group()
                folder.name = newField.text!
                if let error = self.container.dataManager.save(object: folder) {
                    self.view.makeToast(error)
                } else {
                    self.tableView.tableView.reloadData()
                }
            }
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
}
