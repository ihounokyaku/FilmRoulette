//
//  DropboxManager.swift
//  FilmRoulette
//
//  Created by Dylan Southard on 2019/03/25.
//  Copyright © 2019 Dylan Southard. All rights reserved.
//

import UIKit
import SwiftyDropbox

protocol DropboxDelegate{
    func requestComplete(error:String?, data:Data?)
    func completedAuthorization(success:Bool, error:String?)
}

extension DropboxDelegate {
    func requestComplete(error:String?, data:Data?){}
    func completedAuthorization(success:Bool, error:String?){}
}

class DropboxManager: NSObject {
    
    let client = DropboxClientsManager.authorizedClient
    
    func authorize<sender>(sender:sender) where sender:UIViewController, sender:DropboxDelegate {
        (UIApplication.shared.delegate as! AppDelegate).dropboxDelegate = sender
        DropboxClientsManager.authorizeFromController(UIApplication.shared, controller: sender, openURL: { (url: URL) -> Void in
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
                print(error)
                sender.requestComplete(error: error.description, data: nil)
            }
            }
            .progress { progressData in
                print(progressData)
        }
    }

}
