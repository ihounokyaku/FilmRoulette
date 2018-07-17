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
            return self.container.dataManager.moviesDisplayed.count
        }
    }
    
    //MARK: SCROLLING
    var stillScrolling = false
    var finalDestination = 0
    var fullSpins = 0
    var scrollInterval = 0
    var currentDestination = 0
    var sleep:TimeInterval = 0
    var startRow = 0
    var decelerating = false
    var decelerateCount = 1
    
    
//MARK: - ========== SETUP ==========
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK: - ==DELEGATES AND DATASOURCES==
        self.singlePicker.delegate = self
        self.singlePicker.dataSource = self
        self.rouletteView.decelerationRate = UIScrollViewDecelerationRateFast
        self.rouletteView.delegate = self
        self.rouletteView.dataSource = self
        
        //MARK: - ==SETUP ANIMATION AND LOAD DATASOURCE==
        self.rouletteView.gemini.circleRotationAnimation().radius(1000).rotateDirection(.anticlockwise).itemRotationEnabled(true).scale(0.8).scaleEffect(.scaleUp).ease(GeminiEasing.easeOutSine)
        self.loadRoulette()
        
    }
    
//MARK: - ========= UI UPDATE ==========
    //MARK: - ==LOAD ROULETTE==
    func loadRoulette() {
        
        let genres = self.container.dataManager.genres
        
        if singlePicker.selectedRow(inComponent: 0) == 0 {
            self.container.dataManager.moviesDisplayed = self.container.dataManager.allMovies
            
        } else if singlePicker.selectedRow(inComponent: 0) == 1 {
            self.container.dataManager.moviesDisplayed = self.container.dataManager.fsMovies
            
        } else if singlePicker.selectedRow(inComponent: 0) < genres.count + 2 {
            
        } else {
            self.container.dataManager.moviesDisplayed = self.container.dataManager.movies(withTag: self.container.dataManager.tags[self.singlePicker.selectedRow(inComponent: 0) - (2 + genres.count)])
        }
        
        self.rouletteView.reloadData()
        if !self.noMovies {
            self.rouletteView.deselectItem(at: IndexPath(row: 10000, section: 0) , animated: false)
        }
    }
    
  
    
    
    @IBAction func spinPressed(_ sender: Any) {
        if self.displayCount > 0 {
            self.spin()
        }
    }
    
    
}

//MARK: - ==========PICKERVIEW DATASOURCE===============

extension SpinVC : UIPickerViewDataSource {
    
    //MARK: - ==NUMBERS OF SECTIONS AND ROWS==
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.container.dataManager.tags.count + self.container.dataManager.genres.count + 2
    }
    
    //MARK: - ==TITLE FOR ROW==
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        let genres = self.container.dataManager.genres
        if row == 0 {
            return "All Movies"
        } else if row == 1 {
            return "FilmSwipe Movies"
        } else if row < genres.count + 2 {
            return genres[row - 2].name
        }
        
        return self.container.dataManager.tags[row - (2 + genres.count)].name
    }
    
    
    
}

//MARK: - ==========PICKERVIEW DELEGATE===============
extension SpinVC : UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
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
        return 100000000
    }
    
    //MARK: - ==VIEW FOR CELL==
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PosterCell", for: indexPath) as! PosterCell
        cell.posterImageView.image = self.noMovies ? #imageLiteral(resourceName: "blank") : self.container.dataManager.moviesDisplayed[indexPath.row % self.container.dataManager.moviesDisplayed.count].poster

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


//MARK: - ==========SPIN FUNCTIONS==========
extension SpinVC {
    
    
    
    
    func spin() {
        self.startRow = self.rouletteView.indexPathsForVisibleItems.first?.row ?? 0
        self.fullSpins = self.displayCount > 20 ? RandomInt(upTo: 5) + 5 : RandomInt(upTo: 5) + 10
        self.finalDestination = RandomInt(upTo:self.displayCount - 1) + (self.fullSpins * self.displayCount)
        while self.finalDestination < self.startRow + 300 {
            self.finalDestination += self.displayCount
            
        }
        
        self.stillScrolling = true
        self.currentDestination = self.startRow + self.displayCount
        self.scroll()

        
    }
    
    @objc func scroll() {
        
        
        self.rouletteView.selectItem(at: IndexPath(row: self.currentDestination, section: 0), animated: true, scrollPosition: .centeredHorizontally)

        if self.currentDestination >= self.finalDestination {
            self.stillScrolling = false
            return
        }
        
        if self.fullSpins > 0 {
            print("spinning again \(self.fullSpins)")
            self.fullSpins -= 1
            self.currentDestination += self.displayCount
            return
        }
        
        if !decelerating {
            while self.currentDestination >= self.finalDestination - 20 {
                self.finalDestination += self.displayCount
            }
            self.currentDestination = self.finalDestination - 20 + RandomInt(upTo: 5)
            self.scrollInterval = 1
            self.decelerating = true
            return
        }
        
        
        self.currentDestination += self.scrollInterval
        if self.scrollInterval > 1 {
            self.scrollInterval -= 1
        }
        
    }
    
    func resetScrollVariables() {
        self.stillScrolling = false
        self.finalDestination = 0
        self.fullSpins = 0
        self.scrollInterval = 0
        self.currentDestination = 0
        self.sleep = 0
        self.startRow = 0
        self.decelerating = false
    }
    
   
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("ended!")
    }
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if self.stillScrolling {
            if self.decelerating {
                self.sleep += 0.001 * Double(self.decelerateCount)
                self.decelerateCount += 1
                
                self.perform(#selector(scroll), with: nil, afterDelay: sleep)
            } else {
               self.scroll()
            }
            
        } else {
            print("done")
            self.resetScrollVariables()
        }

    }
    
}




