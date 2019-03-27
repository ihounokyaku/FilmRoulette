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
//        self.hideKeyboardWhenTappedAround()
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
    
    func presentView(withIdentifier identifier:VCIdentifier) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let controller = storyboard.instantiateViewController(withIdentifier: identifier.rawValue) as? ModalVC else {return}
        
        //MARK: Configure and Present VC
        controller.masterDelegate = self
        controller.modalPresentationStyle = .popover
        self.present(controller, animated:true, completion:nil)
    }
    
    func presentSingleMovieView<sender>(movie:Movie, imageData:Data?, filmSwipe:Bool, sender:sender) where sender:UIViewController, sender:SingleMovieDelegate {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let controller = storyboard.instantiateViewController(withIdentifier: "SingleMovie") as? SingleMovieVC else {return}
        
        //MARK: Configure and Present VC
        if !movie.imageExists {controller.posterData = imageData}
        controller.movie = movie
        controller.masterDelegate = sender
        controller.filmSwipe = filmSwipe
        //        controller.modalPresentationStyle = .popover
        sender.present(controller, animated:true, completion:nil)
    }
}




