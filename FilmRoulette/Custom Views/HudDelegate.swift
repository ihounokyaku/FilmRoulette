//
//  HudDelegate.swift
//  FilmRoulette
//
//  Created by Dylan Southard on 2019/04/14.
//  Copyright © 2019 Dylan Southard. All rights reserved.
//

import Foundation
import UIKit


protocol HudDelegate {
    var activityIndicator:UIActivityIndicatorView {get}
    var movie:Movie? {get set}
    var loadingPosters:Bool {get set}
    func showHUD()
    func hideHUD()
}

extension HudDelegate {
    func showHideHud(){
        guard let movie = self.movie else {return}
        if !movie.imageExists && movie.imageURL != "" && self.loadingPosters {
            self.showHUD()
        } else {
            self.hideHUD()
        }
    }
    
    func showHUD() {
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
    }
    
    func hideHUD() {
        self.activityIndicator.stopAnimating()
        self.activityIndicator.isHidden = true
    }
}
