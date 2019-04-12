//
//  GroupCell.swift
//  FilmRoulette
//
//  Created by Dylan Southard on 2019/03/28.
//  Copyright © 2019 Dylan Southard. All rights reserved.
//

import UIKit
import SwipeCellKit

class GroupCell: SwipeTableViewCell {

    @IBOutlet weak var image1: UIImageView!
    @IBOutlet weak var image2: UIImageView!
    @IBOutlet weak var image3: UIImageView!
    @IBOutlet weak var image4: UIImageView!
    @IBOutlet weak var image5: UIImageView!
    @IBOutlet weak var image6: UIImageView!
    
    @IBOutlet weak var cellLabel: UILabel!
    
    
    var imageViews = [UIImageView]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.imageViews = [self.image1, self.image2, self.image3, self.image4, self.image5, self.image6]
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setImages(fromMovies movies:[Movie]) {
        self.clearImages()
        var index = 0
        for movie in movies {
            guard index < 6 else {break}
            if movie.imageExists {
                self.imageViews[index].image = movie.poster
                index += 1
            }
        }
    }
    
    private func clearImages() {
        for imageView in self.imageViews {
            imageView.image = nil
        }
    }
    
}
