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
	let defaultConstraints = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: nil)
	let webSocket: URLSessionWebSocketTask
	
	required init?(to url: URL, roomCode: String) throws {
		webSocket = URLSession.shared.webSocketTask(with: url)
		webSocket.resume()
		
		super.init()
		guard let compressedData = Data(base64Encoded: roomCode) else { return nil }

		var index = 0
		let bufferSize = compressedData.count
		let inputFilter = try InputFilter(.decompress, using: .zlib) { length -> Data? in
			let rangeLength = min(length, bufferSize - index)
			let subdata = compressedData.subdata(in: index ..< index + rangeLength)
			index += rangeLength
			
			return subdata
		}
		
		var data = Data()
		while let page = try inputFilter.readData(ofLength: 256) {
			data.append(page)
		}
		
		guard let json = try JSONSerialization.jsonObject(with: data) as? Array<[AnyHashable : Any]> else { return nil }
		
		let rtcConfig = RTCConfiguration()
		rtcConfig.iceServers = json.map { RTCIceServer(fromJSONDictionary: $0) }
		
		peerConnection = factory.peerConnection(
			with: rtcConfig,
			constraints: RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: nil),
			delegate: self)
		
		initiateNegotiation { error in
			print("Finished negotiation")
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
	func jsonDictionary() throws -> [AnyHashable: Any] {
		switch self {
		case .string(let string):
			return try JSONSerialization.jsonObject(with: string.data(using: .utf8)!) as! [AnyHashable: Any]
			
		case .data(let data):
			return try JSONSerialization.jsonObject(with: data) as! [AnyHashable: Any]
			
		@unknown default:
			fatalError()
		}
	}
}

@available(iOS 13, *)
extension PeerConnection: RTCPeerConnectionDelegate {
	func peerConnectionShouldNegotiate(_ peerConnection: RTCPeerConnection) {
		initiateNegotiation { error in
			print("Finished negotiation")
		}
	}
	
	func peerConnection(_ peerConnection: RTCPeerConnection, didChange stateChanged: RTCSignalingState) {
		
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
		
	}
	
	func peerConnection(_ peerConnection: RTCPeerConnection, didRemove candidates: [RTCIceCandidate]) {
		
	}
	
	func peerConnection(_ peerConnection: RTCPeerConnection, didOpen dataChannel: RTCDataChannel) {
		
	}
}
