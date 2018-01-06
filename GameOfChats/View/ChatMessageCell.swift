//
//  ChatMessageCell.swift
//  GameOfChats
//
//  Created by Seth Merritt on 12/19/17.
//  Copyright © 2017 leftyseth. All rights reserved.
//

import UIKit
import AVFoundation

class ChatMessageCell: UICollectionViewCell {
	
	var message: Message?
	var chatLogViewController: ChatLogViewController?
	
	let activityIndicatorView: UIActivityIndicatorView = {
		let aiv = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
		aiv.translatesAutoresizingMaskIntoConstraints = false
		aiv.hidesWhenStopped = true
		return aiv
		
	}()
	
	lazy var playButton: UIButton = {
		let button = UIButton(type: .system)
		button.tintColor = UIColor.white
		button.translatesAutoresizingMaskIntoConstraints = false
		let image = UIImage(named: "play_button")
		button.setImage(image, for: .normal)
		
		button.addTarget(self, action: #selector(handlePlay), for: .touchUpInside)
		return button
	}()
	
	var playerLayer: AVPlayerLayer?
	var player: AVPlayer?
	
	@objc func handlePlay() {
		if let videoUrlString = message?.videoUrl, let url = URL(string: videoUrlString) {
			player = AVPlayer(url: url)
			playerLayer = AVPlayerLayer(player: player) //adds a layer to play the video
			playerLayer?.frame = bubbleView.bounds
			bubbleView.layer.addSublayer(playerLayer!)
			player?.play()
			activityIndicatorView.startAnimating()
			playButton.isHidden = true
		}
		
	}
	
	override func prepareForReuse() {
		super.prepareForReuse() //every time we recycle the cell
		playerLayer?.removeFromSuperlayer()
		player?.pause()
		activityIndicatorView.stopAnimating()
	}
	
	let textView: UITextView = {
		let tv = UITextView()
		tv.text = "SAMPLE TEXT FOR NOW"
		tv.font = UIFont.systemFont(ofSize: 16)
		tv.translatesAutoresizingMaskIntoConstraints = false
		tv.backgroundColor = UIColor.clear
		tv.textColor = .white
		tv.isEditable = false
		
		return tv
	}()
	
	static let blueColor = UIColor(r: 0, g: 137, b: 249)
	
	let bubbleView: UIView = {
		let view = UIView()
		view.backgroundColor = blueColor
		view.translatesAutoresizingMaskIntoConstraints = false
		view.layer.cornerRadius = 16
		view.layer.masksToBounds = true
		return view
	}()
	
	let profileImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.layer.cornerRadius = 16
		imageView.layer.masksToBounds = true
		imageView.contentMode = .scaleAspectFill
		return imageView
	}()
	
	lazy var messageImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.layer.cornerRadius = 16
		imageView.layer.masksToBounds = true
		imageView.contentMode = .scaleAspectFill
		imageView.isUserInteractionEnabled = true
		imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomTap)))
		return imageView
	}()
	
	@objc func handleZoomTap(tapGesture: UITapGestureRecognizer) {
		
		if message?.videoUrl != nil {
			return //this just returns out of the funtion if there is a video url
		}
		
		if let imageView = tapGesture.view as? UIImageView {
			//PRO TIP Dont perform alot of custom logic in a view class. DELEGATE
			self.chatLogViewController?.performZoomInForStartingImageView(startingImageView: imageView)
		}
	}
	
	var bubbleWidthAnchor: NSLayoutConstraint?
	var bubbleViewRightAnchor: NSLayoutConstraint?
	var bubbleViewLeftAnchor: NSLayoutConstraint?
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		addSubview(bubbleView)
		addSubview(textView)
		addSubview(profileImageView)
		
		bubbleView.addSubview(messageImageView)
		messageImageView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor).isActive = true
		messageImageView.topAnchor.constraint(equalTo: bubbleView.topAnchor).isActive = true
		messageImageView.widthAnchor.constraint(equalTo: bubbleView.widthAnchor).isActive = true
		messageImageView.heightAnchor.constraint(equalTo: bubbleView.heightAnchor).isActive = true
		
		bubbleView.addSubview(playButton)
		playButton.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor).isActive = true
		playButton.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor).isActive = true
		playButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
		playButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
		
		bubbleView.addSubview(activityIndicatorView)
		activityIndicatorView.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor).isActive = true
		activityIndicatorView.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor).isActive = true
		activityIndicatorView.widthAnchor.constraint(equalToConstant: 50).isActive = true
		activityIndicatorView.heightAnchor.constraint(equalToConstant: 50).isActive = true
		
		//x,y,w,h
		profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
		profileImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
		profileImageView.widthAnchor.constraint(equalToConstant: 32).isActive = true
		profileImageView.heightAnchor.constraint(equalToConstant: 32).isActive = true
		
		//x,y,w,h
		
		bubbleViewRightAnchor = bubbleView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8)
		
		bubbleViewRightAnchor?.isActive = true
		
		bubbleViewLeftAnchor = bubbleView.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8)
		//        bubbleViewLeftAnchor?.active = false
		
		
		bubbleView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
		
		bubbleWidthAnchor = bubbleView.widthAnchor.constraint(equalToConstant: 200)
		bubbleWidthAnchor?.isActive = true
		
		bubbleView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
		
		//ios 9 constraints
		//x,y,w,h
		//        textView.rightAnchor.constraintEqualToAnchor(self.rightAnchor).active = true
		textView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 8).isActive = true
		textView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
		
		textView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor).isActive = true
		//        textView.widthAnchor.constraintEqualToConstant(200).active = true
		
		
		textView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
}