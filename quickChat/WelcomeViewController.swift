//
//  WelcomeViewController.swift
//  quickChat
//
//  Created by Edward Hung on 19/05/2016.
//  Copyright © 2016 Edward Hung. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class WelcomeViewController: UIViewController {

    // Outlet Decleration
    
    @IBOutlet weak var fbLoginButton: FBSDKLoginButton!
    
    let backendless = Backendless.sharedInstance()
    var currentUser: BackendlessUser?
    
    //TRY//
    @IBAction func Button(sender: AnyObject) {

        if let user = backendless.userService.currentUser {
            print("currernt user")
            print(user)
            print(backendless.userService.currentUser.name)
        } else {
            print("No current user")
        }
    }
    
    
    
    
    // viewWillAppear
    override func viewWillAppear(animated: Bool) {
        
        // Allow user to stay logged in
        backendless.userService.setStayLoggedIn(true)
        
        if backendless.userService.currentUser != nil {
        
            // Present the VC on main que otherwise it will give an warning (Unbalanced calls to begin/end appearance transitions). Everytime when we are trying to do process that takes time it is on the other que. It is good for background actions like download images
            dispatch_async(dispatch_get_main_queue(), {
                
                // Already logged in. Transition to the recent VC
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ChatVC") as! UITabBarController
                vc.selectedIndex = 0
                self.presentViewController(vc, animated: true, completion: nil)
            })
            
        } else {
            
            // No current user
            print("no current user")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Facebook loging button 
        fbLoginButton.readPermissions = ["public_profile", "email"]
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
