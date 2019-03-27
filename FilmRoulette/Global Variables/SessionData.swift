//
//  SessionData.swift
//  FilmRoulette
//
//  Created by Dylan Southard on 2019/03/13.
//  Copyright © 2019 Dylan Southard. All rights reserved.
//

import UIKit
import RealmSwift

class SessionData: NSObject {
    static var DataManager:DataManager?
    static var Posters = [Int:Data]()
    static var CurrentFilterObject:Object?
}
