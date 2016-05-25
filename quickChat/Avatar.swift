//
//  Avatar.swift
//  quickChat
//
//  Created by Edward Hung on 24/05/2016.
//  Copyright © 2016 Edward Hung. All rights reserved.
//

import Foundation

// Upload avatar image to backendless
func uploadAvatar(image: UIImage, result: (imageLink: String?) -> Void) {
    
    // Once the image is uploaded, the result is called back via imageLink
    let imageData = UIImageJPEGRepresentation(image, 1.0)
    
    // Use the current date as the name of the file 
    let dateString = dateFormatter().stringFromDate(NSDate())
    let fileName = "Img/" + dateString + ".jpeg"
    
    // We didnt need to specify a different que for upload because backendless is already uploading on a different thread. 
    // So no need to create another que
    backendless.fileService.upload(fileName, content: imageData, response: { (file) in
        
        // File saved successfully 
        print("Avatar save to backendless successfully")
        result(imageLink: file.fileURL)
        
    }) { (fault: Fault!) in
            print("Error uploading avatar image \(fault)")
    }
}

// Download image from backendless and return the image to result
func getImageFromURL(url: String, result: (image:UIImage?) -> Void) {
    
    //ImageString-> NSURL-> NSData-> UIImage
    
    let URL = NSURL(string: url)
    
    // We want the download to happen NOT on main que. So we created another que here.
    // Not good to download big file on main que otherwise the application will stop happening until download finished
    let downloadQue = dispatch_queue_create("imageDownloadQue", nil)
    
    // Dispatch the code on the new que
    dispatch_async(downloadQue) { 
        
        // Set data from the URL
        let data = NSData(contentsOfURL: URL!)
        
        let image: UIImage!
        
        // If data exist from the URL
        if data != nil {
            
            // Use the NSData to create an image
            image = UIImage(data: data!)
            
            // Get back to the main que and return the image to result when the downloading is complete
            dispatch_async(dispatch_get_main_queue(), { 
                
                result(image: image)
            })
        }
    }
    
}