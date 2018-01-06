//
//  MessagesViewController.swift
//  GameOfChats
//
//  Created by Seth Merritt on 12/14/17.
//  Copyright © 2017 leftyseth. All rights reserved.
//  the screen with the name and logo on top. Click on the messages and start new chats

import UIKit
import Firebase


// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
	switch (lhs, rhs) {
	case let (l?, r?):
		return l < r
	case (nil, _?):
		return true
	default:
		return false
	}
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
	switch (lhs, rhs) {
	case let (l?, r?):
		return l > r
	default:
		return rhs < lhs
	}
}

class MessagesViewController: UITableViewController {

	let cellId = "cellId"
	
	override func viewDidLoad() {
		super.viewDidLoad()
		navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
		let image = UIImage(named: "chat-comment-oval-speech-bubble-with-text-lines")
		navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(handleNewMessage))
		checkIfUserIsLoggedIn()
		tableView.register(ChatterCell.self, forCellReuseIdentifier: cellId)
		tableView.allowsMultipleSelectionDuringEditing = true
		
	}
	
	override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		return true
	}
	
	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		print(indexPath.row)
		guard let uid = Auth.auth().currentUser?.uid else {
			return
		}
		let message = self.messages[indexPath.row]
		
		if let chatPartnerId = message.chatPartnerId() {
			Database.database().reference().child("user-messages").child(uid).child(chatPartnerId).removeValue(completionBlock: { (error, ref) in
				if error != nil {
					print("Failed to delete message:", error as Any)
					return
				}
				self.messagesDictionary.removeValue(forKey: chatPartnerId)
			})
		}
	}
	
	var messages = [Message]()
	var messagesDictionary = [String: Message]()
	
	//this function displays all the conversations on the firstuser screen
	func observeUserMessages() {
		
		guard let uid = Auth.auth().currentUser?.uid else {
			return
		}
		let ref = Database.database().reference().child("user-messages").child(uid)
		ref.observe(.childAdded, with: { (snapshot) in
			let chatterId = snapshot.key
			//this subs into user-messages, current user folder, chat partner folder and grabs the messages
			Database.database().reference().child("user-messages").child(uid).child(chatterId).observe(.childAdded, with: { (snapshot) in
				let messageId = snapshot.key
				self.fetchMessageWithMessageId(messageId: messageId)
			}, withCancel: nil)
		}, withCancel: nil)
		
		ref.observe(.childRemoved, with: { (snapshot) in
			self.messagesDictionary.removeValue(forKey: snapshot.key)
			self.attemptReloadOfTable()
		}, withCancel: nil)

	}
	
	private func fetchMessageWithMessageId(messageId: String) {
		let messageReference = Database.database().reference().child("messages").child(messageId)
		messageReference.observeSingleEvent(of: .value, with: { (snapshot) in
			if let dictionary = snapshot.value as? [String:Any] {
				let message = Message(dictionary:dictionary)

				if let chatPartnerId = message.chatPartnerId() {
					self.messagesDictionary[chatPartnerId] = message
					//this setup of creating the dictionary and creating an array of unique ID's is how you group.
				}
				self.attemptReloadOfTable()
			}
		}, withCancel: nil)
	}
	
	func attemptReloadOfTable() {
		//this piece was just put in to reduce the flickering on the image views to reduce the times you reload the table.
		//this code fires every time you observe the message. so this code tells it to wait .1 seconds before you reload the table.
		self.timer?.invalidate()
		self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
	}
	
	var timer: Timer?
	
	@objc func handleReloadTable() {
		
		self.messages = Array(self.messagesDictionary.values)
		self.messages.sort(by: { (message1, message2) -> Bool in
			return message1.timestamp?.int32Value > message2.timestamp?.int32Value
		})
		DispatchQueue.main.async {
			self.tableView.reloadData()
		}
	}
	
	//MARK:- table view delegates
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return messages.count
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 72
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ChatterCell
		let message = messages[indexPath.row]
		cell.message = message
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let message = messages[indexPath.row]
		guard let chatPartnerId = message.chatPartnerId() else {
			return
		}
		let ref = Database.database().reference().child("users").child(chatPartnerId)
		ref.observeSingleEvent(of: .value, with: { (snapshot) in
			
			guard let dictionary = snapshot.value as? [String: Any] else {
				return
			}
			let chatter = Chatter()
			chatter.id = chatPartnerId
			chatter.setValuesForKeys(dictionary)
			self.showChatControllerForChatter(chatter: chatter)
			
		}, withCancel: nil)
	}
	
	//MARK:- Functions
	@objc func handleNewMessage() {
		let newMessageController = NewMessageViewController()
		newMessageController.messagesController = self //sets the variable in the NewMessageVC to this controller
		let navController = UINavigationController(rootViewController: newMessageController)
		present(navController, animated: true, completion: nil)
	}
	
	//this code checks if the user is logged in before displaying the controller.
	func checkIfUserIsLoggedIn() {
		//user is not logged in.
		if Auth.auth().currentUser?.uid == nil {
			perform(#selector(handleLogout), with: nil, afterDelay: 0)
		} else {
			fetchUserAndSetupNavBarTitle()
		}
	}
	
	func fetchUserAndSetupNavBarTitle() {
		//sets UID to the current user ID
		guard let uid = Auth.auth().currentUser?.uid else { return }  // if for some reason UID is nil, it just returns.
		Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
			if let dictionary = snapshot.value as? [String : Any] {
				//self.navigationItem.title = dictionary["name"] as? String
				
				let chatter = Chatter()
				chatter.setValuesForKeys(dictionary)
				
				self.setupNavBarWithUser(chatter: chatter)
				
			}
			
		}, withCancel: nil)
	}
	
	func setupNavBarWithUser(chatter: Chatter) {
		
		messages.removeAll()
		messagesDictionary.removeAll()
		tableView.reloadData()
		observeUserMessages()
		
		let titleView = UIButton()
		titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
		
		let containerView = UIView()
		containerView.translatesAutoresizingMaskIntoConstraints = false
		titleView.addSubview(containerView)
		
		let profileImageView = UIImageView()
		profileImageView.translatesAutoresizingMaskIntoConstraints = false
		profileImageView.contentMode = .scaleAspectFill
		profileImageView.layer.cornerRadius = 20
		profileImageView.clipsToBounds = true
		if let profileImageUrl = chatter.profileImageUrl {
			profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
		}
		
		containerView.addSubview(profileImageView)
		
		//ios 9 constraints
		profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
		profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
		profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
		profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
		
		let nameLabel = UILabel()
		
		containerView.addSubview(nameLabel)
		nameLabel.text = chatter.name
		nameLabel.translatesAutoresizingMaskIntoConstraints = false
		
		nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
		nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
		nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
		nameLabel.heightAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true
		
		containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
		containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
		
		self.navigationItem.titleView = titleView
		
		//titleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showChatController)))

		
	}
	
	@objc func showChatControllerForChatter(chatter: Chatter) {
		let chatLogViewController = ChatLogViewController(collectionViewLayout: UICollectionViewFlowLayout())
		chatLogViewController.chatter = chatter
		navigationController?.pushViewController(chatLogViewController, animated: true)
	}
	
	@objc func handleLogout() {
		
		do {
			try Auth.auth().signOut()
		} catch let logoutError {
			print(logoutError)
		}

		let loginViewController = LoginViewController()
		loginViewController.messagesViewController = self
		present(loginViewController, animated: true, completion: nil)
	}


}

