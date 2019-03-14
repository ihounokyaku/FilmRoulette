//
//  CustomAlert.swift
//  FilmSwipe
//
//  Created by Dylan Southard on 2018/10/20.
//  Copyright © 2018 Dylan Southard. All rights reserved.
//

import UIKit

class CustomAlert: UIAlertController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let titleFont = [NSAttributedString.Key.font: Fonts.AlertTitleFont]
        let messageFont = [NSAttributedString.Key.font: Fonts.AlertMessageFont]
        var ms = ""
        var ti = ""
        
        if let message = self.message {
            ms = message
        }
        
        if let title = self.title {
            ti = title
        }
        let titleAttrString = NSMutableAttributedString(string: ti, attributes: titleFont)
        let messageAttrString = NSMutableAttributedString(string: ms, attributes: messageFont)
        self.setValue(titleAttrString, forKey: "attributedTitle")
        self.setValue(messageAttrString, forKey: "attributedMessage")
        self.view.layer.cornerRadius = 50
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
