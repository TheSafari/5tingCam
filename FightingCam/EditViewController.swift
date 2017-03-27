//
//  EditViewController.swift
//  FightingCam
//
//  Created by Phuong Thao Tran on 3/18/17.
//  Copyright © 2017 TheSafari. All rights reserved.
//

import UIKit

class EditViewController: UIViewController {

    
    @IBOutlet weak var ivEmoticon: EmoticonImageView!
    
    var image: UIImage?
    var faces = [FaceInfo]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ivEmoticon.image = image
        let imageData = UIImagePNGRepresentation(image!)
        DataManager.shareInstance.fetchFaceInfoFromUrl(data: imageData!, completion: { (items) -> (Void) in
            // Handle after fetch to api success
            print("Fetch Success Item = : \(items) ")
            for index in 0..<items.count{
                FaceInfo.object(at: index, fromList: items, callback: { (face: FaceInfo, index: Int) in
                    DispatchQueue.main.async(){
                        //code
                        let quote =  RealmService.shareInstance.getQuotebyReactionType(reactionType: face.faceReactionType)
                        print((quote?.quoteMessage)!)
                        self.ivEmoticon.addEmoticionFace(face: face)
                        self.faces.append(face)
                    }
                })
                
            }
            
        })
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func onBackButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onDoneButton(_ sender: UIBarButtonItem) {
        print("click done")
        //saveImage()
        saveImage2()
    }
    
    func saveImage(){
        let scale: CGFloat = 1
        UIGraphicsBeginImageContextWithOptions(ivEmoticon.layer.frame.size, false, scale)
        ivEmoticon.layer.render(in: UIGraphicsGetCurrentContext()!)
        let imageSaved = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        UIImageWriteToSavedPhotosAlbum(imageSaved, nil, nil, nil)
        print(">>>> done")
    }
    
    func saveImage2(){
            let bgImage = ivEmoticon.image
            print("width: \(bgImage?.size.width)")
            print("height: \(bgImage?.size.height)")
        
            let newSize = CGSize(width: (bgImage?.size.width)!, height: (bgImage?.size.height)!)  // set this to what you need
        
            UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
            
            bgImage?.draw(in: CGRect(origin: CGPoint.zero, size: newSize))
            for index in 0..<faces.count {
                //let imageView = UIImageView(image: #imageLiteral(resourceName: "Picture1"))
                let w = faces[index].faceRectangle.Width
                let h = faces[index].faceRectangle.height
                let emoticonPos = CGPoint(x: faces[index].faceRectangle.left, y: faces[index].faceRectangle.top)
            
                
                let faceImage = #imageLiteral(resourceName: "Picture1")
                faceImage.draw(in: CGRect(origin: emoticonPos, size: CGSize(width: w!, height: h!)))
                
            }
            let lbl = UILabel()
            lbl.text = "this is my quote"
            lbl.draw(CGRect(origin: CGPoint.zero, size: CGSize(width: 100, height: 200)))
        
            let newImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            
            UIImageWriteToSavedPhotosAlbum(newImage, nil, nil, nil)
            print("save done")
    }



}
