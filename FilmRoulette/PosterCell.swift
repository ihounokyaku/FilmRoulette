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
    }
    
}
