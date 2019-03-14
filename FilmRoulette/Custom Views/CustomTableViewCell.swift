//
//  CustomTableViewCell.swift
//  FilmSwipe
//
//  Created by Dylan Southard on 2018/10/20.
//  Copyright © 2018 Dylan Southard. All rights reserved.
//

import UIKit

@IBDesignable
class CustomTableViewCell: UITableViewCell {

    @IBInspectable var isButton:Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
