//
//  ChatViewController.swift
//  Chat
//
//  Created by Joseph on 16/11/7.
//  Copyright © 2016年 Joseph. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import MobileCoreServices
import AVKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

class ChatViewController: JSQMessagesViewController {

    var messages = [JSQMessage]()
    var messageRef = FIRDatabase.database().reference().child("messages")
    var avatarDict = [String: JSQMessagesAvatarImage]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //for username user photo display
        if let currentUser = FIRAuth.auth()?.currentUser{
        
            self.senderDisplayName = "Anonymous"
            self.senderId = currentUser.uid
            self.senderDisplayName = "0"
        
        }
        
       // let currentUser = FIRAuth.auth()?.currentUser
        //print(currentUser?.uid)
        
//        self.senderId = currentUser!.uid
//        self.senderDisplayName = "0"
        // Do any additional setup after loading the view.
        
//        let rootRef = FIRDatabase.database().reference()
  //      let messageRef = rootRef.child("messages")
        
        
        
  //      print(rootRef)
    //    print(messageRef)
//        
////        messageRef.childByAutoId().setValue("first_message")
////        messageRef.childByAutoId().setValue("secondMessage")
//        
//        messageRef.observeEventType(FIRDataEventType.ChildAdded){(snapShot: FIRDataSnapshot)in
//       // print(snapShot.value)
//            if let dict = snapShot.value as? NSDictionary{
//            print(dict)}
//        }
        
        
        //user info retrive
//        observeUser()
        
        //message retrive
        observeMessages()
        
    }
    
    func observeUser(id: String){
    
        FIRDatabase.database().reference().child("users").child(id).observeEventType(.Value, withBlock: {snapShot in
        //print(snapShot.value)
            if let dict = snapShot.value as? [String: AnyObject]
            {
            
                let avataUrl = dict["profileUrl"] as! String
                self.setupAvatar(avataUrl, messageId: id)
                
            }
        })
        
    }
    
    func setupAvatar(url: String, messageId: String)
    {
        if url != ""
        {
            let fileUrl = NSURL(string: url)
            let data = NSData(contentsOfURL: fileUrl!)
            let image = UIImage(data: data!)
            let userImg = JSQMessagesAvatarImageFactory.avatarImageWithImage(image, diameter: 30)
            avatarDict[messageId] = userImg
        }
        else
        {
            avatarDict[messageId] = JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(named: "profileImage"), diameter:30 )

        }
        collectionView?.reloadData()
    }
    
    func observeMessages(){
        messageRef.observeEventType(.ChildAdded, withBlock: {snapShot in
            if let dict = snapShot.value as? [String: AnyObject]{
                let mediaType = dict["MediaType"] as! String
                let senderId = dict["senderId"] as! String
             //   let senderId = String(senderIdNumber)
                print(dict)
                print(senderId)
                let senderName = dict["senderName"] as! String
               // let senderName = String(senderNameNumber)
                print(senderName)
                
                self.observeUser(senderId)
                
                
                if mediaType == "TEXT" {
                    let text = dict["text"]as! String

                    self.messages.append(JSQMessage(senderId: senderId, displayName: senderName, text: text))

                }else if mediaType == "PHOTO" {
                    let fileUrl = dict["fileUrl"] as! String
                    let data = NSData(contentsOfURL: NSURL(string: fileUrl)!)
                    let picture = UIImage(data: data!)
                    let photo = JSQPhotoMediaItem(image: picture)
                    self.messages.append(JSQMessage(senderId: senderId, displayName: senderName, media: photo))
                    
                    if self.senderId == senderId {
                        photo.appliesMediaViewMaskAsOutgoing = true
                    }
                    else {
                        photo.appliesMediaViewMaskAsOutgoing = false
                    }
                    
                }else if mediaType == "VIDEO" {
                    let fileUrl = dict["fileUrl"] as! String
                    let video = NSURL(string: fileUrl)
                    let movie = JSQVideoMediaItem(fileURL: video, isReadyToPlay: true)
                    
                    self.messages.append(JSQMessage(senderId: senderId, displayName: senderName, media: movie))
                    
                    if self.senderId == senderId {
                        movie.appliesMediaViewMaskAsOutgoing = true
                    }
                    else {
                        movie.appliesMediaViewMaskAsOutgoing = false
                    }
                    

                    
                }
                
                
            
                
                
                
                self.collectionView?.reloadData()
            }
            
        
        })
    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
//        print("didPress")
//        print("\(text)")
//        print(senderId)
//        print(senderDisplayName)
//        messages.append(JSQMessage(senderId: senderId, displayName: senderDisplayName, text: text))
//        collectionView?.reloadData()
        
        let newMessage = messageRef.childByAutoId()
        let messageData = ["text": text, "senderId": senderId,"senderName": senderDisplayName,"MediaType":"TEXT"]
        newMessage.setValue(messageData)
        
        self.finishSendingMessage()
    }
    
    override func didPressAccessoryButton(sender: UIButton!) {
         print("didpressAccessoryButton ")
     //   let imagePicker = UIImagePickerController()
     //   self.presentViewController(imagePicker, animated: true, completion: nil)
     //   imagePicker.delegate = self
        
        let sheet = UIAlertController(title: "Media Messages", message: "Please select a media", preferredStyle: UIAlertControllerStyle.ActionSheet)
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel){(alert:UIAlertAction)in}
        sheet.addAction(cancel)
        
        let photoLibrary = UIAlertAction(title:"Photo Library",style: UIAlertActionStyle.Default){(alert:UIAlertAction)in
            self.getMediaFrom(kUTTypeImage)
        }
        let videoLibrary = UIAlertAction(title:"Video Library",style: UIAlertActionStyle.Default){(alert:UIAlertAction)in
            self.getMediaFrom(kUTTypeMovie)
        }
    

        sheet.addAction(photoLibrary)
        sheet.addAction(videoLibrary)
        
        self.presentViewController(sheet, animated: true, completion: nil)

        
    }
    func getMediaFrom(type: CFString){
        print(type)
        let mediaPicker = UIImagePickerController()
        mediaPicker.delegate = self
        mediaPicker.mediaTypes = [type as String]
        self.presentViewController(mediaPicker, animated: true, completion: nil)
    }
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) ->JSQMessageData!{
        return messages[indexPath.item]
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        
        let message = messages[indexPath.item]
        let bubbleFactory = JSQMessagesBubbleImageFactory()

        if message.senderId == self.senderId {
            return bubbleFactory.outgoingMessagesBubbleImageWithColor(.blackColor())

        }
        else
        {
            return bubbleFactory.incomingMessagesBubbleImageWithColor(.blueColor())

        }
        
      }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        
        let message = messages[indexPath.item]
        
        
        
//        return JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(named: "profileImage"), diameter:30 )
        return avatarDict[message.senderId]
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("number of Items:\(messages.count)")
        return messages.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath:indexPath) as! JSQMessagesCollectionViewCell
        return cell
    }
    
    
    //did tap message bubble
    override func collectionView(collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAtIndexPath indexPath: NSIndexPath!) {
        print("didTapMessageBubbleIndexPath:\(indexPath.item)")
        let message = messages[indexPath.item]
        if message.isMediaMessage{
            if let mediaItem = message.media as? JSQVideoMediaItem{
            let player = AVPlayer(URL: mediaItem.fileURL)
                let playerViewController = AVPlayerViewController()
                playerViewController.player = player
            self.presentViewController(playerViewController, animated: true, completion: nil)
            
            }
        }
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func logoutTapped(sender: AnyObject) {
        print("logoutButtonPressed")
        
        
        // logout with clear user auth
        do{
            try FIRAuth.auth()?.signOut()
        }catch let error{
        
        print(error)}
        
        
        
        // create a main storyboard instance
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        // from main storyboard instanitiate a UIview controller
        let LoginVC = storyboard.instantiateViewControllerWithIdentifier("LoginVC") as! LoginViewController
        
        
        // get the app delegate
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        // set the navigation controller as root view controller
        appDelegate.window?.rootViewController = LoginVC
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    
    //send messages not in text
    func sendMedia(picture: UIImage?, video: NSURL?){
        print(picture)
        print(FIRStorage.storage().reference())
        
        if let picture = picture{
        
            let filePath = "\(FIRAuth.auth()!.currentUser)/\(NSDate.timeIntervalSinceReferenceDate())"
            print(filePath)
            let data = UIImageJPEGRepresentation(picture, 0.1)
            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/jpg"
            FIRStorage.storage().reference().child(filePath).putData(data!, metadata: metadata){(metadata,error)
                in
                if error != nil{
                    print(error?.localizedDescription)
                    return
                }
                let fileUrl = metadata!.downloadURLs![0].absoluteString
                
                let newMessage = self.messageRef.childByAutoId()
                let messageData = ["fileUrl": fileUrl, "senderId": self.senderId,"senderName": self.senderDisplayName,"MediaType":"PHOTO"]
                newMessage.setValue(messageData)
            }
        }
        else if let video = video{
            let filePath = "\(FIRAuth.auth()!.currentUser)/\(NSDate.timeIntervalSinceReferenceDate())"
            print(filePath)
            let data = NSData(contentsOfURL: video)
            let metadata = FIRStorageMetadata()
            metadata.contentType = "video/mp4"
            FIRStorage.storage().reference().child(filePath).putData(data!, metadata: metadata){(metadata,error)
                in
                if error != nil{
                    print(error?.localizedDescription)
                    return
                }
                let fileUrl = metadata!.downloadURLs![0].absoluteString
                
                let newMessage = self.messageRef.childByAutoId()
                let messageData = ["fileUrl": fileUrl, "senderId": self.senderId,"senderName": self.senderDisplayName,"MediaType":"VIDEO"]
                newMessage.setValue(messageData)
            }
        
            
            
        }
        
        
        }
        


}


extension ChatViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        print("did finish picking")
        
        //get the image 
      //  messages.append(JSQMessage(senderId: senderId, displayName: senderDisplayName, text: text))
      //  collectionView?.reloadData()
        
        print(info)
        
        if let picture = info[UIImagePickerControllerOriginalImage] as? UIImage{
            //let photo = JSQPhotoMediaItem(image: picture)
            //messages.append(JSQMessage(senderId: senderId, displayName: senderDisplayName, media: photo))
            
            sendMedia(picture,video:nil)
        }
        else if let video = info[UIImagePickerControllerMediaURL] as? NSURL{
            //let movie = JSQVideoMediaItem(fileURL: video, isReadyToPlay: true)
            //messages.append(JSQMessage(senderId: senderId, displayName: senderDisplayName, media: movie))
            
            sendMedia(nil,video:video)

        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
        collectionView?.reloadData()
    }

}

