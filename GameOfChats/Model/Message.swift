//
//  Message.swift
//  GameOfChats
//
//  Created by Seth Merritt on 12/18/17.
//  Copyright © 2017 leftyseth. All rights reserved.
//

import UIKit
import Firebase

class Message: NSObject {
	
	var fromId: String?
	var text: String?
	var timestamp: NSNumber?
	var toId: String?
	var imageUrl: String?
	var imageWidth: NSNumber?
	var imageHeight: NSNumber?
	var videoUrl: String?
	
	init(dictionary: [String: Any]) {
		self.fromId = dictionary["fromId"] as? String
		self.text = dictionary["text"] as? String
		self.toId = dictionary["toId"] as? String
		self.timestamp = dictionary["timestamp"] as? NSNumber
		self.imageUrl = dictionary["imageUrl"] as? String
		
		self.imageWidth = dictionary["imageWidth"] as? NSNumber
		self.imageHeight = dictionary["imageHeight"] as? NSNumber
		self.videoUrl = dictionary["videoUrl"] as? String
	}
	
	//if the current user is the sender, sends the toId as the partner. If current user is reciever, its sends the fromId as the partner.
	func chatPartnerId() -> String? {
		
		if fromId == Auth.auth().currentUser?.uid {
			return toId
		} else {
			return fromId
		}
	}

}
