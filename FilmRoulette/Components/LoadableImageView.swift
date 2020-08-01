//
//  LoadableImageView.swift
//  FilmSwipe
//
//  Created by Dylan Southard on 2018/10/25.
//  Copyright © 2018 Dylan Southard. All rights reserved.
//

import UIKit

class LoadableImageView: UIImageView {
    
    

    var movie:Movie!
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        super.draw(rect)
    }
    
    func loadImageIfNecessary(){
        guard self.movie.imageExists && self.movie.imageURL != "" else {return}
        PosterQueryManager().queryPoster(forMovie: self.movie, onCompletion: self.reloadPoster)
    }
    
    func reloadPoster(_ errors:[Movie]) {
        
        
        self.image = self.movie.poster
    }
    
    
 

}
