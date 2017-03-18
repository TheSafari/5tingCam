//
//  FaceInfo.swift
//  FightingCam
//
//  Created by Nguyen Trong Khoi on 3/16/17.
//  Copyright © 2017 TheSafari. All rights reserved.
//

import Foundation



class FaceInfo: NSObject  {
    
    let faceScore: FaceScore
    let faceRectangle: FaceRectangle
    
    init(faceScore: FaceScore , faceRectangle: FaceRectangle) {
        self.faceRectangle = faceRectangle
        self.faceScore = faceScore
    }
    
    
    class func object(at: Int, fromList: [[String : AnyObject]] , callback: @escaping ((FaceInfo, Int) -> Void))  {
        DispatchQueue.global(qos: .userInteractive).async(execute: {
            let item = fromList[at]
            let faceRect : FaceRectangle
            let facescore : FaceScore
            
            let faceRectDict = item["faceRectangle"] as? NSDictionary
            let left = faceRectDict?["left"] as! Int
            let height = faceRectDict?["height"] as! Int
            let top = faceRectDict?["top"] as! Int
            let width = faceRectDict?["width"] as! Int
                
            faceRect = FaceRectangle(left: left, height: height, top: top, Width: width)
            
            let scoreDicts = item["scores"] as? NSDictionary
            let anger = scoreDicts?["anger"] as! Float
            let contempt = scoreDicts?["contempt"] as! Float
            let disgust = scoreDicts?["disgust"] as! Float
            let fear = scoreDicts?["fear"] as! Float
            let happiness = scoreDicts?["happiness"] as! Float
            let neutral = scoreDicts?["neutral"] as! Float
            let sadness = scoreDicts?["sadness"] as! Float
            let surprise = scoreDicts?["surprise"] as! Float
            
            facescore = FaceScore(angerCore: anger, contemptScore: contempt, disgustScore: disgust, fearScore: fear, happinessScore: happiness, neutralScore: neutral, sadness: sadness, surprise: surprise)
            
            let faceinfo = FaceInfo(faceScore: facescore, faceRectangle: faceRect)
            callback(faceinfo, at)
        })

    }
}

class FaceRectangle {
    
    
    let left: Int!
    let height: Int!
    let top: Int!
    let Width: Int!
    
    init(left : Int , height: Int , top: Int , Width: Int) {
        self.left = left
        self.height = height
        self.top = top
        self.Width = Width
    }
    
}

class FaceScore {
    
    let angerCore: Float
    let contemptScore: Float
    let disgustScore: Float
    let fearScore: Float
    let happinessScore: Float
    let neutralScore: Float
    let sadness: Float
    let surprise: Float
    
    init(angerCore: Float,contemptScore: Float,disgustScore: Float,fearScore: Float,happinessScore: Float,
        neutralScore: Float, sadness: Float , surprise: Float
        ) {
        self.angerCore = angerCore
        self.contemptScore = contemptScore
        self.disgustScore = disgustScore
        self.fearScore = fearScore
        self.happinessScore = happinessScore
        self.neutralScore = neutralScore
        self.sadness = sadness
        self.surprise = surprise
    }
    
}
