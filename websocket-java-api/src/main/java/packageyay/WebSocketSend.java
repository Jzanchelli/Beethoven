package packageyay;

import javax.websocket.EndpointConfig;
import javax.websocket.OnMessage;
import javax.websocket.OnOpen;
import javax.websocket.Session;
import javax.websocket.server.PathParam;
import javax.websocket.server.ServerEndpoint;
import javax.websocket.server.ServerEndpointConfig;

@ServerEndpoint(value = "/rooms/{uid}/send", configurator = Building.class)
public class WebSocketSend {
	
	Room room = null;
	
	@OnOpen
	public void onOpen(@PathParam("uid") String uid, Session session) {
		System.out.println("Send: " + Integer.toString(System.identityHashCode(Building.building)));

		Building.building.addOrGetRoom(uid);
		room = Building.building.addOrGetRoom(uid);
	}
	
	@OnMessage
	public void handleTextMessage(String message) {
	    System.out.println("NEW TEXT RECEIVED: " + message);  
	    room.addText(message);
	}
}
