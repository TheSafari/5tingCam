//
//  EmoticonImageView.swift
//  AttachImage
//
//  Created by Nam Pham on 3/21/17.
//  Copyright © 2017 Nam Pham. All rights reserved.
//

import UIKit
import AVFoundation

class EmoticonImageView: UIView {
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var ivBackground: UIImageView!
    
    var image: UIImage?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initSubviews()
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubviews()
    }
    
    func initSubviews(){
        print(">>>>>> frame width: \(frame.width) -- height \(frame.height)")
        //standard initialization logic
        let nib = UINib(nibName: "EmoticonImageView", bundle: nil)
        nib.instantiate(withOwner: self, options: nil)
        frame = contentView.frame
        bounds = contentView.bounds
        print(">>>>>> frame width: \(contentView.frame.width) -- height \(contentView.frame.height)")
        contentView.frame = bounds
        addSubview(contentView)
    }
    
    func setImage(bgImage: UIImage) {
        self.image = bgImage
        ivBackground.image = self.image
        print("frame width: \(contentView.frame.width) -- height \(contentView.frame.height)")
        print("image width: \(String(describing: ivBackground.image?.size.width)) -- height \(String(describing: ivBackground.image?.size.height))")
        caculate()
    }
    
    var ratio: CGFloat?
    var offsetX: CGFloat?
    var offsetY: CGFloat?
    var imageRect: CGRect?
    
    func caculate(){
        imageRect = AVMakeRect(aspectRatio: (ivBackground.image?.size)!, insideRect: contentView.frame)
        ratio = (imageRect?.size.width)! / (ivBackground.image?.size.width)!
        
        offsetX = imageRect?.origin.x
        offsetY = imageRect?.origin.y
    }
    
    func addEmoticionFace(face: FaceInfo, imageFace: UIImage){
        let imageView = UIImageView(image: imageFace)
        
        //create image view with (x,y) and (width, height)
        let x = self.offsetX! + CGFloat(face.faceRectangle.left) * ratio!
        let y = self.offsetY! + CGFloat(face.faceRectangle.top) * ratio!
        let width = CGFloat(face.faceRectangle.Width) * ratio!
        let height = CGFloat(face.faceRectangle.height) * ratio!
        print("x \(x) - y: \(y) - widht: \(width) - height: \(height)")
        imageView.frame = CGRect(x: x, y: y, width: width, height: height)
        imageView.contentMode = .scaleAspectFit // OR .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        imageView.tag = 100001
        let rotate = UIRotationGestureRecognizer(target: self, action: #selector(EmoticonImageView.onRotateGesture(_:)))
        rotate.delegate = self
        imageView.addGestureRecognizer(rotate)
        
        // Do any additional setup after loading the view.
        //let pinch = UIPinchGestureRecognizer(target: self, action: #selector(EmoticonImageView.pinch(_:)))
        //pinch.delegate = self
        //imageView.addGestureRecognizer(pinch)
        
        //set ratio cho imageView
        
        for subview in contentView.subviews {
            if (subview.tag == 100001) {
                print(subview)
                subview.removeFromSuperview()
            }
        }
        contentView.addSubview(imageView)
    }
    
    var currentQuote: OriginalQuote?
    
    func addQuote(quote: String){
        
        //create original position of quote
        let x = (imageRect?.origin.x)! + (imageRect?.size.width)! * 0.1
        let y = (imageRect?.origin.y)! + (imageRect?.size.height)! * 0.7
        
        currentQuote = OriginalQuote(quote: quote)
        currentQuote?.x = x / ratio!
        currentQuote?.y = y / ratio!
        
        let label = UILabel(frame: CGRect(x: x, y: y, width: (imageRect?.size.width)! * 0.8, height: 100))
        label.textAlignment = .center
        label.text = quote
        label.numberOfLines = 0
        label.textColor = UIColor.white
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = UIFont(name: "Yellowtail", size: 20.0)
        label.isUserInteractionEnabled = true
        label.tag = 100000
        //add pan gesture for quote
        let pan = UIPanGestureRecognizer(target: self, action: #selector(EmoticonImageView.onQuotePanGesture(_:)))
        label.addGestureRecognizer(pan)
        
        for subview in contentView.subviews {
            if (subview.tag == 100000) {
                print(subview)
                subview.removeFromSuperview()
            }
        }
        
        contentView.addSubview(label)
    }
    
    //==================
    // gesture for quote
    //==================
    var initalFacePoint: CGPoint?
    func onQuotePanGesture(_ sender: UIPanGestureRecognizer) {
        if let currentView = sender.view {
            let state = sender.state
            var translation: CGPoint?
            switch state {
            case .began:
                initalFacePoint = currentView.center
            case .changed:
                translation = sender.translation(in: contentView)
                currentView.center = CGPoint(x: (initalFacePoint?.x)! + (translation?.x)!, y: (initalFacePoint?.y)! + (translation?.y)!)
            default:
                currentQuote?.x = currentView.frame.origin.x / ratio!
                currentQuote?.y = currentView.frame.origin.y / ratio!
                break;
            }
        }
    }
    
    
    //================
    //gesture for face
    //================
    
    //add rotate gesture
    var rotateValue: Double = 0
    
    func onRotateGesture(_ sender: UIRotationGestureRecognizer) {
        if let currentView = sender.view {
            currentView.transform = currentView.transform.rotated(by: sender.rotation)
            rotateValue += toDegree(sender.rotation)
            sender.rotation = 0
        }
    }
    
    func toDegree(_ radians: CGFloat) -> Double {
        return Double(radians * 180/(.pi))
    }
    
    var pichValue: CGFloat = 1
    //add pich gesture
    func pinch(_ sender: UIPinchGestureRecognizer){
        if let currentView = sender.view {
            currentView.transform = currentView.transform.scaledBy(x: sender.scale, y: sender.scale)
            pichValue *= sender.scale
            print("rotate value \(pichValue)")
            sender.scale = 1
        }
    }
    
    func applyFilter(){
        applyFilter(0)
    }
    
    func applyFilter2(){
        applyFilter(1)
    }
    
    func applyFilter3(){
        applyFilter(2)
    }
    
    func applyFilter4(){
        applyFilter(3)
    }
    
    var CIFilterNames = [
        "CIPhotoEffectChrome",
        "CIPhotoEffectFade",
        "CIPhotoEffectInstant",
        "CIPhotoEffectNoir"
    ]
    
    func applyFilter(_ i : Int){
        let openGLContext = EAGLContext(api: .openGLES3)
        let context = CIContext(eaglContext: openGLContext!)
        
        //let coreImage = CIImage(cgImage: cgimg)
        let coreImage = CIImage(image: self.image!)
        
        
        let filter = CIFilter(name: "\(CIFilterNames[i])")
        filter!.setDefaults()
        filter!.setValue(coreImage, forKey: kCIInputImageKey)
        
        
        if let output = filter?.value(forKey: kCIOutputImageKey) as? CIImage {
            let cgimgresult = context.createCGImage(output, from: output.extent)
            ivBackground?.image = UIImage(cgImage: cgimgresult!)
        }
    }
}

extension EmoticonImageView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
