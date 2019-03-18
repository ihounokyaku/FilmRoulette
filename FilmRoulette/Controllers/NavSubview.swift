//
//  NavSubview.swift
//  FilmSwipe
//
//  Created by Dylan Southard on 2018/06/11.
//  Copyright © 2018 Dylan Southard. All rights reserved.
//

import UIKit

class NavSubview: UIViewController, SelectorDelegate {

    //MARK: - =======Variables=======
    var container:NavContainer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func setSelector(buttonCount:Int, color:UIColor?, label1:String = "", label2:String = "", label3:String =  "") {
        
        let allButtons:[UIButton] = [self.container.topButton3, self.container.topButton2, self.container.topButton1]
        guard buttonCount <= allButtons.count else {return}
        var buttons = [UIButton]()
        
        if buttonCount > 0 {
            for i in 1...buttonCount {
                buttons.append(allButtons[buttonCount - i])
            }
            self.container.selector.configure(buttons:buttons, highlightColor: color ?? UIColor().offWhitePrimary(alpha:0.4), delegate:self)
        }
        
        self.container.topButtonLabel1.text = label1
        self.container.topButtonLabel2.text = label2
        self.container.topButtonLabel3.text = label3
    }
    
    
    func selectionDidChange(sender: Selector) {}
}


