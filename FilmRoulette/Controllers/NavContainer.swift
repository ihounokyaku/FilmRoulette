//
//  NavContainer.swift
//  FilmSwipe
//
//  Created by Dylan Southard on 2018/06/11.
//  Copyright © 2018 Dylan Southard. All rights reserved.
//

import UIKit

enum VCIdentifier:String, CaseIterable {
    case spinner = "Spinner"
    case library = "Library"
    case search = "Search"
    case rouletteFilter = "RouletteFilter"
    case basicFilter = "BasicRouletteFilter"
    case advancedFilter = "AdvancedRouletteFilter"
}



class NavContainer: UIViewController {
//MARK: - ===========IBOUTLETS============
    //MARK: - ==VIEWS==
    
    @IBOutlet weak var subviewContainer: UIView!
    @IBOutlet weak var topView: UIView!
    
    
    //MARK: - ==BUTTONS==
   
    @IBOutlet weak var spinButton: UIButton!
    @IBOutlet weak var myListButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    
    @IBOutlet weak var topButton1: UIButton!
    @IBOutlet weak var topButton2: UIButton!
    @IBOutlet weak var topButton3: UIButton!
    
    @IBOutlet weak var selector: Selector!
    
    //MARK: - ==BUTTON LABELS ==
    @IBOutlet weak var topButtonLabel1: UILabel!
    @IBOutlet weak var topButtonLabel2: UILabel!
    @IBOutlet weak var topButtonLabel3: UILabel!
    
    
    //MARK: - =========== VARIABLES============
    
    var currentSubview:NavSubview!
    
    
     //MARK: - =========== SETUP ============
    
    //MARK: - ==Initial==
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK: Set Appearance
        self.setColors()
        self.setFonts()
        self.hideKeyboardWhenTapped()
//        self.hideKeyboardWhenTappedAround()
        //MARK: Load first VC
        self.transition(toVCWithIdentifier: .spinner, animated:false)
    }
    
    //MARK: - == Appearance ==
    func setColors() {
        self.topView.backgroundColor = UIColor().blackBackgroundPrimary()
    }
    
    func setFonts() {
        for label in [self.topButtonLabel1, self.topButtonLabel2, self.topButtonLabel3] {
            label!.font = Fonts.TopSelectorFont
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    
    //MARK: - =========BUTTON ACTIONS===========
    //MARK: - ==NavigationButtons==
    
    @IBAction func navButtonPressed(_ sender: UIButton){
        self.transition(toVCWithIdentifier: VCIdentifier.allCases[sender.tag])
    }
    
    
    //MARK: - =========PRESENT VC===========

    //MARK: - ==ANIMATE TRANSITION==
    func transition(toVCWithIdentifier identifier: VCIdentifier, animated:Bool = true) {
        let con = Conveniences()
        
        //MARK: Get destination VC and assign container
        let destinationVC = con.getSubview(identifier.rawValue) as! NavSubview
        destinationVC.container = self
        
        //MARK: Set alpha and position
        destinationVC.view.alpha = animated ? 0 : 1
        
        con.addAndPosition(viewController:destinationVC, toParent:self, inContainer: self.subviewContainer)
        self.currentSubview = destinationVC
        self.toggleButtons()
        
        //MARK: If not animated, remove subviews and return
        if !animated {
            con.removeSubviews(from:self.subviewContainer)
            return
        }
        
        //MARK: Animate Transition
        UIView.animate(withDuration:0.3, animations:{
            destinationVC.view.alpha = 1
            self.subviewContainer.subviews[0].alpha = 0
        }, completion: {(finished: Bool) in
            con.removeSubviews(from:self.subviewContainer)
        })
    }
    
    

    
    //MARK: - =========UI UPDATE===========
    func toggleButtons() {
        self.spinButton.isEnabled = self.currentSubview as? SpinVC == nil
        
        //self.myListButton.isEnabled = self.currentSubview as? LikedMoviesVC == nil
    }


}
