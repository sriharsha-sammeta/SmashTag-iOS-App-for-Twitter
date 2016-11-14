//
//  TweetImageCollectionViewController.swift
//  Smashtag
//
//  Created by Sriharsha Sammeta on 03/04/15.
//  Copyright (c) 2015 Sriharshaa Sammeta. All rights reserved.
//

import UIKit

let reuseIdentifier = "Cell"

class TweetImageCollectionViewController: UICollectionViewController,CollectionCacheDataSource, UICollectionViewDelegateFlowLayout{

    
    
    
    // only add those tweets that have mediaitem in them

    var tweetsWithMedia:[(tweet: Tweet,media: MediaItem)] = []
    
    private var sizeOfCell :CGFloat = 150 {
        didSet{
            collectionView?.reloadData()
        }
    }
    private var cache = NSCache()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        println("----inside collection view----")
        
        self.collectionView?.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: "pinch:"))
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
//        self.collectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
    
    
    struct Storyboard{
        private static let CellIdentifierForImage = "Image"
        private static let minSizeOfCell:CGFloat = 30
        private static let IdentifierToSegueToTweetVC = "Show Tweet For This Image"
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        //#warning Incomplete method implementation -- Return the number of sections
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //#warning Incomplete method implementation -- Return the number of items in the section
        return tweetsWithMedia.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(Storyboard.CellIdentifierForImage, forIndexPath: indexPath) as TweetImageCollectionViewCell
        
        cell.dataSourceForCache = self
        cell.media = tweetsWithMedia[indexPath.row].media
        
        return cell
    }
    
    
    // MARK: - CollectionCacheDataSource
    
    func dataForURL(url: NSURL?) -> NSData? {
        if let URL = url {
            return cache.objectForKey(URL) as? NSData
        }
        return nil
    }
    
    func saveData(data: NSData, withKey url: NSURL, andSize size: Int) {
        cache.setObject(data, forKey: url, cost: size)
    }
    
    // MARK: - Collection layout -> FlowLayout
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize{
        var media = tweetsWithMedia[indexPath.row].media
        
        let ratio = CGFloat(media.aspectRatio)
        var width = CGFloat(0)
        var height = CGFloat(0)
        
        if ratio < 1 {
            height = sizeOfCell
            width = height * ratio
        }else{
            width = sizeOfCell
            height = width / ratio
        }
//        println("width: \(width) height: \(height)")
        return CGSize(width: width, height: height)
    }

    
    //MARK: - Gestures

    @IBAction func pinch(sender: UIPinchGestureRecognizer) {
//        println("pinch called \(collectionView)")
        println("pinch called ")
        switch sender.state{
        case UIGestureRecognizerState.Began , .Changed,.Ended:
            if sizeOfCell * sender.scale > Storyboard.minSizeOfCell{
                sizeOfCell *= sender.scale
                println("size of Cell: \(sizeOfCell)")
            }
            sender.scale = 1
        default: break
        }
        
    }
    
    //MARK: - Segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier{
            switch identifier{
                
            case Storyboard.IdentifierToSegueToTweetVC:
                if let uttvc = segue.destinationViewController as? TweetTableViewController {
                    if let cell = sender as? TweetImageCollectionViewCell {
                        if let index = collectionView?.indexPathForCell(cell){
                            uttvc.tweets = [[tweetsWithMedia[index.row].tweet]]
                        }
                    }
                }
            default:
                break
                
            }
        }
    }
    
    // MARK: UICollectionViewDelegate

    
    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */

}
