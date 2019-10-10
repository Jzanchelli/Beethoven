import React from 'react';
import Form from 'react-bootstrap/Form';
import Button from 'react-bootstrap/Button';

class ConnectionPanel extends React.Component {

    constructor() {

        super();

        this.state = {
            socketURL: "ws://HOSTNAME/rooms/ROOMNAME/interpreter",
            socketOpen: false,
            socket: null,
            peerConnection: null,
            lastMessageReceived: "",
        }

    }

    onSocketMessage = (event) => {

        var data = event.data

        console.log(event.data);
        this.setState({lastMessageReceived: data});

        var messageReceived = JSON.parse(data);
        
        if (messageReceived.type = "offer") {

            // init potential new peer connection and my SDP
            var newPeerCon = new RTCPeerConnection();

            // receive SDP
            console.log(JSON.stringify(messageReceived));
            newPeerCon.setRemoteDescription(new RTCSessionDescription(messageReceived));
            
            // Send my SDP over socket
            newPeerCon.createOffer().then(offer => {
                offer.type = "answer";
                this.state.socket.send(JSON.stringify(offer));
            })

        }
        elseif (messageReceived.type = "candidate")
        {

            

        }

            // receive ICE candidates


            // add ICE Candidates to peer connection object


            // do a thing every time I receive an ICE Candidate

    }

    configurePeerConnection() {

        // Possibly make promise


        // create RTC config


        // create peer connection

    }

    requestTURNServers() {

        //

    }

    onICECandidateReceived() {

        // Send candidate through socket

    }

    onOpenSocketRequest = (event) => {

        if (!this.state.socketOpen) {
        
            this.setState({socketOpen: true});

            console.log("Socket opening...");

            var newSocket = new WebSocket(this.state.socketURL);

            // i do not know why but if this is not here, the websocket does not connect properly so please don't delete it
            var testInteger = 7;

            newSocket.onmessage = this.onSocketMessage;

            // Remember my socket
            this.setState({socket: newSocket});

        }

        return;

    }

    onURLUpdate = event => {


        if (!this.state.socketOpen) {

            this.setState({socketURL: event.target.value})

        }

        return;

    }

    render() {
        
        return (

            <Form>
                <Form.Group controlId="formUrl">
                    <Form.Label>Socket URL</Form.Label>
                    <Form.Control 
                                  onChange={ this.onURLUpdate }
                                  value={ this.state.socketURL } />
                </Form.Group>

                <Button
                    variant="primary"
                    onClick={ this.onOpenSocketRequest }
                    disabled={ this.state.socketOpen }
                >
                    Open Socket
                </Button>

                <Form.Group controlId="formConnMessage">

                    <Form.Label>Socket Message</Form.Label>
                    <Form.Control value={ this.state.lastMessageReceived } />

                </Form.Group>
            </Form>

        );

    }

}

export default ConnectionPanel;