 //
//  CustomTableView.swift
//  FilmSwipe
//
//  Created by Dylan Southard on 2018/10/17.
//  Copyright © 2018 Dylan Southard. All rights reserved.
//

import UIKit

 enum TableImageType  {
    case search
    case noLiked
    case noResults
    case noFavorites
 }
 
 
 class CustomTableView: UITableView {
    
    var currentImage:UIImageView?
    public var maxWidth:CGFloat = 800
    public var widthMultiplier:CGFloat = 0.6
    public var widthHeightRatio:CGFloat = 1
    private var width:CGFloat {
        let defaultWidth = self.frame.width * self.widthMultiplier
        return UIScreen.main.nativeBounds.width * self.widthMultiplier <= maxWidth ? defaultWidth : maxWidth / 2
    }
   
    
    
    private let images:[TableImageType:String] = [.search:"tableImage-search", .noLiked:"tableImage-noLiked", .noResults:"tableImage-noResults", .noFavorites:"tableImage-noFavorites"]
    
    
    func displayImage(ofType type:TableImageType) {
      self.removeImage(andShowNewOfType: type)
        
    }
    
    private func showNewImage(ofType imageType:TableImageType?) {
        guard let type = imageType else {return}
        self.currentImage = UIImageView(image: UIImage(named:self.images[type]!)!)
        self.currentImage!.frame.size = CGSize(width: self.width, height: self.width * self.widthHeightRatio)
        self.currentImage!.center = self.center
        self.currentImage!.alpha = 0
        self.superview?.addSubview(self.currentImage!)
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
            self.currentImage!.alpha = 1
        }) { _ in
            //On completion
        }
    }
    
    func removeImage(andShowNewOfType type:TableImageType? = nil) {
        if currentImage == nil {
            self.showNewImage(ofType: type)
            return
        }
        
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
                self.currentImage!.alpha = 0
            }) { _ in
                //On completion
                self.currentImage!.removeFromSuperview()
                self.showNewImage(ofType: type)
            }
        
    }
 }
