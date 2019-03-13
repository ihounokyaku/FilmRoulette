//
//  foldersVC.swift
//  FilmRoulette
//
//  Created by Dylan Southard on 2018/07/22.
//  Copyright © 2018 Dylan Southard. All rights reserved.
//

import UIKit

enum TransitionDirection {
    case left
    case right
    case up
    case down
}

class GroupVC: NavSubview {
    
    //MARK - ==========IBOUTLETS===========
    
    @IBOutlet weak var tableContainer: UIView!
    
    @IBOutlet weak var containerView: UIView!
    
    
    //MARK: - ==BUTTONS==
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    
    
    //MARK: - ========= VARS ============
    var tableView:TableVC!
    var previousTableView:TableVC?
    
    //MARK: - ========== SETUP ============
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateUI()
        //self.transition(toVCWithIdentifier: "TableVC", animated: false)
    }
    
    
    //MARK: - ==========UI============
    func updateUI() {
        self.addButton.isHidden = self.tableView.tableType == .library
        self.backButton.isHidden = self.tableView.tableType == .group
        self.backButton.isEnabled = !(self.tableView.tableType == .group)
        self.addButton.isEnabled = !(self.tableView.tableType == .library)
    }
    
    //MARK: - =========NAVIGATION===========
    
    //MARK: - ==BACK==
    @IBAction func backPressed(_ sender: Any) {
        self.backButton.isEnabled = false
        self.dismissView()
        
    }
    
   // MARK: - ==ANIMATE TRANSITION==
    func loadTableVC (ofType type: TableType, direction:TransitionDirection, group:Group?) {
        let xValue = direction == .left ? self.view.frame.width : 0
        let yValue = direction == .down ? -self.view.frame.height : 0
        let endingValue = direction == .left ? -self.view.frame.width : self.view.frame.height
        
        //MARK: get controller
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        self.tableView = storyboard.instantiateViewController(withIdentifier: "TableVC") as! TableVC
        
        //MARK: Assign Values
        self.tableView.delegate = self
        self.tableView.tableType = type
        self.tableView.group = group
        
        self.addChildViewController(self.tableView)
        self.tableView.view.frame = CGRect(x: xValue, y: yValue, width: self.containerView.frame.size.width, height:self.containerView.frame.size.height)
        self.containerView.addSubview(self.tableView.view)
        self.tableView.didMove(toParentViewController: self)
        
        //MARK: Animate Transition
        
            UIView.animate(withDuration:0.3, animations:{
                if direction == .down {
                    self.tableView.view.center.y += endingValue
                } else {
                    self.tableView.view.center.x += endingValue
                }
                
            }, completion: {(finished: Bool) in
               self.updateUI()
            })
    }
    
    func dismissView() {
        UIView.animate(withDuration:0.3, animations:{
            if self.tableView.tableType == .groupContents {
                self.tableView.view.center.x += self.view.frame.width
            } else {
                self.tableView.view.center.y -= self.view.frame.height
            }
        }, completion: {(finished: Bool) in
            let index = self.containerView.subviews.count - 1
            self.containerView.subviews[index].removeFromSuperview()
            if self.childViewControllers.count > 1 {
                 self.childViewControllers.last!.removeFromParentViewController()
            }
            self.tableView = self.childViewControllers.last as! TableVC
            self.tableView.tableView.reloadData()
            self.updateUI()
            
        })
    }


    //MARK: - ========== NEW ============
    
    @IBAction func addPressed(_ sender: Any) {
        
        if self.tableView.tableType == .group {
            self.newFolder()
        } else {
            self.addButton.isEnabled = false
            self.loadTableVC(ofType: .library, direction: .down, group: self.tableView.group)
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
            if newField.text! != "" && GlobalDataManager.folder(withName: newField.text!) == nil{
                let folder = Group()
                folder.name = newField.text!
                if let error = GlobalDataManager.save(object: folder) {
                    self.view.makeToast(error)
                } else {
                    self.tableView.tableView.reloadData()
                }
            }
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? TableVC, segue.identifier == "EmbedSegue" {
            vc.delegate = self
            if let view = self.tableView, view.tableType == .group {
                vc.tableType = .groupContents
                vc.group = self.tableView.group
            }
            self.tableView = vc
        }
    }
}
