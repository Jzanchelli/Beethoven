//
//  ViewController.swift
//  Beethoven
//
//  Created by Dan Shields on 10/6/19.
//  Copyright © 2019 Beethoven. All rights reserved.
//

import UIKit

class TranscriptsViewController: UITableViewController {
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		// TODO: Open the transcript
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1; // TODO
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 0; // TODO
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "Transcript") ?? UITableViewCell(style: .default, reuseIdentifier: "Transcript")
		// TODO: Set up the cell
		return cell
	}
}


extension TranscriptsViewController: ConnectViewControllerDelegate {
	func connectViewController(_ viewController: ConnectViewController, didConnectTo url: URL) {
		guard let viewController = storyboard?.instantiateViewController(identifier: "LiveTextViewController") as? LiveTextViewController else { fatalError() }
		dismiss(animated: true)
		viewController.loadViewIfNeeded()
		viewController.textListener = try! TextListener(url: url)
		navigationController?.pushViewController(viewController, animated: true)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let destination = segue.destination as? ConnectViewController {
			destination.delegate = self
		}
	}
}
