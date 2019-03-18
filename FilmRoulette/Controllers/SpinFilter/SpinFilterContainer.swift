//
//  SpinFilterContainer.swift
//  FilmRoulette
//
//  Created by Dylan Southard on 2019/03/17.
//  Copyright © 2019 Dylan Southard. All rights reserved.
//

import UIKit
import RealmSwift

protocol SpinFiltersDelegate {
    var filterType:FilterType {get}
    func filterResults(withObject object:Object?)
}

enum FilterType:CaseIterable {
    case simple
    case complex
}

class SpinFilterContainer: UIViewController,SelectorDelegate {

    //MARK: - =============== IBOUTLETS ===============
    
    @IBOutlet weak var selector: Selector!
    @IBOutlet weak var subviewContainer: UIView!
    
    //MARK: - == BUTTONS ==
    @IBOutlet weak var basicButton: UIButton!
    @IBOutlet weak var advancedButton: UIButton!
    
    
    //MARK: - =============== VARS ===============
    var delegate:SpinFiltersDelegate!
    
    var filterObject:Object?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.selector.configure(buttons: [self.basicButton, self.advancedButton], highlightColor: UIColor().whitePrimary(alpha: 0.4), delegate: self)
        self.selector.selectItem(atIndex: Prefs.SpinFilterType)
        self.loadSubview(animated: false)
    }
    
    func loadSubview(animated:Bool) {
        self.transition(toVCWithIdentifier: Prefs.SpinFilterType == 0 ? .basicFilter : .advancedFilter, animated:animated)
    }
    
    func transition(toVCWithIdentifier identifier: VCIdentifier, animated:Bool = true) {
        let con = Conveniences()
        
        //MARK: Get destination VC and assign container
        let destinationVC = con.getSubview(identifier.rawValue) as! SpinFilterSubview
        destinationVC.container = self
        
        //MARK: Set alpha and position
        destinationVC.view.alpha = animated ? 0 : 1
        
        con.addAndPosition(viewController:destinationVC, toParent:self, inContainer: self.subviewContainer)
        
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
    
    @IBAction func donePressed(_ sender: Any) {
        self.delegate.filterResults(withObject: self.filterObject)
        self.dismiss(animated: true, completion: nil)
    }

}
