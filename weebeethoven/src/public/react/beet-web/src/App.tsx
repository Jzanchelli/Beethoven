import React, { Component } from 'react';
import 'bootstrap/dist/css/bootstrap.min.css';
import RoomPanel from './RoomPanel';

class App extends Component
{

	render()
  {
		return (
			<div className="App">
				<header className="App-header">
          <link
            rel="stylesheet"
            href="https://maxcdn.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css"
            integrity="sha384-ggOyR0iXCbMQv3Xipma34MD+dH/1fQ784/j6cY/iJTQUOhcWr7x9JvoRxT2MZw1T"
            crossOrigin="anonymous"
          />
				</header>

        <main>

          <RoomPanel />

        </main>

			</div>
		);

	}

}

export default App;
