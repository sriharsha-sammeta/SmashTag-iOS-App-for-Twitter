//
//  TweetTableViewController.swift
//  Smashtag
//
//  Created by Sriharshaa Sammeta on 3/1/15.
//  Copyright (c) 2015 Sriharshaa Sammeta. All rights reserved.
//

import UIKit

class TweetTableViewController: UITableViewController,UITextFieldDelegate,TweetUserImageCacheDataSource {

    var tweets:[[Tweet]] = [[Tweet]]() {
        didSet{
            imageCollectionButton.enabled = !tweetsWithMedia.isEmpty
        }
    }
    
    private var cache = NSCache()
    
    
    var searchText: String? {
        didSet{
            lastSuccefulRequest = nil
            searchTextField?.text = searchText
            tweets.removeAll()
            tableView?.reloadData()
            refresh()
            if searchText != nil {
                LocalUserDefaults.storeText(searchText!)
            }
            println("searchText called !")
        }
    }
    
    private var tweetsWithMedia:[(tweet:Tweet,media:MediaItem)]{
        get{
            var tWM:[(tweet:Tweet,media:MediaItem)] = []
            var tempArr = [Tweet]()
            for tweetArray in tweets{
                var temp = tweetArray.filter{
                    (tweet: Tweet)-> Bool in
                    if !tweet.media.isEmpty {
                        return true
                    }
                    return false
                }
                if !temp.isEmpty {
                    tempArr += temp
                }
            }
            for myTweet in tempArr {
                for media in myTweet.media {
                    tWM.append(tweet: myTweet, media: media)
                }
            }
            return tWM
        }
    }
    
    private lazy var imageCollectionButton:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Camera, target: self, action: "segueToImageCollection")
    
    private var scrollOffset:CGPoint = CGPointZero
    
    // MARK: - View Controller LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if tweets.isEmpty {
            if searchText == nil{
                searchText = "#Apple"
            }
        }
        refresh()
        tableView?.reloadData()
        println("\(self.navigationItem.rightBarButtonItems)")
        
        if self.navigationItem.rightBarButtonItems == nil {
            self.navigationItem.rightBarButtonItems = [imageCollectionButton]
        }else{
            self.navigationItem.rightBarButtonItems?.append(imageCollectionButton)
        }
        imageCollectionButton.enabled = false
        
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.title = nil
    }
    
    var lastSuccefulRequest: TwitterRequest?
    
    var nextRequestToAttempt: TwitterRequest?{
        if lastSuccefulRequest == nil{
            if searchText != nil{
                if searchText!.hasPrefix("@"){

                    var temp = searchText!.substringFromIndex(advance(searchText!.startIndex, 1))
                    println("Twitter request :" + "from:\(temp) OR \(searchText!)")
                    lastSuccefulRequest = TwitterRequest(search: "from:\(temp) OR \(searchText!)", count: 100)
                    return lastSuccefulRequest
                }
                println("Twitter request :" + searchText!)
                lastSuccefulRequest = TwitterRequest(search: searchText!, count: 100)
                return lastSuccefulRequest
            }else{
                lastSuccefulRequest = nil
                return nil
            }
        }else{
            return lastSuccefulRequest!.requestForNewer
        }
    }
    
    func refresh(){
        if refreshControl != nil{
            refreshControl?.beginRefreshing()
        }
        refresh(refreshControl)
    }
    
    
    @IBAction func refresh(sender: UIRefreshControl?) {
        if searchText != nil && !searchText!.isEmpty{
            if let request = nextRequestToAttempt{
                request.fetchTweets{ (newTweets) -> Void in
                    dispatch_async(dispatch_get_main_queue()) { () -> Void in
                        if newTweets.count > 0 {
                            println("tweets came in !")
                            
                            self.tweets.insert(newTweets, atIndex: 0)
                            self.tableView?.reloadData()
                            sender?.endRefreshing()
                            
                            if !self.tweets.isEmpty{
                                println("tweets count : \(self.tweets[0].count)")
                            }else{
                                println("empty tweets")
                            }

                        }else{
                            
                            if self.searchText != nil {
                                var alert = UIAlertController(title: "Twitter Baffled 😳😅 !", message: "0 tweets on \(self.searchText!)", preferredStyle: UIAlertControllerStyle.Alert)
                                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler:nil))
                                self.presentViewController(alert, animated: true, completion: nil)
                            }
                            sender?.endRefreshing()
                        }
                    }
                }
            }
        }else{
        sender?.endRefreshing()
        }
        
    }
    
    @IBOutlet weak var searchTextField: UITextField! {
        didSet{
            searchTextField.delegate = self
            searchTextField.text = searchText
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == searchTextField {
            textField.resignFirstResponder()
            searchText = textField.text
        }
        return true
    }
    // MARK: - UITableViewDataSource

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return tweets.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets[section].count
    }

    private struct Storyboard{
        static let CellReuseIdentifier = "Tweet"
        static let segueToMentionsIdentifier = "Show Mentions"
        static let segueToCollectionView = "Show Image in CollectionView"
    }
        
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.CellReuseIdentifier, forIndexPath: indexPath) as! TweetTableViewCell

        cell.dataSourceForCache = self
        cell.tweet = tweets[indexPath.section][indexPath.row]
        return cell
    }
    
    private func StringsForIndexKeywords(indices: [Tweet.IndexedKeyword])->[String]{
        var str = [String]()
        for index in indices{
            str.append(index.keyword)
        }
        return str
    }
    
        
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identiifier = segue.identifier{
            switch identiifier{
            case Storyboard.segueToMentionsIdentifier:
                if let cell = sender as? TweetTableViewCell {
                    if let indexPath = tableView.indexPathForCell(cell){
                        if let mvc = segue.destinationViewController as? MentionsTableViewController{
                            let tweet = tweets[indexPath.section][indexPath.row]
                            
                            // displaying proper title and back button
                            mvc.titleForNavigationController = tweet.user.screenName
                            if searchText != nil {
                                self.title = searchText!
                            }
                            
                            var users = StringsForIndexKeywords(tweet.userMentions)
                            users.insert("@" + tweet.user.screenName, atIndex: 0)

                            mvc.addMentionsWithImages(tweet.media, withURLs: StringsForIndexKeywords(tweet.urls),withHashTags: StringsForIndexKeywords(tweet.hashtags),andUsers: users)
                            println("seguing to mentions")
                            println("media \(tweet.media)")
                        }
                    }
                }
            case Storyboard.segueToCollectionView:
                if let ticvc = segue.destinationViewController as? TweetImageCollectionViewController{
                    println("tweet with media count :\(tweetsWithMedia.count)")
                    println("Tweets with media: ")
                   
                    if !tweetsWithMedia.isEmpty{
                        ticvc.tweetsWithMedia = tweetsWithMedia
                    }else{
                        ticvc.tweetsWithMedia = []
                    }
                }
            default:
                break
            
            }
        }
    }
    
    func segueToImageCollection(){
        println("seguing to image collection")
        performSegueWithIdentifier(Storyboard.segueToCollectionView, sender: nil)
    }
    
    //Mark: - Cache Data Source
    
    func dataForURL(url: NSURL?) -> NSData? {
        if let URL = url {
            return cache.objectForKey(URL) as? NSData
        }
        return nil
    }
    
    func saveData(data: NSData, withKey url: NSURL, andSize size: Int) {
        cache.setObject(data, forKey: url, cost: size)
    }
    
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
