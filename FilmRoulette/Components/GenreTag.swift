//
//  GenreTag.swift
//  FilmRoulette
//
//  Created by Dylan Southard on 7/26/20.
//  Copyright © 2020 Dylan Southard. All rights reserved.
//

import Foundation
import TagListView

class TagTag:CustomTag{
    
    var tagObject:Tag
    
    init(tag:Tag, table:TagListView){
        self.tagObject = tag
        super.init(title: tag.name, table:table)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
  
}
