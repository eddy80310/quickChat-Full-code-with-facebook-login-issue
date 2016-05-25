//
//  RecentTableViewCell.swift
//  quickChat
//
//  Created by Edward Hung on 19/05/2016.
//  Copyright © 2016 Edward Hung. All rights reserved.
//

import UIKit

class RecentTableViewCell: UITableViewCell {

    // Outlet Decleration
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var counterLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    
    // Global Variable
    let backendless = Backendless.sharedInstance()
    
    // awakeFromNib (Default Function)
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //
    func bindData(recent:NSDictionary){
        
        // Set avatarImageView to circle and set default image
        avatarImageView.layer.cornerRadius = avatarImageView.frame.size.width/2
        avatarImageView.layer.masksToBounds = true
        self.avatarImageView.image = UIImage(named: "avatarPlaceholder")
        
        let withUserId = (recent.objectForKey("withUserUserId") as? String)!
        
        // Get the backendless user and download avatar
        let whereClause = "objectId = '\(withUserId)'"
        let dataQuery = BackendlessDataQuery()
        dataQuery.whereClause = whereClause
        
        let dataStore = backendless.persistenceService.of(BackendlessUser.ofClass())
        dataStore.find(dataQuery, response: { (users: BackendlessCollection!) in
        
            // There will be only one result found so look for the first one as there is only one user
            let withUser = users.data.first as! BackendlessUser
            
            // Use withUser to get our avatar
            
        }) { (fault: Fault!) in
            
            print("error, couldnt get user avatar: \(fault)")
        }
        
        nameLabel.text = recent["withUserUsername"] as? String // This is the same as recent.objectForKey("withUserUsername")
        lastMessageLabel.text = recent["lastMessage"] as? String
        counterLabel.text = ""
        
        // Display counterLabel if it is not 0 (How many new messages)
        if (recent["counter"] as? Int)! != 0 {
            counterLabel.text = "\(recent["counter"]!) New)"
        }
        
        // Receive the date(string) from the database, convert to string to date and get the seconds since that date. Then set label
        let date = dateFormatter().dateFromString((recent["date"] as? String)!)
        let seconds = NSDate().timeIntervalSinceDate(date!)
        dateLabel.text = TimeElapsed(seconds)
    }
    
    // Convert elapsed time into string
    func TimeElapsed(seconds:NSTimeInterval) -> String{
        
        let elapsed: String?
        
        // Less than 1 second
        if seconds < 60 {
            elapsed = "Just Now"
        
        // Less than 1 hour
        } else if (seconds < 60 * 60) {
            let minutes = Int(seconds / 60)
            var minText = "min"
            if minutes > 1 {
                minText = "mins"
            }
            elapsed = "\(minutes) \(minText)"
        
        // Less than 1 day
        } else if (seconds < 24 * 60 * 60) {
            let hours = Int(seconds / (60 * 60))
            var hourText = "hour"
            if hours > 1 {
                hourText = "hours"
            }
            elapsed = "\(hours) \(hourText)"
        
        // More than 24 hours
        } else {
            let days = Int(seconds / 24 * 60 * 60)
            var dayText = "day"
            if days > 1 {
                dayText = "days"
            }
            elapsed = "\(days) \(dayText)"
        }
        return elapsed!
    }
}
