//
//  RegisterViewController.swift
//  quickChat
//
//  Created by Edward Hung on 19/05/2016.
//  Copyright © 2016 Edward Hung. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    // Outlet and variable decleration
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var newUser:BackendlessUser?
    var backendless = Backendless.sharedInstance()
    var email:String? = "DefaultEmailEntry"
    var username:String? = "DefaultUserNameEntry"
    var password:String? = "DefaultPasswordEntry"
    var avatarImage:UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()

        newUser = BackendlessUser()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


    //MARK:  IBActions
    
    // Register Button Click
    @IBAction func registerButtonPressed(sender: UIButton) {
        
        // Check all entry are filled
        if emailTextField.text != "" && usernameTextField.text != "" && passwordTextField.text != "" {
            
            ProgressHUD.show("Registering...")
            email = emailTextField.text
            username = usernameTextField.text
            password = passwordTextField.text
            
            register(self.email!, username: self.username!, password: self.password!, avatarImage: self.avatarImage)
        
        } else {
            
            // Warning to user that all fields are mandatory. Create alert using 3rd party alert
            ProgressHUD.showError("All fields are required")
        }
    }
    
    //MARK: UIImagePickerController Delegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        // Set avatar image
        self.avatarImage = (info[UIImagePickerControllerEditedImage] as! UIImage)
        
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // Upload by using camera
    @IBAction func uploadPhotoButtonPressed(sender: AnyObject) {
        
        // Create action menu 
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        let camera = Camera(delegate_: self)
        
        let takePhoto = UIAlertAction(title: "Take Photo", style: .Default) { (alert: UIAlertAction!) in
            
            camera.PresentPhotoCamera(self, canEdit: true)
        }
        
        let sharePhoto = UIAlertAction(title: "Photo Library", style: .Default) { (alert: UIAlertAction!) in
            camera.PresentPhotoLibrary(self, canEdit: true)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (alert) in
            
            print("Cancelled")
        }
        
        optionMenu.addAction(takePhoto)
        optionMenu.addAction(sharePhoto)
        optionMenu.addAction(cancelAction)
        
        self.presentViewController(optionMenu, animated: true, completion: nil)
    }
    
    
    //MARK: BAckendless user registeration
    
    // Register new user
    func register(email: String, username: String, password: String, avatarImage: UIImage?) {
    
        // Avartar doesnt need to be passed. Check
        if avatarImage == nil {
            
            // No avartar image passed
            newUser!.setProperty("Avatar", object: "")
            
        } else {
            
            uploadAvatar(avatarImage!, result: { (imageLink) in
                
                print(self.backendless.userService.currentUser.name)
                
                let properties = ["Avatar": imageLink!]
                
                print(self.backendless.userService.currentUser.name)
                print("Properties: \(properties)")
                
                self.backendless.userService.currentUser!.updateProperties(properties)
                self.backendless.userService.update(self.backendless.userService.currentUser, response: { (updatedUser: BackendlessUser!) in
                    
                    print("Updated currentuser avatar register()")
                    
                    }, error: { (fault: Fault!) in
                        print("error. couldnt set avatar image register(): \(fault)")
                })
                
            })
        }
        
        newUser!.email = email
        newUser!.name = username
        newUser!.password = password
        
        // Attempt to register user
        backendless.userService.registering(newUser!, response: { (registeredUser: BackendlessUser!) in
            
            // User registered successfully, login
            print("Register Successfully")
            self.loginUser(email, username: username, password: password)
            
            // Remove textfile entry
            self.usernameTextField.text = ""
            self.passwordTextField.text = ""
            self.emailTextField.text = ""
            
            // Dismiss progressHUD Alert
            ProgressHUD.dismiss()
            
        }) { (fault: Fault!) in
            
            // Error when registering
            print("Error in registering \(fault)")
        }
    }
    
    // loginUser
    func loginUser(email:String, username:String, password:String) {
        
        backendless.userService.login(email, password: password, response: { (user: BackendlessUser!) in
            
            // Login successfully, Segue to recents VC and ensure the REcents is alway s the default view (not the settings)

            print("Login Successfully")
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ChatVC") as! UITabBarController
            vc.selectedIndex = 0
            self.presentViewController(vc, animated: true, completion: nil)
            
            }) { (fault) in
                
                // Login failed
                print("Error Login: \(fault)")
        }
    }
}
