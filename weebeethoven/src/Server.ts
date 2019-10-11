import { Server } from '@overnightjs/core';
import { Logger } from '@overnightjs/logger';
class BeethovenServer extends Server {
    
    private readonly SERVER_START_MSG = 'Demo server started on port: ';

    constructor() {
        super();
    }

    public start(port: number): void {
        this.app.listen(port, () => {
            Logger.Imp(this.SERVER_START_MSG + port);
        });
    }
}

export default BeethovenServer;
