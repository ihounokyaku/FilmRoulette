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
    case movieList = "MovieList"
    case groups = "Groups"
    case groupTable = "GroupTable"
    case movieTable = "MovieTable"
    case settings = "Settings"
}



class NavContainer: UIViewController, VCContainerDelegate {
//MARK: - ===========IBOUTLETS============
    //MARK: - ==VIEWS==
    
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var containerView: VCContainer!
    
    
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
    
    var currentNavSubview:NavSubview {
        return self.containerView.currentSubview as! NavSubview
    }
    
    
     //MARK: - =========== SETUP ============
    
    //MARK: - ==Initial==
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK: Set Appearance
        self.setColors()
        self.setFonts()
        self.hideKeyboardWhenTapped()
//        self.hideKeyboardWhenTappedAround()
        //MARK: Load first
        self.containerView.transition(toVCWithIdentifier: .spinner, animated:false, sender:self)
        self.becomeFirstResponder()
    }
    
    //MARK: - === Set gesture ===
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            self.currentNavSubview.shake()
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        get {
            return true
        }
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
        
        self.containerView.transition(toVCWithIdentifier: VCIdentifier.allCases[sender.tag], sender: self)
        self.toggleButtons()
    }
    
    
    @IBAction func settingsPressed(_ sender: Any) {
        self.presentView(withIdentifier: .settings, masterDelegate: self)
    }
    
    
    func presentView(withIdentifier identifier:VCIdentifier, masterDelegate:UIViewController) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let controller = storyboard.instantiateViewController(withIdentifier: identifier.rawValue) as? ModalVC else {return}
        
        //MARK: Configure and Present VC
        controller.masterDelegate = masterDelegate
        controller.modalPresentationStyle = .popover
        self.present(controller, animated:true, completion:nil)
    }

    
    //MARK: - =========UI UPDATE===========
    func toggleButtons() {
        self.spinButton.isEnabled = self.containerView.currentSubview as? SpinVC == nil
        self.myListButton.isEnabled = self.containerView.currentSubview as? LibraryContainer == nil
        self.addButton.isEnabled = self.containerView.currentSubview as? SearchVC == nil
    }
    
    func getSelectorSelection(forSubviewOfType subview:VCIdentifier) {
        self.selector.selectItem(atIndex: UserDefaults.standard.value(forKey: subview.rawValue + "selectorPosition") as? Int ?? 0, animated:false)
    }
    
    func setSelectorSelection(forSubviewOfType subview:VCIdentifier) {
        UserDefaults.standard.set(self.selector.indexOfSelectedItem, forKey: subview.rawValue + "selectorPosition")
    }


}
