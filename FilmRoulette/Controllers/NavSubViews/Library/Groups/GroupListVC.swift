//
//  GroupListVC.swift
//  FilmRoulette
//
//  Created by Dylan Southard on 2019/04/02.
//  Copyright © 2019 Dylan Southard. All rights reserved.
//

import UIKit


enum TableType:String {
    case group
    case groupContents
    case library
}

enum TransitionDirection {
    case left
    case right
    case up
    case down
}

class GroupListVC: LibrarySubview {
    
    var filterObject: FilterObject? {
        didSet {
            self.currentTableVC.tableView.reloadData()
        }
    }
    
    
    //MARK: - =============== IBOUTLETS ===============
    
    
    //MARK: - === VIEWS ===
    @IBOutlet weak var containerView: UIView!
    
    //MARK: - === BUTTONS ===
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    //MARK: - === LABELS ===
    @IBOutlet weak var groupLabel: UILabel!
    @IBOutlet weak var backArrow: UIImageView!
    
    
    //MARK: - =============== VARS ===============
    
    
    //MARK: - === OBJECTS ===
    
    var currentTableVC:TableVC! {didSet {self.currentTableView = self.currentTableVC.tableView}}

    
    //MARK: - === STATE VARIABLE ===
    
    var tableType:TableType = .group
    
    
    //MARK: - =============== SETUP ===============
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadTableVC(ofType: .group, direction: nil, group: nil)
        
    }
    
   
    override func shake() {
        self.currentTableVC.undo()
    }
    
    //MARK: - == CONFIGURE UI ==
    override func toggleDisplay() {
        let display = self.currentTableVC.tableType
        self.backButton.isHidden = display == .group
        self.backArrow.isHidden = display == .group
        self.backButton.isEnabled = display != .group
        self.addButton.setImage(display == .library ? Images.Filter : Images.Plus, for: .normal)
        self.addButton.imageView?.contentMode = .scaleAspectFit
        var labelText = "Groups"
        switch self.currentTableVC.tableType {
        case .library:
            labelText = "Add Movie"
        case .groupContents:
            labelText = self.currentTableVC.group!.name
        default:
            break
        }
        self.groupLabel.text = labelText
        
    }
    
    
    //MARK: - =============== ADD ACTIONS ===============
    
    @IBAction func addPressed(_ sender: Any) {
        
        switch self.currentTableVC.tableType {
        case .group:
            self.newGroup()
        case .groupContents:
            self.loadTableVC(ofType: .library, direction: .down, group: self.currentTableVC.group)
        case .library:
            guard let navSub = self.container as? NavSubview else {return}
            navSub.presentView(withIdentifier: .rouletteFilter)
        }
    }
    
    //MARK: - === ADD MOVIE ===
    
    
    
    //MARK: - === NEW GROUP ===
    
    func newGroup() {
        var newField:UITextField!
        let alert = UIAlertController(title: "Add New Group", message: "", preferredStyle: .alert)
        alert.addTextField {
            (textField) in
            newField = textField
        }
        
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { (action) in
            if newField.text! != "" && Group.Named(newField.text!) == nil{
                let group = Group(name: newField.text!)
                SQLDataManager.Insert(object: group)
                self.currentTableVC.tableView.reloadData()
                
            } else {
                self.view.makeToast("Please choose a unique group name")
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    //MARK: - =============== NAVIGATION ===============
    
    //MARK: - === TRANSITION TO VC  ===
    func loadTableVC (ofType type: TableType, direction:TransitionDirection?, group:Group?) {
        print("loading table of type \(type)")
        let xValue = direction == .left ? self.view.frame.width : 0
        let yValue = direction == .down ? -self.view.frame.height : 0
        let endingValue = direction == .left ? -self.view.frame.width : self.view.frame.height
        
        //MARK: get controller
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let identifier = type == .group ? "GroupTable" : "MovieTable"
        self.currentTableVC = (storyboard.instantiateViewController(withIdentifier: identifier) as! TableVC)
        
        
        //MARK: Assign Values
        self.currentTableVC.controller = self
        self.currentTableVC.tableType = type
        self.currentTableVC.group = group
        
        self.addChild(self.currentTableVC)
        self.currentTableVC.view.frame = CGRect(x: xValue, y: yValue, width: self.containerView.frame.size.width, height:self.containerView.frame.size.height)
        self.containerView.addSubview(self.currentTableVC.view)
        self.currentTableVC.didMove(toParent: self)
        
        //MARK: Animate Transition
        if direction != nil {
            UIView.animate(withDuration:0.3, animations:{
                if direction == .down {
                    self.currentTableVC.view.center.y += endingValue
                } else {
                    self.currentTableVC.view.center.x += endingValue
                }
                
            }, completion: {(finished: Bool) in
                self.finishTransition()
            })
        } else {
            self.finishTransition()
        }
    }
    
    
    func finishTransition() {
        //TODO: CLEAR FIlTERS
        if self.currentTableVC.tableType != .library {
            self.filterObject = nil
        }
        self.toggleDisplay()
    }
    //MARK: - === BACK ===
    
    @IBAction func backPressed(_ sender: Any) {
        self.backButton.isEnabled = false
        self.dismissView()
        
    }
    
    func dismissView() {
        UIView.animate(withDuration:0.3, animations:{
            if self.currentTableVC.tableType == .groupContents {
                self.currentTableVC.view.center.x += self.view.frame.width
            } else {
                self.currentTableVC.view.center.y -= self.view.frame.height
            }
        }, completion: {(finished: Bool) in
            let index = self.containerView.subviews.count - 1
            self.containerView.subviews[index].removeFromSuperview()
            if self.children.count > 1 {
                self.children.last!.removeFromParent()
            }
            self.currentTableVC = (self.children.last as! TableVC)
            self.currentTableVC.tableView.reloadData()
            self.toggleDisplay()
        })
    }
    

    
    
    
    //MARK: - =============== SEARCH BAR ===============
    
    override func search(text: String) { self.currentTableVC.search(text: text) }
    
    override func clearSearch() { self.currentTableVC.clearSearch() }
}
