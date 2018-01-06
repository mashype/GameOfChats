//
//  NewMessageViewController.swift
//  GameOfChats
//
//  Created by Seth Merritt on 12/16/17.
//  Copyright © 2017 leftyseth. All rights reserved.
//

import UIKit
import Firebase
//screen where i select the chat partner
class NewMessageViewController: UITableViewController {

	let cellId = "CellId"
	var chatters = [Chatter]()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
		tableView.register(ChatterCell.self, forCellReuseIdentifier: cellId)
		fetchUser()
	}
	
	func fetchUser() {
		Database.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
			if let dictionary = snapshot.value as? [String : Any] {
				let chatter = Chatter()
				chatter.id = snapshot.key //sets the id on the chatter to the UID in the database
				chatter.setValuesForKeys(dictionary)
				self.chatters.append(chatter)
				DispatchQueue.main.async {
					self.tableView.reloadData()
				}
			}
		}, withCancel: nil)
	}
	
	@objc func handleCancel() {
		dismiss(animated: true, completion: nil)
	}
	
	//MARK:- Table view Delegates
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return chatters.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ChatterCell
		let chatter = chatters[indexPath.row]
		cell.textLabel?.text = chatter.name
		cell.detailTextLabel?.text = chatter.email
		
		//downloads the image from the profile URL
		if let profileImageUrl = chatter.profileImageUrl {
			cell.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
		}
		return cell
		
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 72
	}
	
	var messagesController: MessagesViewController? //creates the variable to call this below.
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		dismiss(animated: true) {
			let chatter = self.chatters[indexPath.row]
			//passes 'chatter' variable over to the MessagesVC into this method to do something with it.
			self.messagesController?.showChatControllerForChatter(chatter: chatter)
		}
	}
}

