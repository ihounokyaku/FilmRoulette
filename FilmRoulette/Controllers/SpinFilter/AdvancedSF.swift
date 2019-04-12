//
//  AdvancedSpinFilterVC.swift
//  FilmRoulette
//
//  Created by Dylan Southard on 2019/03/17.
//  Copyright © 2019 Dylan Southard. All rights reserved.
//

import UIKit
import TagListView
import RealmSwift



class AdvancedFilterVC: SpinFilterSubview, YearRangePickerDelegate{
//MARK: - =========IBOUTLETS==========
    
    
    //MARK: - == SELECTOR ==
    @IBOutlet weak var includeSetter: Selector!
    @IBOutlet weak var mustIncludeButton: UIButton!
    @IBOutlet weak var mayIncludeButton: UIButton!
    @IBOutlet weak var mustExcludeButton: UIButton!
    
    
    
    //MARK: - == OTHER VIEWS ==
    @IBOutlet weak var autofillTable: UITableView!
    @IBOutlet weak var includeTagsField: UITextField!
    @IBOutlet weak var tagView: TagListView!
    
    @IBOutlet weak var mainScrollView: UIScrollView!
    
    //MARK: - === YEAR PICKER ===
    @IBOutlet weak var yearRangePicker: YearRangePicker!
    @IBOutlet weak var startYearPicker: UIPickerView!
    @IBOutlet weak var endYearPicker: UIPickerView!
    
    
    //MARK: - ==========VARS============
    //MARK: - ==ARRAYS==
    var genrePredictions:Results<Genre>?
    var tagPredictions:Results<Tag>?
    
    var predictions:[Object] {
        get {
            var array = [Object]()
            if let gp = self.genrePredictions {
                array += gp.toArray(type: Object.self)
            }
            if let tp = self.tagPredictions {
                array += tp.toArray(type: Object.self)
            }
            
            return array
        }
    }
    
    var tagColors:[FilterObjectType:[FilterCondition:UIColor]] = [
        .genre:[
            .and:UIColor().colorSecondaryLight(),
            .or:UIColor.orange,
            .not:UIColor().colorTextEmphasisLight()
        ],
        .tag: [
            .and:UIColor().colorSecondaryDark(),
            .or:UIColor.yellow,
            .not:UIColor().colorEmphasisDark()
        ]
    ]
    
    //MARK: - ==========SETUP============
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //MARK ==DELEGATES/DATASOURCES==
        self.tagView.delegate = self
        self.autofillTable.delegate = self
        self.autofillTable.dataSource = self
       self.yearRangePicker.delegate = self
        
        
        //MARK: ==Fill Arrays==
        self.getMostRecentFilter()
        
        self.yearPickerSetup()
        
        
        self.hideKeyboardWhenTapped()
        
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.selectorSetup()
        self.refreshTagView()
    }
    
    func selectorSetup() {
        self.includeSetter.configure(buttons: [self.mustIncludeButton, self.mayIncludeButton, self.mustExcludeButton], highlightColor: UIColor().colorTextEmphasisLight(), delegate: self)
    }
    
    func yearPickerSetup() {
        let filter = container.filterObject as? Filter
        self.yearRangePicker.configure(startPicker: self.startYearPicker, endPicker: self.endYearPicker, startYear: filter?.startYear, endYear: filter?.endYear, delegate: self)
    }
    

    //MARK: - =========ADD TAG==========
    @IBAction func addPressed(_ sender: Any) {
        if self.includeTagsField.text != "" {
            
        }
    }
    @IBAction func textDidChange(_ sender: Any) {
        self.showHideAutofillTable()
    }
    
    
    func getMostRecentFilter() {
        
        if let savedFilter = GlobalDataManager.filter(withID: Prefs.MostRecentFilterID) {
            self.container.filterObject = savedFilter
        } else {
            let id = "\(NSDate().timeIntervalSince1970)"
            self.container.filterObject = Filter()
            self.container.filterObject?.setValue(id, forKey: "id")
            self.container.filterObject?.setValue(id, forKey: "name")
           if let error = GlobalDataManager.save(object: self.container.filterObject!)
           {print(error)}
            Prefs.MostRecentFilterID = id
        }
    }
    
    func refreshTagView() {
        
        guard let filter =  self.container.filterObject as? Filter else {return}
        self.tagView.removeAllTags()
        
        self.displayTagArray(names: Array(filter.genresMustInclude), params: .and, objectType:.genre)
        
        self.displayTagArray(names: Array(filter.tagsMustInclude), params: .and, objectType:.tag)
        
        self.displayTagArray(names: Array(filter.genresMayInclude), params: .and, objectType: .genre)
        
        self.displayTagArray(names: Array(filter.tagsMayInclude) + Array(filter.genresMayInclude), params: .or, objectType: .tag)
        
        self.displayTagArray(names:Array(filter.genresMustExclude), params: .not, objectType: .genre)
        
         self.displayTagArray(names: Array(filter.tagsMustExclude), params: .not, objectType: .tag)
    }
    
    func displayTagArray(names:[String], params:FilterCondition, objectType:FilterObjectType) {
        for filter in names {
            self.displayTag(named: filter, withParams: params, objectType: objectType)
        }
    }
    
    //MARK: - ==ADD TAG TO VIEW==
    func displayTag(named tagName:String, withParams ip:FilterCondition, objectType:FilterObjectType) {
        self.tagView.removeTag(tagName)
        
        for tag in self.tagView.tagViews {
            if tag.titleLabel?.text == tagName && tag.objectType == objectType {
                self.tagView.removeTagView(tag)
            }
        }
        
        self.tagView.addTag(tagName)
        self.tagView.tagViews.last!.objectType = objectType
        self.tagView.tagViews.last!.backgroundColor = self.tagColors[objectType]![ip]!
    }
    
   //MARK: - =============== Year Stuff ===============
    
    func yearPickerDidChange(yearPicker: YearRangePicker) {
        guard let filter = self.container.filterObject as? Filter else {print("not an object! \(self.container.filterObject)"); return}
        filter.setDates(start: yearPicker.startYear, end: yearPicker.endYear)
    }

}

//MARK: - ========== TAGLIST STUFF =======================
extension AdvancedFilterVC : TagListViewDelegate {
    func tagRemoveButtonPressed(_ title: String, tagView: TagView, sender: TagListView) {
        guard let filter = self.container.filterObject as? Filter else {return}
        filter.addFilter(title: title, type: tagView.objectType, condition: .none)
        self.refreshTagView()
    }
}

//MARK: - ========== AUTOFILL STUFF =======================

extension AdvancedFilterVC : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.predictions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CandidateCell") as! FilterCandidateCell
        let object = self.predictions[indexPath.row]
        guard let name = object.value(forKey: "name") as? String else {return cell}
        
        cell.textLabel?.text = name
        cell.backgroundColor? = ((object as? Genre) != nil) ? UIColor().colorSecondaryLight(): UIColor().offWhitePrimary()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("row selected")
        let condition = FilterCondition(rawValue: self.includeSetter.indexOfSelectedItem)!
        let selectedObject = self.predictions[indexPath.row]
        let tagName = selectedObject.value(forKey: "name") as! String
        let type:FilterObjectType = ((selectedObject as? Genre) != nil) ? .genre : .tag
        
        guard let object = self.container.filterObject as? Filter else {print("not an object! \(self.container.filterObject)"); return}
        object.addFilter(title: tagName, type: type, condition: condition)
        
        self.includeTagsField.text = ""
        self.refreshTagView()
        self.showHideAutofillTable()
    }
    
    
    
    func showHideAutofillTable() {
        
        //-- Filter predictions
        
        var predicates = [NSPredicate]()
        
        predicates.append(NSPredicate(format: "name CONTAINS[cd] %@", self.includeTagsField.text!))
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        
        self.genrePredictions = GlobalDataManager.allGenres.filter(compoundPredicate)
        self.tagPredictions = GlobalDataManager.allTags.filter(compoundPredicate)
        self.autofillTable.reloadData()
        //-- If predictions exist display table
        if self.predictions.count > 0 {
            
            //-- resize table
            var frame = self.autofillTable.frame
            if self.autofillTable.contentSize.height < 120 {
                frame.size.height = self.autofillTable.contentSize.height
            } else {
                frame.size.height = 100
            }
            self.autofillTable.frame = frame
            
            self.autofillTable.isHidden = false
        } else {
            self.autofillTable.isHidden = true
        }
    }
}

extension TagView {
    private static var _objectType = [String:FilterObjectType]()
    
    var objectType:FilterObjectType {
        get {
            let tmpAddress = String(format: "%p", unsafeBitCast(self, to: Int.self))
            return TagView._objectType[tmpAddress] ?? .genre
        }
        set(newValue) {
            let tmpAddress = String(format: "%p", unsafeBitCast(self, to: Int.self))
            TagView._objectType[tmpAddress] = newValue
        }
    }
}

