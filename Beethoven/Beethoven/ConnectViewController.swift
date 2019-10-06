//
//  ConnectViewController.swift
//  Beethoven
//
//  Created by Dan Shields on 10/6/19.
//  Copyright © 2019 Beethoven. All rights reserved.
//

import Foundation

protocol ConnectViewControllerDelegate: AnyObject {
	func connectViewController(_ viewController: ConnectViewController, didConnectTo url: URL)
}

class ConnectViewController: UIViewController {
	
	weak var delegate: ConnectViewControllerDelegate?
	
	@IBOutlet var roomId: UITextField!
	@IBOutlet var hostname: UITextField!
	
	@IBAction func connect(_ sender: Any?) {
		guard let url = URL(string: "ws://\(hostname.text ?? "")/rooms/\(roomId.text ?? "")/receive") else { return }
		delegate?.connectViewController(self, didConnectTo: url)
	}
}
