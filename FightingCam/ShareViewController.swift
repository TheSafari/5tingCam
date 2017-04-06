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

        // Do any additional setup after loading the view.
        imageSavedView.image = imageSaved
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onBack(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func onDone(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true) { 
            let homeVc = self.storyboard?.instantiateViewController(withIdentifier: "homeViewController") as! HomeViewController
            self.present(homeVc, animated: true, completion: nil)
        }
    }
    
    @IBAction func onFbShare(_ sender: UIButton) {
        
        if let vc = SLComposeViewController(forServiceType: SLServiceTypeFacebook) {
            vc.setInitialText((quoteText != nil) ? quoteText! + "\n#5tingCam" : "" + "\n#5tingCam")
            vc.add(imageSaved!)
            present(vc, animated: true)
        }
    }
    
    @IBAction func onTwitterShare(_ sender: UIButton) {
        
        let vc = SLComposeViewController(forServiceType:SLServiceTypeTwitter)
        vc?.add(imageSaved!)
        vc?.setInitialText((quoteText != nil) ? quoteText! + "\n#5tingCam" : ""  + "\n#5tingCam")
        self.present(vc!, animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
