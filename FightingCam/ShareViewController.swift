//
//  ShareViewController.swift
//  FightingCam
//
//  Created by Phuong Thao Tran on 4/1/17.
//  Copyright © 2017 TheSafari. All rights reserved.
//

import UIKit
import Social

class ShareViewController: UIViewController {
    
    @IBOutlet weak var imageSavedView: UIImageView!
    var imageSaved: UIImage?
    var quoteText: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageSavedView.image = imageSaved
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func onBack(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onDone(_ sender: UIBarButtonItem) {
        let homeVc = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        self.present(homeVc, animated: true, completion: nil)
    }
    
    @IBAction func onFbShare(_ sender: UIButton) {
        
        if let vc = SLComposeViewController(forServiceType: SLServiceTypeFacebook) {
            vc.setInitialText((quoteText != nil) ? quoteText! + "\n#5tingCam" : "\n#5tingCam")
            vc.add(imageSaved!)
            present(vc, animated: true)
        }
    }
    
    @IBAction func onTwitterShare(_ sender: UIButton) {
        
        let vc = SLComposeViewController(forServiceType:SLServiceTypeTwitter)
        vc?.add(imageSaved!)
        vc?.setInitialText((quoteText != nil) ? quoteText! + "\n#5tingCam" : "\n#5tingCam")
        self.present(vc!, animated: true, completion: nil)
    }
}
