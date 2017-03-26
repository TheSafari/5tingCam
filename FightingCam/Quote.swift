//
//  Quote.swift
//  FightingCam
//
//  Created by Nguyen Trong Khoi on 3/26/17.
//  Copyright © 2017 TheSafari. All rights reserved.
//

import Foundation
import RealmSwift

final class Quote : Object{
    dynamic var id: Int = 0
    
    dynamic var type: Int = -1
    dynamic var quoteMessage: String = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
}


