//
//  IncomingMessage.swift
//  quickChat
//
//  Created by Edward Hung on 22/05/2016.
//  Copyright © 2016 Edward Hung. All rights reserved.
//

import Foundation

class IncomingMessage {
    
    var collectionView: JSQMessagesCollectionView
    
    init(collectionView_: JSQMessagesCollectionView) {
    
        collectionView = collectionView_
    }
    
    func createMessage(dictionary: NSDictionary) -> JSQMessage? {
    
        var message: JSQMessage?
        
        // Check the type of message we are creating
        let type: String = (dictionary.objectForKey("type") as? String)!
        
        if type == "text" {
        
            // Create text message
            message = createTextMessage(dictionary)
        }
        
        if type == "location" {

            // Create location message
            message = createLocationMessage(dictionary)
        }
        
        if type == "picture" {
            
            // Create picture message
            message = createPictureMessage(dictionary)
        }
        
        if let mes = message {
            
            return mes
        }
        
        return nil
    }
    
    func createTextMessage(item: NSDictionary) -> JSQMessage {
        
        print("CreateTextMessage()")
        
        let name = item["senderName"] as? String
        let userId = item["senderId"] as? String
        let date = dateFormatter().dateFromString((item["date"] as? String)!)
        
        let text = item["message"] as? String
        
        return JSQMessage(senderId: userId, senderDisplayName: name, date: date, text: text)
        
    }
    
    func createLocationMessage(item: NSDictionary) -> JSQMessage {
        
        print("CreateLocationMessage()")
        let name = item["senderName"] as? String
        let userId = item["senderId"] as? String
        let date = dateFormatter().dateFromString((item["date"] as? String)!)
        
        let latitude = item["latitude"] as? Double
        let longitude = item["longitude"] as? Double
        
        let mediaItem = JSQLocationMediaItem(location: nil)
        
        // Is the message outgoing or incomming message
        mediaItem.appliesMediaViewMaskAsOutgoing = returnOutgoingStatusFromUser(userId!)
        
        let location = CLLocation(latitude: latitude!, longitude: longitude!)
        
        mediaItem.setLocation(location) { 
            // Update our collectionView
            self.collectionView.reloadData()
        }
        
        return JSQMessage(senderId: userId, senderDisplayName: name, date: date, media: mediaItem)
    }
    
    func returnOutgoingStatusFromUser(senderId: String) -> Bool {
        
        if senderId == backendless.userService.currentUser.objectId {
            // Outgoing
            return true
        
        } else {
            //Incomming
            return false
        }
    }
    
    func createPictureMessage(item: NSDictionary) -> JSQMessage {
        
        print("CreatePictureMessage()")
        
        let name = item["senderName"] as? String
        let userId = item["senderId"] as? String
        let date = dateFormatter().dateFromString((item["date"] as? String)!)
        
        let mediaItem = JSQPhotoMediaItem(image: nil)
        mediaItem.appliesMediaViewMaskAsOutgoing = returnOutgoingStatusFromUser(userId!)
        
        imageFromData(item) { (image: UIImage?) in
            
            mediaItem.image = image
            
            self.collectionView.reloadData()
        }
        
        return JSQMessage(senderId: userId, senderDisplayName: name, date: date, media: mediaItem)
        
    }
    
    func imageFromData(item:NSDictionary, result: (image:UIImage?) -> Void) {
        
        // result is a function inside the function
        
        var image: UIImage?
        
        // Convert image from string to NSdata
        let decodedData = NSData(base64EncodedString: (item["picture"] as? String)!, options: NSDataBase64DecodingOptions(rawValue: 0))
        
        image = UIImage(data: decodedData!)
        
        result(image: image)
    }
    
    
    
    
    
    
}