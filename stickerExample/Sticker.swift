//
//  Sticker.swift
//  stickerExample
//
//  Created by AINSLIE YUEN on 4/19/17.
//  Copyright © 2017 Aroopy. All rights reserved.

// Usage:
// To create a sticker:
// let mySticker1 = Sticker(imageFileName: "stickerThankYou2Blue.png", stickerInitSize: 200, closeButtonSize: 50)
//
// To add a created sticker to a parent (stickerView):
// stickerView.addSubview(mySticker1)
//
// The translations, rotations, rescalings of the sticker are taken care of by the
// transform property inherited from UIImageView. The image itself is not actually changed.
//
// To draw the Sticker as a UIImage onto a graphic Context
// (that is the same size as the parentview's frame size):
//
// let location = CGPoint( x: mySticker1.frame.minX, y: mySticker1.frame.minY )
// mySticker1.renderWithTransform().draw(at: location )

import UIKit

class Sticker: UIImageView, UIGestureRecognizerDelegate {
    var singleTapRecognizer = UITapGestureRecognizer()
    var pinchRecognizer = UIPinchGestureRecognizer()
    var panRecognizer = UIPanGestureRecognizer()
    var rotationRecognizer = UIRotationGestureRecognizer()
    
    var savedUnderlyingPhoto = UIImage()
    var cumulativePinchScale = CGFloat(1.0)
    
    var closeButton = UIButton()
    var buttonSize = 50
    
    init(imageFileName: String, stickerInitSize: Int, closeButtonSize: Int ) {
        super.init(frame:CGRect(origin: CGPoint(x:0,y:0), size: CGSize(width: stickerInitSize, height: stickerInitSize)))
        let initImage = generateImageWithMaxSide( imageFileName, maxSide: stickerInitSize )
        self.frame = CGRect(origin: CGPoint(x:0,y:0), size: initImage.size )
        
        image = initImage
        savedUnderlyingPhoto = initImage
        
        singleTapRecognizer = UITapGestureRecognizer(target: self, action:#selector(Sticker.handleTap(_:)))
        singleTapRecognizer.numberOfTapsRequired = 1
        singleTapRecognizer.numberOfTouchesRequired = 1
        singleTapRecognizer.delegate = self
        singleTapRecognizer.isEnabled = true
        self.addGestureRecognizer(singleTapRecognizer)
        
        pinchRecognizer = UIPinchGestureRecognizer(target: self, action:#selector(Sticker.handlePinch(_:)))
        pinchRecognizer.isEnabled = true
        pinchRecognizer.delegate = self
        self.addGestureRecognizer(pinchRecognizer)
        
        panRecognizer = UIPanGestureRecognizer(target: self, action:#selector(Sticker.handlePan(_:)))
        panRecognizer.isEnabled = true
        panRecognizer.delegate = self
        self.addGestureRecognizer(panRecognizer)
        
        rotationRecognizer = UIRotationGestureRecognizer(target: self, action:#selector(Sticker.handleRotate(_:)))
        rotationRecognizer.isEnabled = true
        rotationRecognizer.delegate = self
        self.addGestureRecognizer(rotationRecognizer)
        
        buttonSize = closeButtonSize
        closeButton = UIButton(frame:CGRect( x: 0,y: 0,width: buttonSize,height: buttonSize) )
        let closeImage  = generateSizedButtonImage( CGFloat(buttonSize), height: CGFloat(buttonSize) )
        closeButton.setImage(closeImage, for: UIControlState() )
        closeButton.addTarget(self, action: #selector(Sticker.removeSticker( _: )), for:.touchUpInside)
        closeButton.isHidden = false
        self.addSubview(closeButton)
        
        layer.borderColor = UIColor.red.cgColor
        layer.borderWidth = 1.0
        self.isUserInteractionEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func handleTap(_ recognizer: UITapGestureRecognizer) {
        if( pinchRecognizer.isEnabled  == false ){
            enableSticker()
        } else {
            disableSticker()
        }
    }
    
    func enableSticker(){
        pinchRecognizer.isEnabled = true
        panRecognizer.isEnabled = true
        rotationRecognizer.isEnabled = true
        closeButton.isHidden = false
        layer.borderColor = UIColor.red.cgColor
        layer.borderWidth = 2.0
    }
    
    func disableSticker(){
        pinchRecognizer.isEnabled = false
        panRecognizer.isEnabled = false
        rotationRecognizer.isEnabled = false
        closeButton.isHidden = true
        layer.borderColor = UIColor.clear.cgColor
    }
    
    func handlePinch(_ recognizer: UIPinchGestureRecognizer) {
        if let view = recognizer.view {
            view.transform = view.transform.scaledBy(x: recognizer.scale, y: recognizer.scale)
            cumulativePinchScale *= recognizer.scale
            //As we zoom in the scale increases.
            //But we want the closeButton to stay the same size relative to the screen
            //even if the sticker itself gets huge! So we need to divide the orig ButtonSize by the scale
            let newButtonSize = Int( CGFloat(buttonSize) / cumulativePinchScale )
            closeButton.frame = CGRect( x: 0,y: 0,width: newButtonSize,height: newButtonSize)
            recognizer.scale = 1
        }
    }
    func handlePan(_ recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: self.superview)
        if let view = recognizer.view {
            view.center = CGPoint(x:view.center.x + translation.x,
                                  y:view.center.y + translation.y)
        }
        recognizer.setTranslation(CGPoint( x:0,y:0), in: self.superview)
    }
    
    func handleRotate( _ recognizer : UIRotationGestureRecognizer) {
        if let view = recognizer.view {
            view.transform = view.transform.rotated(by: recognizer.rotation)
            recognizer.rotation = 0
        }
    }
    
    func gestureRecognizer( _ thisG: UIGestureRecognizer,
                            shouldRecognizeSimultaneouslyWith shouldRecognizeSimultaneouslyWithGestureRecognizer:UIGestureRecognizer) -> Bool {
        if( thisG.isKind(of: UIPinchGestureRecognizer.self )){
            if( shouldRecognizeSimultaneouslyWithGestureRecognizer.isKind(of: UIPanGestureRecognizer.self)){
                return true
            }
            else if( shouldRecognizeSimultaneouslyWithGestureRecognizer.isKind(of: UIRotationGestureRecognizer.self)){
                return true
            } else{
                return false
            }
        } else if( thisG.isKind(of: UIRotationGestureRecognizer.self )){
            if( shouldRecognizeSimultaneouslyWithGestureRecognizer.isKind(of: UIPanGestureRecognizer.self)){
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
    func renderWithTransform() -> UIImage {
        if let _ = image?.cgImage {
            var myCIImage = CIImage(cgImage: savedUnderlyingPhoto.cgImage!)
            let reqdAffineTransform = self.transform
            //Need to correct the transform matrix because the rotation direction is the opposite
            let angle = atan2(transform.b, transform.a)
            let correctedAffineTransform = reqdAffineTransform.rotated( by: -2.0 * angle )
            myCIImage = myCIImage.applying(correctedAffineTransform)
            let outputImage = UIImage(ciImage: myCIImage, scale: savedUnderlyingPhoto.scale, orientation: savedUnderlyingPhoto.imageOrientation)
            return outputImage
        } else {
            print("Unable to generate CiImage .... returning empty UIImage()")
            return UIImage()
        }
    }
    func generateSizedButtonImage( _ width: CGFloat, height: CGFloat ) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(CGSize( width: width, height: height), false, 0)
        let closeImage = UIImage(named: "redCross.png" )
        closeImage?.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        let sizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return sizedImage!
    }
    func generateImageWithMaxSide( _ imageName: String, maxSide: Int ) -> UIImage{
        if let rawImage = UIImage(named: imageName ){
            var width, height: CGFloat
            if( rawImage.size.width > rawImage.size.height ){
                width = CGFloat(maxSide)
                height = CGFloat(maxSide) * ( rawImage.size.height / rawImage.size.width )
            } else {
                height = CGFloat(maxSide)
                width = CGFloat(maxSide) * ( rawImage.size.width / rawImage.size.height )
            }
            UIGraphicsBeginImageContextWithOptions(CGSize( width: width, height: height), false, 0)
            rawImage.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
            let sizedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return sizedImage!
        } else {
            print("Couldn't find \(imageName) to make into a sticker!")
            return UIImage()
        }
    }
    func removeSticker( _ sender: UIButton ){
        self.removeFromSuperview()
        self.image = nil
    }
}
