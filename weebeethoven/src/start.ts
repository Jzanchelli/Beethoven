import BeethovenServer from './Server';

// Start the server or run tests
if ( process.argv[2] !== 'test' ) 
{
  let server: BeethovenServer = new BeethovenServer();
  server.start(8080);
  
}
