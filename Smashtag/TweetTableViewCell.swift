//
//  TweetTableViewCell.swift
//  Smashtag
//
//  Created by Sriharshaa Sammeta on 3/1/15.
//  Copyright (c) 2015 Sriharshaa Sammeta. All rights reserved.
//

import UIKit

protocol TweetUserImageCacheDataSource{
    func dataForURL(url: NSURL?)->NSData?
    func saveData(data:NSData,withKey url:NSURL, andSize size:Int)
}

class TweetTableViewCell: UITableViewCell
{
    @IBInspectable
    var userColor = UIColor.orangeColor()
    
    @IBInspectable
    var hashTagColor = UIColor.blueColor()
    
    @IBInspectable
    var urlColor = UIColor.brownColor()

    var dataSourceForCache: TweetUserImageCacheDataSource?
    
    var tweet: Tweet?{
        didSet{
            updateUI()
        }
    }

    @IBOutlet weak var tweetProfileImageView: UIImageView!
    @IBOutlet weak var tweetScreenNameLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    func updateUI(){
     // reset any existing tweet Information
        tweetTextLabel?.attributedText = nil
        tweetProfileImageView?.image = nil
        tweetScreenNameLabel?.text = nil
    //load new information from our tweet (if any)
        
        if let tweet = self.tweet{
            
            var tweetText = NSMutableAttributedString(string: tweet.text)
            
            // user mentions color
            for user in tweet.userMentions {
                tweetText.addAttribute(NSForegroundColorAttributeName, value: userColor, range: user.nsrange)
            }
            
            //hashtags color
            for hashtag in tweet.hashtags{
                tweetText.addAttribute(NSForegroundColorAttributeName, value: hashTagColor, range: hashtag.nsrange)
            }
            
            //URL color
            for url in tweet.urls{
                tweetText.addAttribute(NSForegroundColorAttributeName, value: urlColor, range: url.nsrange)
            }
            
            
            
            tweetTextLabel?.attributedText = tweetText
            if tweetTextLabel?.attributedText != nil{
                for _ in tweet.media {
                    var stringWithCamera = tweetTextLabel.attributedText.mutableCopy() as NSMutableAttributedString
                    stringWithCamera.appendAttributedString(NSAttributedString(string: " 📷"))
                    tweetTextLabel.attributedText = stringWithCamera
                }
            
            }
        }
        
        tweetScreenNameLabel?.text = tweet != nil ? "\(tweet!.user)" : nil
        
        if let dataSource = dataSourceForCache{
            if let url =  tweet?.user.profileImageURL{
                if let imageData = dataSource.dataForURL(url){
//                    println("taking frm cache")
                    self.tweetProfileImageView?.image = UIImage(data: imageData)
                }
            }
        }
        
        if let url =  tweet?.user.profileImageURL{
            let qos = Int(QOS_CLASS_USER_INITIATED.value)
            dispatch_async(dispatch_get_global_queue(qos, 0)){ () -> Void in
                let offURL = url
                let imageData = NSData(contentsOfURL: url)
                if url == offURL{
                    dispatch_async(dispatch_get_main_queue()){
                        if imageData != nil{
                            self.tweetProfileImageView?.image = UIImage(data: imageData!)
                            self.dataSourceForCache?.saveData(imageData!, withKey: url, andSize: imageData!.length)
                        }
                    }
                }
                
            }
        }
        
    }
}
