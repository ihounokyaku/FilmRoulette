//
//  ViewController.swift
//  FilmRoulette
//
//  Created by Dylan Southard on 2018/07/09.
//  Copyright © 2018 Dylan Southard. All rights reserved.
//

import UIKit
import WheelPicker
import RealmSwift

class SpinVC: NavSubview {

//MARK: - ===========IBOUTLETS============
    
    
    //MARK: - ==PICKERS N TABLES==
    @IBOutlet weak var singlePicker: UIPickerView!
    @IBOutlet weak var rouletteView: WheelPicker!
    

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
        
        //MARK: - ==UPDATE UI==
        //self.rouletteView.scrollDirection = .horizontal
        //self.rouletteView.style = .style3D
        //self.rouletteView.isMaskDisabled = false
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
        self.rouletteView.select(0, animated: false)
        self.fillDisplayArray()
        self.rouletteView.reloadData()
        if self.displayCount > 2 {
            self.rouletteView.select((self.displayCount / 2) - 1, animated: true)
        }
    }
    
    //MARK: - ==MAKE INFINITE==
    
    func fillDisplayArray() {
        while self.displayCount > 0 && (self.displayCount < 12 || (self.rouletteView.rowOfCenteredItem ?? self.rouletteView.selectedItem) + 5 > self.displayCount) {
            let numberOfObjects:Int = displayCount
            self.container.dataManager.moviesDisplayed.append(objectsIn: self.container.dataManager.moviesDisplayed)
            self.rouletteView.insertCells(numberOfCells: numberOfObjects, beginningAt: numberOfObjects - 1)
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
extension SpinVC : WheelPickerDataSource {
    
    
    func numberOfItems(_ wheelPicker: WheelPicker) -> Int {
        if self.noMovies {
            return 1
        }
        return self.container.dataManager.moviesDisplayed.count
    }
    
    func imageFor(_ wheelPicker: WheelPicker, at index: Int) -> UIImage {
        return self.noMovies ? #imageLiteral(resourceName: "blank") : self.container.dataManager.moviesDisplayed[index].poster
    }
}

//MARK: - ==========WHEELPICKER DELEGATE===============

extension SpinVC : WheelPickerDelegate {
    func wheelPicker(_ wheelPicker: WheelPicker, didSelectItemAt index: Int) {
        //self.fillDisplayArray()
    }
    
    func wheelPickerDidScroll(_ wheelPicker: WheelPicker, direction: UICollectionViewScrollDirection) {
        self.fillDisplayArray()
    }
    
}

extension SpinVC {
    
    func animateScroll() {
        
    }
    
//    func randomNumber()-> Int {
//        
//    }
    
}




