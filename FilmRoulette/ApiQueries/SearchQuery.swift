//
//  SearchQuery.swift
//  FilmSwipe
//
//  Created by Dylan Southard on 2018/10/07.
//  Copyright © 2018 Dylan Southard. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON


class SearchQuery: MainQuery {

    let searchQueryURL = "https://api.themoviedb.org/3/search/movie"
    
    func execute(searchTerm:String) {
//        self.delegate.setProgressBar(to: 0)
        
        Alamofire.request(self.searchQueryURL, method:.get, parameters:["api_key":self.delegate.apiKey,"query":searchTerm]).responseJSON { (response) in
            if response.result.isSuccess {
                
                let json:JSON =  JSON(response.result.value!)
                
                let ids = json["results"].arrayValue.map({$0["id"].int})
                if let realIDs = ids as? [Int] {
                    self.delegate.initialQueryComplete(results: realIDs, error: nil)
                } else {
                    self.delegate.initialQueryComplete(results: nil, error: "Something went wrong")
                }
            } else {
                self.delegate.initialQueryComplete(results: nil, error: String(describing: response.result.error))
            }
        }
    }
}
