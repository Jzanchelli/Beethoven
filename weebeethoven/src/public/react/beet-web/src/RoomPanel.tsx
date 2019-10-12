import React, { Component } from 'react';
import { Button, Form }     from 'react-bootstrap';

class RoomPanel extends Component {

    private static ROOM_STATE_CREATE = 0;
    private static ROOM_STATE_CHECKING = 1
    private static ROOM_STATE_JOIN   = 2;
    private static ROOM_STATE_LEAVE  = 3;
    private static ROOM_STATE_OFFLINE = 4;
    

    private static ROOM_STATE_STRINGS: string[] = [
        "Create Room",
        "Checking Room...",
        "Join Room",
        "Leave Room",
        "Room Server Not Responding",
    ];

    /**
     * Current state of the RoomPanel
     * 
     * room: string representing room code
     * roomState: 
     *  0 if ready to create
     *  1 if in checking process
     *  2 if ready to join
     *  3 if ready to leave
     *  4 if server is offline
     */
    state = 
    {
        room: '',
        roomState: RoomPanel.ROOM_STATE_CREATE,

        roomServerIP: '',
        parentProps: null,
    }

    constructor(props: any)
    {
        super(props);
        this.state.roomServerIP = props.roomServerIP;
        this.state.parentProps  = props;
    }

    /**
     * Checks to see if a room of the current room code exists on the room server.
     */
    async checkRoom(room: string) {

        // Do nothing if empty room string.
        if (room === "")
        {
            return;
        }

        // Begin checking room
        this.setRoomState(RoomPanel.ROOM_STATE_CHECKING);
        console.log("Checking for room: " + room);

        try {

            var callTo: string = `/api/room/${ room }`;
            console.log(callTo);
            let response = await fetch(callTo)
                                .then(res => res.json());

            var roomExists: boolean = response.roomExists;

            if (roomExists)
            {
                this.setRoomState(RoomPanel.ROOM_STATE_JOIN);
            }
            else
            {
                this.setRoomState(RoomPanel.ROOM_STATE_CREATE);
            }

        }
        catch (err)
        {
            this.setRoomState(RoomPanel.ROOM_STATE_OFFLINE);
            console.log(err);
        }

        return;

    }

    /**
     * Sets the room state to the provided integer
     *  
     * @param stateNum number representing current roomPanel state
     */
    setRoomState(stateNum: number)
    {
        this.setState({roomState: stateNum});
    }

    /**
     * Attempts to join the current room.
     */
    joinRoom() 
    {
        this.setRoomState(RoomPanel.ROOM_STATE_LEAVE);
    }

    /**
     * Disconnects from the current room
     */
    leaveRoom()
    {
        this.checkRoom(this.state.room);
    }

    /**
     * Event for when the panel's room button is clicked
     */
    onRoomButtonClick = (event : any) => 
    {

        switch(this.state.roomState)
        {
            case RoomPanel.ROOM_STATE_CHECKING:
                break;
            
            case RoomPanel.ROOM_STATE_CREATE:
                this.joinRoom();
                break;

            case RoomPanel.ROOM_STATE_JOIN:
                this.joinRoom();
                break;

            case RoomPanel.ROOM_STATE_LEAVE:
                this.leaveRoom();
                break;
            
        }

    }

    /**
     * Event for when the room code changes
     */
    onRoomCodeChange = (event: any) =>
    {
        var newRoomCode: string = event.target.value;
        this.setState({ room: newRoomCode });

        // TODO: Find way to check room less
        this.checkRoom( newRoomCode );
    }

    /**
     * Renders the RoomPanel
     */
    render()
    {
        return(
            <Form>
                <Form.Group controlId="formRoomCode">
                    <Form.Label>Room Code</Form.Label>
                    <Form.Control
                        type="text"
                        placeholder="MyRoomCode"
                        onChangeCapture={ this.onRoomCodeChange }
                        disabled={ this.state.roomState === RoomPanel.ROOM_STATE_LEAVE }
                    />
                </Form.Group>

                <Button
                    onClick = { this.onRoomButtonClick }
                    disabled={ this.state.roomState === RoomPanel.ROOM_STATE_CHECKING ||
                               this.state.roomState === RoomPanel.ROOM_STATE_OFFLINE }
                >
                    { RoomPanel.ROOM_STATE_STRINGS[this.state.roomState] }
                </Button>
            </Form>
        );
    }

}

export default RoomPanel;