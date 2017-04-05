//
//  GlobalFunction.swift
//  FightingCam
//
//  Created by Nguyen Trong Khoi on 3/26/17.
//  Copyright © 2017 TheSafari. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

import UIKit

func incrementQuoteID(quote: Quote) -> Quote {
    let realm = try! Realm()
    let increatedID = (realm.objects(Quote.self).max(ofProperty: "id") as Int? ?? 0) + 1
    quote.id = increatedID
    return quote
}

func incrementStickerID(sticker: Sticker) -> Sticker {
    let realm = try! Realm()
    let increatedID = (realm.objects(Sticker.self).max(ofProperty: "id") as Int? ?? 0) + 1
    sticker.id = increatedID
    return sticker
}




enum FACE_REACTION_TYPE : Int{
    case anger = 0
    case fear = 1
    case happiness = 2
    case sadness = 3
    case surprise = 4
}

func  imageReaction(scores: [Float]) -> FACE_REACTION_TYPE{
    var maxindex: Int = 0
    
    for i in 1...scores.count - 1 {
        let newnumber: Float = scores[i];
        if newnumber > scores[maxindex]{
            maxindex = i
        }
    }
    return FACE_REACTION_TYPE(rawValue: maxindex)!
}


func random(from range: ClosedRange<Int>) -> Int {
    let lowerBound = range.lowerBound
    let upperBound = range.upperBound
    return lowerBound + Int(arc4random_uniform(UInt32(upperBound - lowerBound + 1)))
}



func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
    let size = image.size
    
    let widthRatio  = targetSize.width  / image.size.width
    let heightRatio = targetSize.height / image.size.height
    
    // Figure out what our orientation is, and use that to form the rectangle
    var newSize: CGSize
    if(widthRatio > heightRatio) {
        newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
    } else {
        newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
    }
    
    // This is the rect that we've calculated out and this is what is actually used below
    let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
    
    // Actually do the resizing to the rect using the ImageContext stuff
    UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
    image.draw(in: rect)
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return newImage!
}
