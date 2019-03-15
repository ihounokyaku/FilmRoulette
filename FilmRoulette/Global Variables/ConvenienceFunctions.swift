//
//  ConvenienceFunctions.swift
//  FilmSwipe
//
//  Created by Dylan Southard on 2018/09/29.
//  Copyright © 2018 Dylan Southard. All rights reserved.
//

import Foundation
import UIKit
import LocalAuthentication

enum ViewControllerPresentationDirection {
    case left
    case right
}

struct Conveniences {
    func valueFromRatio(ratioWidth:Float, ratioHeight:Float, width:Float? = nil, height:Float? = nil)->Float {
        guard height != nil || width != nil else {return 0}
        if let h = height {
            return (ratioWidth / ratioHeight) * h
        } else if let w = width {
            return (ratioHeight / ratioWidth) * w
        }
        return 0
    }
    
    func imageFromData(data:Data?)-> UIImage {
        
        guard let realData = data else {return Images.NoImage}
        return UIImage(data:realData) ?? Images.NoImage
    }
    
    
    
    //MARK: - ========= CALLING VCs =======
    
    //MARK: - ==GET VC==
    func getSubview (_ identifier:String)-> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        return storyboard.instantiateViewController(withIdentifier: identifier)
    }
    //MARK: - ==CALL THAT VC UP==
    func addAndPosition(viewController:UIViewController, toParent parent:UIViewController, inContainer container:UIView) {
        parent.addChildViewController(viewController)
        container.addSubview(viewController.view)
        viewController.didMove(toParentViewController: parent)
        viewController.view.frame = CGRect(x: 0, y: 0, width: container.frame.size.width, height:container.frame.size.height)
    }
    
    func presentVCAnimated(viewController:UIViewController, toParent parent:UIViewController, inContainer container:UIView, direction:ViewControllerPresentationDirection, previousVC:UIViewController) {
        let x:CGFloat = direction == .left ? container.frame.size.width : 0 - container.frame.size.width
        viewController.view.frame = CGRect(x: x, y: 0, width: container.frame.size.width, height:container.frame.size.height)
        parent.addChildViewController(viewController)
        container.addSubview(viewController.view)
        viewController.didMove(toParentViewController: parent)
        
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
            viewController.view.frame = CGRect(x: 0, y: 0, width: container.frame.size.width, height:container.frame.size.height)
            previousVC.view.frame = CGRect(x: 0 - x, y: 0, width: container.frame.size.width, height:container.frame.size.height)
        }) { _ in
            //On completion
        }
    }
    
    func presentViewSwipe(fromView prevView:UIView, toView newView:UIView, inView container:UIView, direction:UISwipeGestureRecognizer.Direction, completion:@escaping ()->()?){
        let x:CGFloat = direction == .left ? container.frame.size.width : 0 - container.frame.size.width
        newView.frame = CGRect(x: x, y: 0, width: container.frame.size.width, height:container.frame.size.height)
        container.addSubview(newView)
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
            newView.frame = CGRect(x: 0, y: 0, width: container.frame.size.width, height:container.frame.size.height)
            prevView.frame = CGRect(x: 0 - x, y: 0, width: container.frame.size.width, height:container.frame.size.height)
        }) { _ in
            //On completion
            completion()
        }
    }
    
    
    func presentSingleMovieView<sender>(movie:Movie, imageData:Data?, sender:sender) where sender:UIViewController, sender:SingleMovieDelegate {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let controller = storyboard.instantiateViewController(withIdentifier: "SingleMovie") as? SingleMovieVC else {return}
        
        //MARK: Configure and Present VC
        if !movie.imageExists {controller.posterData = imageData}
        controller.movie = movie
        controller.delegate = sender
//        controller.modalPresentationStyle = .popover
        sender.present(controller, animated:true, completion:nil)
    }
    
    
    func swipeDisplay(view:UIView, from prevView:UIView, inContainer container:UIView, direction:UISwipeGestureRecognizer.Direction, completion:(()->())? = nil){
        let x:CGFloat = direction == .left ? container.frame.size.width : 0 - container.frame.size.width
        view.frame = CGRect(x: x, y: 0, width: container.frame.size.width, height:container.frame.size.height)
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
            view.frame = CGRect(x: 0, y: 0, width: container.frame.size.width, height:container.frame.size.height)
            prevView.frame = CGRect(x: 0 - x, y: 0, width: container.frame.size.width, height:container.frame.size.height)
        }) { _ in
            //On completion
            if let handler = completion {
                handler()
            }
        }
    }
    

    
    //MARK: - ==REMOVE SUBVIEWS==
    func removeSubviews (from container:UIView) {
        while container.subviews.count > 1 {
            container.subviews[0].removeFromSuperview()
        }
    }
    
    
    //MARK: - ==ALERTS==
    func presentConfirmationAlert(inVC vc:UIViewController, title:String, message:String, forAction confirmationAction:@escaping ()->()){
        let alert = CustomAlert(title: title, message:message, preferredStyle: .alert)
        
        //Mark: Define Delete/Cancel Actions
        let action = UIAlertAction(title: "Just do it!", style: .default) { (action) in
            confirmationAction()
        }

        let action2 = UIAlertAction(title:"Nevermind", style:.cancel)
        
        action2.setValue(UIColor().colorTextEmphasis(), forKey: "titleTextColor")
        action.setValue(UIColor().colorSecondaryDark(), forKey: "titleTextColor")
        
        alert.view.backgroundColor = UIColor().offWhitePrimary()
        alert.addAction(action)
        alert.addAction(action2)
        vc.present(alert, animated: true, completion: nil)
    }
    
    func presentAlertWithTwoChoices(inVC vc:UIViewController, title:String, message:String, buttonOneText:String, buttonTwoText:String, firstAction:@escaping ()->(), secondAction:@escaping ()->()){
        let alert = CustomAlert(title: title, message:message, preferredStyle: .alert)
        
        //Mark: Define Delete/Cancel Actions
        let action = UIAlertAction(title: buttonOneText, style: .default) { (action) in
            firstAction()
        }
        
        let action2 = UIAlertAction(title:buttonTwoText, style:.default){ (action) in
            secondAction()
        }
        
        action2.setValue(UIColor().colorTextEmphasis(), forKey: "titleTextColor")
        action.setValue(UIColor().colorSecondaryDark(), forKey: "titleTextColor")
        
        alert.view.backgroundColor = UIColor().offWhitePrimary()
        alert.addAction(action)
        alert.addAction(action2)
        vc.present(alert, animated: true, completion: nil)
    }
    
    func presentErrorAlert(withTitle title:String, message:String, sender:UIViewController) {
        let alertController = CustomAlert(title: title, message: message, preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: "OK", style: .default) { (action) in
        }
       
        defaultAction.setValue(UIColor().colorSecondaryDark(), forKey: "titleTextColor")
        alertController.addAction(defaultAction)
        sender.present(alertController, animated: true, completion: nil)
    }

    
    
    func deleteFile(atURL url:URL) {
        do {
            try FileManager.default.removeItem(at: url)
        } catch let error {
            print(error)
        }
    }
    
    
    
//    func presentSplashView(ofType type:splashViewType, sender:SplashViewDelegate, container:UIView) {
//        
//        var splashView:SplashView!
//        let height = CGFloat(Conveniences().valueFromRatio(ratioWidth: 1084, ratioHeight: 1568, width:Float(container.frame.width)))
//        let shield = UIView(frame: container.frame)
//        shield.backgroundColor = UIColor().offWhitePrimary(alpha: 0.8)
//        let frame = CGRect(x: 0, y: 0, width: container.frame.width, height: height)
//        
//        
//        if type == .tutorial {
//            var images = [UIImage]()
//            for num in 1...5 {
//                if let image = UIImage(named: "tutorial-\(num)") {
//                    images.append(image)
//                }
//            }
//            splashView = TutorialView(frame: frame, images: images)
//        } else {
//            splashView = UpgradeView(frame: frame)
//        }
//        
//        splashView.center = container.center
//        shield.addSubview(splashView)
//        shield.alpha = 0
//        container.addSubview(shield)
//        splashView.shieldView = shield
//        splashView.delegate = sender
//        splashView.appear()
//    }
    
    func presentAuthenticationAlert(sender:UIViewController, completion:@escaping ()->()) {
        let context = LAContext()
        if context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthentication, error: nil) {
            context.evaluatePolicy(LAPolicy.deviceOwnerAuthentication, localizedReason: "access settings") { (success, error) in
                if success {
                    completion()
                } else {
                    if let e = error {
                        Conveniences().presentErrorAlert(withTitle: "Error!", message: e.localizedDescription, sender: sender)
                    }
                    
                }
            }
            
        }
    }
    
    func allFilesInDirectory(atURL url:URL)-> [URL]?{
        
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
            // process files
            return fileURLs
        } catch let error{
            print("Error while enumerating files \(error.localizedDescription)")
            return nil
        }
    }
    
    func deleteAllFiles(inDirectory url:URL) {
        guard let files = self.allFilesInDirectory(atURL: url) else {return}
        for file in files{
           self.deleteFile(atURL: file)
        }
    }
}


