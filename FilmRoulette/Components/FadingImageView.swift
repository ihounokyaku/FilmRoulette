//
//  FadingImageView.swift
//  FilmRoulette
//
//  Created by Dylan Southard on 2019/04/14.
//  Copyright © 2019 Dylan Southard. All rights reserved.
//

import UIKit

class FadingImageView: UIView {
    
    var currentImage:UIImageView?
    var filterView:UIView!
    
    
    var imageAlpha:CGFloat = 0.3
    var filterColor = UIColor().offWhitePrimary()
    var filterAlpha:CGFloat = 0.4
    var transitionTime = 0.5
    

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupView()
    }
    
    func setupView() {
        self.filterView = UIView(frame: self.frame)
        self.filterView.backgroundColor = self.filterColor
        self.filterView.alpha = 0
        self.addSubview(self.filterView)
    }
    
    func setImage(_ image:UIImage?){
        guard let image = image else {return}
        let imageView = UIImageView(frame: self.frame)
        imageView.contentMode = .scaleAspectFill
        imageView.image = image
        imageView.alpha = 0
        self.addSubview(imageView)
        self.bringSubview(toFront: self.filterView)
        UIView.animate(withDuration: self.transitionTime, animations: {
            self.filterView.alpha = self.filterAlpha
            imageView.alpha = self.imageAlpha
            
            if let prevImageView = self.currentImage {
                prevImageView.alpha = 0
            }
        }) { (_) in
            self.currentImage?.removeFromSuperview()
            self.currentImage = imageView
        }
    }
    
    func clearImage() {
        guard let imageView = self.currentImage else {return}
        
        UIView.animate(withDuration: self.transitionTime, animations: {
            imageView.alpha = 0
            self.filterView.alpha = 0
        }) { (_) in
            imageView.removeFromSuperview()
        }
    }
}
