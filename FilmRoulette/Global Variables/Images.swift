//
//  Images.swift
//  FilmRoulette
//
//  Created by Dylan Southard on 2019/03/15.
//  Copyright © 2019 Dylan Southard. All rights reserved.
//

import UIKit



class Images: NSObject {
    
    static var AddToLibrary:UIImage {
        get {
            return Images.safeImage(named: "icon-star-fill")
        }
    }
    
    static var RemoveFromLibrary:UIImage {
        get {
            return Images.safeImage(named: "icon-x-fill")
        }
    }
    
    static let NoImage = UIImage(named:"noImage")!
    
    static func safeImage(named name:String)-> UIImage {
        return UIImage(named:name) ?? Images.NoImage
    }
    
}
