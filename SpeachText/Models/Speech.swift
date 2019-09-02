//
//  Speech.swift
//  SpeachText
//
//  Created by Mahendra Vishwakarma on 02/09/19.
//  Copyright © 2019 Mahendra Vishwakarma. All rights reserved.
//

import Foundation
import RealmSwift


class Speech:Object {
   @objc dynamic var speech : String = ""
   @objc dynamic var sID : String = ""
   @objc dynamic var createdDate : String = ""
    
    override static func primaryKey() -> String? {
        return "sID"
    }
}
