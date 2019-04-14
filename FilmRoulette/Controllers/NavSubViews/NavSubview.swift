//
//  NavSubview.swift
//  FilmSwipe
//
//  Created by Dylan Southard on 2018/06/11.
//  Copyright © 2018 Dylan Southard. All rights reserved.
//

import UIKit

class NavSubview: UIViewController, ContainerSubview, SelectorDelegate {
    
     //MARK: - =======Variables=======
    var container: VCContainerDelegate!
    var subViewType:VCIdentifier!
    
    
    var navContainer:NavContainer {
        return self.container as! NavContainer
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.hideKeyboardWhenTappedAround()
        // Do any additional setup after loading the view.
        self.becomeFirstResponder()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.configureSelector()
        
    }
    
    //MARK: - === Configure ===
    func shake(){print("shaky shaky")}
    //MARK: - === Set gesture ===
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            self.shake()
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        get {
            return true
        }
    }
    
    func configureSelector(){}
    
    func setSelector(buttonCount:Int, color:UIColor?, label1:String = "", label2:String = "", label3:String =  "") {
        self.navContainer.selector.isHidden = self.subViewType == .search
        let allButtons:[UIButton] = [self.navContainer.topButton3, self.navContainer.topButton2, self.navContainer.topButton1]
        guard buttonCount <= allButtons.count else {return}
        var buttons = [UIButton]()
        
        if buttonCount > 0 {
            for i in 1...buttonCount {
                buttons.append(allButtons[buttonCount - i])
            }
            self.navContainer.selector.configure(buttons:buttons, highlightColor: color ?? UIColor().offWhitePrimary(alpha:0.4), delegate:self)
        }
        
        self.navContainer.topButtonLabel1.text = label1
        self.navContainer.topButtonLabel2.text = label2
        self.navContainer.topButtonLabel3.text = label3
        
        self.navContainer.getSelectorSelection(forSubviewOfType: self.subViewType)
    }
    
    
    func selectionDidChange(sender: Selector) {
        if sender == self.navContainer.selector {
            self.navContainer.setSelectorSelection(forSubviewOfType: self.subViewType)
        }
    }
    
    func presentView(withIdentifier identifier:VCIdentifier) {
        self.navContainer.presentView(withIdentifier: identifier, masterDelegate: self)
    }
    
    func presentSingleMovieView<sender>(movie:Movie, imageData:Data?, filmSwipe:Bool, sender:sender) where sender:UIViewController, sender:SingleMovieDelegate {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let controller = storyboard.instantiateViewController(withIdentifier: "SingleMovie") as? SingleMovieVC else {return}
        
        //MARK: Configure and Present VC
        if !movie.imageExists {controller.posterData = imageData}
        controller.movie = movie
        controller.masterDelegate = sender
        controller.filmSwipe = filmSwipe
        //        controller.modalPresentationStyle = .popover
        sender.present(controller, animated:true, completion:nil)
    }
}




