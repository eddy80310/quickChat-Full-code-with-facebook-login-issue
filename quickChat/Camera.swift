//
//  Camera.swift
//  quickChat
//
//  Created by Edward Hung on 23/05/2016.
//  Copyright © 2016 Edward Hung. All rights reserved.
//

import Foundation
import MobileCoreServices

class Camera {
    
    var delegate:protocol<UINavigationControllerDelegate, UIImagePickerControllerDelegate>?
    
    init(delegate_: protocol<UINavigationControllerDelegate, UIImagePickerControllerDelegate>?) {
        
        delegate = delegate_
    }
    
    func PresentPhotoLibrary(target: UIViewController, canEdit:Bool) {
        
        // Check if the device have photo Library or photo album
        if !(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary)) && !( UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum)) {
            
            // Exit
            return
        }
        
        // Photo library or photo album exists
        let type = kUTTypeImage as String // Use only image. User can not choose video
        let imagePicker = UIImagePickerController()
        
        // Check if photo library is there
        if UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary) {
            
            imagePicker.sourceType = .PhotoLibrary
            
            // Check if there is any object in the photo library 
            if let availableTypes = UIImagePickerController.availableMediaTypesForSourceType(.PhotoLibrary) {
                
                if (availableTypes as NSArray).containsObject(type) {
                    
                    imagePicker.mediaTypes = [type]
                    imagePicker.allowsEditing = canEdit
                    
                }
            }
        } else if UIImagePickerController.isSourceTypeAvailable(.SavedPhotosAlbum) {
            
            // Photo library not present, check photo album
            
            imagePicker.sourceType = .SavedPhotosAlbum
            
            if let availableTypes = UIImagePickerController.availableMediaTypesForSourceType(.SavedPhotosAlbum) {
                
                if (availableTypes as NSArray).containsObject(type) {
                    
                    imagePicker.mediaTypes = [type]
                }
            }
        } else {
            
            return
        }
        
        imagePicker.allowsEditing = canEdit
        imagePicker.delegate = delegate
        target.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func PresentPhotoCamera(target: UIViewController, canEdit: Bool) {
        
        if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            return
        }
        
        let type1 = kUTTypeImage as String
        let imagePicker = UIImagePickerController()
        
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            
            if let availableTypes = UIImagePickerController.availableMediaTypesForSourceType(.Camera){
            
                if (availableTypes as NSArray).containsObject(type1) {
                
                    imagePicker.mediaTypes = [type1]
                    
                    // Set default camera to be rear camera
                    imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
                }
            }
            
            // Set default camer to be rear camera {
            if UIImagePickerController.isCameraDeviceAvailable(.Rear) {
                
                imagePicker.cameraDevice = UIImagePickerControllerCameraDevice.Rear
            
            } else if UIImagePickerController.isCameraDeviceAvailable(.Front) {
                
                imagePicker.cameraDevice = UIImagePickerControllerCameraDevice.Front
            
            } else {
                
                // Show alert that device have no camer
                print("Device have no camera")
                return
            }
            imagePicker.allowsEditing = canEdit
            imagePicker.showsCameraControls = true
            imagePicker.delegate = delegate
            target.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
}
