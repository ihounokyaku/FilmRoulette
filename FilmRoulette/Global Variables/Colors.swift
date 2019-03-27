//
//  Colors.swift
//  FilmSwipe
//
//  Created by Dylan Southard on 2018/09/27.
//  Copyright © 2018 Dylan Southard. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
    
    
    func blackBackgroundPrimary(alpha:CGFloat = 1)-> UIColor{
        return self.fromHexWithAlpha(hex:"#252A26", alpha:alpha)
    }
    func offWhitePrimary(alpha:CGFloat = 1)-> UIColor{
        return self.fromHexWithAlpha(hex:"#EEF2FA", alpha:alpha)
    }
    func colorSecondaryDark(alpha:CGFloat = 1)-> UIColor{
        return self.fromHexWithAlpha(hex:"#638278", alpha:alpha)
    }
    func colorSecondaryLight(alpha:CGFloat = 1)-> UIColor{
        return self.fromHexWithAlpha(hex:"#9BD5BF", alpha:alpha)
    }
    func colorEmphasisDark(alpha:CGFloat = 1)-> UIColor{
        return self.fromHexWithAlpha(hex:"#C1553E", alpha:alpha)
    }
    func whitePrimary(alpha:CGFloat = 1)-> UIColor{
        return self.fromHexWithAlpha(hex:"#EFEFEF", alpha:alpha)
    }
    func textDarkPrimary(alpha:CGFloat = 1)-> UIColor{
        return self.fromHexWithAlpha(hex:"#1D1E20", alpha:alpha)
    }
    func textLightPrimary(alpha:CGFloat = 1)-> UIColor{
        return self.offWhitePrimary(alpha:alpha)
    }
    func colorTextEmphasis(alpha:CGFloat = 1)-> UIColor{
        return self.fromHexWithAlpha(hex:"#C1553E", alpha:alpha)
    }
    func colorTextEmphasisLight(alpha:CGFloat = 1)-> UIColor{
        return self.fromHexWithAlpha(hex:"#D07163", alpha:alpha)
    }
   
    
    static var SelectorWhite:UIColor {
        return UIColor().offWhitePrimary(alpha:0.4)
    }
    
    
    
    
    func fromHexWithAlpha(hex:String, alpha:CGFloat)-> UIColor{
        let color = UIColor(hexString: hex)
        return color.withAlphaComponent(alpha)
    }
}

