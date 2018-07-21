//
//  SettingsVC.swift
//  FilmRoulette
//
//  Created by Dylan Southard on 2018/07/20.
//  Copyright © 2018 Dylan Southard. All rights reserved.
//

import UIKit
import TagListView

enum InclusionParams:Int {
    case and = 0
    case or = 1
    case not = 2
    case none = 3
}

class SettingsVC: UIViewController {
    
    //MARK: - =========IBOUTLETS==========
    @IBOutlet weak var includeSetter: UISegmentedControl!
    
    @IBOutlet weak var autofillTable: UITableView!
    @IBOutlet weak var includeTagsField: UITextField!
    @IBOutlet weak var tagView: TagListView!
    
    
    //MARK: - ==========VARS============
    //MARK: - ==ARRAYS==
    var predictions = [String]()
    var possibleTags = [String]()
    
    
    //MARK: - ========== SETUP ==========
    var delegate:SpinVC!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK ==DELEGATES/DATASOURCES==
        self.tagView.delegate = self
        self.autofillTable.delegate = self
        self.autofillTable.dataSource = self
       
        
        //MARK: ==Fill Arrays==
        self.possibleTags = self.delegate.container.dataManager.allGenres.map({return $0.name})
        self.possibleTags += self.delegate.container.dataManager.allTags.map({return $0.name})
        
        //MARK: ==UPDATE UI==
        self.refreshTagView()
    }

    //MARK: - ========== NAVIGATION =======================
    
    @IBAction func donePressed(_ sender: Any) {
        self.dismiss(animated: true) {
            //TODO: reload delegate stuff
            self.delegate.loadFromSettings()
        }
    }
    
    
    //MARK: - =========ADD TAG==========
    @IBAction func addPressed(_ sender: Any) {
        if self.includeTagsField.text != "" {
            
        }
    }
    @IBAction func textDidChange(_ sender: Any) {
        self.showHideAutofillTable()
    }
    
    
    
    func refreshTagView() {
        self.tagView.removeAllTags()
        for tag in Prefs.mustBeIncluded {
            self.displayTag(named: tag, withParams: .and, ofColor: UIColor.green)
        }
        
        for tag in Prefs.canBeIncluded {
            self.displayTag(named: tag, withParams: .or, ofColor: UIColor.yellow)
        }
        
        for tag in Prefs.excluded {
            self.displayTag(named: tag, withParams: .not, ofColor: UIColor.red)
        }
    }
    
    //MARK: - ==ADD TAG TO VIEW==
    func displayTag(named tagName:String, withParams ip:InclusionParams, ofColor tagColor:UIColor) {
        
        self.tagView.removeTag(tagName)
        self.tagView.addTag(tagName)
        self.tagView.tagViews.last!.backgroundColor = tagColor
    }
    
    
    //MARK: - ==ADD/REMOVE FROM PREFS==
    func addRemoveTagFromPrefs(tag:String, exclude ip:InclusionParams) {
        Prefs.canBeIncluded = ip == .or ? Prefs.canBeIncluded.appending(tag) : Prefs.canBeIncluded.removing(tag)
        Prefs.mustBeIncluded = ip == .and ? Prefs.mustBeIncluded.appending(tag) : Prefs.mustBeIncluded.removing(tag)
        Prefs.excluded = ip == .not ? Prefs.excluded.appending(tag) : Prefs.excluded.removing(tag)
    }
}

//MARK: - ========== TAGLIST STUFF =======================
extension SettingsVC : TagListViewDelegate {
    func tagRemoveButtonPressed(_ title: String, tagView: TagView, sender: TagListView) {
        self.addRemoveTagFromPrefs(tag: title, exclude: .none)
        self.refreshTagView()
    }
}

//MARK: - ========== AUTOFILL STUFF =======================

extension SettingsVC : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.predictions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CandidateCell")!
        cell.textLabel?.text = self.predictions[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let ip = InclusionParams(rawValue: self.includeSetter.selectedSegmentIndex)!
        let tagName = self.predictions[indexPath.row]
        self.addRemoveTagFromPrefs(tag: tagName, exclude: ip)
        self.includeTagsField.text = ""
        self.refreshTagView()
        self.showHideAutofillTable()
        }
    
    
    
    func showHideAutofillTable() {
        
        //-- Filter predictions
        
        
        self.predictions = self.possibleTags.filter({ (item) -> Bool in
            return item.lowercased().contains(self.includeTagsField.text!.lowercased())
        })
        
        //-- If predictions exist display table
        if self.predictions.count > 0 {
            self.autofillTable.reloadData()
            
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
