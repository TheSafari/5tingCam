//
//  RealmService.swift
//  FightingCam
//
//  Created by Nguyen Trong Khoi on 3/26/17.
//  Copyright © 2017 TheSafari. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class RealmService{
    
    static let shareInstance = RealmService()
    let realm = try! Realm()
    
    func writeQuoteData(quote: Quote){
        
        try! realm.write {
            realm.add(incrementQuoteID(quote: quote))
        }
    }
    
    func getQuotebyReactionType(reactionType: FACE_REACTION_TYPE )->Quote? {
        let listquote = realm.objects(Quote.self).filter("type == %@", reactionType.rawValue)
        let index = random(from: 0 ... listquote.count - 1)
        return Array(listquote)[index]
        
    }
}