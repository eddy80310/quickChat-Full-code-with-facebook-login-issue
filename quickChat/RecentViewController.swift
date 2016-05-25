//
//  RecentViewController.swift
//  quickChat
//
//  Created by Edward Hung on 19/05/2016.
//  Copyright © 2016 Edward Hung. All rights reserved.
//

import UIKit

class RecentViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ChooseUserDelegate {

    // Outlet Decleration
    @IBOutlet weak var tableView: UITableView!
    
    // Variable Decleration
    var recents: [NSDictionary] = []
    
    // viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadRecents()
        //self.tabBarController?.tabBar.hidden = false
        
        self.title = backendless.userService.currentUser.name + "Chats"

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: UITableviewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recents.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! RecentTableViewCell

        let recent = recents[indexPath.row]
        
        // Update image and data in cell
        cell.bindData(recent)
        
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    //MARK: UITableviewDelegateFunctions
    
    // When user select the tableview
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // Deselect user
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        // Create recent for user2 users if it has been deleted
        let recent = recents[indexPath.row]
        RestartRecentChat(recent)
        
        // Call segue
        performSegueWithIdentifier("recentToChatSeg", sender: indexPath)
    }
    
    // Deleting table. Allow the slide to delete to appear
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    // What happems when the user is deleting the table
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        // Keep a copy of recents before deleted
        let recent = recents[indexPath.row]
        
        // Remove recents from the array 
        recents.removeAtIndex(indexPath.row)
        
        // Delete recent from FB
        DeleteRecentItem(recent)
        
        // Reload tableView
        tableView.reloadData()
    }
    
    //MARK: IBActions
    
    // Create new chat button
    @IBAction func startNewChatBarButtonItemPress(sender: AnyObject) {
        
        performSegueWithIdentifier("recentToChooseUserVC", sender: self)
    }
    
    //MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        // show Choose user controller
        if segue.identifier == "recentToChooseUserVC" {
            let vc = segue.destinationViewController as! ChooseUserViewController
            vc.delegate = self
        }
        
        // Show chat view controller
        if segue.identifier == "recentToChatSeg" {
            let indexPath = sender as! NSIndexPath
            let chatVC = segue.destinationViewController as! ChatViewController
            let recent = recents[indexPath.row] // recent will be usable at chatVC
            
            // Hide the bar button item (Bug fix by instructor)
            chatVC.hidesBottomBarWhenPushed = true
            
            // Set chatVC recent to our recent
            chatVC.recent = recent
            chatVC.chatRoomId = recent["chatRoomID"] as? String
            
        }
    }
    
    //MARK: ChooseUserDelegate
    func createChatroom(withUser: BackendlessUser) {
        
        let chatVC = ChatViewController()
        navigationController?.pushViewController(chatVC, animated: true)
        chatVC.hidesBottomBarWhenPushed = true
        
        // Set chatVC recent to our recent
        chatVC.witUser = withUser
        chatVC.chatRoomId = startChat(backendless.userService.currentUser, user2: withUser)
    }
    
    //MARK: Load Recents from firebase
    func loadRecents(){
        
        // Query firebase using observeEventType as we are querying all the items in the recent
        firebase.child("Recent").queryOrderedByChild("userId").queryEqualToValue(backendless.userService.currentUser.objectId).observeEventType(.Value, withBlock: {
            snapshot in
            
            // Ensure rents array is completely empty 
            self.recents.removeAll()
            
            // Check if snapshot exists
            if snapshot.exists(){
                
                // Sort array based on date so the latest chat is on top
                let sorted = ((snapshot.value?.allValues)! as NSArray).sortedArrayUsingDescriptors([NSSortDescriptor(key:"date", ascending: false)])
                
                // Append sorted aray
                for recent in sorted {
                    self.recents.append(recent as! NSDictionary)
                    
                    // Add function to have offline access as well
                    /*firebase.child("Recent").queryOrderedByChild("chatRoomID").queryEqualToValue(recent["chatRommID"]).observeEventType(.Value, withBlock: {
                        snapshot in
                    })*/
                }
                
            } else {
                
                // Snapshot doesnt exist
            }
            self.tableView.reloadData()
        })
    }
}
