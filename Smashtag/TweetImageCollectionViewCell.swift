//
//  ImageCollectionViewCell.swift
//  Smashtag
//
//  Created by Sriharsha Sammeta on 03/04/15.
//  Copyright (c) 2015 Sriharshaa Sammeta. All rights reserved.
//

import UIKit

protocol CollectionCacheDataSource{
    func dataForURL(url: NSURL?)->NSData?
    func saveData(data:NSData,withKey url:NSURL, andSize size:Int)
}

class TweetImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var media: MediaItem?{
        didSet{
            updateUI()
        }
    }
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var dataSourceForCache:CollectionCacheDataSource?
    

    private func updateUI(){
        
        // image from cache
        if let dataSource = dataSourceForCache{
            if let data = dataSource.dataForURL(media?.url){
                self.imageView?.image = UIImage(data: data)
                return
            }
        }
    
        
        //else image via new request
        if let url =  media?.url{
            spinner?.startAnimating()
            let qos = Int(QOS_CLASS_USER_INITIATED.value)
            dispatch_async(dispatch_get_global_queue(qos, 0)){ () -> Void in
                let offURL = url
                let imageData = NSData(contentsOfURL: url)
                if url == offURL{
                    dispatch_async(dispatch_get_main_queue()){
                        if imageData != nil{
                            self.imageView?.image = UIImage(data: imageData!)
                            
                            
                            //saving image to cache
                            if let dataSource = self.dataSourceForCache{
                                dataSource.saveData(imageData!, withKey: url,andSize: imageData!.length)
                            }
                            self.spinner?.stopAnimating()
                        }
                    }
                }
                
            }
        }
    }
    
    
}

