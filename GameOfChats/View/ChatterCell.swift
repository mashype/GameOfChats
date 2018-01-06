//
//  ChatterCell.swift
//  GameOfChats
//
//  Created by Seth Merritt on 12/18/17.
//  Copyright © 2017 leftyseth. All rights reserved.
//

import  UIKit
import Firebase

//create a custom cell without the storyboard.
class ChatterCell: UITableViewCell {
	
	var message: Message? {
		didSet {
			setupNameAndProfileImage()
			detailTextLabel?.text = message?.text
			if let seconds = message?.timestamp?.doubleValue {
				let timestampDate = NSDate(timeIntervalSince1970: seconds)
				let dateFormatter = DateFormatter()
				dateFormatter.dateFormat = "hh:mm:ss a"
				timeLabel.text = dateFormatter.string(from: (timestampDate) as Date)
			}
		}
	}
	
	private func setupNameAndProfileImage() {
		//calls the function we created in the message model
		if let id = message?.chatPartnerId() {
			let ref = Database.database().reference().child("users").child(id)
			ref.observeSingleEvent(of: .value, with: { (snapshot) in
				if let dictionary = snapshot.value as? [String:Any] {
					self.textLabel?.text = dictionary["name"] as? String
					if let profileImageUrl = dictionary["profileImageUrl"] as? String {
						self.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
					}
				}
			}, withCancel: nil)
		}
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		textLabel?.frame = CGRect(x: 64, y: textLabel!.frame.origin.y - 2, width: textLabel!.frame.width, height: textLabel!.frame.height)
		detailTextLabel?.frame = CGRect(x: 64, y: detailTextLabel!.frame.origin.y + 2, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
	}
	
	let profileImageView: UIImageView = {
		let imageView = UIImageView()
		// imageView.image = UIImage(named:"profile.png") I could use this to set a default image
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.layer.cornerRadius = 24
		imageView.layer.masksToBounds = true
		imageView.contentMode = .scaleAspectFill
		return imageView
	}()
	
	let timeLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: 12)
		label.textColor = UIColor.darkGray
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
		
		addSubview(profileImageView)
		addSubview(timeLabel)
		
		//ios 9 constraint anchors. In this case SELF is the entire cell class
		profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
		profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
		profileImageView.widthAnchor.constraint(equalToConstant: 48).isActive = true
		profileImageView.heightAnchor.constraint(equalToConstant: 48).isActive = true
		
		timeLabel.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
		timeLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 18).isActive = true
		timeLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
		timeLabel.heightAnchor.constraint(equalTo: (textLabel?.heightAnchor)!).isActive = true
		
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
}
