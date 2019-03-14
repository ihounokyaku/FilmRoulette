//
//  Fonts.swift
//  FilmSwipe
//
//  Created by Dylan Southard on 2018/09/27.
//  Copyright © 2018 Dylan Southard. All rights reserved.
//

import Foundation
import UIKit

extension UIFont {
    
    func fontSizeByDevice(defaultSize:CGFloat, iPhone5:CGFloat, ipad:CGFloat, ipadPro:CGFloat? = nil)-> CGFloat {
        if UIDevice.current.screenType == .iPhones_5_5s_5c_SE {
            return iPhone5
        } else if UIDevice.current.screenType == .ipad {
            if let pro = ipadPro {
                if UIDevice.isiPadPro {return pro}
            }
            
            return ipad
        }
        return defaultSize
    }
    
}

class Fonts:NSObject {
    
    //MARK: - default fonts
    static var PrimaryRegular:UIFont{
        return UIFont(name: "Nunito-Regular", size: 12)!
    }
    
    static var PrimaryBold:UIFont{
        return UIFont(name: "Nunito-Bold", size: 12)!
    }
    
    static var PrimaryItalic:UIFont{
        return UIFont(name: "Nunito-Italic", size: 12)!
    }
    
    static var PrimarySemiBold:UIFont{
        return UIFont(name: "Nunito-SemiBold", size: 12)!
    }
    
    static var GothicSemiBold:UIFont{
        return UIFont(name: "AppleSDGothicNeo-SemiBold", size: 12) ?? UIFont(name: "Nunito-SemiBold", size: 12)!
    }
    //MARK: - specific fonts
    
    static var TopSelectorFont:UIFont {
        return Fonts.PrimaryBold.withSize(UIFont().fontSizeByDevice(defaultSize: 15, iPhone5: 12, ipad: 25))
    }
    
    static var KidsModeFont:UIFont {
        return Fonts.PrimaryBold.withSize(UIFont().fontSizeByDevice(defaultSize: 16, iPhone5: 16, ipad: 25))
    }
    
    static var AlertTitleFont:UIFont {return Fonts.PrimaryBold.withSize(18)}
    
    static var AlertMessageFont:UIFont {return Fonts.PrimaryRegular.withSize(16)}
    
    static var YearPickerFont:UIFont {return Fonts.PrimaryItalic.withSize(15)}
    
    static var SearchBarFont:UIFont {
        return Fonts.PrimaryRegular.withSize(UIFont().fontSizeByDevice(defaultSize: 14, iPhone5: 14, ipad: 25))
    }
    
    static var ExpandViewTitleFont:UIFont {
        return Fonts.PrimaryBold.withSize(UIFont().fontSizeByDevice(defaultSize: 20, iPhone5: 18, ipad: 25))
    }
    
    static var ExpandViewGenreFont:UIFont {
        return Fonts.PrimaryItalic.withSize(UIFont().fontSizeByDevice(defaultSize: 15, iPhone5: 13, ipad: 17))
    }
    
    static var ExpandViewDescriptionFont:UIFont {
        return Fonts.PrimaryRegular.withSize(UIFont().fontSizeByDevice(defaultSize: 15, iPhone5: 13, ipad: 20))
    }
    
    static var MovieCellTitle:UIFont {
        return Fonts.PrimaryBold.withSize(UIFont().fontSizeByDevice(defaultSize: 15, iPhone5: 15, ipad: 30))
    }
    
    static var MovieCellDate:UIFont {
        return Fonts.PrimaryBold.withSize(UIFont().fontSizeByDevice(defaultSize: 14, iPhone5: 14, ipad: 30))
    }
    
    static var DoneButton:UIFont {
        return Fonts.PrimaryBold.withSize(UIFont().fontSizeByDevice(defaultSize: 17, iPhone5: 17, ipad: 30))
    }
    
    //MARK: - PopupViews
    
    static var SingleViewTitle:UIFont {
        return Fonts.PrimaryBold.withSize(UIFont().fontSizeByDevice(defaultSize: 24, iPhone5: 19, ipad: 35, ipadPro: 50))
    }
    
    static var SingleViewGenres:UIFont {
        return Fonts.PrimaryItalic.withSize(UIFont().fontSizeByDevice(defaultSize: 15, iPhone5: 15, ipad: 25, ipadPro: 35))
    }
    
    static var SingleViewDesc:UIFont {
        return Fonts.PrimaryRegular.withSize(UIFont().fontSizeByDevice(defaultSize: 15, iPhone5: 14, ipad: 20, ipadPro: 30))
    }
    
    static var SubviewHeader:UIFont {
        return Fonts.PrimaryRegular.withSize(UIFont().fontSizeByDevice(defaultSize: 23, iPhone5: 23, ipad: 45))
    }
    
    static var SettingsTableHeader:UIFont {
        return Fonts.PrimaryRegular.withSize(UIFont().fontSizeByDevice(defaultSize: 17, iPhone5: 17, ipad: 25))
    }
    
    static var SettingsTableTitle:UIFont {
        return Fonts.PrimaryRegular.withSize(UIFont().fontSizeByDevice(defaultSize: 17, iPhone5: 17, ipad: 35))
    }
    
    static var SettingsTableLabel:UIFont {
        return Fonts.PrimaryRegular.withSize(UIFont().fontSizeByDevice(defaultSize: 17, iPhone5: 17, ipad: 25))
    }
    
    static var SettingsStateLabel:UIFont {
        return Fonts.PrimaryRegular.withSize(UIFont().fontSizeByDevice(defaultSize: 12, iPhone5: 12, ipad: 23))
    }
    
    //MARK: - Special Views
    
    static var TutorialButtons:UIFont {
        return Fonts.PrimaryRegular.withSize(UIFont().fontSizeByDevice(defaultSize: 17, iPhone5: 17, ipad: 30))
    }
    
    static var CountdownNumber:UIFont {
        return Fonts.GothicSemiBold.withSize(UIFont().fontSizeByDevice(defaultSize: 90, iPhone5: 90, ipad: 150))
    }

}


