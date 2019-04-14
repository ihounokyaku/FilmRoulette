//
//  SettingsContainer.swift
//  FilmSwipe
//
//  Created by Dylan Southard on 2018/10/18.
//  Copyright © 2018 Dylan Southard. All rights reserved.
//

import UIKit

class SettingsContainer: ModalVC {
//    var splashView: SplashView?
    
    //MARK: - =============== IBOUTLETS ===============
    
    
    //MARK: - === VIEWS ===
   
    @IBOutlet weak var tableContainer: UIView!
    @IBOutlet weak var topView: UIView!
    
    //MARK: - === LABELS ===
    
     @IBOutlet weak var topLabel: UILabel!
    
    //MARK: - === BUTTONS ===
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    
    
    
    //MARK: - =============== VARS ===============
    
    //MARK: - === OBJECTS ===
    var delegate:NavContainer {
        return self.masterDelegate as! NavContainer
    }
    var mainTable:SettingsTable!

    
    //MARK: - === STATE VARIABLES ===
    var settingsChanged = false
    var annihilated = false
    

    
    //MARK: - =============== SETUP ===============
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setColors()
        self.setFonts()
    }
    
    //MARK: - === UI SETUP  ===
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func setColors(){
        self.topView.backgroundColor = UIColor().blackBackgroundPrimary()
        self.doneButton.backgroundColor = UIColor().blackBackgroundPrimary()
    }
    
    func setFonts() {
        self.doneButton.titleLabel?.font = Fonts.DoneButton
        self.topLabel.font = Fonts.SubviewHeader
    }
    
    
    
    //MARK: - =============== BUTTON ACTIONS ===============
    
    @IBAction func backPressed(_ sender: Any) {
        
            self.dismissed()

        
    }
    
    @IBAction func donePressed(_ sender: Any) {
        self.dismissed()
    }
    
    @IBAction func helpButtonPressed(_ sender: Any) {
//        Conveniences().presentSplashView(ofType: .tutorial, sender: self, container: self.view)
    }

    
    //MARK: - =============== NAVIGATION ===============
    func dismissed() {
        
        
        self.dismiss(animated: true) {
            //after dismissal
            
            if self.settingsChanged {
               
                self.delegate.containerView.transition(toVCWithIdentifier: self.delegate.currentNavSubview.subViewType, animated: false, sender: self.delegate)
                
            }
        }
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SettingsTableSegue" {
            guard let vc = segue.destination as? SettingsTable else {return}
            vc.container = self
            self.mainTable = vc
        }
    }
}
