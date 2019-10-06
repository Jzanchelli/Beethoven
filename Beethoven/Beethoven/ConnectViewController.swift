//
//  ConnectViewController.swift
//  Beethoven
//
//  Created by Dan Shields on 10/6/19.
//  Copyright © 2019 Beethoven. All rights reserved.
//

import Foundation

protocol ConnectViewControllerDelegate: AnyObject {
	func connectViewController(_ viewController: ConnectViewController, didConnectTo hostname: String, at roomId: String, usingMicrophone: Bool)
}

class ConnectViewController: UIViewController {
	
	weak var delegate: ConnectViewControllerDelegate?
	
	@IBOutlet var roomId: UITextField!
	@IBOutlet var hostname: UITextField!
	@IBOutlet var microphoneToggle: UISwitch!
	
	@IBAction func connect(_ sender: Any?) {
		delegate?.connectViewController(self, didConnectTo: hostname.text ?? "", at: roomId.text ?? "", usingMicrophone: microphoneToggle.isOn)
	}
}
