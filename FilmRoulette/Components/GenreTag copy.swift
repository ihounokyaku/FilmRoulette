//
//  GenreTag.swift
//  FilmRoulette
//
//  Created by Dylan Southard on 7/26/20.
//  Copyright © 2020 Dylan Southard. All rights reserved.
//

import Foundation
import TagListView

class GenreTag:CustomTag{
    
    var genre:Genre
    
    init(genre:Genre, table:TagListView){
        self.genre = genre
        super.init(title: genre.name, table:table)
    }
    
    required init?(coder:NSCoder) {
        self.genre = GenreType.action.genre
        super.init(coder: coder)
    }
    
}
