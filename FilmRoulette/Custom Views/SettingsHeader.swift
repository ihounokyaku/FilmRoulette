//
//  SettingsHeader.swift
//  FilmSwipe
//
//  Created by Dylan Southard on 2018/10/20.
//  Copyright © 2018 Dylan Southard. All rights reserved.
//

import UIKit

enum SettingsHeaderType {
    case swipe
    case data
    case upgrade
}

class SettingsHeader: UITableViewHeaderFooterView {

    @IBOutlet weak var headerIcon: UIImageView!
    @IBOutlet weak var customLabel: UILabel!
    
    
    private let popuplateOptions:[String:[SettingsHeaderType:String]] = [
        "image":[.swipe:"headerIcon-1",.data:"headerIcon-2", .upgrade:"headerIcon-1"],
        "text":[.swipe:"SPIN PREFERENCES", .data:"FILM LIBRARY", .upgrade:"DIRECTOR'S CUT"]
    ]
    
    
    var type:SettingsHeaderType = .swipe {
        didSet {
            self.populate()
        }
    }
    
    private func populate(){
        self.headerIcon.image = UIImage(named:self.popuplateOptions["image"]![self.type]!)
        self.customLabel.text = self.popuplateOptions["text"]![self.type]!
        self.customLabel.font = Fonts.SettingsTableHeader
        self.customLabel.frame = self.headerIcon.frame
        
    }
    
    
//    override init(reuseIdentifier: String?) {
//        super.init(reuseIdentifier: reuseIdentifier)
//        self.commonInit()
//    }
//
//
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        commonInit()
//    }
//
//    private func commonInit() {
//        Bundle.main.loadNibNamed("SettingsHeader", owner: self, options: nil)
//        addSubview(contentView)
//    }
  
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let heightDifference = self.headerIcon.frame.height - self.customLabel.frame.height
        self.customLabel.frame.origin = CGPoint(x: self.customLabel.frame.origin.x, y: self.headerIcon.frame.origin.y + heightDifference + customLabel.frame.height / 7)
    }

}
