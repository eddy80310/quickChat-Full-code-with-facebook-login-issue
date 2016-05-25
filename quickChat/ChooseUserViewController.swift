//
//  ChooseUserViewController.swift
//  quickChat
//
//  Created by Edward Hung on 19/05/2016.
//  Copyright © 2016 Edward Hung. All rights reserved.
//

import UIKit

protocol ChooseUserDelegate {
    func createChatroom(withUser: BackendlessUser)
}

class ChooseUserViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // Outlet Decleration
    @IBOutlet weak var tableView: UITableView!
    
    // Variable Decleration
    var users: [BackendlessUser] = []
    var delegate: ChooseUserDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Run the loadUsers functiont to create a list of user
        loadUsers()
        // Do any additional setup after loading the view.
        
        //TRY///
        let token = FBSDKAccessToken.currentAccessToken()
        let request = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"email"], tokenString: token.tokenString, version: nil, HTTPMethod: "GET")
        
        request.startWithCompletionHandler({ (connection, result, error : NSError!) -> Void in
            
            if error == nil {
                
                print("Request Complete")
                print("result = \(result)")
                
                let facebookId = result["id"]! as! String
                
                let avatarUrl = "https://graph.facebook.com/\(facebookId)/picture?type=normal"
                
                //update backendless user with avatar link
                //updateBackendlessUser(facebookId, avatarUrl: avatarUrl)
                
            } else {
                
                print("Facebook request error \(error)")
            }
        })
        
        //TRY///
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: UITableviewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        let user = users[indexPath.row]
        cell.textLabel?.text = user.name
        
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    //MARK: UITableviewDelegate
    
    // Whenever user taps on the cell
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // Get user to pass onto createChatRoom function
        let user = users[indexPath.row]
        delegate.createChatroom(user)
        
        // De-select the cell
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        // Show the previous VC
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: IBAction
    
    // Cancel Button
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        
        // Return back to previous VC
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: Load Backendless Users
    
    // Setup user array of usersby querying the database
    func loadUsers(){
        
        // Retreive all users but current user 
        let whereClause = "objectID != '\(backendless.userService.currentUser.objectId)'" // currentUser was already decleared as backendless.userService.currentUser
        let dataQuery = BackendlessDataQuery()
        dataQuery.whereClause = whereClause
        let dataStore = backendless.persistenceService.of(BackendlessUser.ofClass()) // backendless was already decleared as Backendless.sharedInstance()
        dataStore.find(dataQuery, response: { (users: BackendlessCollection!) in
            
            // Data found, reload tableview
            self.users = users.data as! [BackendlessUser]
            self.tableView.reloadData()
            
        }) { (fault: Fault!) in
                print("Error, couldnt retrive users in ChooseUserViewController: \(fault)")
        }
    }
    

}
