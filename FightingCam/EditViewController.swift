//
//  EditViewController.swift
//  FightingCam
//
//  Created by Phuong Thao Tran on 3/18/17.
//  Copyright © 2017 TheSafari. All rights reserved.
//

import UIKit
import AVFoundation
import MBProgressHUD


class EditViewController: UIViewController {
    
    
    @IBOutlet weak var ivEmoticon: EmoticonImageView!
    
    var image: UIImage?
    var faces = [FaceInfo]()
    var quote : String?
    var faceUiImage: UIImage?
    var imageSaved: UIImage? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initFilterMenu()
        
        speaker = Speaker()
        speaker?.setMyDelegate(self)
        
        ivEmoticon.image = image
        let imageData = UIImagePNGRepresentation(image!)
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        DataManager.shareInstance.fetchFaceInfoFromUrl(data: imageData!, completion: { (items) -> (Void) in
            // Handle after fetch to api success
            print("Fetch Success Item = : \(items) ")
            for index in 0..<items.count{
                FaceInfo.object(at: index, fromList: items, callback: { (face: FaceInfo, index: Int) in
                    DispatchQueue.main.async(){
                        //get quotes
                        let quote =  RealmService.shareInstance.getQuotebyReactionType(reactionType: face.faceReactionType)
                        self.quote = quote?.quoteMessage
                        print(self.quote!)
                        self.ivEmoticon.addQuote(quote: self.quote!)
                        //get emoticon
                        let faceName = RealmService.shareInstance.getStickerbybyReactionType(reactionType: face.faceReactionType)?.stickerName
                        
                        self.faceUiImage = UIImage(named: faceName!)
                        
                        self.ivEmoticon.addEmoticionFace(face: face, imageFace: self.faceUiImage!)
                        self.faces.append(face)
                        //get animal sound
                        
                        MBProgressHUD.hide(for: self.view, animated: true)
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
        //saveImage2()
        //playMusic()
        textToSpeech()
    }
    
    @IBAction func onBackClick(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onSoundClick(_ sender: UIButton) {
        print("click done")
        //playMusic()
        textToSpeech()
    }
    
    @IBAction func onDoneClick(_ sender: UIButton) {
        //saveImage()
        saveImage2()
        let shareVc = self.storyboard?.instantiateViewController(withIdentifier: "shareViewController") as! ShareViewController
        shareVc.imageSaved = self.imageSaved
        self.present(shareVc, animated: true, completion: nil)
    }
    
    @IBAction func onFilter(_ sender: UIButton) {
        //open filter
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
            let w = faces[index].faceRectangle.Width
            let h = faces[index].faceRectangle.height
            let emoticonPos = CGPoint(x: faces[index].faceRectangle.left, y: faces[index].faceRectangle.top)
            
            
            let faceImage = self.faceUiImage
            faceImage?.draw(in: CGRect(origin: emoticonPos, size: CGSize(width: w!, height: h!)))
            
        }
        
        let quoteX = (bgImage?.size.width)! * 0.1
        let quoteY = (bgImage?.size.height)! * 0.7
        let lbl = UILabel(frame: CGRect(x: quoteX, y: quoteY, width: (bgImage?.size.width)! * 0.8, height: 100))
        lbl.text = self.quote
        lbl.textAlignment = .center
        lbl.text = quote
        lbl.numberOfLines = 0
        lbl.textColor = UIColor.white
        lbl.lineBreakMode = NSLineBreakMode.byWordWrapping
        let fontSize = 20.0 / ivEmoticon.ratio!
        lbl.font = UIFont(name: "Yellowtail", size: fontSize)
        //lbl.draw(CGRect(x: 50, y: 750, width: (bgImage?.size.width)! * 0.8, height: 100))
        lbl.drawText(in: CGRect(x: quoteX, y: quoteY, width: (bgImage?.size.width)! * 0.8, height: 100))
        
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        self.imageSaved = newImage
        UIImageWriteToSavedPhotosAlbum(newImage, nil, nil, nil)
        print("save done")
    }

    var bombSoundEffect: AVAudioPlayer!
    func playMusic(fullName: String){
        var component = fullName.components(separatedBy: ".")
        if (component.count >= 2) {
            let path = Bundle.main.path(forResource: component[0], ofType:component[1])!
            let url = URL(fileURLWithPath: path)
            
            do {
                let sound = try AVAudioPlayer(contentsOf: url)
                bombSoundEffect = sound
                sound.play()
            } catch {
                // couldn't load file :(
            }
        }
    }
    
    var speaker:Speaker?
    
    func textToSpeech(){
        speaker?.speak(self.quote!, in: "en-US")
    }
    
    @IBOutlet weak var filerMenuView: UIView!
    @IBOutlet weak var darkFillView: UIViewX!
    @IBOutlet weak var btnFilter1: UIButton!
    @IBOutlet weak var btnFilter2: UIButton!
    @IBOutlet weak var btnFilter3: UIButton!
    @IBOutlet weak var btnFilter4: UIButton!
    
    func initFilterMenu(){
        btnFilter1.alpha = 0
        btnFilter2.alpha = 0
        btnFilter3.alpha = 0
        btnFilter4.alpha = 0
    }
    
    @IBAction func onFilterClick(_ sender: UIButton) {
        if darkFillView.transform == CGAffineTransform.identity {
            UIView.animate(withDuration: 0.7, animations: {
                self.darkFillView.transform = CGAffineTransform(scaleX: 11, y: 11)
                self.filerMenuView.transform = CGAffineTransform(translationX: 0, y: -62)
            }, completion: { (true) in
                UIView.animate(withDuration: 0.4, animations: {
                    self.toggleFilterButton()
                })
                
            })
            
        } else {
            UIView.animate(withDuration: 0.7, animations: {
                self.darkFillView.transform = .identity
                self.filerMenuView.transform = .identity
                self.toggleFilterButton()
            }, completion: { (true) in
                
            })
        }
    }
    
    func toggleFilterButton(){
        let alpha = CGFloat(btnFilter1.alpha == 0 ? 1 :0)
        btnFilter1.alpha = alpha
        btnFilter2.alpha = alpha
        btnFilter3.alpha = alpha
        btnFilter4.alpha = alpha
    }
    
    @IBAction func onFilter1Click(_ sender: UIButton) {
        ivEmoticon.applyFilter()
    }
    
    @IBAction func onFilter2Click(_ sender: UIButton) {
        ivEmoticon.applyFilter2()
    }
    
    @IBAction func onFilter3Click(_ sender: UIButton) {
        ivEmoticon.applyFilter3()
    }
    
    @IBAction func onFilter4Click(_ sender: UIButton) {
        ivEmoticon.applyFilter4()
    }
    

}

extension EditViewController : SpeakerDelegate {
    func startSpeaker() {
        print("start speaker")
    }
    
    func stopSpeaker() {
        print("stop speaker")
        playMusic(fullName: "Audio2.wav")
    }
}


