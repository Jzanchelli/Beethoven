import React from 'react';
import TranscriptionBox from './components/TranscriptionBox.js'
import ConnectionPanel from './components/ConnectionPanel.js'

function App() {
  return (
    <div class="App">
      <div class="container">
        <h1>
          It's Typing Time, Motherfuckers!
        </h1>

        <TranscriptionBox />
        <ConnectionPanel />

      </div>

    </div>
  );
}

export default App;
