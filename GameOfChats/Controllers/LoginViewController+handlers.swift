//
//  LoginViewController+handlers.swift
//  GameOfChats
//
//  Created by Seth Merritt on 12/16/17.
//  Copyright © 2017 leftyseth. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage

extension LoginViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	
	@objc func handleSelectProfileImageView() {
		let picker = UIImagePickerController()
		picker.delegate = self
		picker.allowsEditing = true
		present(picker, animated: true, completion: nil)
	}
	
	//handles the user registration process
	@objc func handleRegister() {
		guard let email = emailTextField.text, let password = passwordTextField.text, let name = nameTextField.text else {
			print("login error")
			return
		}
		
		Auth.auth().createUser(withEmail: email, password: password, completion: { (user:User?, error) in
			if error != nil {
				print(error!)
				return
			}
			
			guard let uid = user?.uid else { return }
			//successfully created user
			let imageName = NSUUID().uuidString
			let storageRef = Storage.storage().reference().child("profile_images").child("\(imageName).jpg")
			
			//unwraps safetly. If there is no image, then no value. Compression sets to a much smaller file size
			if let profileImage = self.profileImageView.image, let uploadData = UIImageJPEGRepresentation(profileImage, 0.1) {
				storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
					if error != nil {
						print(error!)
						return
					}
					if let profileImageUrl = metadata?.downloadURL()?.absoluteString {
						let values = ["name" : name, "email" : email, "profileImageUrl" : profileImageUrl ]
						self.registerUserIntoDatabaseWithUID(uid: uid, values: values)
						print(metadata!)
					}
				})
			}
		})
	}
	
	private func registerUserIntoDatabaseWithUID(uid: String, values:[String:Any]) {
		let ref = Database.database().reference()
		let usersReference = ref.child("users").child(uid)
		
		usersReference.updateChildValues(values, withCompletionBlock: {(err, ref) in
			if err != nil {
				print(err!)
				return
			}
			//self.messagesViewController?.navigationItem.title = values["name"] as? String
      let chatter = Chatter()
			//this setter will crash the app if keys do not match
			chatter.setValuesForKeys(values)
			self.messagesViewController?.setupNavBarWithUser(chatter: chatter)
			self.dismiss(animated: true, completion: nil)
		})
	}

	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
		var selectedImageFromPicker: UIImage?
		if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
			selectedImageFromPicker = editedImage
		} else	if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
			selectedImageFromPicker = originalImage
		}
		if let selectedImage = selectedImageFromPicker {
			profileImageView.image = selectedImage
		}
		dismiss(animated: true, completion: nil)
	}
	
	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		dismiss(animated: true, completion: nil)
	}
	
}
