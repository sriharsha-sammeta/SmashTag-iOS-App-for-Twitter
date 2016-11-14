//
//  ImageTableViewCell.swift
//  Smashtag
//
//  Created by Sriharsha Sammeta on 31/03/15.
//  Copyright (c) 2015 Sriharshaa Sammeta. All rights reserved.
//

import UIKit

class ImageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var mentionImageView: UIImageView!

    var media: MediaItem?{
        didSet{
            updateUI()
        }
    }

    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    private func updateUI(){
        
        if let url =  media?.url{
            spinner?.startAnimating()
            let qos = Int(QOS_CLASS_USER_INITIATED.value)
            dispatch_async(dispatch_get_global_queue(qos, 0)){ () -> Void in
                let offURL = url
                let imageData = NSData(contentsOfURL: url)
                if url == offURL{
                    dispatch_async(dispatch_get_main_queue()){
                        if imageData != nil{
                            self.mentionImageView?.image = UIImage(data: imageData!)
                            self.spinner?.stopAnimating()
                        }
                    }
                }
                
            }
        }

        
//        if let mediaWithUrl = media{
//            if let imageData = NSData(contentsOfURL: mediaWithUrl.url){
//                // block main thread
//                mentionImageView?.image = UIImage(data: imageData)
//            }
//        }
        
    }
   

}
