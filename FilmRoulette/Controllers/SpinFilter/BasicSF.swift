//
//  SettingsVC.swift
//  FilmRoulette
//
//  Created by Dylan Southard on 2018/07/20.
//  Copyright © 2018 Dylan Southard. All rights reserved.
//

import UIKit
import RealmSwift

enum PickerViewDisplayFilter:String, CaseIterable {
    case genre = "Genre"
    case group = "Group"
    case tag = "Tag"
}




class BasicFilterVC: SpinFilterSubview {
    
    //MARK: - =========IBOUTLETS==========
    
    @IBOutlet weak var singlePicker: UIPickerView!
    
    //MARK: - ==Buttons==
    @IBOutlet weak var pickerSelector: Selector!
    
    //MARK: Picker Buttons
    @IBOutlet weak var genreButton: UIButton!
    @IBOutlet weak var groupButton: UIButton!
    @IBOutlet weak var tagButton: UIButton!
    
    //MARK: - ==========VARS============
        
    
    //MARK: - ========== SETUP ==========
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK ==DELEGATES/DATASOURCES==
        self.singlePicker.delegate = self
        self.singlePicker.dataSource = self
        self.view.layoutIfNeeded()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.pickerSelector.configure(buttons: [self.genreButton, self.groupButton, self.tagButton], highlightColor: UIColor().colorSecondaryLight(), delegate: self)
       
        self.pickerSelector.selectItem(atIndex: Prefs.SpinPickerSelectorPosition)
        if self.pickerDataSource.count > 0 {
            self.container.filterObject = self.pickerDataSource[self.singlePicker.selectedRow(inComponent: 0)]
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        
    }
    
    //MARK: - =============== Set Options ===============
    override func selectionDidChange(sender: Selector) {
        Prefs.SpinPickerSelectorPosition = self.pickerSelector.indexOfSelectedItem
        self.singlePicker.reloadAllComponents()
    }
}



    
    

//MARK: - ==========PICKERVIEW DATASOURCE===============

extension BasicFilterVC : UIPickerViewDataSource {
    
    var pickerDisplayFilter:PickerViewDisplayFilter {
        get {
            return PickerViewDisplayFilter.allCases[Prefs.SpinPickerSelectorPosition]
        }
    }

    var pickerDataSource:[Object] {
        get {
            switch self.pickerDisplayFilter {
            case .group:
                return Array(GlobalDataManager.groups)
            case .genre:
                return Array(GlobalDataManager.genres)
            case .tag:
                return Array(GlobalDataManager.tags)
            }
        }
    }
    //MARK: - ==NUMBERS OF SECTIONS AND ROWS==
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return self.pickerDataSource.count
    }
    
    //MARK: - ==TITLE FOR ROW==
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return self.pickerDataSource[row].value(forKey: "name") as? String ?? ""
    }
}

//MARK: - ==========PICKERVIEW DELEGATE===============
extension BasicFilterVC : UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.container.filterObject = self.pickerDataSource[row]
    }
}
