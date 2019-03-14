//
//  SwipeQuery.swift
//  FilmSwipe
//
//  Created by Dylan Southard on 2018/10/07.
//  Copyright © 2018 Dylan Southard. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

protocol MainQueryDelegate {
    var page:Int {get set}
    var apiKey:String {get}
    func initialQueryComplete(results:[Int]?, error:String?)
    func updateProgressBar(by progress:Float)
}


class MainQuery: NSObject {
    var idArray = [Int]()
    var idsAlreadyQueued:[Int]!
    var delegate:MainQueryDelegate!
    
    init(delegate:MainQueryDelegate) {
        self.delegate = delegate
    }
    
    
    func idArray(fromJSON json:JSON)-> [Int?] {
        return json["results"].arrayValue.map({$0["id"].int})
    }
    
    func idArrayRemovingDuplicates(from originalArray:[Int])-> [Int] {
        var array =  [Int]()
        for item in originalArray {
            if !Prefs.swipedMovies.contains(item) && !self.idsAlreadyQueued.contains(item) && !idArray.contains(item) {
                array.append(item)
            }
        }
        
        
        return array
    }
}
