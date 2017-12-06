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
    var sourceImage: UIImage = nil
    var imagePicker = UIImagePickerController()
    
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
        let userID = FIRAuth.auth()?.currentUser?.uid
        let storageRef = FIRStorage.storage().reference()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        sourceImage = (info[UIImagePickerControllerOriginalImage] as? UIImage)!
        picker.dismiss(animated: true, completion: nil)
        imageView.image = sourceImage
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
