//
//  AdvancedSpinFilterVC.swift
//  FilmRoulette
//
//  Created by Dylan Southard on 2019/03/17.
//  Copyright © 2019 Dylan Southard. All rights reserved.
//

import UIKit
import TagListView




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
    var genrePredictions:[Genre]?
    var tagPredictions:[Tag]?
    
    var predictions:[Any] {
        get {
            var array = [Any]()
            if let gp = self.genrePredictions {
                array += gp
            }
            if let tp = self.tagPredictions {
                array += tp
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
        self.refreshChipView()
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
        
        
        
        if let savedFilter = SQLDataManager.FetchObject(ofType: .filter, withID: Prefs.MostRecentFilterID) as? Filter {
            print("getting saved")
            self.container.filterObject = savedFilter
        } else {
            let name = "newFilter"
            print("saving new filter")
            let filter = Filter(name: name, startYear: 0, endYear: 0)
            self.container.filterObject = filter
            
            SQLDataManager.Insert(object: filter)
        
            Prefs.MostRecentFilterID = filter.id
        }
    }
    
    func nameOf(genreOrTag object:Any)->String? {
        
        if let genre = object as? Genre {
            
            return genre.name
            
        } else if let tag = object as? Tag {
            
            return tag.name
            
        }
        
        return nil
        
    }
    
    func refreshChipView() {
        
        guard let filter =  self.container.filterObject as? Filter else {return}
        self.tagView.removeAllTags()
        
        self.displayChipArray(objects: filter.genresMustInclude.toGenres, params: .and)
        
        self.displayChipArray(objects: SQLDataManager.Tags(withIDs: filter.tagsMustInclude), params: .and)
        
        self.displayChipArray(objects: filter.genresMayInclude.toGenres, params: .or)
        
        self.displayChipArray(objects: SQLDataManager.Tags(withIDs: filter.tagsMayInclude), params: .or)
        
        self.displayChipArray(objects:filter.genresMustExclude.toGenres, params: .not)
        
         self.displayChipArray(objects: SQLDataManager.Tags(withIDs: filter.tagsMustExclude), params: .not)
        
    }
    
    func displayChipArray(objects:[FilterObject], params:FilterCondition) {
        for filter in objects {
             print("displaying \(filter)")
            self.displayTag(withObject: filter, withParams: params)
           
        }
    }
    
    //MARK: - ==ADD TAG TO VIEW==
    func displayTag(withObject object:FilterObject, withParams ip:FilterCondition) {
        self.tagView.removeTag(object.name)
        
//        for tag in self.tagView.tagViews {
//            if tag.titleLabel?.text == tagName && tag.objectType == objectType {
//                self.tagView.removeTagView(tag)
//            }
//        }
        
        if let tag = object as? Tag { self.tagView.addTagView(TagTag(tag: tag, table: self.tagView)) }
        else if let genre = object as? Genre { self.tagView.addTagView(GenreTag(genre:genre, table: self.tagView)) }
    
        self.tagView.tagViews.last!.backgroundColor = self.tagColors[object.filterType]![ip]!
    }
    
   //MARK: - =============== Year Stuff ===============
    
    func yearPickerDidChange(yearPicker: YearRangePicker) {
        guard let filter = self.container.filterObject as? Filter else {return}
        filter.setDates(start: yearPicker.startYear, end: yearPicker.endYear)
    }

}

//MARK: - ========== TAGLIST STUFF =======================
extension AdvancedFilterVC : TagListViewDelegate {
    func tagRemoveButtonPressed(_ title: String, tagView: TagView, sender: TagListView) {
        
        guard let filter = self.container.filterObject as? Filter else {return}
        
        
        if let genreTag = tagView as? GenreTag {
            
            filter.addOrRemoveFilter(type: .genre, objectID: genreTag.genre.id, condition: .none)
            
        } else if let tagTag = tagView as? TagTag {
            
            filter.addOrRemoveFilter(type: .tag, objectID: tagTag.tagObject.id, condition: .none)
            
        } else {
            
        }
        
        
    
        self.refreshChipView()
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

        guard let realName = self.nameOf(genreOrTag: object) else {return cell}
        
        cell.textLabel?.text = realName
        
        cell.backgroundColor? = ((object as? Genre) != nil) ? UIColor().colorSecondaryLight(): UIColor().offWhitePrimary()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        guard let filter = self.container.filterObject as? Filter else { return }
        
        let condition = FilterCondition.allCases[self.includeSetter.indexOfSelectedItem]
        
        let object = self.predictions[indexPath.row]
        
        if let genre = object as? Genre {
          
            filter.addOrRemoveFilter(type: .genre, objectID: genre.id, condition: condition)
            
        } else if let tag = object as? Tag {
            
            filter.addOrRemoveFilter(type: .tag, objectID: tag.id, condition: condition)
        }
        
    
        self.includeTagsField.text = ""
        self.refreshChipView()
        self.showHideAutofillTable()
    }
    
    
    
    func showHideAutofillTable() {
        
        //-- Filter predictions
        
        let text = self.includeTagsField.text!
        
        self.genrePredictions = Genre.All.filter({$0.name.lowercased().contains(text.lowercased())})
        self.tagPredictions = SQLDataManager.AllTags.filter({$0.name.lowercased().contains(text.lowercased())})
        
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

