//
//  ViewController.swift
//  FilmRoulette
//
//  Created by Dylan Southard on 2018/07/09.
//  Copyright © 2018 Dylan Southard. All rights reserved.
//

import UIKit

class SpinVC: NavSubview {

//MARK: - ===========IBOUTLETS============
    
    
    //MARK: - ==PICKERS N TABLES==
    @IBOutlet weak var singlePicker: UIPickerView!
    

    
//MARK: - ========== SETUP ==========
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK: - ==DELEGATES AND DATASOURCES==
        self.singlePicker.delegate = self
        self.singlePicker.dataSource = self
        
    }

    
}

//MARK: - ==========PICKERVIEW DATASOURCE===============

extension SpinVC : UIPickerViewDataSource {
    
    //MARK: - ==NUMBERS OF SECTIONS AND ROWS==
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.container.dataManager.tags.count + 1
    }
    
    //MARK: - ==TITLE FOR ROW==
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row == 0 {
            return "FilmSwipe Movies"
        }
        return self.container.dataManager.tags[row - 1].name
    }
    
    
    
}

//MARK: - ==========PICKERVIEW DELEGATE===============
extension SpinVC : UIPickerViewDelegate {
    
}

