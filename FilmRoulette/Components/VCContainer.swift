//
//  VCContainer.swift
//  FilmRoulette
//
//  Created by Dylan Southard on 2019/04/02.
//  Copyright © 2019 Dylan Southard. All rights reserved.
//

import UIKit


protocol ContainerSubview {
    var container:VCContainerDelegate! {get set}
}

protocol VCContainerDelegate {
    var containerView: VCContainer! {get}
    
}

class VCContainer: UIView {
    
    var currentSubview:ContainerSubview?
   
    
    func transition(toVCWithIdentifier identifier: VCIdentifier, animated:Bool = true, sender:UIViewController) {
        
        
        
        let con = Conveniences()
        
        //MARK: Get destination VC and assign container
        var destinationVC = con.getSubview(identifier.rawValue) as! ContainerSubview & UIViewController
        
        guard let vcdel = sender as? UIViewController & VCContainerDelegate  else { return }
        destinationVC.container = vcdel
     
        
        
        
        //MARK: Set alpha and position
        destinationVC.view.alpha = animated ? 0 : 1
        
        con.addAndPosition(viewController:destinationVC, toParent:sender, inContainer: self)
        self.currentSubview = destinationVC
        
        //MARK: If not animated, remove subviews and return
        if !animated {
            con.removeSubviews(from:self)
            return
        }
        
        //MARK: Animate Transition
        UIView.animate(withDuration:0.3, animations:{
            destinationVC.view.alpha = 1
            self.subviews[0].alpha = 0
        }, completion: {(finished: Bool) in
            con.removeSubviews(from:self)
        })
    }
}
