//  ChatLogViewController.swift
//  GameOfChats
//  Created by Seth Merritt on 12/17/17.
//  Copyright © 2017 leftyseth. All rights reserved.
//  the screen where you actual enter the messages

import UIKit
import Firebase
import MobileCoreServices
import AVFoundation


class ChatLogViewController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	//MARK:- Variables
	var chatter: Chatter? {
		didSet {
			navigationItem.title = chatter?.name
			observeMessages()
		}
	}
	
	var messages = [Message]()
	
	//MARK:- Loading and observing messages
	//view to show all the messages on the thread
	func observeMessages() {
		guard let uid = Auth.auth().currentUser?.uid, let toId = chatter?.id else {  //chatter here is the chat partner passed from NewMsgVC
			return
		}
		let userMessagesRef = Database.database().reference().child("user-messages").child(uid).child(toId)
		
		userMessagesRef.observe(.childAdded, with: { (snapshot) in
			let messageId = snapshot.key
			let messagesRef = Database.database().reference().child("messages").child(messageId)
			messagesRef.observeSingleEvent(of: .value, with: { (snapshot) in
				guard let dictionary = snapshot.value as? [String:Any] else {
					return
				}

				self.messages.append(Message(dictionary: dictionary))
				DispatchQueue.main.async {
					self.collectionView?.reloadData()
					//scroll to the last index
					let indexPath = IndexPath(item: self.messages.count - 1, section: 0)
					self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
				}
			}, withCancel: nil)
		}, withCancel: nil)
	}
	
	
	
	let cellId = "cellId"
	
	override func viewDidLoad() {
		super.viewDidLoad()
		collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0) // sets some spacing in the bubbles and space on the bottom of the screen
		collectionView?.alwaysBounceVertical = true
		collectionView?.backgroundColor = UIColor.white
		collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
		//follows the scrolling
		collectionView?.keyboardDismissMode = .interactive

		setupKeyboardObservers()
	}
	
	lazy var inputContainerView: ChatInputContainerView = {

		let chatInputContainerView = ChatInputContainerView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
		chatInputContainerView.chatLogController = self
		return chatInputContainerView
		
	}()
	
	@objc func handleUploadTap() {
		let imagePickerController = UIImagePickerController()
		imagePickerController.delegate = self
		imagePickerController.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String] //allows movie loads
		imagePickerController.allowsEditing = true
		present(imagePickerController, animated: true, completion: nil)
	}
	//MARK:- Image Picker functions
	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		dismiss(animated: true, completion: nil)
	}
	
	@objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
		if let videoUrl = info[UIImagePickerControllerMediaURL] as? URL {
			//we selected a video
			handleVideoSelectedForUrl(url: videoUrl)
		} else {
			//we selected an image
			handleImageSelectedForInfo(info: info)
		}
		dismiss(animated: true, completion: nil)
	}
	
	private func handleVideoSelectedForUrl(url: URL) {
		let filename = NSUUID().uuidString + ".mov"
		let uploadTask = Storage.storage().reference().child("message_movies").child(filename).putFile(from: url, metadata: nil, completion: { (metadata, error) in
			if error != nil {
				print("failed upload:", error!)
				return
			}
			if let videoUrl = metadata?.downloadURL()?.absoluteString {
				//"imageUrl" : imageUrl,
				if let thumbnailImage = self.thumbnailImageForFileUrl(fileUrl: url) {
					
					self.uploadToFirebaseStorageUsingImage(image: thumbnailImage, completion: { (imageUrl) in
						let properties: [String:Any] = ["imageUrl" : imageUrl, "imageWidth" : thumbnailImage.size.width, "imageHeight" : thumbnailImage.size.height, "videoUrl" : videoUrl]
						self.sendMessageWithProperties(properties: properties)
					})
				}
			}
		})
		uploadTask.observe(.progress) { (snapshot) in
			if let completedUnitCount = snapshot.progress?.completedUnitCount {
				self.navigationItem.title = String(completedUnitCount)
			}
			print(snapshot.progress?.completedUnitCount as Any)
		}
		
		uploadTask.observe(.success) { (snapshot) in
			self.navigationItem.title = self.chatter?.name
		}
	}
	
	private func thumbnailImageForFileUrl(fileUrl: URL) -> UIImage? {
		let asset = AVAsset(url: fileUrl) //this url is the location to the actual FILE.
		let imageGenerator = AVAssetImageGenerator(asset: asset)
	
		do {
			let thumbnailCGImage = try imageGenerator.copyCGImage(at: CMTimeMake(1, 60), actualTime: nil) //put in do/catch because it throws
			return UIImage(cgImage: thumbnailCGImage) //converts the CGImage to a UIImage and returns it back to the caller
		} catch let err {
			print(err)
		}
		return nil
	}
	
	private func handleImageSelectedForInfo(info: [String:Any]) {
		var selectedImageFromPicker: UIImage?
		if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
			selectedImageFromPicker = editedImage
		} else	if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
			selectedImageFromPicker = originalImage
		}
		if let selectedImage = selectedImageFromPicker {
			uploadToFirebaseStorageUsingImage(image: selectedImage, completion: { (imageUrl) in
				self.sendMessageWithImageUrl(imageUrl, image: selectedImage)
			})
		}
	}
	
	fileprivate func uploadToFirebaseStorageUsingImage(image: UIImage, completion: @escaping (_ imageUrl: String) -> ()) {
		//first create a name for the image
		let imageName = NSUUID().uuidString
		//first get the reference to the storage location
		let ref = Storage.storage().reference().child("message_images").child(imageName)
		if let uploadData = UIImageJPEGRepresentation(image, 0.2) {  //image her is the image we passed into the method
			
			ref.putData(uploadData, metadata: nil, completion: { (metadata, error) in
				if error != nil {
					print("failed to upload", error!)
					return
				}
				if let imageUrl = metadata?.downloadURL()?.absoluteString {
					completion(imageUrl)
				}
			})
		}
		
	}
	
	//MARK:- Keyboard Navigation
	override var inputAccessoryView: UIView? {
		get {
			return inputContainerView
		}
	}
	
	override var canBecomeFirstResponder: Bool {
		return true
	}
	
	func setupKeyboardObservers() {
		NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
//		NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
//		NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
		
	}
	
	@objc func handleKeyboardDidShow() {
		if messages.count > 0 {
			let indexPath = IndexPath(item: messages.count - 1, section: 0)
			collectionView?.scrollToItem(at: indexPath, at: .top, animated: true)
		}
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		//call to dismiss the keyboard observers and prevent the memory leak. Otherwise it continues to duplicate these calls every time.
		NotificationCenter.default.removeObserver(self)
	}
	
	
	@objc func handleKeyboardWillShow(_ notification: NSNotification) {
		//this gets us the height of the keyboard area that we can use to move when called.
		let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
		let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue

		//move the input area up. The negative just takes the opposite of the number.
		containerViewBottomAnchor?.constant = -keyboardFrame!.height
		
		UIView.animate(withDuration: keyboardDuration!) {
			self.view.layoutIfNeeded()
		}
	}
	
	@objc func handleKeyboardWillHide(_ notification: NSNotification) {
		//just handles when the keyboard is dismissed and resets the input down to the bottom.
		containerViewBottomAnchor?.constant = 0
		
		let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
		UIView.animate(withDuration: keyboardDuration!) {
			self.view.layoutIfNeeded()
		}
	}
	
	private func estimatedFrameForText(text: String) -> CGRect {
		let size = CGSize(width: 200, height: 1000)
		let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
		return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16)], context: nil)
	}
	//MARK:- Sending the messages
	
	var containerViewBottomAnchor: NSLayoutConstraint?
	
	//handles the sending of the text only but no image.
	@objc func handleSend() {
		let properties: [String:Any] = ["text" : inputContainerView.inputTextField.text!]
		sendMessageWithProperties(properties: properties)
	}
	
	fileprivate func sendMessageWithImageUrl(_ imageUrl: String, image: UIImage) {
		let properties: [String:Any] = ["imageUrl" : imageUrl, "imageWidth" : image.size.width, "imageHeight" : image.size.height]
		sendMessageWithProperties(properties: properties)
	}
	
	private func sendMessageWithProperties(properties: [String : Any]) {
		let ref = Database.database().reference().child("messages")
		let childRef = ref.childByAutoId()
		let toId = chatter!.id!
		let fromId = Auth.auth().currentUser!.uid
		let timestamp = Int(Date().timeIntervalSince1970)
		var values: [String:Any] = ["toId" : toId, "fromId" : fromId, "timestamp" : timestamp]
		
		//append the properties dict onto values.
		//the key is $0 and the value is $1
		properties.forEach({values[$0] = $1})
		
		childRef.updateChildValues(values) { (error, ref) in
			if error != nil{
				print(error!)
				return
			}
			self.inputContainerView.inputTextField.text = nil  //clears the field after load
			let userMessagesRef = Database.database().reference().child("user-messages").child(fromId).child(toId) //thie groups messages by the sender with FromID
			let messageId = childRef.key  //just gets the actual ID from the unique ID under childRef
			userMessagesRef.updateChildValues([messageId: 1])
			let recipientUserMessageRef = Database.database().reference().child("user-messages").child(toId).child(fromId)
			recipientUserMessageRef.updateChildValues([messageId: 1])
		}
	}
	
	//called when device rotates
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		collectionView?.collectionViewLayout.invalidateLayout()
	}
	
	//MARK:- Table view delegates
	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return messages.count
	}
	
	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
		cell.chatLogViewController = self
		
		let message = messages[indexPath.item]
		cell.message = message
		
		cell.textView.text = message.text
		setupCell(cell: cell, message: message)
		//modify the width
		if let text = message.text {
			cell.bubbleWidthAnchor?.constant = estimatedFrameForText(text: text).width + 32
			cell.textView.isHidden = false //hid this since its covering the photo to tap on
		} else if message.imageUrl != nil {
			//fall in here for images since image messages have no text
			cell.bubbleWidthAnchor?.constant = 200
			cell.textView.isHidden = true
		}
		cell.playButton.isHidden = message.videoUrl == nil //when videoURL is empty, play button is hidden
		
		
		return cell
	}
	
	//setup up the bubble colors
	private func setupCell(cell: ChatMessageCell, message: Message) {
		
		if let profileImageUrl = self.chatter?.profileImageUrl {
			cell.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
		}

		if message.fromId == Auth.auth().currentUser?.uid {
			//outgoing blue
			cell.bubbleView.backgroundColor = ChatMessageCell.blueColor
			cell.textView.textColor = UIColor.white
			cell.bubbleViewRightAnchor?.isActive = true
			cell.bubbleViewLeftAnchor?.isActive = false
			cell.profileImageView.isHidden = true
		} else {
			//incoming gray
			cell.bubbleView.backgroundColor = UIColor(r: 240, g: 240, b: 240)
			cell.textView.textColor = UIColor.black
			cell.bubbleViewRightAnchor?.isActive = false
			cell.bubbleViewLeftAnchor?.isActive = true
			cell.profileImageView.isHidden = false
		}
		
		if let messageImageUrl = message.imageUrl {
			cell.messageImageView.loadImageUsingCacheWithUrlString(urlString: messageImageUrl)
			cell.messageImageView.isHidden = false
			cell.bubbleView.backgroundColor = UIColor.clear
		} else {
			cell.messageImageView.isHidden = true
		}
		
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		var height: CGFloat = 80
		
		let message = messages[indexPath.item]
		if let text = message.text {
			height = estimatedFrameForText(text: text).height + 20
		} else if let imageWidth = message.imageWidth?.floatValue, let imageHeight = message.imageHeight?.floatValue {
			
			// h1 / w1 = h2 / w2
			// solve for h1: h1 = h2 / w2 * w1
			height = CGFloat(imageHeight / imageWidth * 200)
			
		}
		
		let width = UIScreen.main.bounds.width
		return CGSize(width: width, height: height)
	}
	
	//MARK:- Image Zoom
	var startingFrame: CGRect?
	var blackBackgroundView: UIView?
	var startingImageView: UIImageView?
	
	//my custom zooming logic clicking on the image.
	func performZoomInForStartingImageView(startingImageView: UIImageView) {
		
		self.startingImageView = startingImageView
		self.startingImageView?.isHidden = true //hides the image as soon as its clicked
		
		startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)
		let zoomingImageView = UIImageView(frame: startingFrame!)
		zoomingImageView.backgroundColor = UIColor.red
		zoomingImageView.image = startingImageView.image
		zoomingImageView.isUserInteractionEnabled = true
		zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
		
		if let keyWindow = UIApplication.shared.keyWindow {
			blackBackgroundView = UIView(frame: keyWindow.frame)
			blackBackgroundView?.backgroundColor = UIColor.black
			blackBackgroundView?.alpha = 0
			keyWindow.addSubview(blackBackgroundView!)
			
			keyWindow.addSubview(zoomingImageView)

			UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
				self.blackBackgroundView?.alpha = 1
				self.inputContainerView.alpha = 0
				
				//h2/w1 = h1/w1  h2 = h1/w1*2
				let height = self.startingFrame!.height / self.startingFrame!.width * keyWindow.frame.width
				zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
				zoomingImageView.center = keyWindow.center

			}, completion: nil)
		}
	}
	@objc func handleZoomOut(tapGesture:UITapGestureRecognizer) {
		if let zoomOutImageView = tapGesture.view {
			//need to animate back out.
			zoomOutImageView.layer.cornerRadius = 16
			zoomOutImageView.clipsToBounds = true
			
			UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
				zoomOutImageView.frame = self.startingFrame!
				self.blackBackgroundView?.alpha = 0
				self.inputContainerView.alpha = 1
			}, completion: { (completed) in
				zoomOutImageView.removeFromSuperview()
				self.startingImageView?.isHidden = false
				self.blackBackgroundView?.removeFromSuperview()
			})
		}
	}
}




