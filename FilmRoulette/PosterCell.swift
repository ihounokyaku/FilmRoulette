//
//  PosterCell.swift
//  FilmRoulette
//
//  Created by Dylan Southard on 15/7/18.
//  Copyright © ค.ศ. 2018 Dylan Southard. All rights reserved.
//

import UIKit
import Gemini

class PosterCell: GeminiCell, HudDelegate {
    
    
    
    @IBOutlet weak var hud: UIActivityIndicatorView!
    
    
    lazy var customShadowView:UIView = {
        let _view = UIView()
        _view.layer.shadowColor = UIColor.black.cgColor
        _view.layer.shadowOffset = .zero
        _view.layer.shadowOpacity = 1
        _view.layer.shadowRadius = 20
        _view.backgroundColor = UIColor.blue
        self.addSubview(_view)
        
        return _view
    }()
    
//    override var shadowView: UIView? {
//        return self.customShadowView
//    }
    
    var shadowRadius:CGFloat = 5 {
        didSet {
            self.layer.shadowRadius = self.shadowRadius
        }
    }
    

    
    var loadingPosters = false
    
    
    
    var activityIndicator: UIActivityIndicatorView {
        get {
           return self.hud
        }
    }
    
    var movie: Movie?
    
    @IBOutlet weak var posterImageView: UIImageView!
    
    
    func configure(movie:Movie, poster:UIImage, loading:Bool) {
        self.movie = movie
        self.loadingPosters = loading
        self.posterImageView.image = poster
        self.showHideHud()
        self.addShadow()
    }
    
    func addShadow() {
        
//        self.layer.borderWidth = 1.0
//        self.layer.borderColor = UIColor.lightGray.cgColor
        
        self.layer.backgroundColor = UIColor.white.cgColor
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 2.0, height: 4.0)
        self.layer.shadowRadius = self.shadowRadius
        self.layer.shadowOpacity = 1.0
        self.layer.masksToBounds = false
    }
    
    
    
    
    
    
    
}
