//
//  RecentsTableViewController.swift
//  Smashtag
//
//  Created by Sriharsha Sammeta on 01/04/15.
//  Copyright (c) 2015 Sriharshaa Sammeta. All rights reserved.
//

import UIKit

class RecentsTableViewController: UITableViewController {

    private var searchMentions:[[String]] {
        get{
            var userDefaults = NSUserDefaults.standardUserDefaults()
            if let object = userDefaults.objectForKey(LocalUserDefaults.searchesForUserDefaults) as? [String]{
                return [object]
            }else{
                println("from recents still empty")
                return [[String]]()

            }
        }
        set{
            var userDefaults = NSUserDefaults.standardUserDefaults()
            userDefaults.setObject(newValue, forKey: LocalUserDefaults.searchesForUserDefaults)
            userDefaults.synchronize()
        }
    }
    @IBAction func refresh(sender: UIRefreshControl) {
        tableView.reloadData()
        refreshControl?.endRefreshing()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if refreshControl != nil{
            refreshControl?.beginRefreshing()
        }
        tableView.reloadData()
        refreshControl?.endRefreshing()
    }


    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return searchMentions.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return searchMentions[section].count
    }

    struct StoryBoard{
        private static let cellIdentifier = "Search Text"
        private static let segueToSearchTweet = "Show Recent Tweets"
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(StoryBoard.cellIdentifier, forIndexPath: indexPath) as UITableViewCell
        cell.textLabel?.text = searchMentions[indexPath.section][indexPath.row]
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        println("segue identifier \(segue.identifier)")
        if let identifier = segue.identifier{
            switch identifier{
            case StoryBoard.segueToSearchTweet:
                println("segue from recents ")
                if let ttvc = segue.destinationViewController as? TweetTableViewController{
                    if let cell = sender as? UITableViewCell {
                        if let indexPath = tableView.indexPathForCell(cell){
                        ttvc.searchText = searchMentions[indexPath.section][indexPath.row]
                            println("search text:\(ttvc.searchText)")
                        }
                    }
                }
            default:
                break
            }
        }
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */


    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            LocalUserDefaults.removeTextAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

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
