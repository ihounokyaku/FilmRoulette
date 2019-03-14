//
//  SingleMovieVC.swift
//  FilmSwipe
//
//  Created by Dylan Southard on 2018/06/20.
//  Copyright © 2018 Dylan Southard. All rights reserved.
//

import UIKit
import AVKit
import WebKit
import Alamofire

enum MovieSelector:Int {
    case toWatch = 0
    case watched = 1
    case loved = 2
    case notInterested = 3
}

protocol SingleMovieDelegate {
    func backFromSingleMovie(changed:Bool)
}

extension SingleMovieDelegate {
    func backFromSingleMovie(changed:Bool){}
}

class SingleMovieVC: UIViewController {

    //MARK: - ==========IBOUTLETS===========
    //MARK: - ==VIEWS==
    @IBOutlet weak var posterView: LoadableImageView!
    @IBOutlet weak var selectButtonView: UIView!
    @IBOutlet weak var selectorView: UIView!
    @IBOutlet weak var topView: UIView!
    
    
    //MARK: - ==LABELS/TEXTFIELDS==
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var descTextView: UITextView!
    
    //MARK: - ==BUTTONS==
//    @IBOutlet weak var enlargeButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    //    @IBOutlet weak var exOutButton: UIButton!
    @IBOutlet weak var trailerButton: UIButton!
    
    //MARK: - ==SELECTOR BUTTONS==
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var watchedButton: UIButton!
    @IBOutlet weak var loveButton: UIButton!
    @IBOutlet weak var notInterestedButton: UIButton!
    
    
    //MARK: - ==========VARIABLES===========
    var movie:Movie!
    var posterData:Data?
    
    //MARK: - ==MANAGERS==
    let dataManager = DataManager()

     //MARK: - ==DELEGATES ETC==
    var delegate:SingleMovieDelegate?
    
    var changed:Bool = false
    
    var trailerBkgView:TrailerView?
    
    //MARK: - ==========SETUP===========
    override func viewDidLoad() {
        super.viewDidLoad()
       
        
        self.posterView.movie = self.movie
        
        //MARK: - UPDATE UI
        self.trailerButton.isEnabled = URL(string:self.movie.trailerUrl) != nil
        self.selectorView.layer.borderColor = UIColor().blackBackgroundPrimary().cgColor
        self.selectorView.layer.borderWidth = 1
        
        self.setColors()
        self.setFonts()
        self.updateUI()
    }
    
    //MARK: - ==========UI===========
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func setColors() {
        self.topView.backgroundColor = UIColor().blackBackgroundPrimary()
        self.doneButton.backgroundColor = UIColor().blackBackgroundPrimary()
    }
    
    func setFonts() {
        self.doneButton.titleLabel?.font = Fonts.DoneButton
        self.titleLabel.font = Fonts.SingleViewTitle
        self.genreLabel.font = Fonts.SingleViewGenres
        self.descTextView.font = Fonts.SingleViewDesc
        
    }
    
    //MARK: - ==Set images and labels==
    func updateUI() {
        self.posterView.image = poster()
        self.titleLabel.text = self.movie.title + "\n(" + self.movie.releaseDate.year() + ")"
        let genres = Array(self.movie.genres).prefix(3)
        self.genreLabel.text = Array(genres).asString()
        self.descTextView.text = self.movie.desc
        self.updateSelectorStates()
       
    }
    
    func updateSelectorStates() {
        //MARK: Reset images
        
        var liked = false
        var watched = false
        var loved = false
        var notInterested = false
        for button in [self.watchedButton, self.likeButton, self.notInterestedButton, self.loveButton] {
            button!.isEnabled = true
        }

        //MARK: Set Images
        if let savedMovie = self.dataManager.movie(withId: self.movie.id) {
            
            //Mark liked or watched
            if savedMovie.watched {
                watched = true
                self.watchedButton.isEnabled = false
            } else if savedMovie.love {
                loved = true
                self.loveButton.isEnabled = false
            } else {
                liked = true
                self.likeButton.isEnabled = false
            }
            
        } else if Prefs.swipedMovies.contains(self.movie.id) {
            notInterested = true
            self.notInterestedButton.isEnabled = false
        }
        
//        self.likeButton.setImage(SelectorIcon().image(for: .toWatch, deselected: !liked), for: .normal)
//        self.watchedButton.setImage(SelectorIcon().image(for: .watched, deselected: !watched), for: .normal)
//        self.loveButton.setImage(SelectorIcon().image(for: .loved, deselected: !loved), for: .normal)
//        self.notInterestedButton.setImage(SelectorIcon().image(for: .notInterested, deselected: !notInterested), for: .normal)
    }

    //MARK: - ==GET DATA OR SAVED IMAGE==
    func poster()-> UIImage {
        if let data = self.posterData, let image = UIImage(data:data) {
                return image
            } else {
                self.posterView.loadImageIfNecessary()
            return self.movie.poster
            }
        
    }
    
    //MARK: - ========== SELECTOR  FUNCTIONS ==========
    
    @IBAction func selectorPressed(_ sender: UIButton) {
        self.addOrUpdateMovie(MovieSelector(rawValue: sender.tag)!)
        self.changed = true
    }
    
    func addOrUpdateMovie(_ selector:MovieSelector) {
        
        if Prefs.swipedMovies.contains(movie.id) {
            print("contained in swiped")
        } else {
            print("not contained in swiped")
        }
            //CHECK if movie is already liked
            if let savedMovie = dataManager.movie(withId: movie.id) {
                
                if selector == .notInterested {
                    //Duplicate and delete
                    let movie = Movie(value:self.movie)
                    self.movie = movie
                    self.dataManager.deleteObject(object: savedMovie)
                    
                } else {
                    //UPDATE
                    var loved = movie.love
                    var watched = movie.watched
                    
                    if selector == .loved {
                        loved = !loved
                        if loved == true {watched = false}
                    } else if (selector == .toWatch) == (watched == true) {
                        watched = !watched
                        loved = false
                    } else {
                        loved = false
                    }
                    
                    dataManager.updateMovie(movie: savedMovie, updatedValues: ["watched":watched, "love":loved])
                    self.movie = savedMovie
                }
            } else {
                Prefs.swipedMovies.append(self.movie.id)
                print("appended \(movie.title)")
                if selector != .notInterested {
                    //MARK: Save New
//                    dataManager.saveToFavorites(movie: self.movie, imageData: self.posterData, love: selector == .loved, watched:selector == .watched)
                }
        }
        self.updateSelectorStates()
    }
    
 
    @IBAction func playTrailerPressed(_ sender: Any) {
        guard let url = URL(string: self.movie.trailerUrl) else {return }
        self.trailerButton.isEnabled = false
        let view = TrailerView()
        let webView = WKWebView()
        view.webView = webView
        view.backgroundColor = UIColor().blackBackgroundPrimary(alpha: 0.8)
        view.frame.size = CGSize(width: self.view.frame.width, height: self.view.frame.height)
        webView.frame.size = CGSize(width: self.trailerButton.frame.width * 0.9, height: 0.0)
        webView.isOpaque = false
        webView.backgroundColor = UIColor().blackBackgroundPrimary(alpha: 0.4)
        webView.scrollView.backgroundColor = UIColor().blackBackgroundPrimary(alpha: 0.4)
        
        let buttonPosition = self.view.convert(self.view.frame.origin, from: self.trailerButton)
        let buttonCenter = CGPoint(x: buttonPosition.x + (self.trailerButton.frame.width / 2), y: buttonPosition.y + (self.trailerButton.frame.height / 2))
//        view.center = buttonCenter
        webView.center = buttonCenter
//        view.frame = webView.frame
        
        
        view.alpha = 0
        webView.alpha = 0
        self.view.addSubview(view)
       self.view.addSubview(webView)
        let request = URLRequest(url: url)
        webView.load(request)
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
            
            webView.frame.size = CGSize(width: self.view.frame.width * 0.9, height: ((self.view.frame.width * 0.9) / 16) * 9)
            
            webView.center = self.view.center
            webView.alpha = 1
            
            
        }) { _ in
            
        }
        UIView.animate(withDuration: 0.6, delay: 0.2, options: .curveEaseIn, animations: {

            view.alpha = 1
        }) { _ in
            //On completion
            self.trailerBkgView = view
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissTrailerView(_:)))
            view.addGestureRecognizer(tap)
        }
        
    }
    
    @objc func dismissTrailerView(_ gesture:UITapGestureRecognizer) {
        guard let view = self.trailerBkgView else {return}
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
            view.frame.size = CGSize(width: view.frame.width, height: 0)
            view.webView.frame.size = CGSize(width: view.webView.frame.width, height: 0)
            view.center = self.view.center
            view.webView.center = self.view.center
            view.alpha = 0
            view.webView.alpha = 0
        }) { _ in
            self.trailerButton.isEnabled = true
            self.trailerBkgView = nil
            view.webView.removeFromSuperview()
            view.removeFromSuperview()
        }

    }
    

    //MARK: - ==========NAVIGATION===========

    @IBAction func backPressed(_ sender: Any) {
        
        self.dismiss(animated: true) {
            self.delegate?.backFromSingleMovie(changed: self.changed)
//            if self.delegate != nil {
////                self.delegate!.container.newQueryManager.queryPosters(forMovies: self.delegate!.container.newQueryManager.searchResults)
//            } else if self.likedDelegate != nil {
//                self.likedDelegate!.movieTable.reloadData()
//            }
        }
    }
}



