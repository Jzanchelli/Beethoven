//
//  TextListener.swift
//  Beethoven
//
//  Created by Dan Shields on 10/6/19.
//  Copyright © 2019 Beethoven. All rights reserved.
//

import Foundation

@available(iOS 13.0, *)
class TextListener {
	let websocket: URLSessionWebSocketTask
	let queue = DispatchQueue(label: "receive")
	
	init(url: URL) throws {
		websocket = URLSession.shared.webSocketTask(with: url)
		self.websocket.resume()
		self.heartbeat()
	}
	
	func receive(callback: @escaping (String?, Error?) -> ()) {
		self.websocket.receive { [weak self] result in
			let text: String?
			let error: Error?
			if case .success(let message) = result, case .data(let data) = message {
				text = String(bytes: data, encoding: .utf8)
				error = nil
			}
			else if case .success(let message) = result, case .string(let string) = message {
				text = string
				error = nil
			}
			else if case .failure(let theError) = result {
				text = nil
				error = theError
			}
			else {
				text = nil
				error = nil
			}
			
			DispatchQueue.main.async {
				callback(text, error)
				if error == nil {
					self?.receive(callback: callback)
				}
			}
		}
	}
	
	func heartbeat() {
		websocket.sendPing { [weak self] error in
			if let error = error {
				print("Sending PING failed: \(error)")
			}
			else {
				DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
					self?.heartbeat()
				}
			}
		}
	}
	
	func close() {
		websocket.cancel(with: .normalClosure, reason: nil)
	}
}
