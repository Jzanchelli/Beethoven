package packageyay;

import java.util.ArrayList;

import javax.websocket.RemoteEndpoint;

public class Room {
	
	ArrayList<RemoteEndpoint.Async> receiveEndpoints = new ArrayList<RemoteEndpoint.Async>();
	//Adds a person to be sent our text
	void addReceiveEndpoint(RemoteEndpoint.Async async) {
		receiveEndpoints.add(async);
		System.out.println("Received Listening Endpoint");
		async.sendText(sb.toString());
	}
	
	//Our running transcript
	StringBuffer sb = new StringBuffer();
	
	public void addText(String text) {
		sb.append(text);
		dispatch(text);
	}
		
	public void dispatch(String text) {
		ArrayList<RemoteEndpoint.Async> toRemove = new ArrayList<RemoteEndpoint.Async>();
		for(RemoteEndpoint.Async endpoint : receiveEndpoints) {
			try {
			endpoint.sendText(text);
		    System.out.println("trying to send: " + text);  
			} catch (Exception e) {
				toRemove.add(endpoint);
				continue;
			}
		}
		for(RemoteEndpoint.Async item : toRemove) {
			receiveEndpoints.remove(item);
		}
	}
	
}
