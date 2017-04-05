//
//  DataManager.swift
//  FightingCam
//
//  Created by Nguyen Trong Khoi on 3/15/17.
//  Copyright © 2017 TheSafari. All rights reserved.
//


import Foundation



class DataManager{
    
    let privateKey: String = "d1585b6996744cc1ba37bed121948051"
    let baseUrl : String! = "https://westus.api.cognitive.microsoft.com"
    
    static let shareInstance = DataManager()
    
    
    
    func fetchFaceInfoFromUrl(data: Data, completion: @escaping ([[String : AnyObject]]) -> (Void) , failure: @escaping(String) -> (Void)){
        
        let headers = [
            "ocp-apim-subscription-key": "d1585b6996744cc1ba37bed121948051",
            "content-type": "application/octet-stream",
            "cache-control": "no-cache"
        ]
        
        let postData = data
        let request = NSMutableURLRequest(url: NSURL(string: baseUrl.appending("/emotion/v1.0/recognize"))! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 7)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = postData
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest,
                                        completionHandler: { (dataOrNil, response, error) in
                                            if  error != nil{
                                                failure((error?.localizedDescription)!)
                                                return
                                            }
                                            if let data = dataOrNil {
                                                if let responseDictionary = try! JSONSerialization.jsonObject(
                                                    with: data, options:[]) as? [[String : AnyObject]] {
                                                    completion(responseDictionary)
                                                    print("Server --> Client ::"  )
                                                    print(" \(responseDictionary)")
                                                    
                                                    
                                                }
                                                return
                                            }
                                            failure("Parse Json failure")
        })
        dataTask.resume()
    }
    
    
}
