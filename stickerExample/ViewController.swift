//
//  ViewController.swift
//  stickerExample
//
//  Created by AINSLIE YUEN on 4/19/17.
//  Copyright © 2017 Aroopy. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
      
    @IBOutlet var stickerView: UIImageView!
    var stickerArray: [Sticker] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layoutIfNeeded()
        let blankimage = UIImage(named: "simpleShape1" )
        stickerView.image = blankimage
        stickerView.isUserInteractionEnabled = true
    }

    @IBAction func addSticker(_ sender: Any) {
        let mySticker1 = Sticker(imageFileName: "stickerThankYou2Blue", stickerInitSize: 200, closeButtonSize: 50 )
        stickerArray.append(mySticker1)
        stickerView.addSubview(mySticker1)
    }
    
    @IBAction func shareButton(_ sender: UIBarButtonItem) {
        //The stickers' size is with respect to the frame of their superview.
        UIGraphicsBeginImageContext(CGSize(width: (stickerView.frame.size.width), height: (stickerView.frame.size.height)))
        for each in stickerArray {
            let location = CGPoint( x: each.frame.minX, y: each.frame.minY )
            each.renderWithTransform().draw(at: location )
        }
        let stickersImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let properWidth = CGFloat((stickerView.image?.size.width)!)
        let properHeight = CGFloat((stickerView.image?.size.height)!)
        
        UIGraphicsBeginImageContext(CGSize(width: properWidth, height: properHeight))
        stickerView.image?.draw(in: CGRect(x: 0, y: 0, width: properWidth, height: properHeight))
        stickersImage?.draw(in: CGRect(x: 0, y: 0, width: properWidth, height: properHeight))
        let whole_image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        let objectsToShare = ["Stickers are fun!", whole_image! ] as [Any]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        activityVC.popoverPresentationController?.barButtonItem = sender
        activityVC.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.addToReadingList,
                                            UIActivityType.assignToContact,
                                            UIActivityType.copyToPasteboard,
                                            UIActivityType.postToVimeo,
        ]
        self.present(activityVC, animated: true, completion: nil)
    }
    
}

