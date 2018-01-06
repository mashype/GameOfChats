//
//  Extensions.swift
//  GameOfChats
//
//  Created by Seth Merritt on 12/16/17.
//  Copyright © 2017 leftyseth. All rights reserved.
//

import UIKit


//THIS IS IMPORTANT. It Caches my user images so that I do not need to download them each time the page refreshes.
let imageCache = NSCache<AnyObject, AnyObject>()

extension UIImageView {
	
	func loadImageUsingCacheWithUrlString(urlString: String) {
		//this just blanks out the image with whitespace before it downloads to prevent flashing.
		self.image = nil
		
		//check cache for image first.
		if let cachedImage = imageCache.object(forKey: urlString as AnyObject) as? UIImage {
			self.image = cachedImage
			return
		}
		
		//otherwise fire off a new download
		let url = URL(string: urlString)
		URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
			//dowload hit an error, so return error.
			if error != nil {
				print(error!.localizedDescription)
				return
			}
			DispatchQueue.main.async {
				
				if let downloadedImage = UIImage(data: data!) {
					imageCache.setObject(downloadedImage, forKey: urlString as AnyObject)
					self.image = downloadedImage
				}
				
				
				
			}
			
		}).resume() //this piece is needed to actually fire the URL session request.
		
	}
	
}
