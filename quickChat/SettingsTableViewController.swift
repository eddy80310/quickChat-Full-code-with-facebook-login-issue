//
//  SettingsTableViewController.swift
//  quickChat
//
//  Created by Edward Hung on 23/05/2016.
//  Copyright © 2016 Edward Hung. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    // Outlet Decleration
    @IBOutlet weak var HeaderView: UIView!
    @IBOutlet weak var imageUser: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var avatarCell: UITableViewCell!
    @IBOutlet weak var termsCell: UITableViewCell!
    @IBOutlet weak var privacyCell: UITableViewCell!
    @IBOutlet weak var logOutCell: UITableViewCell!
    
    @IBOutlet weak var avatarSwitch: UISwitch!
    
    // Variable Declareation
    var avatarSwitchStatus = true
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    // Check if the application is running for the first time
    var firstLoad: Bool?
    
    
    
    // View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set header view
        self.tableView.tableHeaderView = HeaderView
        
        // Create round avatar
        imageUser.layer.cornerRadius = imageUser.frame.size.width / 2
        imageUser.layer.masksToBounds = true
        
        loadUserDefaults()
        
        //updateUI()
        
        
    }

    override func viewWillAppear(animated: Bool) {
        updateUI() //E.H Update otherwise the image only update on first run
        
        print(backendless.userService.currentUser.name)
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: IBActions
    
    @IBAction func didClickAvatarImage(sender: AnyObject) {
        
        changePhoto()
        
    }
    
    @IBAction func avatarSwitchValueChange(switchState: UISwitch) {
        
        if switchState.on {
            avatarSwitchStatus = true
            print("Avatar ON")
        }
        else {
            avatarSwitchStatus = false
            print("Avatar OFF")
        }
        
        saveUserDefaults()
    }
    
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        // First section
        if section == 0 { return 3 }
        
        // Second section
        if section == 1 { return 1 }
        

        return 0
    }

    //MARK: Table View
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // First section first cell
        if (indexPath.section == 0) && (indexPath.row == 0) { return privacyCell }
        if (indexPath.section == 0) && (indexPath.row == 1) { return termsCell }
        if (indexPath.section == 0) && (indexPath.row == 2) { return avatarCell }
        if (indexPath.section == 1) && (indexPath.row == 0) { return logOutCell }

        return UITableViewCell()
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        // Seperate section (create more space)
        if section == 0 {
            return 0
        } else {
            return 25 
        }
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        // Create headerview with empty background 
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clearColor()
        
        return headerView
    }
    
    //MARK: Tableview delegate functions
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // Check if it is the logout section
        if indexPath.section == 1 && indexPath.row == 0 {
            
            // Display warining action sheet
            showLogoutView()
        }
    }
    
    //MARK: Change photo
    func changePhoto() {
        
        let camera = Camera(delegate_: self)
        
        // Create option menu to allow user to choose image
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        // When choose to take photo is pressed
        let takePhoto = UIAlertAction(title: "Take Photo", style: .Default) { (alert: UIAlertAction!) in
            camera.PresentPhotoCamera(self, canEdit: true)
        }
        
        // Choose from photo library 
        let sharePhoto = UIAlertAction(title: "Photo Library", style: .Default) { (alert: UIAlertAction) in
            camera.PresentPhotoLibrary(self, canEdit: true)
        }
        
        // Cancel Action 
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (alert: UIAlertAction!) in
            
            print("Cancel")
        }
        
        optionMenu.addAction(takePhoto)
        optionMenu.addAction(sharePhoto)
        optionMenu.addAction(cancelAction)
        
        // Present option menu 
        self.presentViewController(optionMenu, animated: true, completion: nil)
    }
    
    //MARK: UIImagePickerControllerDelegate
    
    // Everytime an user took a photo or choose an image
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        let image = info[UIImagePickerControllerEditedImage] as! UIImage
        
        // Upload image to backendless
        
        uploadAvatar(image) { (imageLink) in
            
            // Save image to backendless as the user's avatar
            let properties = ["Avatar" : imageLink!]
            
            // Set the property to current user
            backendless.userService.currentUser.updateProperties(properties)
            
            // Upload image to backendless
            backendless.userService.update(currentUser, response: { (updatedUser: BackendlessUser!) in
                
                print("Updated current user \(updatedUser)")
                
                }, error: { (fault: Fault!) in
                    print("Error saving Avatar to backendless: \(fault)")
            })
        }
        
        // Dismiss view controller
        picker.dismissViewControllerAnimated(true, completion: nil)
        
        //updateUI() //E.H add. This doesnt update the image properly because the link doesnt not get generated fast enough
    }
    
    //MARK: Update UI
    
    func updateUI () {
        
        // Set avatar image and name text label
        userNameLabel.text = backendless.userService.currentUser.name
        avatarSwitch.setOn(avatarSwitchStatus, animated: false)
        
        // Check if we have image link in backenedless and save to avatar image
        if let imageLink = backendless.userService.currentUser.getProperty("Avatar") {
            getImageFromURL(imageLink as! String, result: { (image) in
                self.imageUser.image = image
            })
        }
    }
    
    //MARK: Helper functions
    func showLogoutView(){
        
        // Create alert controller
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        let logoutAction = UIAlertAction(title: "Log Out", style: .Destructive) { (alert: UIAlertAction!) in
            
            // logout user
            self.logOut()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (alert: UIAlertAction!) in
            print("Cancel")
        }
        
        optionMenu.addAction(logoutAction)
        optionMenu.addAction(cancelAction)
        
        self.presentViewController(optionMenu, animated: true, completion: nil)
    }
    
    // Logout the user
    func logOut(){
        
        backendless.userService.logout(
            { ( user : AnyObject!) -> () in
                print("User logged out.")
                
                // Show login view
                let loginView = self.storyboard?.instantiateViewControllerWithIdentifier("LoginView")
                self.presentViewController(loginView!, animated: true, completion: nil)
            },
            error: { ( fault : Fault!) -> () in
                print("Server reported an error: \(fault)")
        })
        
        
        
    }
    
    //MARK: UserDefaults
    
    func saveUserDefaults() {
        
        userDefaults.setBool(avatarSwitchStatus, forKey: kAVATARSTATE)
        userDefaults.synchronize()
        
    }
    
    func loadUserDefaults() {
     
        // Check if it is the first time the application is loading 
        firstLoad = userDefaults.boolForKey(kFIRSTRUN)
        
        if !firstLoad! {
            
            // User default empty, i.e. the first time application is running
            userDefaults.setBool(true, forKey: kFIRSTRUN)
            userDefaults.setBool(avatarSwitchStatus, forKey: kAVATARSTATE)
            userDefaults.synchronize()
        }
        
        avatarSwitchStatus = userDefaults.boolForKey(kAVATARSTATE)
    }
    
    
    
    
    
    
    

}
