//
//  DropboxManager.swift
//  FilmRoulette
//
//  Created by Dylan Southard on 2019/03/25.
//  Copyright © 2019 Dylan Southard. All rights reserved.
//

import UIKit
import SwiftyDropbox
import SVProgressHUD

protocol DropboxDelegate{
    var dropboxManager:DropboxManager {get set}
    func requestComplete(error:String?, data:Data?)
    func completedAuthorization(success:Bool, error:String?)
    func dropboxSyncComleted()
}

extension DropboxDelegate {
    func syncFromDropbox(){
        guard let vc = self as? UIViewController & DropboxDelegate  else {return}
        
        if self.dropboxManager.client == nil {
            print("going to authorize")

            self.dropboxManager.authorize(sender: vc)
        } else {
            print("going to import")
            SVProgressHUD.show(withStatus: "Connecting to Dropbox")
            self.dropboxManager.importFile(sender: vc)
        }
        
    }
    
    func requestComplete(error: String?, data: Data?) {
        guard let vc = self as? UIViewController & DropboxDelegate else {return}
        if let realError = error {
            vc.view.makeToast(realError)
        } else if let realData = data {
            DispatchQueue.main.async {
                
                SVProgressHUD.showProgress(0, status: "File found! Syncing...")
            }
            JSONHandler().sync(fromData: realData)
            
            self.dropboxSyncComleted()
            
            print("got the goods")
        } else {
            vc.view.makeToast("No data found")
        }
    }
    
    func completedAuthorization(success: Bool, error: String?) {
        guard let vc = self as? UIViewController & DropboxDelegate else {return}
        if let realError = error {
            vc.view.makeToast(realError)
        } else if success {
            vc.view.makeToast("successfully logged in to Dropbox")
        }
    }
}



class DropboxManager: NSObject {
    
    let client = DropboxClientsManager.authorizedClient
    
    func authorize(sender:DropboxDelegate) {
        guard let vc = sender as? UIViewController else {return}
        (UIApplication.shared.delegate as! AppDelegate).dropboxDelegate = sender
        DropboxClientsManager.authorizeFromController(UIApplication.shared, controller: vc, openURL: { (url: URL) -> Void in
            UIApplication.shared.openURL(url)
        })
    }
    
    func importFile(sender:DropboxDelegate) {
        
        client?.files.download(path: "/Apps/FilmRoulette/FilmLibrary.json").response { response, error in
            if let response = response {
                let responseMetadata = response.0
                print(responseMetadata)
                
                let fileContents = response.1
                print(fileContents)
                sender.requestComplete(error: nil, data: fileContents)
            } else if let error = error {
                print(error.description)
                sender.requestComplete(error: "Could not get library file!", data: nil)
            }
            }
            .progress { progressData in
                print(progressData)
        }
    }

}
