package packageyay;

import javax.websocket.*;
import javax.websocket.server.PathParam;
import javax.websocket.server.ServerEndpoint;
import javax.websocket.server.ServerEndpointConfig;

@ServerEndpoint(value = "/rooms/{uid}/receive", configurator = Building.class)
public class WebSocketReceive{

	@OnOpen
	public void onOpen(@PathParam("uid") String uid, Session session) {
		System.out.println("Receive: " + Integer.toString(System.identityHashCode(Building.building)));
		//add you to the rooms sockets
		Building.building.addOrGetRoom(uid).addReceiveEndpoint(session.getAsyncRemote());
	}
	
	
}


