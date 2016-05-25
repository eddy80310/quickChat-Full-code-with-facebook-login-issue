//
//  OutgoingMessage.swift
//  quickChat
//
//  Created by Edward Hung on 21/05/2016.
//  Copyright © 2016 Edward Hung. All rights reserved.
//

import Foundation
import Firebase

// Outgoing message class
class OutgoingMessage {
    
    //private let firbase = FIRDatabase.database().reference().child("Recent") // This is different to the instructor
    //let ref = firebase.child("Message")
    
    // Create a dictionary of messages
    let messageDictionary: NSMutableDictionary // Data in NSMutableDictionary can be changed later on. The NSDictionary can not
    
    // Message initializer - create and set dictionary
    init(message:String, senderId:String, senderName:String, date:NSDate, status: String, type: String){
        
        messageDictionary = NSMutableDictionary(objects: [message, senderId, senderName, dateFormatter().stringFromDate(date), status, type], forKeys: ["message", "senderId", "senderName", "date", "status", "type"]) // NSDate needs to ne a string to be able to save in the dictionary
    }
    
    // Location initializer
    init(message: String, latitude: NSNumber, longitude:NSNumber, senderId: String, senderName: String, date: NSDate, status: String, type: String) {
        
        messageDictionary = NSMutableDictionary(objects: [message, latitude, longitude, senderId, senderName, dateFormatter().stringFromDate(date), status, type], forKeys: ["message", "latitude", "longitude", "senderId", "senderName", "date", "status", "type"])
    }
    
    // Picture initializer - create and set dictionary
    init(message:String, pictureData: NSData, senderId: String, senderName: String, date:NSDate, status: String, type: String){
    
        // Convert picture:NSData to string so that it can be stored in firebase. (FB doesnt take NSData)
        let pic = pictureData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
        
        messageDictionary = NSMutableDictionary(objects: [message, pic, senderId, senderName, dateFormatter().stringFromDate(date), status, type], forKeys: ["message", "picture", "senderId", "senderName", "date", "status", "type"]) // Can not put UIImage in the dictionary
    }
    
    // SendMessage Function
    func  sendMessage(chatRoomID:String, item: NSMutableDictionary){
    
        // Generate random reference for each message
        let reference = firebase.child("Messsage").child(chatRoomID).childByAutoId()
        
        item["messageId"] = reference.key // The standar NSdicntionry will not allow this line as it is not mutable
        
        // Save to firebase
        reference.setValue(item){(error, ref) -> Void in
        
            if error != nil {
                print("Error, couldnt send message OutgoingMesge.Swift \(error)")
            
            } else {
            
                // Save successfully to FB
                print("Save successfully OutgoingMessage")
            }
            
            // Update recent here
            UpdateRecents(chatRoomID, lastMessage: (item["message"] as? String)!)
            
            // Send push notification
            
            
        }
    }
    
    
    
    
    
    
    
    
    
    
}