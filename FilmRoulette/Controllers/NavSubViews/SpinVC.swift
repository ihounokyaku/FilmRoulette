//
//  ViewController.swift
//  FilmRoulette
//
//  Created by Dylan Southard on 2018/07/09.
//  Copyright © 2018 Dylan Southard. All rights reserved.
//

import UIKit
import RealmSwift
import Gemini

enum LibraryType:CaseIterable {
    case library
    case filmSwipe
}

class SpinVC: NavSubview, SpinFiltersDelegate, PosterGetterDelegate, SpinnerDelegate, SingleMovieDelegate {
    
    

//MARK: - ===========IBOUTLETS============
    
    
    //MARK: - ==PICKERS N TABLES==
    
    @IBOutlet weak var rouletteView:GeminiCollectionView!
    
    //MARK: - === VIEWS ===
    @IBOutlet weak var backgroundViewGradient: UIImageView!
    @IBOutlet weak var backgroundImageView: FadingImageView!
    
    
    //MARK: - ==Buttons==
    @IBOutlet weak var spinButton: UIButton!
    @IBOutlet weak var spinSelector: Selector!
    
    //MARK: Selector Buttons
    
    @IBOutlet weak var allButton: UIButton!
    @IBOutlet weak var unwatchedButton: UIButton!
    @IBOutlet weak var starredButton: UIButton!
    
    
    
//MARK: - ===========VARIABLES============
    
    //MARK: - ==State Vars==
    var noMovies:Bool {
        get {
            return self.displayCount == 0
        }
    }
    
    var displayCount:Int {
        get {
            return GlobalDataManager.moviesDisplayed.count
        }
    }
    
    var displayOption:MovieOption? {
        get {
            let options:[Int:MovieOption] = [1:.unwatched, 2:.loved]
            return options[self.spinSelector.indexOfSelectedItem]
        }
    }
    
    var filterType:FilterType {
        get {
            guard let object = self.filterObject else {return .none}
            return (object as? Filter != nil) ? .complex : .simple
        }
    }
    
    var filterObject:Object? {
        didSet {
            SessionData.CurrentFilterObject = self.filterObject
            self.loadRoulette()
        }
    }
    
    var libraryType:LibraryType {
        guard LibraryType.allCases.count > self.navContainer.selector.indexOfSelectedItem else {return .library}
        return LibraryType.allCases[self.navContainer.selector.indexOfSelectedItem]
    }
    
    
   //MARK: - === OBJECTS ===
    var spinner:Spinner!
    var posterGetter:PosterGetter!
    
    
//MARK: - ========== SETUP ==========
    override func viewDidLoad() {
        super.viewDidLoad()
        self.posterGetter = PosterGetter(delegate: self)
        self.subViewType = .spinner
        self.rouletteView.decelerationRate = UIScrollViewDecelerationRateFast
        self.rouletteView.delegate = self
        self.rouletteView.dataSource = self
        
        self.rouletteView.showsHorizontalScrollIndicator = false
        //MARK: - == Appearance ==
        self.spinner = Spinner(collectionView: self.rouletteView)
        self.spinner.delegate = self
        //MARK: - ==SETUP ANIMATION AND LOAD DATASOURCE==
    self.rouletteView.gemini.circleRotationAnimation().radius(1000).rotateDirection(.anticlockwise).itemRotationEnabled(true).scale(0.8).scaleEffect(.scaleUp).ease(GeminiEasing.easeOutSine)
        
        
        //        self.displayTypeController.selectedSegmentIndex = Prefs.selectorPosition
        //MARK: - == SET FILTER ==
        
        
        self.filterObject = SessionData.CurrentFilterObject
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(true)
        if self.libraryType == .library {
            self.posterGetter.completeMissingPosters(forMovies: GlobalDataManager.moviesDisplayed)
        }
        self.loadRoulette()
    }
    
    override func configureSelector() {
        self.setSelector(buttonCount:2, color: nil, label2: "My Library", label3:"FilmSwipe")
        self.spinSelector.configure(buttons: [self.allButton, self.unwatchedButton, self.starredButton], highlightColor: UIColor().colorTextEmphasisLight(), delegate: self)
    }
    
    
    //MARK: - == Appearance ==
    
    
    
//MARK: - ========= UI UPDATE ==========
    
    //MARK: - ==SWITCH DISPLAY==
    override func selectionDidChange(sender: Selector) {
        super.selectionDidChange(sender: sender)
        self.loadRoulette()
    }

    //MARK: - ==== QUERY ANY POSTERS ====
    
    
    func completeMissingPosters() { self.posterGetter.completeMissingPosters(forMovies: GlobalDataManager.moviesDisplayed) }
    
    func loadedPoster() { self.reloadRoulette() }
    
    
    
//MARK: - =============== SET ROULETTE ===============
    
    //MARK: - == GET FILTERS ==
    func filterResults(withObject object: Object?) {
        self.filterObject = object
        //TODO: - simple or complex
        Prefs.SpinFilterType = FilterType.allCases.firstIndex(of: .simple)!
        self.loadRoulette()
    }
    
    
    //MARK: - == LOAD with FILTERS ==
    func loadRoulette() {
        
        if self.libraryType == .library {
            GlobalDataManager.moviesDisplayed = GlobalDataManager.allMovies
        } else {
            GlobalDataManager.moviesDisplayed = GlobalDataManager.fsMovies
        }
        
        GlobalDataManager.moviesDisplayed = GlobalDataManager.movies(GlobalDataManager.moviesDisplayed, filteredBy: self.filterObject, libraryType: self.libraryType)
        
        
        GlobalDataManager.moviesDisplayed = GlobalDataManager.movies(GlobalDataManager.moviesDisplayed, filteredBy: self.displayOption)
        
        self.reloadRoulette()
    }
    
//    func applyFilters() {
//        guard self.filterObject != nil else {return}
//        if self.filterType == .simple {
//            if let genre = self.filterObject as? Genre {
//                GlobalDataManager.moviesDisplayed = GlobalDataManager.movies(withGenre: genre)
//            } else if let group = self.filterObject as? Group {
//                GlobalDataManager.moviesDisplayed = group.movies.filter("TRUEPREDICATE")
//            } else if let tag = self.filterObject as? Tag {
//                GlobalDataManager.moviesDisplayed = GlobalDataManager.movies(withTag: tag)
//            }
//        } else if let filter = self.filterObject as? Filter, self.libraryType == .library {
//            GlobalDataManager.moviesDisplayed = filter.apply(to: GlobalDataManager.moviesDisplayed, delegate: GlobalDataManager)
//        }
//    }

    
    
    //MARK: - ==CUSTOM ARRAY==
//    func loadFromSettings() {
//        GlobalDataManager.moviesDisplayed = GlobalDataManager.allMovies
//
//        if Prefs.mustBeIncluded.count > 0 {
//            GlobalDataManager.moviesDisplayed = GlobalDataManager.moviesDisplayed.filter(self.compoundTagPredicate(and: true, tags: Prefs.mustBeIncluded))
//        }
//        if Prefs.canBeIncluded.count > 0 {
//            GlobalDataManager.moviesDisplayed = GlobalDataManager.moviesDisplayed.filter(self.compoundTagPredicate(and: false, tags: Prefs.canBeIncluded))
//        }
//        for tag in Prefs.excluded  {
//            if let genre = GlobalDataManager.genre(named: tag) {
//                GlobalDataManager.moviesDisplayed = GlobalDataManager.moviesDisplayed.filter("NOT (%@ IN genreList)", genre)
//            } else if let tag = GlobalDataManager.tag(named: tag) {
//                GlobalDataManager.moviesDisplayed = GlobalDataManager.moviesDisplayed.filter("NOT (%@ IN tags)", tag)
//            }
//        }
//        print("going to reload func")
//        self.reloadRoulette()
//    }
    
    func compoundTagPredicate(and:Bool, tags:[String])-> NSCompoundPredicate {
        var predicates = [NSPredicate]()
        
        for tag in tags {
            if let genre = GlobalDataManager.genre(named: tag) {
                predicates.append(NSPredicate(format: "%@ IN genreList", genre))
            } else if let tag = GlobalDataManager.tag(named: tag) {
                predicates.append(NSPredicate(format: "%@ IN tags", tag))
            }
        }
        if and {
            return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        }
        return NSCompoundPredicate(orPredicateWithSubpredicates: predicates)
    }
    
    //MARK: - ==RELOAD==
    func reloadRoulette() {
       print("going to reload")
        
        DispatchQueue.main.async {
            self.rouletteView.reloadData()
            if !self.noMovies {
                self.rouletteView.deselectItem(at: IndexPath(row: 10000, section: 0) , animated: false)
            }
        }
        
        
    }
  
    
    //MARK: - ==========SPIN==========
    @IBAction func spinPressed(_ sender: Any) {
        
        if self.displayCount > 0 {
            self.backgroundImageView.clearImage()
            self.spinner.spin(toIndex: RandomInt(upTo:self.displayCount - 1), outOf: self.displayCount)
        }
    }
    
    
//MARK: - ========= Navigation ==========
    
    @IBAction func settingPressed(_ sender: Any) {
        self.presentView(withIdentifier: .rouletteFilter)
    }
    
    @IBAction func clearFiltersPressed(_ sender: Any) {
        self.filterObject = nil
        self.loadRoulette()
    }
    
}



//MARK: - ==========WHEELPICKER DATASOURCE===============
extension SpinVC : UICollectionViewDataSource {
    
    //MARK: - ==NO of CELLS==
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       
        if self.noMovies {
            return 1
        }
        return 1000000
    }
    
    //MARK: - ==VIEW FOR CELL==
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PosterCell", for: indexPath) as! PosterCell
        if !self.noMovies {
            cell.configure(movie: GlobalDataManager.moviesDisplayed[indexPath.row % GlobalDataManager.moviesDisplayed.count], poster: GlobalDataManager.moviesDisplayed[indexPath.row % GlobalDataManager.moviesDisplayed.count].poster, loading: self.posterGetter.loading)
        }
        
        
//        cell.posterImageView.image = self.noMovies ? #imageLiteral(resourceName: "blank") : GlobalDataManager.moviesDisplayed[indexPath.row % GlobalDataManager.moviesDisplayed.count].poster
        
        self.rouletteView.animateCell(cell)
        
        return cell
        
    }
    
    
}

//MARK: - ==========WHEELPICKER DELEGATE===============

extension SpinVC : UICollectionViewDelegate {
    
    //MARK: - ==ANIMATE WHEN SCROLLING==
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.rouletteView.animateVisibleCells()
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? GeminiCell {
            
            self.rouletteView.animateCell(cell)
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("ended scrolling")
        self.selectCenter()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.selectCenter()
    }
    
    func selectCenter() {
        guard let cell = rouletteView.centerCell as? PosterCell else {print("not poster cell"); return}
        let indexPath = self.rouletteView.indexPath(for: cell)
        self.rouletteView.scrollToItem(at: indexPath!, at: .centeredHorizontally, animated: true)
        self.backgroundImageView.setImage(cell.posterImageView.image)
    }
    
    func selectedItem(atIndexPath indexPath:IndexPath) {
        guard let cell = rouletteView.cellForItem(at: indexPath) as? PosterCell else {return}
        self.backgroundImageView.setImage(cell.posterImageView.image)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let cell = self.rouletteView.cellForItem(at: indexPath) as? PosterCell, let movie = cell.movie else {return}
//        self.presentSingleMovieView(movie: movie, imageData: movie.poster, filmSwipe: false, sender: self)
    }
    
    func backFromSingleMovie(changed: Bool) {
        if changed { self.reloadRoulette() }
    }
    
    
}


extension UICollectionView {
    var centerCell:UICollectionViewCell? {
        get {
            let closestCell = self.visibleCells[0]
            for cell in self.visibleCells as [UICollectionViewCell] {
                let closestCellDelta = abs(closestCell.center.x - self.bounds.size.width/2.0 - self.contentOffset.x + 50)
                let cellDelta = abs(cell.center.x - self.bounds.size.width/2.0 - self.contentOffset.x)
                if (cellDelta < closestCellDelta){
                    return cell
                }
            }
            return nil
        }
    }
}





