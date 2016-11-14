//
//  MentionsTableViewController.swift
//  Smashtag
//
//  Created by Sriharsha Sammeta on 31/03/15.
//  Copyright (c) 2015 Sriharshaa Sammeta. All rights reserved.
//

import UIKit


class MentionsTableViewController: UITableViewController {
    private enum Mentions: Printable{
        case Images([MediaItem])
        case HashTags([String])
        case Users([String])
        case URLs([String])
        
        var count:Int {
            switch self{
            case .Images(let imageString):
                return imageString.count
            case .HashTags(let hashTags):
                return hashTags.count
            case .Users(let users):
                return users.count
            case .URLs(let urls):
                return urls.count
            default:
                return 0
            }
        }
        var description:String {
            switch self{
            case .Images(_):
                return "Images"
            case .HashTags(_):
                return "Hashtags"
            case .Users(_):
                return "Users"
            case .URLs(_):
                return "URLs"
            default:
                return "No mentions of Image or hashtags or Users !"
            }
        }
    }
    
    private var tweetMentions = [Mentions]()
    
    var titleForNavigationController:String? = "Mentions"{
        didSet{
            if titleForNavigationController == nil{
                titleForNavigationController = "Mentions"
            }
        }
    }
    
    private struct Storyboard{
        static let CellIdentifierForImage = "Image"
        static let CellIdentifierForNonImageOrURL = "Not Image Or URL"
        static let CellIdentifierforURL = "URL"
        static let SegueToTweets = "Show Tweets"
        static let SegueToImage = "Show Image"
        static let SegueToWebView = "Show URL"
    }
    func addMentionsWithImages(images: [MediaItem],withURLs urls: [String],withHashTags hashTags:[String],andUsers users:[String]){
        // reset
        tweetMentions.removeAll(keepCapacity: false)
        if !images.isEmpty{
            tweetMentions.append(Mentions.Images(images))
        }
        if !urls.isEmpty{
            tweetMentions.append(Mentions.URLs(urls))
        }
        if !hashTags.isEmpty{
            tweetMentions.append(Mentions.HashTags(hashTags))
        }
        if !users.isEmpty{
            tweetMentions.append(Mentions.Users(users))
        }
        
        println("Mentions :\(tweetMentions)")
    }
    
    
    // MARK: - Table View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = titleForNavigationController
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        tableView.reloadData()
    }


    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return tweetMentions.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweetMentions[section].count
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tweetMentions[section].description
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        switch tweetMentions[indexPath.section]{
        case .Images(var mediaItem):
            var imageCell = tableView.dequeueReusableCellWithIdentifier(Storyboard.CellIdentifierForImage, forIndexPath: indexPath) as ImageTableViewCell
            imageCell.media = mediaItem[indexPath.row]
            println("returning imageCell \(imageCell.media?.url)")
            return imageCell
        case .URLs(var urls):
            var cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.CellIdentifierforURL, forIndexPath: indexPath) as UITableViewCell
            cell.textLabel?.text = urls[indexPath.row]
            return cell
        case .HashTags(var hashTags):
            var cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.CellIdentifierForNonImageOrURL, forIndexPath: indexPath) as UITableViewCell
            cell.textLabel?.text = hashTags[indexPath.row]
            return cell
        case .Users(var users):
            var cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.CellIdentifierForNonImageOrURL, forIndexPath: indexPath) as UITableViewCell
            cell.textLabel?.text = users[indexPath.row]
            return cell
        }
    }
    
    
    
    //MARK: - Navigation or Segue
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier{
            switch identifier{
            case Storyboard.SegueToTweets:
                if let ttvc = segue.destinationViewController as? TweetTableViewController{
                    if let cell = sender as? UITableViewCell {
                        ttvc.searchText = cell.textLabel?.text
                    }
                }
            case Storyboard.SegueToImage:
                if let ivc =  segue.destinationViewController as? ImageViewController{
                    if let imageCell = sender as? ImageTableViewCell{
                        ivc.imageURL = imageCell.media?.url
                    }
                }
            case Storyboard.SegueToWebView:
                if let wvc = segue.destinationViewController as? WebViewController {
                    if let webCell = sender as? UITableViewCell{
                        wvc.url = webCell.textLabel?.text
                    }
                }
            default:
                break
                
            }
        }
    }

    
    //MARK: - Table View Delegate

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch tweetMentions[indexPath.section]{
        case .Images(var medias):
            let media = medias[indexPath.row]
            println("width: \(view.bounds.width) aspect ratio: \(media.aspectRatio)")
            let heightForImage = self.view.bounds.width / CGFloat(media.aspectRatio)
            println("height: \(heightForImage)")
            return heightForImage
        default:
            return UITableViewAutomaticDimension
        }
    }
    
//    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        switch tweetMentions[indexPath.section]{
//        case .URLs(var urls):
//            var urlString: String = urls[indexPath.row]
//            if let url = NSURL(string: urlString){
//                
//                var alert = UIAlertController(title: urlString, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
//                alert.addAction(UIAlertAction(title: "Open in Safari", style: UIAlertActionStyle.Default, handler: {
//                    (action:UIAlertAction!) in
//                    UIApplication.sharedApplication().openURL(url)
//                    return
//                }))
//                alert.addAction(UIAlertAction(title: "Copy", style: UIAlertActionStyle.Default, handler: {
//                    (action:UIAlertAction!) in
//                    UIPasteboard.generalPasteboard().string = urlString
//                    self.tableView.deselectRowAtIndexPath(indexPath, animated: false)
//                    return
//                }))
//                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: {
//                    (action:UIAlertAction!) in
//                    self.tableView.deselectRowAtIndexPath(indexPath, animated: false)
//                    return
//                }))
//                presentViewController(alert, animated: true, completion: nil)
//            }
//        default:
//            break
//        }
//        
//    }

    
    
    
    
    
    
    
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

  

}
