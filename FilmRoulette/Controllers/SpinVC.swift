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
    
    
    
    
//MARK: - ========== SETUP ==========
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK: - ==DELEGATES AND DATASOURCES==
        self.singlePicker.delegate = self
        self.singlePicker.dataSource = self
        self.rouletteView.delegate = self
        self.rouletteView.dataSource = self
        
        //MARK: - ==SETUP ANIMATION AND LOAD DATASOURCE==
        self.rouletteView.gemini.circleRotationAnimation().radius(1000).rotateDirection(.anticlockwise).itemRotationEnabled(true).scale(0.8).scaleEffect(.scaleUp)
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
        let position = self.rouletteView.indexPathsForVisibleItems.first?.row ?? 0
        let start = self.displayCount > 150 ? position + (displayCount * 3) : position + 500
        let rando = RandomInt(between: start, and: start + displayCount)
        //self.fillDisplayArray(toAtLeast: rando + 12)
        self.rouletteView.scrollToItem(at: IndexPath(row: rando, section: 0), at: .centeredHorizontally, animated: true)
    }
    
//    func randomNumber()-> Int {
//
//    }
    
}




