//
//  ChatInputContainerView.swift
//  GameOfChats
//
//  Created by Seth Merritt on 12/22/17.
//  Copyright © 2017 leftyseth. All rights reserved.
//	seperate refactor to create the message type view on chat log VC

import UIKit

class ChatInputContainerView: UIView, UITextFieldDelegate {

	weak var chatLogController: ChatLogViewController? {
		didSet {
			sendButton.addTarget(chatLogController, action: #selector(ChatLogViewController.handleSend), for: .touchUpInside)
			uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: chatLogController, action: #selector(ChatLogViewController.handleUploadTap)))
		}
	}
	
	//closure to access this variable outside the setupInputComponents.
	lazy var inputTextField: UITextField = {
		let textField = UITextField()
		textField.placeholder = "Enter Message..."
		textField.translatesAutoresizingMaskIntoConstraints = false
		textField.delegate = self
		return textField
	}() //the parentheses executes the closure block
	
	let uploadImageView: UIImageView = {
		let uploadImageView = UIImageView()
		uploadImageView.isUserInteractionEnabled = true
		uploadImageView.image = UIImage(named: "image-add-button")
		uploadImageView.translatesAutoresizingMaskIntoConstraints = false
		return uploadImageView
	}()
	
	let sendButton = UIButton(type: .system)
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		backgroundColor = UIColor.white
		
		addSubview(uploadImageView)
		uploadImageView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
		uploadImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
		uploadImageView.widthAnchor.constraint(equalToConstant: 44).isActive = true
		uploadImageView.heightAnchor.constraint(equalToConstant: 44).isActive = true
		
		sendButton.setTitle("Send", for: .normal)
		sendButton.translatesAutoresizingMaskIntoConstraints = false
		
		addSubview(sendButton)
		//send constraints
		sendButton.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
		sendButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
		sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
		sendButton.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
		
		addSubview(self.inputTextField)
		self.inputTextField.leftAnchor.constraint(equalTo: uploadImageView.rightAnchor, constant: 8).isActive = true
		self.inputTextField.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
		self.inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
		self.inputTextField.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
		
		let separatorLineView = UIView()
		separatorLineView.backgroundColor = UIColor(r: 220, g: 220, b: 220)
		separatorLineView.translatesAutoresizingMaskIntoConstraints = false
		addSubview(separatorLineView)
		//constraints
		separatorLineView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
		separatorLineView.topAnchor.constraint(equalTo: topAnchor).isActive = true
		separatorLineView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
		separatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
		
	}
	
	//makes the enter key post the message.
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		chatLogController?.handleSend()
		return true
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
}
