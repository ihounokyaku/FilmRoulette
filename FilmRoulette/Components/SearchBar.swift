//
//  SearchBar.swift
//  FilmSwipe
//
//  Created by Dylan Southard on 2018/09/30.
//  Copyright © 2018 Dylan Southard. All rights reserved.
//

import UIKit
@IBDesignable
class SearchBar: UISearchBar {

    private var internalBarHeight: CGFloat = 0.6 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    private var internalBarWidth: CGFloat = 0.8 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable var barBKGColor:UIColor?{
        didSet{
            self.setNeedsDisplay()
        }
    }
    
    private var adaptiveSearchField:UITextField {
        if #available(iOS 13.0, *) {
            return self.searchTextField
        } else {
            return value(forKey: "_searchField") as! UITextField
        }
    }
    
   var barHeight:CGFloat {
        set {
            if newValue <= 1.0 {
                self.internalBarHeight = barHeight
            }
        }
        get {
            return internalBarHeight
        }
    }
    
    var barWidth:CGFloat {
        
        set {
            if newValue <= 1.0 {
                self.internalBarWidth = barWidth
            }
        }
        get {
            return internalBarWidth
        }
    }
    
    @IBInspectable var font:UIFont? {
        didSet {
            self.setNeedsDisplay()
            
        }
    }
    
    public var textColor:UIColor? {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    public var borderColor:UIColor? {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    public var cursorColor:UIColor? {
        didSet {
            self.setNeedsDisplay()
        }
    }

    
    override func willMove(toSuperview newSuperview: UIView?) {
        
        super.willMove(toSuperview: newSuperview)
        let textField = self.adaptiveSearchField
        textField.backgroundColor = UIColor().offWhitePrimary()
        textField.borderStyle = .none
        textField.clipsToBounds = true
        
        textField.layer.borderWidth = 1.0
        textField.tintColor = UIColor().colorSecondaryDark()
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor().whitePrimary(alpha: 0.4).cgColor
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let textField = self.adaptiveSearchField
        self.font = Fonts.SearchBarFont
        if let font = self.font {
            textField.font = font
        }
        
        
       
        textField.textColor = self.textColor ?? UIColor().textDarkPrimary(alpha: 1)
        
        let textFieldWidth:CGFloat = self.frame.width * barWidth
        let textFieldHeight:CGFloat = self.frame.height * barHeight
        
        textField.frame = CGRect(x: self.frame.width / 2 - textFieldWidth / 2 , y: self.frame.height / 2 - textFieldHeight / 2 , width: textFieldWidth, height: textFieldHeight)
        textField.layer.cornerRadius = textFieldHeight / 2
        textField.leftView = self.searchIcon()
        
    }
    
    func searchIcon()->UIView {
        let searchIcon = UIImageView(image: UIImage(named: "searchIcon"))
        let imageHeight:CGFloat = (self.frame.height * self.barHeight) * 0.45
        let outerView = UIView(frame: CGRect(x:0, y:0, width:imageHeight + 10, height:imageHeight))
//        let imageHeight =
       
        searchIcon.frame = CGRect(x:0, y:0, width:imageHeight + 10, height:imageHeight)
        searchIcon.contentMode = .scaleAspectFit
        outerView.addSubview(searchIcon)
       
        return outerView
    }
   
}
