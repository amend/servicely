//
//  ChangeProfilePictureViewController.swift
//  servicely
//
//  Created by Dana Vaziri on 10/31/17.
//  Copyright © 2017 Andoni Mendoza. All rights reserved.
//

import UIKit
import Photos
import Firebase
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

class ChangeProfilePictureViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var choosePictureButton: UIButton!
    @IBOutlet weak var setPictureButton: UIButton!
    @IBOutlet weak var savingPicLabel: UILabel!
    
    var sourceImage: UIImage? = nil
    var imagePicker = UIImagePickerController()
    
    var imageURL:NSURL = NSURL()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let colorScheme = ColorScheme.getColorScheme()
        headerView.backgroundColor = colorScheme
        choosePictureButton.backgroundColor = colorScheme
        setPictureButton.backgroundColor = colorScheme
        
        if(imageView.image == nil) {
            let db:DatabaseWrapper = DatabaseWrapper()
            db.getCurrentUser() { (user:NSDictionary?) in
                let profilePicURL = user?["profilePic"] as? String ?? ""
                
                if(profilePicURL != "") {
                    db.retrieveImage(profilePicURL) { (image:UIImage) in
                        self.imageView.image = image
                    }
                }
                
            }
        }
    }
    
    @IBAction func choosePicture(_ sender: Any) {
        checkPermission()
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            print("Button capture")
            
            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum;
            imagePicker.allowsEditing = false
            
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func setPicture(_ sender: Any) {
        self.savingPicLabel.text = "Saving profile pic..."
        uploadPhoto(sourceImage!, completionBlock: {})
    }
    
    func uploadPhoto(_ image: UIImage, completionBlock: @escaping () -> Void) {
        let userID = Auth.auth().currentUser?.uid

        let ref = Storage.storage().reference().child("images/").child("\(userID!).jpg")    // you may want to use UUID().uuidString + ".jpg" instead of "myFileName.jpg" if you want to upload multiple files with unique names
        
        let meta = StorageMetadata()
        meta.contentType = "image/jpg"
        
        // 0.8 here is the compression quality percentage
        
        //ref.put(UIImageJPEGRepresentation(image, 0.8)!, metadata: meta, completion: { (imageMeta, error) in
        ref.putData(UIImageJPEGRepresentation(image, 0.8)!, metadata: meta, completion: { (imageMeta, error) in
            if error != nil {
                // handle the error
                return
            }
            
            // most likely required data
            let downloadURL = imageMeta?.downloadURL()?.absoluteString      // needed to later download the image
            let imagePath = imageMeta?.path     // needed if you want to be able to delete the image later
            
            // optional data
            let timeStamp = imageMeta?.timeCreated
            let size = imageMeta?.size
            
            // ----- should save these data in your database at this point -----
            
            // ************* start db stuff, wrap this chunk and others in class *************
            let userID = Auth.auth().currentUser?.uid
            
            // Save to Firebase.
            let refDatabaseReference = Database.database().reference()
            
            //\ref.child("users/\(userID!)/profilePic").setValue(downloadURL)
            ref.child("users/\(userID!)/profilePic").setValue(downloadURL, forKey: "profilePic")
            
            // ************* end db stuff, wrap this chunk and others in class *************

            self.savingPicLabel.text = ""
            
            completionBlock()
        })
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        sourceImage = (info[UIImagePickerControllerOriginalImage] as? UIImage)!
        picker.dismiss(animated: true, completion: nil)
        imageView.image = sourceImage
        
        // get locla url of image
        imageURL = info[UIImagePickerControllerReferenceURL] as! NSURL
        //let imageName - imageUR
        //let imageName = imageURL.path!.lastPathComponent
        //let documentDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first as! String
        //let localPath = documentDirectory.stringByAppendingPathComponent(imageName)
    }
    
    func checkPermission() {
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch photoAuthorizationStatus {
        case .authorized:
            print("Access is granted by user")
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({
                (newStatus) in
                print("status is \(newStatus)")
                if newStatus ==  PHAuthorizationStatus.authorized {
                    /* do stuff here */
                    print("success")
                }
            })
            print("It is not determined until now")
        case .restricted:
            // same same
            print("User do not have access to photo album.")
        case .denied:
            // same same
            print("User has denied the permission.")
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}