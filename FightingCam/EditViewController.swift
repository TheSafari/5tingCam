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
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var soundButton: UIButton!
    @IBOutlet weak var ivEmoticon: EmoticonImageView!
    
    let defaults = UserDefaults.standard
    
    var image: UIImage?
    var faces = [FaceInfo]()
    var faceUiImage: UIImage?
    var imageSaved: UIImage? = nil
    var emoticonName: String? = ""
    var soundSetting = true
    var apiResult: [[String: AnyObject]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.soundSetting = defaults.bool(forKey: "soundSetting")
        self.updateSoundIcon()
        initFilterMenu()
        
        speaker = Speaker()
        speaker?.setMyDelegate(self)
        
        //ivEmoticon.image = image
        ivEmoticon.setImage(bgImage: image!)
        
        
        
        let imageData = UIImagePNGRepresentation(image!)
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        DataManager.shareInstance.fetchFaceInfoFromUrl(data: imageData!, completion: { (items) -> (Void) in
            // Handle after fetch to api success
            self.apiResult = items
            print("Fetch Success Item = : \(items) ")
            if items.count == 0 {
                DispatchQueue.main.async(){
                    MBProgressHUD.hide(for: self.view, animated: true)
                }
                print("No face detected")
                let alert = UIAlertController(title: "Face not found", message: "No face detected. Please try another picture!", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)

                return
            }
            for index in 0..<items.count{
                FaceInfo.object(at: index, fromList: items, callback: { (face: FaceInfo, index: Int) in
                    DispatchQueue.main.async(){
                        //get emoticon
                        let faceName = RealmService.shareInstance.getStickerbybyReactionType(reactionType: face.faceReactionType)?.stickerName
                        self.faceUiImage = UIImage(named: faceName!)
                        self.emoticonName = faceName
                        self.ivEmoticon.addEmoticionFace(face: face, imageFace: self.faceUiImage!)
                        self.faces.append(face)
                        
                        //get quotes
                        let quote =  RealmService.shareInstance.getQuotebyReactionType(reactionType: face.faceReactionType)
                        self.ivEmoticon.addQuote(quote: (quote?.quoteMessage)!)
                        
                        MBProgressHUD.hide(for: self.view, animated: true)
                        if !self.soundSetting {
                            self.textToSpeech()
                        }
                    }
                })
            }
        }, failure: { (errorMessage) in
            print("errorMessage : \(errorMessage)")
             DispatchQueue.main.async(){
            MBProgressHUD.hide(for: self.view, animated: true)
            }
            let alert = UIAlertController(title: "Face not found", message: "No face detected. Please try another picture!", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        })
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func onBackClick(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onSoundClick(_ sender: UIButton) {
        //mute/unmute
        self.soundSetting = !self.soundSetting
        self.updateSoundIcon()
        defaults.setValue(self.soundSetting, forKey: "soundSetting")
    }
    
    func updateSoundIcon(){
        if soundSetting {
            soundButton.setImage(UIImage(named: "ic_sound"), for: UIControlState.normal)
            speaker?.stop()
        }
        else {
            soundButton.setImage(UIImage(named: "mute"), for: UIControlState.normal)
            textToSpeech()
        }
    }
    
    @IBAction func onDoneClick(_ sender: UIButton) {
        //saveImage()
        saveImage2()
        let shareVc = self.storyboard?.instantiateViewController(withIdentifier: "shareViewController") as! ShareViewController
        shareVc.imageSaved = self.imageSaved
        shareVc.quoteText = ivEmoticon.currentQuote?.quote
        self.present(shareVc, animated: true, completion: nil)
    }
    
    @IBAction func onFilter(_ sender: UIButton) {
        //open filter
    }
    
    @IBAction func onRandomOther(_ sender: UIButton) {
        for index in 0..<self.apiResult.count{
            FaceInfo.object(at: index, fromList: self.apiResult , callback: { (face: FaceInfo, index: Int) in
                DispatchQueue.main.async(){
                    //get emoticon
                    let faceName = RealmService.shareInstance.getStickerbybyReactionType(reactionType: face.faceReactionType)?.stickerName
                    self.faceUiImage = UIImage(named: faceName!)
                    self.emoticonName = faceName
                    self.ivEmoticon.addEmoticionFace(face: face, imageFace: self.faceUiImage!)
                    self.faces.append(face)
                    
                    //get quotes
                    let quote =  RealmService.shareInstance.getQuotebyReactionType(reactionType: face.faceReactionType)
                    self.ivEmoticon.addQuote(quote: (quote?.quoteMessage)!)
                    
                    if !self.soundSetting {
                        self.textToSpeech()
                    }
                }
            })
        }
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
        var bgImage = ivEmoticon.image
        if (selectedIndex > -1) {
            bgImage = createFilteredImage(selectedIndex)
        }
        
        let newSize = CGSize(width: (bgImage?.size.width)!, height: (bgImage?.size.height)!)  // set this to what you need
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        
        bgImage?.draw(in: CGRect(origin: CGPoint.zero, size: newSize))
        for index in 0..<faces.count {
            let w = faces[index].faceRectangle.Width
            let h = faces[index].faceRectangle.height
            let emoticonPos = CGPoint(x: faces[index].faceRectangle.left, y: faces[index].faceRectangle.top)
            
            
            let faceImage = self.faceUiImage
            let rotatedImage = faceImage?.rotated(by: Measurement(value: ivEmoticon.rotateValue, unit: .degrees))
            //let rotatedImage = faceImage?.scale(scaleBy: ivEmoticon.pichValue)
            let rect = CGRect(origin: emoticonPos, size: CGSize(width: (w)!, height: (h)!))
            rotatedImage?.draw(in: rect)
            
        }
        
        //save quote
        if let currentQuote = ivEmoticon.currentQuote{
            let quoteX = currentQuote.x
            let quoteY = currentQuote.y
            
            let lbl = UILabel(frame: CGRect(x: quoteX!, y: quoteY!, width: (bgImage?.size.width)! * 0.8, height: 100))
            lbl.textAlignment = .center
            lbl.text = currentQuote.quote
            lbl.numberOfLines = 0
            lbl.textColor = UIColor.white
            lbl.lineBreakMode = NSLineBreakMode.byWordWrapping
            let fontSize = 20.0 / ivEmoticon.ratio!
            lbl.font = UIFont(name: "Yellowtail", size: fontSize)
            lbl.drawText(in: CGRect(x: quoteX!, y: quoteY!, width: (bgImage?.size.width)! * 0.8, height: 100))
        }
        
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
        speaker?.speak((ivEmoticon.currentQuote?.quote)!, in: "en-US")
    }
    
    @IBOutlet weak var filerMenuView: UIView!
    @IBOutlet weak var darkFillView: UIViewX!
    
    @IBOutlet weak var btnFilter1: UIButton!
    @IBOutlet weak var btnFilter2: UIButton!
    @IBOutlet weak var btnFilter3: UIButton!
    @IBOutlet weak var btnFilter4: UIButton!
    var selectedIndex = -1

    
    func initFilterMenu(){
        btnFilter1.alpha = 0
        btnFilter2.alpha = 0
        btnFilter3.alpha = 0
        btnFilter4.alpha = 0
        
        btnFilter1.setBackgroundImage(createFilteredImage(0), for: .normal)
        btnFilter2.setBackgroundImage(createFilteredImage(1), for: .normal)
        btnFilter3.setBackgroundImage(createFilteredImage(2), for: .normal)
        btnFilter4.setBackgroundImage(createFilteredImage(3), for: .normal)
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
    
    @IBAction func onClickBtn1(_ sender: UIButton) {
        ivEmoticon.applyFilter()
        selectedIndex = 0
    }
    
    
    @IBAction func onClickBtn2(_ sender: UIButton) {
        ivEmoticon.applyFilter2()
        selectedIndex = 1
    }
    
    @IBAction func onClickButton3(_ sender: UIButton) {
        ivEmoticon.applyFilter3()
        selectedIndex = 2
    }
    
    @IBAction func onClickBtn4(_ sender: UIButton) {
        ivEmoticon.applyFilter4()
        selectedIndex = 3
    }
    
    var CIFilterNames = [
        "CIPhotoEffectChrome",
        "CIPhotoEffectFade",
        "CIPhotoEffectInstant",
        "CIPhotoEffectNoir"
    ]
    
    func createFilteredImage(_ i: Int) -> UIImage{
        // Create filters for each button
        let ciContext = CIContext(options: nil)
        let coreImage = CIImage(image: self.image!)
        let filter = CIFilter(name: "\(CIFilterNames[i])" )
        filter!.setDefaults()
        filter!.setValue(coreImage, forKey: kCIInputImageKey)
        let filteredImageData = filter!.value(forKey: kCIOutputImageKey) as! CIImage
        let filteredImageRef = ciContext.createCGImage(filteredImageData, from: filteredImageData.extent)
        let imageForButton = UIImage(cgImage: filteredImageRef!)
        return imageForButton
    }
    
}

extension EditViewController : SpeakerDelegate {
    func startSpeaker() {
    }
    
    func stopSpeaker() {
        if (emoticonName?.contains("Picture"))! {
            let fileNumber = emoticonName?.components(separatedBy: CharacterSet.decimalDigits.inverted).joined(separator: "")
            if !soundSetting {
                playMusic(fullName: "Audio" + fileNumber! + ".wav")
            }
        }
    }
}

extension UIImage {
    struct RotationOptions: OptionSet {
        let rawValue: Int
        
        static let flipOnVerticalAxis = RotationOptions(rawValue: 1)
        static let flipOnHorizontalAxis = RotationOptions(rawValue: 2)
    }
    
    func rotated(by rotationAngle: Measurement<UnitAngle>, options: RotationOptions = []) -> UIImage? {
        guard let cgImage = self.cgImage else { return nil }
        
        let rotationInRadians = CGFloat(rotationAngle.converted(to: .radians).value)
        let transform = CGAffineTransform(rotationAngle: rotationInRadians)
        var rect = CGRect(origin: .zero, size: self.size).applying(transform)
        rect.origin = .zero
        
        let renderer = UIGraphicsImageRenderer(size: rect.size)
        return renderer.image { renderContext in
            renderContext.cgContext.translateBy(x: rect.midX, y: rect.midY)
            renderContext.cgContext.rotate(by: rotationInRadians)
            
            let x = options.contains(.flipOnVerticalAxis) ? -1.0 : 1.0
            let y = options.contains(.flipOnHorizontalAxis) ? 1.0 : -1.0
            renderContext.cgContext.scaleBy(x: CGFloat(x), y: CGFloat(y))
            
            let drawRect = CGRect(origin: CGPoint(x: -self.size.width/2, y: -self.size.height/2), size: self.size)
            renderContext.cgContext.draw(cgImage, in: drawRect)
        }
    }
    
    func scale(scaleBy scaleValue: CGFloat) -> UIImage? {
        guard let cgImage = self.cgImage else { return nil }
        
        
        let transform = CGAffineTransform(scaleX: scaleValue, y: scaleValue)
        var rect = CGRect(origin: .zero, size: self.size).applying(transform)
        rect.origin = .zero
        
        
        let renderer = UIGraphicsImageRenderer(size: rect.size)
        return renderer.image { renderContext in
            renderContext.cgContext.scaleBy(x: CGFloat(scaleValue), y: CGFloat(scaleValue))
            
            let drawRect = CGRect(origin: CGPoint(x: -self.size.width/2, y: -self.size.height/2), size: self.size)
            renderContext.cgContext.draw(cgImage, in: drawRect)
        }
    }
    
}


