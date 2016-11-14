//
//  UnwindTweetTableViewController.swift
//  Smashtag
//
//  Created by Sriharsha Sammeta on 03/04/15.
//  Copyright (c) 2015 Sriharshaa Sammeta. All rights reserved.
//

import UIKit

class UnwindTweetTableViewController: TweetTableViewController {
    @IBAction func unwindToRoot(segue: UIStoryboardSegue){
        println("unwinding!")
    }
}
