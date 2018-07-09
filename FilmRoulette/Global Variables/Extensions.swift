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

//MARK: - ========ARRAY  EXTENSIONS ===========
//MARK: - ==String Array==
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
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}


//MARK: - ========Image-Related Extensions ===========
//MARK: - ==Image From String==
extension String {
    func image () -> UIImage {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
        let getImagePath = paths.appendingPathComponent(self)
        var image:UIImage = UIImage()
        if self != "" {
            if FileManager().fileExists(atPath: getImagePath) {
                
                image = UIImage(contentsOfFile: getImagePath)!
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

//MARK: - =============UICOLOR=====================
extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.characters.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
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





