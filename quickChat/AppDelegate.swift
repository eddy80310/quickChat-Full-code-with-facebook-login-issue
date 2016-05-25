//
//  AppDelegate.swift
//  quickChat
//
//  Created by Edward Hung on 19/05/2016.
//  Copyright © 2016 Edward Hung. All rights reserved.
//

import UIKit
import Firebase
//import FirebaseDatabase
import CoreLocation


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
    
    // Backendless variables
    let APP_ID = "42D66D02-BE8B-0D03-FFDD-F7F0A3ED1900"
    let SECRET_KEY = "771EFB9C-9C31-709C-FFE4-7911AF69AC00"
    let VERSION_NUM = "v1"
    var backendless = Backendless.sharedInstance()
    
    // Location variables
    var locationManager:CLLocationManager?
    var coordinate:CLLocationCoordinate2D?
    // Setup PList to get location working
    // NSLocationWhenInUseUsageDescription = your text
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        // Facebook setup
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        // Firebase Setup
        FIRApp.configure()
        
        // Offline mode. Code updated E.H due to FB update
        FIRDatabase.database().persistenceEnabled = true
        
        // Backendless Setup
        backendless.initApp(APP_ID, secret:SECRET_KEY, version:VERSION_NUM)
        // If you plan to use Backendless Media Service, uncomment the following line (iOS ONLY!)
        // backendless.mediaService = MediaService()
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    // This gets called whenever the application become active
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        locationManagerStart()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        locationManagerStop()
    }

    //MARK: LocationManager functions
    
    func locationManagerStart() {
        
        // Check if we have location manager setup. Otherwise the app will crash
        if locationManager == nil {
            print("No location manager present. Init location manager")
            locationManager = CLLocationManager()
            locationManager?.delegate = self
            locationManager!.desiredAccuracy = kCLLocationAccuracyBest
            locationManager!.requestWhenInUseAuthorization()
        }
        print("Have location manager")
        
        locationManager!.startUpdatingLocation()
    }
    
    // Stop device to register user location
    func locationManagerStop() {
        
        locationManager?.stopUpdatingLocation()
    }
    
    //MARK: CLLocationManager Delegate
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {

        coordinate = newLocation.coordinate
    }
    
    //MARK: Facebook Login

    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        
        let result = FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
        
        if result {
            
            let token = FBSDKAccessToken.currentAccessToken()
            print("token = \(token)")
            
            let fieldsMapping = ["id" : "facebookId", "name" : "name", "email" : "email"]
            
            backendless.userService.loginWithFacebookSDK(token, fieldsMapping: fieldsMapping, response: { (user: BackendlessUser!) in
                
                print("Login to FB successfully")
                print("user = \(user)")
                print("user.name = \(user.name)")
                print("user.objectId = \(user.objectId)")
                
                }, error: { (fault: Fault!) in
                    
                    print("fault = \(fault)")
                    
            })
        
//            backendless.userService.loginWithFacebookSDK(token, fieldsMapping: fieldsMapping)
        }
        
        print("result = \(result)")
        
        return result
    }
    
    
    
    
}

