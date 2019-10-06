//
//  PeerConnection.swift
//  Beethoven
//
//  Created by Dan Shields on 10/5/19.
//  Copyright © 2019 Beethoven. All rights reserved.
//

import Foundation
import WebRTC
import Compression

let dummyError = NSError(domain: "TODO", code: -1, userInfo: nil)

@available(iOS 13, *)
class PeerConnection: NSObject {
	
	let factory = RTCPeerConnectionFactory()
	var peerConnection: RTCPeerConnection!
	// We require the other endpoint can receive media
	let defaultConstraints = RTCMediaConstraints(mandatoryConstraints: [kRTCMediaConstraintsOfferToReceiveAudio: kRTCMediaConstraintsValueFalse, kRTCMediaConstraintsOfferToReceiveVideo: kRTCMediaConstraintsValueFalse], optionalConstraints: nil)
	let webSocket: URLSessionWebSocketTask
	
	required init?(to hostname: String, roomId: String) throws {
		// Our signaling server connects us to the interpreter who we send audio to
		webSocket = URLSession.shared.webSocketTask(with: URL(string: "ws://\(hostname)/rooms/\(roomId)/microphone")!)
		webSocket.resume()
		super.init()
		
		configurePeerConnection { [weak self] error in
			guard error != nil else { print("Failed to configure peer connection: \(error!)"); return }
			self?.initiateNegotiation { error in
				guard error != nil else { print("Failed to initiate negotation: \(error!)"); return }
				print("Finished negotiation")
				self?.receiveIceCandidates { error in
					if let error = error {
						print("Error receiving ice candidates: \(error)")
					}
				}
			}
		}
	}
	
	func requestTURNServers(at url: URL, completion: @escaping ([RTCIceServer]?, Error?) -> Void) {
		var request = URLRequest(url: url)
		request.addValue("Mozilla/5.0", forHTTPHeaderField: "user-agent")
		request.addValue("origin", forHTTPHeaderField: "https://apprtc.appspot.com")
		URLSession.shared.dataTask(with: request) { data, response, error in
			guard let data = data else { completion(nil, error); return }
			guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { completion(nil, dummyError); return }
			completion(RTCIceServer.servers(fromCEODJSONDictionary: json), nil)
		}
	}
	
	func configurePeerConnection(completion: @escaping (Error?) -> ()) {
		let stunServer = RTCIceServer(urlStrings: ["stun:stun.l.google.com:19302"])
		requestTURNServers(at: URL(string: "https://computeengineondemand.appspot.com/turn?username=iapprtc&key=4080218913")!)
		{ [weak self] (turnServers, error) in
			if let error = error {
				print("Warning: Error requesting turn servers: \(error)")
			}
			
			let configuration = RTCConfiguration()
			configuration.iceServers = [stunServer] + (turnServers ?? [])
			guard let self = self else { return }
			
			self.peerConnection = self.factory.peerConnection(with: configuration, constraints: self.defaultConstraints, delegate: self)
			
			// Add an audio stream so we can negotatiate audio with SDPs
			let track = self.factory.audioTrack(withTrackId: "AUD0")
			let sender = self.peerConnection.add(track, streamIds: ["AUD"])
		}
	}
	
	func receiveIceCandidates(completion: @escaping (Error?) -> ()) {
		webSocket.receive { [weak self] result in
			guard case .success(let message) = result,
				case .string(let string) = message,
				let data = string.data(using: .utf8),
				let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
				let candidate = RTCIceCandidate(fromJSONDictionary: json)
			else {
				completion(dummyError)
				return
			}
			
			self?.peerConnection.add(candidate)
			// Only continue listening for ice candidates if we don't have a connection already
			if self!.peerConnection.iceConnectionState != .completed
				&& self!.peerConnection.iceConnectionState != .failed
				&& self!.peerConnection.iceConnectionState != .disconnected
				&& self!.peerConnection.iceConnectionState != .closed
			{
				self?.receiveIceCandidates(completion: completion)
			}
			else {
				completion(nil)
			}
		}
	}
		
	/// Start signaling
	func initiateNegotiation(completion: @escaping (Error?) -> ()) {
		peerConnection.offer(for: defaultConstraints) { [weak self] sdp, error in
			guard error != nil, let sdp = sdp else { completion(error!); return }
			self?.peerConnection.setLocalDescription(sdp) { error in
				guard error != nil else { completion(error!); return }
				self?.sendSDP(sdp) { error in
					guard error != nil else { completion(error!); return }
					self?.receiveSDP { sdp, error in
						guard error != nil, let sdp = sdp else { completion(error!); return }
						self?.peerConnection.setRemoteDescription(sdp) { error in
							completion(error)
						}
					}
				}
			}
		}
	}
	
	func awaitNegotiation(completion: @escaping (Error?) -> ()) {
		receiveSDP { [weak self] sdp, error in
			guard error != nil, let sdp = sdp else { completion(error!); return }
			self?.peerConnection.setRemoteDescription(sdp) { error in
				guard error != nil else { completion(error!); return }
				self?.peerConnection.answer(for: self!.defaultConstraints) { sdp, error in
					guard error != nil, let sdp = sdp else { completion(error!); return }
					self?.peerConnection.setLocalDescription(sdp) { error in
						guard error != nil else { completion(error!); return }
						self?.sendSDP(sdp) { error in
							completion(error)
						}
					}
				}
			}
		}
	}
	
	func sendSDP(_ sdp: RTCSessionDescription, completion: @escaping (Error?) -> ()) {
		peerConnection.setLocalDescription(sdp) { [weak self] error in
			guard error != nil else { completion(error!); return }
			guard let jsonString = sdp.jsonData().flatMap({ String(bytes: $0, encoding: .utf8) }) else { completion(dummyError); return }
			self?.webSocket.send(.string(jsonString)) { error in
				guard error == nil else { completion(error!); return }
				completion(nil)
			}
		}
	}
	
	func receiveSDP(completion: @escaping (RTCSessionDescription?, Error?) -> ()) {
		webSocket.receive { [weak self] result in
			guard case .success(let result) = result else { completion(nil, dummyError); return }
			let sdp = RTCSessionDescription(fromJSONDictionary: try! result.jsonDictionary())!
			
			self?.peerConnection.setRemoteDescription(sdp) { error in
				guard error != nil else { completion(nil, dummyError); return }
				completion(sdp, nil)
			}
		}
	}
}

@available(iOS 13, *)
extension URLSessionWebSocketTask.Message {
	func jsonDictionary() throws -> [String: Any] {
		switch self {
		case .string(let string):
			return try JSONSerialization.jsonObject(with: string.data(using: .utf8)!) as! [String: Any]
			
		case .data(let data):
			return try JSONSerialization.jsonObject(with: data) as! [String: Any]
			
		@unknown default:
			fatalError()
		}
	}
}

@available(iOS 13, *)
extension PeerConnection: RTCPeerConnectionDelegate {
	func peerConnectionShouldNegotiate(_ peerConnection: RTCPeerConnection) {
		print("Should negotiate for some reason?")
	}
	
	func peerConnection(_ peerConnection: RTCPeerConnection, didChange stateChanged: RTCSignalingState) {
		print("Signaling state changed: \(peerConnection)")
	}
	
	func peerConnection(_ peerConnection: RTCPeerConnection, didAdd stream: RTCMediaStream) {
		
	}
	
	func peerConnection(_ peerConnection: RTCPeerConnection, didRemove stream: RTCMediaStream) {
		
	}
	
	func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceConnectionState) {
		
	}
	
	func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceGatheringState) {
		
	}
	
	func peerConnection(_ peerConnection: RTCPeerConnection, didGenerate candidate: RTCIceCandidate) {
		guard let json = String(data: candidate.jsonData(), encoding: .utf8) else { print("Failed to convert json to string"); return  }
		webSocket.send(.string(json)) { error in
			if let error = error {
				print("Failed to send ice candidate: \(error)")
			}
		}
	}
	
	func peerConnection(_ peerConnection: RTCPeerConnection, didRemove candidates: [RTCIceCandidate]) {
		
	}
	
	func peerConnection(_ peerConnection: RTCPeerConnection, didOpen dataChannel: RTCDataChannel) {
		
	}
}
