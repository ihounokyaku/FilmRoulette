//
//  MovieListCell.swift
//  FilmSwipe
//
//  Created by Dylan Southard on 2018/09/28.
//  Copyright © 2018 Dylan Southard. All rights reserved.
//

import UIKit
protocol MovieCellDelegate {
    func buttonTapped(at index:IndexPath)
}


class MovieListCell: UITableViewCell, HudDelegate{
    
    
    var movie: Movie?

    var activityIndicator: UIActivityIndicatorView {
        get {
            return self.hud
        }
    }
    
    
    

    //MARK: - =============== IBOUTLETS ===============
    @IBOutlet weak var buttonRightImage: UIImageView?
    @IBOutlet weak var buttonRight: UIButton?
    
    @IBOutlet weak var posterImage: UIImageView!
    
    @IBOutlet weak var stripImageRight: UIImageView!
    @IBOutlet weak var stripImageLeft: UIImageView!
    @IBOutlet weak var textUpper: UILabel!
    @IBOutlet weak var textLower: UILabel!
    @IBOutlet weak var hud: UIActivityIndicatorView!
    
    

    //MARK: - =============== VARS ===============
    
    //MARK: - === STATUS VARS ===
    var showButton = true
    var indexPath:IndexPath!
    var loadingPosters = false
    
    //MARK: - === OBJECTS ===
    var delegate:MovieCellDelegate?
    
    var rightButtonEnabled:Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
        self.selectionStyle = UITableViewCell.SelectionStyle.none
    }
    
    func configure(movie:Movie, poster:UIImage, loadingPosters:Bool) {
        self.loadingPosters = loadingPosters
        self.movie = movie
        let titleBuffer = movie.title.count > 19 ? "     " : ""
        let stripImage = indexPath.row % 2 == 0 ? UIImage(named: "stripDotsUpper") : UIImage(named: "stripDotsLower")
        self.textUpper.font = Fonts.MovieCellTitle
        self.textLower.font = Fonts.MovieCellDate
        self.posterImage.image = poster
        self.textUpper.text = movie.title + titleBuffer
        self.textLower.text = "(\(movie.releaseYear))"
        self.stripImageRight.image = stripImage
        self.stripImageLeft.image = stripImage
        self.showHideHud()
        self.setColors()
    }

    
//    func config(title:String, releaseYear:String, poster:UIImage) {
//        let titleBuffer = title.count > 19 ? "     " : ""
//        let stripImage = indexPath.row % 2 == 0 ? UIImage(named: "stripDotsUpper") : UIImage(named: "stripDotsLower")
//        self.textUpper.font = Fonts.MovieCellTitle
//        self.textLower.font = Fonts.MovieCellDate
//        self.posterImage.image = poster
//        self.textUpper.text = title + titleBuffer
//        self.textLower.text = "(\(releaseYear))"
//        self.stripImageRight.image = stripImage
//        self.stripImageLeft.image = stripImage
//        self.setColors()
//    }
    
    
    private func setColors() {
       
    }

//    private func setButton() {
//       print("going to set button")
//        let buttonWidth = self.rightButtonEnabled ? self.movieView.frame.width * 0.086 : 5
//
//       self.buttonRightImage.isHidden = true
//
//        self.buttonRightImage.frame = CGRect(x: self.movieView.trailing() - buttonWidth - 15, y: self.buttonRightImage.frame.origin.y, width: buttonWidth, height: buttonRightImage.frame.size.height)
//        self.textView.backgroundColor = UIColor.green
//        self.textView.frame = CGRect(x: self.textView.frame.origin.x, y: self.textView.frame.origin.y, width: self.movieView.frame.width - posterImage.frame.width - self.buttonRight.frame.width - 35, height: self.textView.frame.height)
//        self.contentView.setNeedsDisplay()
//        self.contentView.layoutIfNeeded()
//        self.contentView.setNeedsDisplay()
//
////        self.buttonRightImage.isHidden = !self.rightButtonEnabled
//        self.buttonRight.isEnabled = self.rightButtonEnabled
//
//
//
//    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func loveTapped(_ sender: Any) {
        
        self.delegate?.buttonTapped(at: self.indexPath)

    }
}
