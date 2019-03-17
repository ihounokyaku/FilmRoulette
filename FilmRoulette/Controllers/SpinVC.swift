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
class SpinVC: NavSubview {

//MARK: - ===========IBOUTLETS============
    
    
    //MARK: - ==PICKERS N TABLES==
    @IBOutlet weak var singlePicker: UIPickerView!
    @IBOutlet weak var rouletteView:GeminiCollectionView!
    
    
    //MARK: - ==Buttons==
    @IBOutlet weak var spinButton: UIButton!
    
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
            return options[self.container.selector.indexOfSelectedItem]
        }
    }
    
    //MARK: SCROLLING
    var spinner:Spinner!
    
    
//MARK: - ========== SETUP ==========
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK: - ==DELEGATES AND DATASOURCES==
        self.singlePicker.delegate = self
        self.singlePicker.dataSource = self
        self.rouletteView.decelerationRate = UIScrollViewDecelerationRateFast
        self.rouletteView.delegate = self
        self.rouletteView.dataSource = self
        
        //MARK: - == Appearance ==
        self.spinner = Spinner(collectionView: self.rouletteView)
        //MARK: - ==SETUP ANIMATION AND LOAD DATASOURCE==
        self.rouletteView.gemini.circleRotationAnimation().radius(1000).rotateDirection(.anticlockwise).itemRotationEnabled(true).scale(0.8).scaleEffect(.scaleUp).ease(GeminiEasing.easeOutSine)
        
        //        self.displayTypeController.selectedSegmentIndex = Prefs.selectorPosition
        self.loadRoulette()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.setSelector(buttonCount:3, color: nil, label1: "All", label2: "Unwatched", label3:"Starred")
    }
    
    
    //MARK: - == Appearance ==
    
    
    
//MARK: - ========= UI UPDATE ==========
    
    //MARK: - ==SWITCH DISPLAY==
    override func selectionDidChange(sender: Selector) {
        if sender.indexOfSelectedItem == 2 {
            if Prefs.canBeIncluded.count == 0 && Prefs.mustBeIncluded.count == 0 && Prefs.excluded.count == 0  {
                self.presentView(withIdentifier: .rouletteFilter)
                return
            }
        }
        self.loadRoulette()
    }
    
    
    func loadRoulette() {
        if self.container.selector.indexOfSelectedItem == 2 {
            self.loadFromSettings()
        } else {
            self.loadFromFolder()
        }
        
        self.singlePicker.isHidden = self.container.selector.indexOfSelectedItem == 2
//        self.settingsButton.isHidden = self.displayTypeController.selectedSegmentIndex == 0
    }
    
    
    
    //MARK: - ==LOAD FROM FOLDER==
    func loadFromFolder() {
        
        let genres = GlobalDataManager.genres
        
        if singlePicker.selectedRow(inComponent: 0) == 0 {
            GlobalDataManager.moviesDisplayed = GlobalDataManager.allMovies
            
        } else if singlePicker.selectedRow(inComponent: 0) == 1 {
            GlobalDataManager.moviesDisplayed = GlobalDataManager.fsMovies
            
        } else if singlePicker.selectedRow(inComponent: 0) < genres.count + 2 {
            GlobalDataManager.moviesDisplayed = GlobalDataManager.movies(withGenre: genres[self.singlePicker.selectedRow(inComponent: 0) - 2])
        } else {
            GlobalDataManager.moviesDisplayed = GlobalDataManager.allGroups[self.singlePicker.selectedRow(inComponent: 0) - (2 + genres.count)].movies.filter("TRUEPREDICATE")
        }
        
        GlobalDataManager.moviesDisplayed = GlobalDataManager.movies(GlobalDataManager.moviesDisplayed, filteredBy: self.displayOption)
        
        self.reloadRoulette()
    }
    
    
    //MARK: - ==CUSTOM ARRAY==
    func loadFromSettings() {
        GlobalDataManager.moviesDisplayed = GlobalDataManager.allMovies
        
        if Prefs.mustBeIncluded.count > 0 {
            GlobalDataManager.moviesDisplayed = GlobalDataManager.moviesDisplayed.filter(self.compoundTagPredicate(and: true, tags: Prefs.mustBeIncluded))
        }
        if Prefs.canBeIncluded.count > 0 {
            GlobalDataManager.moviesDisplayed = GlobalDataManager.moviesDisplayed.filter(self.compoundTagPredicate(and: false, tags: Prefs.canBeIncluded))
        }
        for tag in Prefs.excluded  {
            if let genre = GlobalDataManager.genre(named: tag) {
                GlobalDataManager.moviesDisplayed = GlobalDataManager.moviesDisplayed.filter("NOT (%@ IN genreList)", genre)
            } else if let tag = GlobalDataManager.tag(named: tag) {
                GlobalDataManager.moviesDisplayed = GlobalDataManager.moviesDisplayed.filter("NOT (%@ IN tags)", tag)
            }
        }
        print("going to reload func")
        self.reloadRoulette()
    }
    
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
            self.spinner.spin(toIndex: RandomInt(upTo:self.displayCount - 1), outOf: self.displayCount)
        }
    }
    
    
//MARK: - ========= Navigation ==========
    
    @IBAction func settingPressed(_ sender: Any) {
        self.presentView(withIdentifier: .rouletteFilter)
    }
    
    
    func presentView(withIdentifier identifier:VCIdentifier) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let controller = storyboard.instantiateViewController(withIdentifier: identifier.rawValue) as? SettingsVC else {return}
    
        //MARK: Configure and Present VC
        controller.delegate = self
        controller.modalPresentationStyle = .popover
        self.present(controller, animated:true, completion:nil)
    }
    
}

//MARK: - ==========PICKERVIEW DATASOURCE===============

extension SpinVC : UIPickerViewDataSource {
    
    //MARK: - ==NUMBERS OF SECTIONS AND ROWS==
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return GlobalDataManager.allGroups.count + GlobalDataManager.genres.count + 2
    }
    
    //MARK: - ==TITLE FOR ROW==
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        let genres = GlobalDataManager.genres
        if row == 0 {
            return "All Movies"
        } else if row == 1 {
            return "FilmSwipe Movies"
        } else if row < genres.count + 2 {
            return genres[row - 2].name
        }
        return GlobalDataManager.allGroups[row - (2 + genres.count)].name
    }
}

//MARK: - ==========PICKERVIEW DELEGATE===============
extension SpinVC : UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.loadFromFolder()
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
        
        cell.posterImageView.image = self.noMovies ? #imageLiteral(resourceName: "blank") : GlobalDataManager.moviesDisplayed[indexPath.row % GlobalDataManager.moviesDisplayed.count].poster
        
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
    
}




