//
//  ViewController.swift
//  FilmRoulette
//
//  Created by Dylan Southard on 2018/07/09.
//  Copyright © 2018 Dylan Southard. All rights reserved.
//

import UIKit
import Gemini

enum LibraryType:CaseIterable {
    case library
    case filmSwipe
}

protocol FilterObject {
    func filter(movies:[Movie])->[Movie]
    var name:String {get}
    var filterType:FilterObjectType{get}
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
    
    var moviesDisplayed = [Movie]()
    
    //MARK: - ==State Vars==
    var noMovies:Bool { return self.displayCount == 0 }
    
    var displayCount:Int { return self.moviesDisplayed.count }
    
    var displayOption:MovieOption? {
      
            let options:[Int:MovieOption] = [1:.unwatched, 2:.loved]
            return options[self.spinSelector.indexOfSelectedItem]
        
    }
    
    var filterType:FilterType {
        get {
            guard let object = self.filterObject else {return .none}
            return (object as? Filter != nil) ? .complex : .simple
        }
    }
    
    var filterObject:FilterObject? {
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
        self.rouletteView.decelerationRate = UIScrollView.DecelerationRate.fast
        self.rouletteView.delegate = self
        self.rouletteView.dataSource = self
        self.rouletteView.allowsSelection = true
        self.rouletteView.allowsMultipleSelection = true
        self.rouletteView.showsHorizontalScrollIndicator = false
        //MARK: - == Appearance ==
        self.spinner = Spinner(collectionView: self.rouletteView)
        self.spinner.delegate = self
        
        
        
        //MARK: - ==SETUP ANIMATION AND LOAD DATASOURCE==
    self.rouletteView.gemini.circleRotationAnimation().radius(1000).rotateDirection(.anticlockwise).itemRotationEnabled(true).scale(0.8).scaleEffect(.scaleUp).ease(GeminiEasing.easeOutSine).shadowEffect(.fadeIn)
        
        
        //        self.displayTypeController.selectedSegmentIndex = Prefs.selectorPosition
        //MARK: - == SET FILTER ==
        
        
        self.filterObject = SessionData.CurrentFilterObject
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(true)
        if self.libraryType == .library {
            self.posterGetter.completeMissingPosters(forMovies: self.moviesDisplayed)
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
    
    
    func completeMissingPosters() { self.posterGetter.completeMissingPosters(forMovies: self.moviesDisplayed) }
    
    func loadedPoster(_ toRequery:[Movie]) {
        
        self.reloadRoulette()
      
        self.posterGetter.completeErrorPosters(forMovies: toRequery)
        
    }
    
    
    
//MARK: - =============== SET ROULETTE ===============
    
    //MARK: - == GET FILTERS ==
    func filterResults(withObject object: FilterObject?) {
        
        self.filterObject = object
        
        //TODO: - simple or complex
        Prefs.SpinFilterType = FilterType.allCases.firstIndex(of: .simple)!
        
        self.loadRoulette()
    }
    
    
    //MARK: - == LOAD with FILTERS ==
    func loadRoulette() {
        
        if self.libraryType == .library {
            print("it is all \(SQLDataManager.AllMovies.count)")
            self.moviesDisplayed = SQLDataManager.AllMovies
            
        } else {
            
            self.moviesDisplayed = SQLDataManager.FSMovies
            
        }
        
        if let displayOption = self.displayOption {
            
            self.moviesDisplayed = self.moviesDisplayed.filteredBy(option: displayOption)
            
        }
        
        if let filter = self.filterObject {
            
            
            self.moviesDisplayed = filter.filter(movies: self.moviesDisplayed)
            print("going to filter 2 with\(filter.name) \(filter.filterType)")
        }
       
        self.reloadRoulette()
    }
    

    
//    func compoundTagPredicate(and:Bool, tags:[String])-> NSCompoundPredicate {
//        var predicates = [NSPredicate]()
//
//        for tag in tags {
//            if let genre = GlobalDataManager.genre(named: tag) {
//                predicates.append(NSPredicate(format: "%@ IN genreList", genre))
//            } else if let tag = GlobalDataManager.tag(named: tag) {
//                predicates.append(NSPredicate(format: "%@ IN tags", tag))
//            }
//        }
//        if and {
//            return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
//        }
//        return NSCompoundPredicate(orPredicateWithSubpredicates: predicates)
//    }
    
    //MARK: - ==RELOAD==
    func reloadRoulette() {
       
        
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
            return 0
        }
        return 1000000
    }
    
    //MARK: - ==VIEW FOR CELL==
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PosterCell", for: indexPath) as! PosterCell
        if !self.noMovies {
            cell.configure(movie: self.moviesDisplayed[indexPath.row % self.moviesDisplayed.count],
                           poster: self.moviesDisplayed[indexPath.row % self.moviesDisplayed.count].poster,
                           loading: self.posterGetter.loading)
            self.setShadowRadius(forCell: cell)
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
        if let roulette = scrollView as? GeminiCollectionView, let cells = roulette.visibleCells as? [PosterCell] {
            for cell in cells {
            
                self.setShadowRadius(forCell: cell)
                
                
            }
        }
    }
    
    func setShadowRadius(forCell cell:PosterCell) {
//        let distanceFromCenter = Int(abs(cell.center.x - self.rouletteView.bounds.size.width/2.0 - self.rouletteView.contentOffset.x) / 16)
//
//
//        let shadowSize = distanceFromCenter == 0 ? 10 : CGFloat(20 / distanceFromCenter) / 2
//        print("\(cell.movie?.title) distance \(distanceFromCenter) shadow \(shadowSize)")
//        if cell.shadowRadius != shadowSize {
//            cell.shadowRadius = shadowSize
//        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? GeminiCell {
            
            self.rouletteView.animateCell(cell)
            if let pCell = cell as? PosterCell {
                self.setShadowRadius(forCell: pCell)
            }
            
        }
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
        guard let cell = self.rouletteView.cellForItem(at: indexPath) as? PosterCell, let movie = cell.movie else {return}
        
        self.presentSingleMovieView(movie: movie, imageData: nil, filmSwipe:false, sender: self)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("ended scrolling")
        guard let ip = self.selectCenter() else {return}
        
        self.rouletteView.scrollToItem(at: ip, at: .centeredHorizontally, animated: true)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
       _ = self.selectCenter()
    }
    
    func selectCenter()->IndexPath? {
        
        guard let indexPath = rouletteView.centerCellIndexPath, let cell = self.rouletteView.cellForItem(at: indexPath) as? PosterCell else {print("not centered"); return nil}
    
        self.backgroundImageView.setImage(cell.posterImageView.image)
        return indexPath
    }
    
    func selectedItem(atIndexPath indexPath:IndexPath) {
        guard let cell = rouletteView.cellForItem(at: indexPath) as? PosterCell else {return}
        self.backgroundImageView.setImage(cell.posterImageView.image)
    }
    
  
   
    
    func backFromSingleMovie(changed: Bool) {
        if changed { self.reloadRoulette() }
    }
    
    
}

extension SpinVC : UICollectionViewDelegateFlowLayout {
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width:200, height:300)
//    }
    
}




extension UICollectionView {
    var centerCell:UICollectionViewCell? {
        get {
            let closestCell = self.visibleCells[0]
            for cell in self.visibleCells as [UICollectionViewCell] {
                let closestCellDelta = abs(closestCell.center.x - self.bounds.size.width/2.0 - self.contentOffset.x)
                let cellDelta = abs(cell.center.x - self.bounds.size.width/2.0 - self.contentOffset.x)
                if (cellDelta < closestCellDelta){
                    return cell
                }
            }
            return nil
        }
    }
}





