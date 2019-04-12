//
//  YearRangePicker.swift
//  FilmRoulette
//
//  Created by Dylan Southard on 2019/04/09.
//  Copyright © 2019 Dylan Southard. All rights reserved.
//

import UIKit

protocol YearRangePickerDelegate {
    func yearPickerDidChange(yearPicker:YearRangePicker)
    
}

extension YearRangePickerDelegate {
    func yearPickerDidChange(yearPicker:YearRangePicker) {}
}



class YearRangePicker: UIView, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    //MARK: - =============== IBOUTLETS ===============
    
    var startYearPicker: UIPickerView? {
        didSet {
            self.setDelegateAndDataSource(forPicker: self.startYearPicker)
        }
    }
    var endYearPicker: UIPickerView? {
        didSet {
            self.setDelegateAndDataSource(forPicker: self.endYearPicker)
        }
    }
    
    
    //MARK: - =============== VARS ===============
    
    //MARK: - === Objects ===
    
    var delegate:YearRangePickerDelegate?
    
    //MARK: - === Year Vars ===
    var minYear = 1900
    var maxYear = Date().year()
    
    
    var startYear:Int {
        get {
            return savedStartYear
        }
    }
    
    var endYear:Int {
        get {
            return savedEndYear
        }
    }
    
    
    private var savedStartYear:Int {
        get { return UserDefaults.standard.value(forKey: self.startYearKey) as? Int ?? self.minYear }
        set { UserDefaults.standard.set(newValue, forKey: self.startYearKey) }
    }
    
    private var savedEndYear:Int {
        get { return UserDefaults.standard.value(forKey: self.endYearKey) as? Int ?? self.maxYear }
        set { UserDefaults.standard.set(newValue, forKey: self.endYearKey) }
    }
    
    //MARK: - === StringValues ===
    private var startYearKey = "StartYear"
    private var endYearKey = "EndYear"
    
    //MARK: - === UIOptions ===
    
    var endPickerTextColor = UIColor().colorTextEmphasisLight()
    var startPickerTextColor = UIColor().colorTextEmphasisLight()
    
    var textColor = UIColor().colorTextEmphasisLight() {
        didSet {
            self.endPickerTextColor = self.textColor
            self.startPickerTextColor = self.textColor
        }
    }
    
    var endPickerBackgroundColor = UIColor.clear
    var startPickerBackgroundColor = UIColor.clear
    
    var pickerBackgroundColor = UIColor.clear {
        didSet {
            self.endPickerBackgroundColor = self.pickerBackgroundColor
            self.startPickerBackgroundColor = self.pickerBackgroundColor
        }
    }
    
    var pickerLabelFont = Fonts.YearPickerFont
   
    
    //MARK: - =============== CONFIGURE ===============
    
    
    func configure(startPicker:UIPickerView, endPicker:UIPickerView, startYear:Int?, endYear:Int?, delegate:YearRangePickerDelegate?){
        
        if let sy = startYear, sy < self.maxYear, sy >= self.minYear {
            self.savedStartYear = sy
            if sy < self.minYear {self.minYear = sy}
        } else {
            self.savedStartYear = self.minYear
        }
        
        if let ey = endYear, ey > self.minYear, ey <= self.endYear {
            self.savedEndYear = ey
            if ey > self.maxYear {self.maxYear = ey}
        } else {
            print("max year is \(self.maxYear)")
            self.savedEndYear = self.maxYear
        }
        
        self.startYearPicker = startPicker
        self.endYearPicker = endPicker
        self.reloadPickerData()
        
        
        self.startYearPicker!.selectRow(self.savedStartYear - minYear, inComponent: 0, animated: false)
        self.endYearPicker!.selectRow(self.savedEndYear - minYear, inComponent: 0, animated: false)
        self.delegate = delegate
    }
    
    private func setDelegateAndDataSource(forPicker picker:UIPickerView?) {
        guard picker != nil else {return}
        picker!.dataSource = self
        picker!.delegate = self
    }
    
    func reloadPickerData(){
        self.startYearPicker?.reloadAllComponents()
        self.endYearPicker?.reloadAllComponents()
    }
    
    
    //MARK: - =============== PICKER VIEW DATASOURCE ===============
    
    //MARK: - === NUMBERS ===
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return self.maxYear - self.minYear
        if pickerView == self.endYearPicker  {
            return self.maxYear - self.minYear + 1
        } else if pickerView == self.startYearPicker {
            return self.maxYear - self.minYear
        }
        return 0
    }
    
    //MARK: - === VIEWS ===
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel: UILabel? = (view as? UILabel)
        if pickerLabel == nil {
            pickerLabel = UILabel()
            pickerLabel?.font = self.pickerLabelFont
            pickerLabel?.textAlignment = .center
        }
        pickerLabel?.text = "\(row + self.minYear)"
        pickerLabel?.textColor = pickerView == self.startYearPicker ? self.startPickerTextColor : self.endPickerTextColor
        pickerLabel?.backgroundColor = pickerView == self.startYearPicker ? self.startPickerBackgroundColor : self.endPickerBackgroundColor
        
        pickerLabel?.shadowColor = UIColor.clear
        pickerLabel?.shadowOffset = CGSize(width:0,height:1);
        
        return pickerLabel!
    }
    
    //MARK: - =============== PICKERVIEW DELEGATE ===============
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //MARK: Change start or end year when components picked
        self.setMinMax()
        self.savedEndYear = self.minYear + self.endYearPicker!.selectedRow(inComponent: 0)
        self.savedStartYear = self.minYear + self.startYearPicker!.selectedRow(inComponent: 0)
        self.delegate?.yearPickerDidChange(yearPicker:self)
    }
    
    private func setMinMax() {
        guard endYearPicker != nil && self.startYearPicker != nil else {return}
        let selectedEndYear = self.endYearPicker!.selectedRow(inComponent: 0)
        let selectedStartYear = self.startYearPicker!.selectedRow(inComponent: 0)
        if selectedEndYear < selectedStartYear {
            if selectedStartYear < self.endYearPicker!.numberOfRows(inComponent: 0) - 1 {
                self.endYearPicker!.selectRow(selectedStartYear, inComponent: 0, animated: true)
            } else {
                self.startYearPicker!.selectRow(selectedEndYear, inComponent: 0, animated: true)
            }
        }
    }

}
