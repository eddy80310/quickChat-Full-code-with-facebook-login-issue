//
//  ChatViewController.swift
//  quickChat
//
//  Created by Edward Hung on 20/05/2016.
//  Copyright © 2016 Edward Hung. All rights reserved.
//

import UIKit

class ChatViewController: JSQMessagesViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    // UINavifationControllerDelegate is required to display camera
    
    // Firebase setup
    // let ref = Firebase(url:"https://quickchataplication.firebaseio.com/Message") This is old code
    // let firebase = FIRDatabase.database().reference()
    let ref = firebase.child("Messsage")

    
    // Variable Decleration
    var messages: [JSQMessage] = []
    var objects: [NSDictionary] = []
    var loaded: [NSDictionary] = []
    var witUser: BackendlessUser?
    var recent: NSDictionary?
    var chatRoomId: String!
    var initialLoadComplete: Bool = true
    
    var avatarImagesDictionary: NSMutableDictionary?
    var avatarDictionary: NSMutableDictionary?
    
    var showAvatars: Bool = false
    
    var firstLoad: Bool?
    
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    // Set chat bubble colour
    let outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleBlueColor())
    let incommingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
    
    // As soon as we are leaving the view
    override func viewWillDisappear(animated: Bool) {
        
        // Update Recent
        ClearRecentCounter(chatRoomId)
        ref.removeAllObservers() // Observer is the childChange, childRemoved... etc under observeEventType of FB. We no longer want to listen to the change when we leave the view
    }
    
    // viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        self.senderId = backendless.userService.currentUser.objectId
        self.senderDisplayName = backendless.userService.currentUser.name
        
        // Initially set avatar to be nil until program works correctly
        collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero
        collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero
        
        // Check if we have withUser
        if witUser?.objectId == nil {
            
            getWithUserFromRecent(recent!, result: { (withUser) in
                self.witUser = withUser
                self.title = withUser.name
                self.getAvatars() // Must check if we have withUser otherwise we will have error if withUser does not exist
            })
        
        } else {
            self.title = witUser?.name
            self.getAvatars()
        }
        
        // Load firebase messages
        loadmessages()
        
        // Set toolbar
        self.inputToolbar.contentView.textView.placeHolder = "New Message"
        
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        
        // Check user default
        loadUserDefaults()  
        
    }
    
    //MARK: JSQMessages dataSource functions
    
    // Required function: Apple default collection view.
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        // Set color of text
        
        // Retreive cell instance
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        
        // Get message and find out sender
        let data = messages[indexPath.row]
        
        print("DEBUG///OPEN//")
        print(data)
        print("DEBUG///Close//")
        
        //if let media = data.media {
           
            //E.H Add otherwise location will crash
        //    return cell
        //}
        
        // Outgoing message text is white
        
        if data.senderId == backendless.userService.currentUser.objectId {
            cell.textView?.textColor = UIColor.whiteColor()
        
        // Incomming message text is black
        } else {
            cell.textView?.textColor = UIColor.blackColor()
        }
        
        return cell
        
    }
    
    // Required function: JSQ default collection view.
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        
        // Return what the collectionViewCell is going to display
        
        let data = messages[indexPath.row]
        
        return data
    }
    
    // Required function: Apple default collection view.
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return messages.count
    }
    
    // Required function: JSQ default collection view.
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        
        let data = messages[indexPath.row]
        
        // Check who is the sender
        if data.senderId == backendless.userService.currentUser.objectId{
            
            // Outgoing message
            return outgoingBubble
            
        } else {
            
            // Incomming message
            return incommingBubble
        }
    }
    
    // AttributedTextForCellTopLabel - Timestamp every 3 message text
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        
        // Pass time stamp for every 3 message
        if indexPath.item % 3 == 0 {
            
            let message = messages[indexPath.item]
            
            return JSQMessagesTimestampFormatter.sharedFormatter().attributedTimestampForDate(message.date)
        }
        
        return nil
    }
    
    // heightForCellTopLabelAtIndexPath - Timestamp every 3 message height
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        
        // Ever 3 messages
        if indexPath.item % 3 == 0 {
            
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        
        return 0.0
    }
    
    // AttributedTextForCellBottomLabel - Delivered Status text
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        
        // Show on last message
        let message = objects[indexPath.row]
        let status = message["status"] as! String
        
        // Check if this cell is the last message in the array and is outgoing message
        if outgoing(objects[indexPath.row]) {
            
            return NSAttributedString(string: status)
        
        } else {
            
            return NSAttributedString(string: "")
        }
    }
    
    // heightForCellBottomLabelAtIndexPath - Delivered Status text
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        
        if indexPath.row == (messages.count - 1) {
            
            return kJSQMessagesCollectionViewCellLabelHeightDefault
            
        } else {
            
            return 0.0
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        
        let message = messages[indexPath.row]
        let avatar = avatarDictionary!.objectForKey(message.senderId) as! JSQMessageAvatarImageDataSource
        
        return avatar
    }
    
    //MARK: JSQMessages Delegate function
    
    // Send button press
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        
        // Check if there is any text in the text field
        if text != "" {
            
            // Send message
            sendMessage(text, date: date, picture: nil, location: nil)
            
        } else {
            // Empty text field do nothing
        }
    }
    
    // Attachement button press
    override func didPressAccessoryButton(sender: UIButton!) {
        
        print("Accessory button pressed")
        
        let camera = Camera(delegate_: self)
        
        // Create alert controller
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let takePhoto = UIAlertAction(title: "Take Photo", style: .Default) { (alert: UIAlertAction!) in
            // When user press the take photo button
            print("Take Photo")
            camera.PresentPhotoCamera(self, canEdit: true)
        }
        
        let sharePhoto = UIAlertAction(title: "Photo Library", style: .Default) { (alert: UIAlertAction!) in
            print("Photo Library")
            camera.PresentPhotoLibrary(self, canEdit: true)
        }
        
        let shareLocation = UIAlertAction(title: "Share Location", style: .Default) { (alert: UIAlertAction!) in
            print("Share Location")
            
            // Need to check if we have location access otherwise we will not have CLLocation manager and the application will crash
            if self.haveAccessToLocation() {
                self.sendMessage(nil, date: NSDate(), picture: nil, location: "location")
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (alert: UIAlertAction!) in
            print("Cancel")
        }
        
        // Set alert action to alert controller 
        optionMenu.addAction(takePhoto)
        optionMenu.addAction(sharePhoto)
        optionMenu.addAction(shareLocation)
        optionMenu.addAction(cancelAction)
        
        // Present alert controller 
        self.presentViewController(optionMenu, animated: true, completion: nil)
    
    }
    
    //MARK: Send message. Can be message or image or location
    func sendMessage(text:String?, date:NSDate, picture:UIImage?, location: String?){
    
        // Check what type of message is sent
        
        var outgoingMessage = OutgoingMessage?()
        
        // Check for text message
        if let text = text {
            
            // Send text message
            outgoingMessage = OutgoingMessage(message: text, senderId: backendless.userService.currentUser.objectId, senderName: backendless.userService.currentUser.name, date: date, status: "Delivered", type: "text")
            
        }
        
        // Check for picture
        if let pic = picture {
            
            // Send picture message
            let imageData = UIImageJPEGRepresentation(pic, 1.0)
            outgoingMessage = OutgoingMessage(message: "Picture", pictureData: imageData!, senderId: backendless.userService.currentUser.objectId, senderName: backendless.userService.currentUser.name, date: date, status: "Delivered", type: "picture")
            
        }
        
        // Check for location
        if let _ = location {
            
            // Send location message
            let lat: NSNumber = NSNumber(double:(appDelegate.coordinate?.latitude)!)
            let lng: NSNumber = NSNumber(double:(appDelegate.coordinate?.longitude)!)
            

            outgoingMessage = OutgoingMessage(message: "Location", latitude: lat, longitude: lng, senderId: senderId, senderName: backendless.userService.currentUser!.name, date: date, status: "Delivered", type: "location")
        }
        
        // PLay message sent sound (JSQMessage)
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        self.finishSendingMessage() // This will sum up our JSQ functionality that we will need to do everytime after message
        
        // Save to firebase
        outgoingMessage!.sendMessage(chatRoomId, item: outgoingMessage!.messageDictionary)
        
        // Reload collection view
    }
    
    //MARK: Load Message from firebase
    func loadmessages() {
        
        // Query for firebase when item is added
        ref.child(chatRoomId).observeEventType(.ChildAdded, withBlock: {
            (snapshot) in
            
            print("Debug 3")
            
            if snapshot.exists() {
                
                print("Snapshot Exists in loadmessages()")
                
                let item = (snapshot.value as? NSDictionary)!
                
                    // Check if initial load completed and we are receiving new message
                if self.initialLoadComplete {
                    
                    print("Initial Load complete2")
                    
                    let incoming = self.insertMessage(item)
                    
                    if incoming {
                        
                        print("Play incomming sound loadedMessage()")
                        
                        // Play message received sound
                        JSQSystemSoundPlayer.jsq_playMessageReceivedSound()
                    }
                    
                    self.finishSendingMessageAnimated(true)
                    
                } else {
                    
                    // Add each dictionary to loaded array
                    print("Append to loaded")
                    
                    self.loaded.append(item)
                    
                }
            }
        })
        
        
        ref.child("chatRoomId").observeEventType(.ChildChanged, withBlock: {
            (snapshot) in
            
            // Update message. For future improvement
        })
        
        ref.child("chatRoomId").observeEventType(.ChildRemoved, withBlock: {
            (snapshot) in
            
            // Delete message For future improvement
        })
        
        print("loadmessages()")
        
        // Query firebase.
        ref.child(chatRoomId).observeSingleEventOfType(.Value, withBlock: {
            (snapshot) in
            
            // Get dictionary from FB
            
            // Create JSQ messages
            self.insertMessages()
            
            self.finishReceivingMessageAnimated(true) // Scroll down to latest message and play sound
            
            // Set inital load complete as it is an observeSingleEvenOftype
            print("initial load complate1")
            self.initialLoadComplete = true
            
        })
    }
    
    
    func insertMessages(){
    
        print("insertMessages()")
        print("loaded.count = \(loaded.count)")
        
        for item in loaded {
            
            print("item in loaded: =  \(item)")
            // Create message
            insertMessage(item)
        }
    }
    
    func insertMessage(item: NSDictionary) -> Bool {
        
        print("insertMessage()")
        print("item print \(item)")
        
        let incomingMessage = IncomingMessage(collectionView_: self.collectionView!)
        
        let message = incomingMessage.createMessage(item)
        
        // Add item to object array 
        objects.append(item)
        
        // Add newly created message to the message area
        messages.append(message!)
        
        // Check whether the message is incoming or outgoing
        return incoming(item)
    }
    
    func incoming(item: NSDictionary) -> Bool {
        
        // Check if this is incoming or outgoing message by checking with senderId
        if backendless.userService.currentUser.objectId == item["senderId"] as! String {
            
            // Outgoing message
            return false
            
        } else {
            
            // Incomming message
            return true
        }
    }
    
    func outgoing(item:NSDictionary) -> Bool {
        
        // Check if this is incoming or outgoing message by checking with senderId
        if backendless.userService.currentUser.objectId == item["senderId"] as! String {
            
            // Outgoing message
            return true
            
        } else {
            
            // Incomming message
            return false
        }
    }


    /*NOTE: Firebase functions
     observeSingleEventOfType-> run only once .Vale = get back everything
     observeEventType .ChileAdded = Evertime there was a new chat (new object that we added)
     observeEventType . ChildChanged = Message edited
     observeEventType . ChildRemoved = Message deleted
     */
    
    
    //MARK: Helper Function 
    
    // Check if we have location access
    func haveAccessToLocation()-> Bool {
        
        if let _ = appDelegate.coordinate?.latitude {
            return true
        } else {
            return false
        }
    }
    
    func getAvatars() {
        
        if showAvatars {
            
            // Set Avatar size
            collectionView?.collectionViewLayout.incomingAvatarViewSize = CGSizeMake(30, 30)
            collectionView?.collectionViewLayout.outgoingAvatarViewSize = CGSizeMake(30, 30)
            
            // Download Avatar
            avatarImageFromBackendlessUser(backendless.userService.currentUser)
            avatarImageFromBackendlessUser(self.witUser!)
            
            // Create avatar
            createAvatars(avatarImagesDictionary)
        }
    }
    
    // Receive withUser from recent
    func getWithUserFromRecent(recent: NSDictionary, result: (withUser: BackendlessUser) -> Void) {
        
        
        let withUserId = recent["withUserUserId"] as? String
        
        print(withUserId)
        
        let whereClause = "objectId = '\(withUserId!)'"
        let dataQuery = BackendlessDataQuery()
        dataQuery.whereClause = whereClause
        
        let dataStore = backendless.persistenceService.of(BackendlessUser.ofClass())
        
        dataStore.find(dataQuery, response: { (users: BackendlessCollection!) in
            
            let withUser = users.data.first as! BackendlessUser
            result(withUser: withUser)
            
        }) { (fault: Fault!) in
            print("Server reported an error rgetWithUserFromRecent() \(fault)")

        }
    }
    
    // Create JSQMessage avatar
    func createAvatars(avatars: NSMutableDictionary?) {
        
        // Initiate avatar with the placeholder
        var currentUserAvatar = JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(named: "avatarPlaceholder"), diameter: 70)
        var withUserAvatar = JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(named: "avatarPlaceholder"), diameter: 70)
        
        // Check if we have the avatar dictionary for current user
        if let avat = avatars {
            
            if let currentUserAvatarImage = avat.objectForKey(backendless.userService.currentUser.objectId) {
            
                currentUserAvatar = JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(data: currentUserAvatarImage as! NSData), diameter: 70)
                
                self.collectionView?.reloadData()
            }
        }
        
        // Check if we have the avatar dictionary for withUser
        if let avat = avatars {
            
            if let withUsertUserAvatarImage = avat.objectForKey(self.witUser!.objectId) {
                
                withUserAvatar = JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(data: withUsertUserAvatarImage as! NSData), diameter: 70)
                
                self.collectionView?.reloadData()
            }
        }
        
        avatarDictionary = [backendless.userService.currentUser.objectId: currentUserAvatar, self.witUser!.objectId: withUserAvatar]
    }
    
    // Get avatar image from backendless user
    func avatarImageFromBackendlessUser(user: BackendlessUser) {
        
        // imageURLString ->UIimage -> JPEG
    
        if let imageLink = user.getProperty("Avatar") {
                
            print("user: \(user)")
            print("Avatar imageLink = \(user.getProperty("Avatar"))")
            
            // Download avatar image from URL
            getImageFromURL(imageLink as! String, result: { (image) in
                
                let imageData = UIImageJPEGRepresentation(image!, 1.0)
                
                // If there is an image already, delete it and replace with new one
                if self.avatarImagesDictionary != nil {
                    
                    self.avatarImagesDictionary!.removeObjectForKey(user.objectId)
                    self.avatarImagesDictionary!.setObject(imageData!, forKey: user.objectId!)
                
                } else {
                    
                    self.avatarImagesDictionary = [user.objectId!: imageData!]
                }
                
                self.createAvatars(self.avatarImagesDictionary)
            })
        }
    }
    
    
    //MARK: JSQDelegate functions
    
    // This funciton will run whenever the user tapps on the mesage bubble
    override func collectionView(collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAtIndexPath indexPath: NSIndexPath!) {
        
        // Tap to view image in the message
        let object = objects[indexPath.row]
        
        if object["type"] as! String == "picture" {
            
            let message = messages[indexPath.row]
            
            // Create JSQ photo media item 
            let mediaItem = message.media as! JSQPhotoMediaItem
            let photos = IDMPhoto.photosWithImages([mediaItem.image])
            let browser = IDMPhotoBrowser(photos: photos)
            
            self.presentViewController(browser, animated: true, completion: nil)
        }
        
        // Check user is tapping on location message. Perform segue
        if object["type"] as! String == "location" {
            
            performSegueWithIdentifier("chatToMapSeg", sender: indexPath)

        }
    }
    
    //MARK: UIImagePickerController functions
    
    // This code will run once the user choose a  photo or takes a photo
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        let picture = info[UIImagePickerControllerEditedImage] as! UIImage
        
        self.sendMessage(nil, date: NSDate(), picture: picture, location: nil)
        
        // Dismiss picker view
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        // Check which segue is getting called
        if segue.identifier == "chatToMapSeg" {
            
            let indexPath = sender as! NSIndexPath
            let message = messages[indexPath.row]
            
            let mediaItem = message.media as! JSQLocationMediaItem
            
            let mapView = segue.destinationViewController as! MapViewController
            mapView.location = mediaItem.location
        }
    }
    
    //MARK: UserDefault functions
    func loadUserDefaults() {
        
        // Check if it is the first time the application is loading
        firstLoad = userDefaults.boolForKey(kFIRSTRUN)
        
        if !firstLoad! {
            
            // User default empty, i.e. the first time application is running
            userDefaults.setBool(true, forKey: kFIRSTRUN)
            userDefaults.setBool(showAvatars, forKey: kAVATARSTATE)
            userDefaults.synchronize()
        }
        
        showAvatars = userDefaults.boolForKey(kAVATARSTATE)
    }
    
    
    
    
    
    
    
    
}
