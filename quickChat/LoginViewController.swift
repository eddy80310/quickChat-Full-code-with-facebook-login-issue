//
//  LoginViewController.swift
//  quickChat
//
//  Created by Edward Hung on 19/05/2016.
//  Copyright © 2016 Edward Hung. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    // Outlet and Variable Decleration
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    let backendless = Backendless.sharedInstance()
    var email: String?
    var password: String?
    
    // viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - IBAction
    
    // Login button
    @IBAction func loginBarButtonItemPressed(sender: UIBarButtonItem) {
        
        // Check all fields are filled
        if emailTextField.text != "" && passwordTextField.text != "" {
            
            self.email = emailTextField.text
            self.password = passwordTextField.text
            
            // Login user
            loginUser(email!, password: password!)
            
        } else {
            
            // Warning to user that all fields are mandatory. Create alert using 3rd party alert
            ProgressHUD.showError("All fields are required")
        }
    }

    // MARK: Functions
    
    // Login function
    func loginUser(email:String, password:String) {
        
        self.backendless.userService.login(email, password: password, response: { (user: BackendlessUser!) in
            
            // Loging successfully
            print("Login Successfully as \(user.name)")
            
            // Set textfiled to empty string
            self.emailTextField.text = ""
            self.passwordTextField.text = ""
            
            // Segue to recents VC and ensure the REcents is alway s the default view (not the settings)
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ChatVC") as! UITabBarController
            vc.selectedIndex = 0
            self.presentViewController(vc, animated: true, completion: nil)
            
        }) { (fault: Fault!) in
            
            // Login failed
            print("Error login user: \(fault)")
        }
    }

}
