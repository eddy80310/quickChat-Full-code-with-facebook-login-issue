//
//  RegisterUser.swift
//  quickChat
//
//  Created by Edward Hung on 25/05/2016.
//  Copyright © 2016 Edward Hung. All rights reserved.
//

import Foundation

// Update backendlessuser with facebook avatar
func updateBackendlessUser(facebookId: String, avatarUrl: String) {
    
    print("facebookId \(facebookId)")
    print("avatarUrl \(avatarUrl)")
    
    
    // Query for backendless
    let whereClause = "facebookId = '\(facebookId)'"
    let dataQuery = BackendlessDataQuery()
    dataQuery.whereClause = whereClause
    let dataStore = backendless.persistenceService.of(BackendlessUser.ofClass())
    
    dataStore.find(dataQuery, response: { (users: BackendlessCollection!) in
        
        print("users = \(users)")
        
        let user =  users.data.first as! BackendlessUser
        
        print(user)
        
        let properties = ["Avatar" : avatarUrl]
        
        user.updateProperties(properties)
        backendless.userService.update(user)
        
    }) { (fault: Fault!) in
        
        print("Server error updateBackendlessUser() \(fault)")
        
    }
}