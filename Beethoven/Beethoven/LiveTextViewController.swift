//
//  LiveTextViewController.swift
//  Beethoven
//
//  Created by Dan Shields on 10/6/19.
//  Copyright © 2019 Beethoven. All rights reserved.
//

import Foundation

class LiveTextViewController: UIViewController {
	
	@IBOutlet var textView: UITextView!
	
	var textListener: TextListener! {
		didSet {
			oldValue?.close()
			textListener.receive { [weak self] text, error in
				self?.receive(text ?? "")
				if let error = error {
					// TODO: Handle errors
					print("Error receiving text: \(error)")
				}
			}
		}
	}
	
	var peerConnection: PeerConnection?
	
	func receive(_ text: String) {
		textView.text = (textView.text ?? "") + text
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		textListener?.close()
	}
}
