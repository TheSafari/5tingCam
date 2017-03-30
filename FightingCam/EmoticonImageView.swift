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
    
    var image: UIImage? {
        get { return ivBackground.image}
        set { ivBackground.image = newValue
            print("frame width: \(contentView.frame.width) -- height \(contentView.frame.height)")
            print("image width: \(ivBackground.image?.size.width) -- height \(ivBackground.image?.size.height)")
            caculate()
            applyFilter()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initSubviews()
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubviews()
    }
    
    func initSubviews(){
        //standard initialization logic
        let nib = UINib(nibName: "EmoticonImageView", bundle: nil)
        nib.instantiate(withOwner: self, options: nil)
        contentView.frame = bounds
        addSubview(contentView)
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
            //set ratio cho imageView
            contentView.addSubview(imageView)
    }
    
    func addQuote(quote: String){
        //create original position of quote
        let x = (imageRect?.origin.x)! + 8
        let y = (imageRect?.origin.y)! + (imageRect?.size.height)! * 0.7
        
        let label = UILabel(frame: CGRect(x: x, y: y, width: 200, height: 100))
        label.textAlignment = .center
        label.text = quote
        label.numberOfLines = 0
        label.textColor = UIColor.white
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        contentView.addSubview(label)
    }
    
    func applyFilter(){
        guard let image = ivBackground?.image, let cgimg = image.cgImage else {
            print("imageView doesn't have an image!")
            return
        }
        
        let openGLContext = EAGLContext(api: .openGLES3)
        let context = CIContext(eaglContext: openGLContext!)
        
        let coreImage = CIImage(cgImage: cgimg)
        
        let filter = CIFilter(name: "CISepiaTone")
        filter?.setValue(coreImage, forKey: kCIInputImageKey)
        filter?.setValue(1, forKey: kCIInputIntensityKey)
        
        if let output = filter?.value(forKey: kCIOutputImageKey) as? CIImage {
            let cgimgresult = context.createCGImage(output, from: output.extent)
            let result = UIImage(cgImage: cgimgresult!)
            ivBackground?.image = result
        }
    }
    
    
    
    
}
