import React from 'react';

class TranscriptionBox extends React.Component {

    constructor() {

        super();

        this.BUFFER_FILL_LEVEL = 32;
        this.state = {
            value: "",
            lastReadIndex: 0,
            bufferPieces: [],
        }

    }

    onNewBufferPiece(bufferPiece) {

        console.log("onBufferFill called");
        this.state.bufferPieces.push(bufferPiece);

    }

    onChange = (event) => {

        this.setState({
            value: event.target.value
        });

        if (this.state.value.length > this.state.lastReadIndex + this.BUFFER_FILL_LEVEL)
        {
            var bufferPiece = this.state.value.substr(this.state.lastReadIndex);
            this.state.lastReadIndex = this.state.value.length - 1;
            
            console.log("Buffer filled");
            this.onNewBufferPiece(bufferPiece);

        }

    }

    render() {
    
        return (
            <div className="form-group">
                <label htmlFor="TranscriptionBox">
                    Transcription
                </label>
                <textarea
                    className="form-control"
                    id="transcriptionTextBox"
                    rows="50"
                    value={ this.state.value }
                    onChangeCapture={ this.onChange }
                />
            </div>
        );

    }
}

export default TranscriptionBox;