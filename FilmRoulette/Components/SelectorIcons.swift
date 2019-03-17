//
//  Color.swift
//  FilmSwipe
//
//  Created by Dylan Southard on 2018/10/17.
//  Copyright © 2018 Dylan Southard. All rights reserved.
//

import UIKit

enum MovieOption:String,CaseIterable {
    case watched = "check"
    case loved = "stars"
    case unwatched = "star"
}



class SelectorIcon: NSObject {
    
    private func suffix(_ deselected:Bool)-> String{
        return deselected ? "outline" : "fill"
    }
    
    func image(for type:MovieOption, deselected:Bool = false)->UIImage {
        return UIImage(named: "icon-" + type.rawValue + "-" + self.suffix(deselected))!
    }
    
    
}
