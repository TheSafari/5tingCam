//
//  HomeViewController.swift
//  FightingCam
//
//  Created by Phuong Thao Tran on 3/18/17.
//  Copyright © 2017 TheSafari. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UINavigationControllerDelegate,  UIImagePickerControllerDelegate {
    
    var selectedImage: UIImage?
    var pathOfImage: UIBezierPath?
    
    @IBOutlet weak var ivBg: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func onOpenPhotoLibrary(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary;
        imagePicker.allowsEditing = false
        self.present(imagePicker, animated: true, completion: nil)
        
    }
    
    @IBAction func onTakePhoto(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.camera;
        imagePicker.allowsEditing = false
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {

        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            selectedImage = image
            //temp Test request API
        } else{
            print("Something went wrong")
        }
        
        
        picker.dismiss(animated: true) {
            self.performSegue(withIdentifier: "goToEditScreen", sender: self)
        }
        
        
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navVc = segue.destination as? UINavigationController
        let editVc = navVc?.topViewController as? EditViewController
        if editVc != nil  {
            print("abc")
            editVc?.image = selectedImage
        } else {
            print("nil")
        }
    
    }
    
    @IBAction func onClickSetting(_ sender: UIButton) {
       performSegue(withIdentifier: "goToEditScreen", sender: self)
    }
    
}
