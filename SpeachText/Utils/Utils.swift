//
//  Utils.swift
//  SpeachText
//
//  Created by Mahendra Vishwakarma on 02/09/19.
//  Copyright © 2019 Mahendra Vishwakarma. All rights reserved.
//

import Foundation
import RealmSwift

class Utils {
    static let realm = try! Realm()
    static public func setDateFormat(date:Date) -> String {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "dd-MMM-yyyy hh:mm a"
        return dateFormat.string(from: date)
        
    }
}
