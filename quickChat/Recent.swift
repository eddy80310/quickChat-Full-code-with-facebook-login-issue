//
//  Recent.swift
//  quickChat
//
//  Created by Edward Hung on 19/05/2016.
//  Copyright © 2016 Edward Hung. All rights reserved.
//

import Foundation
import Firebase

//------Constants-----\\
public let kAVATARSTATE = "avatarState"
public let kFIRSTRUN = "firstRun"
//-----------\\



// These functions and variables allow all swift files to access

// For firebase
let firebase = FIRDatabase.database().reference()
let backendless = Backendless.sharedInstance()
let currentUser = backendless.userService.currentUser


//MARK: Create Chatroom

// Take two backendless user and return a string as chatroomI
func startChat(user1: BackendlessUser, user2: BackendlessUser) -> String{

    // User1 is current user
    let userId1:String = user1.objectId
    let userId2:String = user2.objectId
    var chatRoomId:String = ""
    
    // Compare the two IDs. The compare function will return the same result when the two items are compared
    let value = userId1.compare(userId1).rawValue
    
    if value < 0 {
        chatRoomId = userId1.stringByAppendingString(userId2)
    
    } else {
        chatRoomId = userId2.stringByAppendingString(userId1)
    }
    
    let members = [userId1,userId2]
    
    // Create recent
    CreateRecent(userId1, chatroomID: chatRoomId, members: members, withUserUsername: user2.name!, withUserUserId: userId2)
    CreateRecent(userId2, chatroomID: chatRoomId, members: members, withUserUsername: user1.name!, withUserUserId: userId1)
    
    return chatRoomId
}

//MARK: Create Recent

func CreateRecent(userId:String, chatroomID:String, members:[String], withUserUsername:String, withUserUserId:String){
    
    print("Func:CreateRecent. userId = \(userId)")
    
    // Check firebase to see if we have that recent already
    
    // Query firebase under the path https://quickchatapplication-10559.firebaseio.com/Recent.
    // Check if the chatroom ID matches the chatroomId we are sending
    // This code will run only once (obervesSingleEventOfType). Otherwise everytime firebase change this code will run 
    // snapshot is the value that returns when firebase is queried
    
    
    //firebase.child("Recent").queryOrderedByChild("chatRoomID").queryEqualToValue(chatroomID).observeEventType(.Value, withBlock:{ snapshot in
    firebase.child("Recent").queryOrderedByChild("chatRoomID").queryEqualToValue(chatroomID).observeSingleEventOfType(.Value, withBlock:{ snapshot in
        
        // Why is it only returning one snapshot.(sometimes)
        
        var createRecent = true
        
        print("entering querying phase")
        
        // check if we have result
        if snapshot.exists() {
            
            print("passed chatRoomId = \(chatroomID)")
            print("snapshot exists")
            print("//////Snapshot/////")
            print(snapshot)
            print("//////Snapshot/////")
            print("Snapshot.value.count = \(snapshot.value?.allValues.count)")
            
            for recent in (snapshot.value?.allValues)! {
                
                print("Compare the below two item")
                print("recent(userId) = \(recent["userId"])")
                print("userId = \(userId)")
                
                // if we already have recent with UserId, we dont create a new chat room
                if recent["userId"] as! String == userId {
                    createRecent = false
                    
                    print("a \(recent["userId"])")
                }
            }
        
        } else {
            
            print("snapshot does not exist")
            //print("b \(recent["userId"])")
        }
        
        print("create Recent Bool \(createRecent)")
        
        // Need to create new recent chat room
        if createRecent {
            
            // Create recent item here
            createRecentItem(userId, chatroomID: chatroomID, members: members, withUserUsername: withUserUsername, withUserUserId: withUserUserId)
            
        }
    })
}

func createRecentItem(userId: String, chatroomID:String , members:[String], withUserUsername:String, withUserUserId:String){
    
    print("Func:Create Recent Item")
    
    // Generate a ID(by firebase) for the recent. Create date from current date
    let ref = firebase.child("Recent").childByAutoId()
    let recentId = ref.key
    let date = dateFormatter().stringFromDate(NSDate() )
    
    // Create recent dictionary
    let recent = ["recentId": recentId, "userId": userId, "chatRoomID": chatroomID, "members": members, "withUserUsername": withUserUsername, "lastMessage": "", "counter": 0, "date": date, "withUserUserId": withUserUserId]
    
    // Save dict to firebase
    ref.setValue(recent, withCompletionBlock: { (error, ref) in
        
        if error != nil {
            
            // Error creating recent to FB
            print("error creating recent to FB \(error)")
            
        } else {
            // Successfully create to FB
            print("Save to FB successfully")
        }
    })
}

//MARK: Update Recent
func UpdateRecents(chatRoomID: String, lastMessage: String){
    
    // Make Query to FB to get both Recents for the two user in the same chatRoomOD
    firebase.child("Recent").queryOrderedByChild("chatRoomID").queryEqualToValue(chatRoomID).observeSingleEventOfType(.Value, withBlock: {
        (snapshot) in
        
        // Check if there is any result
        if snapshot.exists() {
            
            // go through every recent and update it
            for recent in (snapshot.value?.allValues)! {
                
                // Update recent Item
                UpdateRecentItem(recent as! NSDictionary, lastMessage: lastMessage)
            }
        
        } else {
            
            print("Snapshot does not exist UpdateRecents Function")
            // Snapshot doesnt exist
        }
    })
}

func UpdateRecentItem(recent: NSDictionary, lastMessage: String){
    
    print("UpdateRecentItem()")
    
    // Update date
    let date = dateFormatter().stringFromDate(NSDate()) // NSDate() = current date
    var counter = recent["counter"] as! Int
    
    // Update counter for other user by checking if the recent is the current user or the other user
    if recent["userId"] as? String != backendless.userService.currentUser.objectId {
        counter = counter + 1
    }
    
    // Update firebase with the diction values
    let values = ["lastMessage": lastMessage, "counter": counter, "date": date]
    
    // Update firebase to tell the recent to replace all the items in values
    firebase.child("Recent").child((recent["recentId"] as? String)!).updateChildValues(values as [NSObject : AnyObject]) { (error, ref) in
     
        if error != nil {
            print("Error update firebase UpdateRecentItem() \(error)")
        
        } else {
            print("UpdateRecentItem() Successfully")
        }
    }
}

//MARK: Restart Recent Chat (Incase the other user deleted their recent chat)
func RestartRecentChat(recent:NSDictionary){
    
    for userId in recent["members"] as! [String] {
        
        print("aa: \(userId)")
        print("bb: \(backendless.userService.currentUser.objectId)")
        // The current user will have a recent, the other user might not if it was deleted
        if userId != backendless.userService.currentUser.objectId{
            
            CreateRecent(userId, chatroomID: (recent["chatRoomID"] as? String)!, members: recent["members"] as! [String], withUserUsername: backendless.userService.currentUser.name, withUserUserId: backendless.userService.currentUser.objectId)
        } else {
            
            // No need to create new chat as the current user would have the chat already
        }
    }
}

//MARK: Delete Recent function
func DeleteRecentItem(recent:NSDictionary){
    
    firebase.child("Recent").child((recent["recentId"]as? String)!).removeValueWithCompletionBlock { (error, ref) in
        
        if error != nil {
    
            print("Error deleting recent item RecentSwift \(error)")
        
        } else {
            
            print("Delete successfully")
        }
    }
    
}

//MARK: Clear recent counter function
func ClearRecentCounter(chatRoomID: String) {
    
    print("ClearRecentCounter()")
    
    // Firebase query
    firebase.child("Recent").queryOrderedByChild("chatRoomID").queryEqualToValue(chatRoomID).observeEventType(.Value, withBlock: {
        (snapshot) in
        
        if snapshot.exists() {
            
            print("Snapshot Exists")
            
            for recent in (snapshot.value?.allValues)! {
                
                if recent.objectForKey("userId") as? String == backendless.userService.currentUser.objectId {
                    
                    // Clear recent counter
                    ClearRecentCounterItem(recent as! NSDictionary)
                    
                }
            }
        }
    })
}

func ClearRecentCounterItem(recent: NSDictionary) {
    
    print("ClearRecentCounterItem()")
    
    // Firebase Query
    firebase.child("Recent").child((recent["recentId"] as? String)!).updateChildValues(["counter": 0]) { (error, ref) in
        
        if error != nil {
            print("Error clearRecentCounterItem() \(error)")
        
        } else {
            // Update counter success
            print("Update Counter Successfully")
        }
    }
}

//MARK: Helper functions

private let dateFormat = "YYYYMMddHHmmss"

func dateFormatter() -> NSDateFormatter {
    
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = dateFormat
    
    return dateFormatter
}

// Universal variables

