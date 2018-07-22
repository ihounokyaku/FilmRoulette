//
//  NavContainer.swift
//  FilmSwipe
//
//  Created by Dylan Southard on 2018/06/11.
//  Copyright © 2018 Dylan Southard. All rights reserved.
//

import UIKit

class NavContainer: UIViewController {
//MARK: - ===========IBOUTLETS============
    //MARK: - ==VIEWS==
    
    @IBOutlet weak var subviewContainer: UIView!
    
    
    //MARK: - ==BUTTONS==
   
    @IBOutlet weak var spinButton: UIButton!
    @IBOutlet weak var myListButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    
    
    //MARK: - =========== VARIABLES============
    
    var currentSubview:NavSubview!
    
    //MARK: - ==MANAGERS==

    var dataManager = DataManager()
    
     //MARK: - =========== SETUP ============
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK: Load first VC
        self.transition(toVCWithIdentifier: "Spinner", animated:false)
    }
    
    //MARK: - =========BUTTON ACTIONS===========
    //MARK: - ==NavigationButtons==
    @IBAction func spinPressed(_ sender: Any) {
        self.transition(toVCWithIdentifier: "Spinner")
    }
    
    @IBAction func myListPressed(_ sender: Any) {
        self.transition(toVCWithIdentifier: "Library")
    }
    
    @IBAction func addPressed(_ sender: Any) {
        self.transition(toVCWithIdentifier: "Search")
    }
    
    @IBAction func myGroupsPressed(_ sender: Any) {
        self.transition(toVCWithIdentifier: "GroupVC")
    }
    
    
    //MARK: - =========PRESENT VC===========

    //MARK: - ==ANIMATE TRANSITION==
    func transition(toVCWithIdentifier identifier: String, animated:Bool = true) {
        
        //MARK: Get destination VC and assign container
        let destinationVC = self.getSubview(identifier) as! NavSubview
        destinationVC.container = self
        
        //MARK: Set alpha and position
        destinationVC.view.alpha = animated ? 0 : 1
        
        self.addAndPosition(viewController:destinationVC, toParent:self, inContainer: self.subviewContainer)
        self.currentSubview = destinationVC
        self.toggleButtons()
        
        //MARK: If not animated, remove subviews and return
        if !animated {
            self.removeSubviews(from:self.subviewContainer)
            return
        }
        
        //MARK: Animate Transition
        UIView.animate(withDuration:0.3, animations:{
            destinationVC.view.alpha = 1
            self.subviewContainer.subviews[0].alpha = 0
        }, completion: {(finished: Bool) in
            self.removeSubviews(from:self.subviewContainer)
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
    
    //MARK: - ==REMOVE SUBVIEWS==
    func removeSubviews (from container:UIView) {
            while container.subviews.count > 1 {
                container.subviews[0].removeFromSuperview()
            }
    }
    
    //MARK: - =========UI UPDATE===========
    func toggleButtons() {
        self.spinButton.isEnabled = self.currentSubview as? SpinVC == nil
        //self.myListButton.isEnabled = self.currentSubview as? LikedMoviesVC == nil
    }


}
