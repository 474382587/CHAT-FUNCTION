//
//  Helper.swift
//  Chat
//
//  Created by Joseph on 16/11/7.
//  Copyright © 2016年 Joseph. All rights reserved.
//

import Foundation
import FirebaseAuth
import UIKit
import FirebaseDatabase

class Helper{

    static let helper = Helper()
    
    func LoginTapped() {
    
    print("login tapped")
    
    // switch the view by setting navigation controller as root view
    //controller
    //steps:
    
    FIRAuth.auth()?.signInAnonymouslyWithCompletion({ (anonymousUser:FIRUser?, error:NSError?) in
    if error == nil{
    print("no error \(anonymousUser!.uid)")
        
    let newUser = FIRDatabase.database().reference().child("users").child(anonymousUser!.uid)
        newUser.setValue(["displayname" : "Anonymous","id": "\(anonymousUser!.uid)","profileUrl":""])
    
    
    // create a main storyboard instance
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    
    // from main storyboard instanitiate a navigation controller
    let naviVC = storyboard.instantiateViewControllerWithIdentifier("NavigationVC") as! UINavigationController
    
    
    // get the app delegate
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    // set the navigation controller as root view controller
    appDelegate.window?.rootViewController = naviVC
    
    }
    else{
    print(error!.localizedDescription)
    return
    }
    
    })
    
    
    }
    
    
    func switchToNavigationViewController(){
        let storyboard = UIStoryboard(name:"Main", bundle: nil)
        let naviVC = storyboard.instantiateViewControllerWithIdentifier("NavigationVC") as! UINavigationController
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.window?.rootViewController = naviVC
        
    }
    
}