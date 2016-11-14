//
//  LocalDefaults.swift
//  Smashtag
//
//  Created by Sriharsha Sammeta on 04/04/15.
//  Copyright (c) 2015 Sriharshaa Sammeta. All rights reserved.
//

import Foundation

struct LocalUserDefaults{
    static let searchesForUserDefaults = "Saved Tweet Searches"
    
    static func storeText(searchText:String){
        var userDefaults = NSUserDefaults.standardUserDefaults()
        var object = userDefaults.objectForKey(LocalUserDefaults.searchesForUserDefaults) as? [String]
        if object != nil {
            if object!.count > 100 {
                object!.removeAtIndex(object!.count - 1)
            }
        }else{
            object = [String]()
        }
        object!.insert(searchText, atIndex: 0)
        userDefaults.setValue(object, forKey: LocalUserDefaults.searchesForUserDefaults)
        userDefaults.synchronize()
    }
    static func removeTextAtIndex(index:Int){
        var userDefaults = NSUserDefaults.standardUserDefaults()
        if var object = userDefaults.objectForKey(LocalUserDefaults.searchesForUserDefaults) as? [String] {
            if index >= 0 && index < object.count{
                object.removeAtIndex(index)
                userDefaults.setValue(object, forKey: LocalUserDefaults.searchesForUserDefaults)
                userDefaults.synchronize()
            }
        }
    }
}
