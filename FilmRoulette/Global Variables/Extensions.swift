//
//  Extensions.swift
//  FilmSwipe
//
//  Created by Dylan Southard on 2018/06/11.
//  Copyright © 2018 Dylan Southard. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON


//MARK: - ========REALM  EXTENSIONS ===========

extension Results where Element == Movie {
    func asList()->List<Movie> {
        let list = List<Movie>()
        list.append(objectsIn: self)
        return list
    }
    
    
}

extension Results {
    func toArray<T>(type: T.Type) -> [T] {
        return compactMap { $0 as? T }
    }
}

extension List where Element == String {
    
    func removing(_ string:String)-> List<String> {
        let array = self
        if array.contains(string) {
            array.remove(at: array.index(of: string)!)
        }
        return array
    }
    
    func appending(_ string:String)-> List<String> {
        let array = self
        if !array.contains(string) {
            array.append(string)
        }
        return array
    }
    
}

//MARK: - ========ARRAY  EXTENSIONS ===========
//MARK: - ==String Array==
extension Array where Element: Comparable {
    func containsSameElements(as other: [Element]) -> Bool {
        return self.count == other.count && self.sorted() == other.sorted()
    }
}

extension Array where Element == String {
    
    func asList()->List<String> {
        let list = List<String>()
        for str in self {
            list.append(str)
        }
        return list
    }
        
    func asString()->String {
        var string = ""
        var index = 1
        for str in self {
            string += str
            if index != self.count {
                string += ", "
            }
            index += 1
        }
        return string
    }
    
    func removing(_ string:String)-> [String] {
        var array = self
        if array.contains(string) {
            array.remove(at: array.index(of: string)!)
        }
        return array
    }
    
    func appending(_ string:String)-> [String] {
        var array = self
        if !array.contains(string) {
            array.append(string)
        }
        return array
    }
        
}



extension Array where Element == Movie {
    
    func removeMovie(movie:Movie)->[Movie] {
        
        if self.contains(movie) {
            var array = self
            array.remove(at: self.index(of: movie)!)
            return array
        }
        return self
    }
}

//MARK: - ==Shuffle Array==
extension MutableCollection {
    /// Shuffles the contents of this collection.
    mutating func shuffle() {
        let c = count
        guard c > 1 else { return }
        
        for (firstUnshuffled, unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            // Change `Int` in the next line to `IndexDistance` in < Swift 4.1
            let d: Int = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            let i = index(firstUnshuffled, offsetBy: d)
            swapAt(firstUnshuffled, i)
        }
    }
}

extension Sequence {
    /// Returns an array with the contents of this sequence, shuffled.
    func shuffled() -> [Element] {
        var result = Array(self)
        result.shuffle()
        return result
    }
}

//Keyboard Dismiss
extension UIView {
    
}


extension UIViewController {
    
    func hideKeyboardWhenTapped() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        tap.numberOfTapsRequired = 1
        view.addGestureRecognizer(tap)
    }
    
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}


//MARK: - ========Image-Related Extensions ===========
//MARK: - ==Image From String==
extension String {
    
 
        var alphanumeric: String {
            return self.components(separatedBy: CharacterSet.alphanumerics.inverted).joined().lowercased()
        }
    
    
    func image () -> UIImage {
        
        let getImagePath = ImageDirectory.appendingPathComponent(self)
        var image:UIImage = UIImage()
        if self != "" {
            if FileManager().fileExists(atPath: getImagePath.path) {
                
                image = UIImage(contentsOfFile: getImagePath.path)!
            }else {
                image = UIImage(named: "noImage.png")!
            }
        }else {
            image = UIImage(named: "noImage.png")!
        }
        return image
    }
}
    

//MARK: - ==Save Thumbnail==
extension UIImage {
    
    func resized(toWidth width: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    func saveAsPng(named name:String) {
        if let data = UIImagePNGRepresentation(self) {
            let filename = DocumentsDirectory.appendingPathComponent(name)
            try? data.write(to: filename)
        }
    }
}


//MARK: - ==========JSON PARSING===========
//Extension to parse JSON
extension String{
    func toDictionary() -> NSDictionary {
        let blankDict : NSDictionary = [:]
        if let data = self.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
            } catch {
                
                print("error going to dic" + error.localizedDescription + "\nself")
            }
        }
        return blankDict
    }
}

//MARK: - ==========DATE SCHIZZZ===========
extension Date {
    func year()-> Int {
        let calendar = NSCalendar.current
        return calendar.component(.year, from: self)
    }
}

extension String {
    func year()-> String {
        if let index = (self.range(of: "-", options:NSString.CompareOptions.backwards)?.lowerBound) {
            return String(self.prefix(upTo: index)).year()
        }
        return self
    }
}


//MARK: - ========JSON  EXTENSIONS ===========
extension JSON {
    func toMovie()-> Movie? {
        let movie = Movie()
        
        //MARK: check for title and return nil if nil
        if let title = self["title"].string {
            movie.title = title
        } else {
            //MARK: RETURN IF NO TITLE
            print("BAAAAAAAD DAAAATA")
            return nil
        }
        movie.id = self["id"].int ?? 550
        movie.desc = self["overview"].string ?? "This film defies description"
        movie.imageUrl = self["poster_path"].string ?? ""
        movie.releaseDate = self["release_date"].string ?? "1980-09-10"
        movie.releaseYear = Int(movie.releaseDate.year()) ?? 1980
        movie.imdbID = self["imdb_id"].string ?? ""
        
        let videos = self["videos"]["results"].arrayValue.first
        print("videos = \(videos)")
        movie.trailerUrl = "https://www.youtube.com/embed/" + (videos?["key"].string ?? "")
        print ("trailer url is \(movie.trailerUrl)")
        
        let genres = self["genres"].arrayValue.map({$0["name"].string})
        
        for genre in genres {
            if let realGenre = genre {
                movie.genres.append(realGenre)
            }
        }
        
        return movie
    }
}

//MARK - ======DEVICE TYPE=======
extension UIDevice {
    var iPhoneX: Bool {
        return UIScreen.main.nativeBounds.height == 2436
    }
    var iPhone: Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }
    enum ScreenType: String {
        case iPhones_4_4S = "iPhone 4 or iPhone 4S"
        case iPhones_5_5s_5c_SE = "iPhone 5, iPhone 5s, iPhone 5c or iPhone SE"
        case iPhones_6_6s_7_8 = "iPhone 6, iPhone 6S, iPhone 7 or iPhone 8"
        case iPhones_6Plus_6sPlus_7Plus_8Plus = "iPhone 6 Plus, iPhone 6S Plus, iPhone 7 Plus or iPhone 8 Plus"
        case iPhones_X_XS = "iPhone X or iPhone XS"
        case iPhone_XR = "iPhone XR"
        case iPhone_XSMax = "iPhone XS Max"
        case ipad = "ipad"
        
        case unknown
    }
    var screenType: ScreenType {
        switch UIScreen.main.nativeBounds.height {
        case 960:
            return .iPhones_4_4S
        case 1136:
            return .iPhones_5_5s_5c_SE
        case 1334:
            return .iPhones_6_6s_7_8
        case 1792:
            return .iPhone_XR
        case 1920, 2208:
            return .iPhones_6Plus_6sPlus_7Plus_8Plus
        case 2436:
            return .iPhones_X_XS
        case 2688:
            return .iPhone_XSMax
        default:
            if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad {
                return .ipad
            }
            return .unknown
        }
    }
    
    public class var isiPad: Bool {
        return UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad
    }
    
    public class var isiPadPro129: Bool {
        return isiPad && UIScreen.main.nativeBounds.size.height == 2732
    }
    
    public class var isiPadPro97: Bool {
        return isiPad && UIScreen.main.nativeBounds.size.height == 2048
    }
    
    public class var isiPadPro: Bool {
        return isiPad && (isiPadPro97 || isiPadPro129)
    }
    
    
    
    
}









