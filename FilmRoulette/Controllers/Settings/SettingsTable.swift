//
//  SettingsTable.swift
//  FilmSwipe
//
//  Created by Dylan Southard on 2018/10/18.
//  Copyright © 2018 Dylan Southard. All rights reserved.
//

import UIKit
import StoreKit
import SwiftyDropbox

enum ExportDataType:String {
    case csv = "FilmLibrary.csv"
    case frl = "FilmLibrary.fsl"
}


class SettingsTable: UITableViewController, DropboxDelegate {
   
    

    

    //MARK: - ============ OUTLETS ============
    
    
    
    
    //MARK: - == STATE LABELS ==

    
    //MARK: - === Pickers/Switches ===

    @IBOutlet weak var wheelPicker: UIPickerView!
    @IBOutlet weak var kidsSwitch: UISwitch!
    
    //MARK: - == Table Labels =

    @IBOutlet weak var labelWheelType: UILabel!
    @IBOutlet weak var labelKids: UILabel!
    @IBOutlet weak var labelImport: UILabel!
    @IBOutlet weak var labelExport: UILabel!
    @IBOutlet weak var labelDelete: UILabel!
    @IBOutlet weak var labelUpgrade: UILabel!
    @IBOutlet weak var labelRestore: UILabel!
    
  
    //    var splashView:SplashView?
    
    
    //MARK: - ==========VARIABLES===========

    
    //MARK: - === STATE ===
    var fullVersion = String()
    var rated = String()
    var linkedToDropbox:Bool {
        return self.dropboxManager.client != nil
    }

    //MARK: - === OBJECTS ===
    var tap:UITapGestureRecognizer!
    var container:SettingsContainer!
    var dropboxManager = DropboxManager()
    
    
    //MARK: - =============== SETUP ===============
    override func viewDidLoad() {
        super.viewDidLoad()
//        InAppPurchase.delegate = self
        //MARK: Delegates/Datasources
        self.wheelPicker.delegate = self
        self.wheelPicker.dataSource = self
        
        tableView.register(UINib(nibName: "SettingsHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "CustomHeader")
       
       
        //MARK: UPDATE UI
        self.setColors()
        self.setFonts()
        self.kidsSwitch.isOn = Prefs.kidsMode
   
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    
    func setColors() {
        tableView.backgroundColor = UIColor().blackBackgroundPrimary()
        self.kidsSwitch.onTintColor = UIColor().colorSecondaryDark()
    }
    
    func setFonts() {
        for label in [self.labelWheelType, self.labelKids, self.labelImport, self.labelDelete, self.labelExport, self.labelRestore, self.labelUpgrade] {
            label!.font = Fonts.SettingsTableLabel
        }
//        self.dropboxStatusLabel.font = Fonts.SettingsStateLabel
    }
    
    func setLabels() {
        self.labelImport.text = self.linkedToDropbox ? "Unlink from Dropbox" : "Link to Dropbox"
        
    }
    
    //MARK: - == KIDS MODE ==
    
    
    @IBAction func kidSwitchPressed(_ sender: Any) {
        if !Prefs.directorsCut {
            self.presentDirectorsCutPrompt(withTitle: "Kids' Mode", andMessage: "Limits the types of movies that are shown and settings that can be accessed. Unlock the Director's Cut for access to this feature!")
        }
    }
    
    
    
    func dropboxSyncComleted() {
        
    }
   
    
    @IBAction func kidsSwichFlipped(_ sender: Any) {
        DispatchQueue.main.async {
        if Prefs.directorsCut {
        Prefs.kidsMode = self.kidsSwitch.isOn
        self.container.settingsChanged = true
        } else {
            self.kidsSwitch.setOn(false, animated: true)
        }
        }
    }
    
    
    func presentDirectorsCutPrompt(withTitle title:String, andMessage message:String) {
//        Conveniences().presentSplashView(ofType: .upgrade, sender:self, container:self.container.view)
        Conveniences().presentErrorAlert(withTitle: title, message: message, sender: self)
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if Prefs.directorsCut && indexPath.section == 2 {
            return 0.0
        }
    
        if UIDevice.current.screenType == .ipad {
            return 80
        }
        return 44
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
      if indexPath.section == 1 {
            
            if indexPath.row == 2 {
               
               self.completeAnnihilation()
            } else if indexPath.row == 1 {
                if !Prefs.directorsCut {
                    self.presentDirectorsCutPrompt(withTitle: "Export/Backup Data", andMessage: "unlock the Director's Cut to enable exporting of your movie lists and library backups!")
                } else {
                    self.showExportAlert()
                }
            } else if indexPath.row == 0 {
                //TODO: send to dropbox
                if self.linkedToDropbox {
                   DropboxClientsManager.unlinkClients()
                } else {
                    self.dropboxManager.authorize(sender: self)
                }
                
               
        }
        } else if indexPath.section == 2 {
            
            if indexPath.row == 0 {
//                Conveniences().presentSplashView(ofType: .upgrade, sender:self, container:self.container.view)
               
            } else if indexPath.row == 1 {
                //TODO: RESTORE
                
                Conveniences().presentConfirmationAlert(inVC: self, title: "Restore", message: "Would you like to restore your purchases?", forAction: self.restorePurchases)
            }
        }
        
    }
    
  
    
//    func topButtonPressed(inUpgradeView: UpgradeView) {
//        Conveniences().presentConfirmationAlert(inVC: self, title: "An offer you shouldn't refuse", message:  "Would you like to unlock the Director's Cut for just 99¢?", forAction: self.upgrade)
//    }
    
    
    
    func restorePurchases() {
        SKPaymentQueue.default().add(self as! SKPaymentTransactionObserver)
        SKPaymentQueue.default().restoreCompletedTransactions()
        
//        InAppPurchase.sharedInstance.restoreTransactions()
        self.tableView.reloadData()
    }
    
    func upgrade() {
//        if let splash = self.container.splashView as? UpgradeView {
//            splash.disableButtons()
//        }
//        InAppPurchase.sharedInstance.buyUnlockTestInAppPurchase1()
    
        
    }
    
    
    func purchaseFailed() {
//        if let splash = self.container.splashView as? UpgradeView {
//            splash.enableButtons()
//        }
    }
    
    func purchaseSucessful() {
        
//        self.container.splashView?.dismissSplashView()
//        self.tableView.reloadData()
        
    }


    

    
    
    //MARK: - ===== HANDLE HIGHLIGHT ====-
    
    override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? CustomTableViewCell, cell.isButton {
            cell.backgroundColor = UIColor().offWhitePrimary(alpha: 0.4)
        }
    }
    
    override func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? CustomTableViewCell, cell.isButton {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
                 cell.backgroundColor = UIColor.clear
            }) { _ in
                //On completion
            }
            
           
        }
    }
    
    
    
    //MARK: - =====BUTTON FUNCTIONS=====
    
    func showExportAlert() {
        Conveniences().presentAlertWithTwoChoices(inVC: self, title: "Export Data", message: "Would you like to export your movie collection as a list (CSV) or back up your library?", buttonOneText: "List", buttonTwoText: "Back Up", firstAction: self.exportAsCSV, secondAction: self.exportAsFSL)
    }
    
    func exportAsCSV() {
        self.exportData(ofType: .csv)
    }
    
    func exportAsFSL() {
        self.exportData(ofType: .frl)
    }
    
    func exportData(ofType type:ExportDataType) {
        //TODO -- Export
        
//        let possibleController = type == .csv ? DataSharingManager(sender:self).exportWindowCSV : DataSharingManager(sender:self).exportWindow
//        guard let controller = possibleController else {
//            Conveniences().presentErrorAlert(withTitle: "Error", message: "Could not export data", sender: self); return
//        }
//
//
//        self.present(controller, animated: true, completion: nil)
        
        
    }
    
    
    
    func completeAnnihilation() {
       // TODO: - 
//        let annihilate = {
//            let dataManager = DataManager()
//            for movie in GlobalDataManager.allMovies {
//                dataManager.deleteObject(object: movie)
//            }
//
//            Prefs().resetAll()
//            self.container.annihilated = true
//            self.container.settingsChanged = true
//        }
//
//        Conveniences().presentConfirmationAlert(inVC: self.container, title: "Delete Everything??", message: "Are you sure you're making the right decision? I think we should stop.", forAction: annihilate)
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerTypes:[SettingsHeaderType] = [.swipe, .data, .upgrade]
        
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "CustomHeader") as! SettingsHeader
        headerView.type = headerTypes[section]
        headerView.backgroundColor = UIColor().offWhitePrimary()
        if Prefs.directorsCut && section == 2 {
            headerView.isHidden = true
        }
        
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if Prefs.directorsCut && section == 2 {
            return 0.0
        }
        let widthMultiplier:Float = UIDevice.current.screenType == .ipad ? 0.6 : 1
        
        let height = Conveniences().valueFromRatio(ratioWidth: 375, ratioHeight: 50, width: Float(self.view.frame.width) * widthMultiplier)
        
        return CGFloat(height)
    }

}


extension SettingsTable : UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //TODO: Change spin type
        
        //MARK: Change start or end year when components picked
      
    }
    
   
    
    //MARK: - ==MINMAXPICKERVALUES==
 
}

extension SettingsTable : UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return 0
    }

    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel: UILabel? = (view as? UILabel)

        return pickerLabel!
    }
    

    
}

