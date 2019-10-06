package packageyay;
import java.util.concurrent.ConcurrentHashMap;
import java.util.UUID;

import javax.websocket.server.ServerEndpointConfig;

public class Building extends ServerEndpointConfig.Configurator{
	
    private final ConcurrentHashMap<String, Room> rooms = new ConcurrentHashMap<>();

    public static Building building = new Building();
    
    private String newId() {
        return UUID.randomUUID().toString();
    } 
	
    public Room addOrGetRoom(String uID) {
    	if(rooms.containsKey(uID)) {
    		return rooms.get(uID);
    	} else {
        	Room newRoom = new Room();
        	rooms.put(uID, newRoom);
        	return newRoom;
    	}
    }
	
	
}
