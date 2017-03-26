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
                        self.ivEmoticon.addEmoticionFace(face: face)
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
        saveImage()
    }
    
    func saveImage(){
        let scale: CGFloat = 1
        UIGraphicsBeginImageContextWithOptions(ivEmoticon.layer.frame.size, false, scale)
        ivEmoticon.layer.render(in: UIGraphicsGetCurrentContext()!)
        let imageSaved = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        UIImageWriteToSavedPhotosAlbum(imageSaved, nil, nil, nil)
    }


}
