import BeethovenServer from './Server';

// Start the server or run tests
if ( process.argv[2] !== 'test' ) 
{
	let server = new BeethovenServer();
  server.start(3000);
}
