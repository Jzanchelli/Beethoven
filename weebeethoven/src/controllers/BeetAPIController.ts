import { OK, BAD_REQUEST } from 'http-status-codes';
import { Controller, Get } from '@overnightjs/core';
import { Logger } from '@overnightjs/logger';
import { Request, Response } from 'express';

@Controller('api/room')
class BeetAPIController {

    private rooms = new Object();

    @Get(':code')
        private checkRoomCode(req: Request, res: Response) {
            try {
                const { code } = req.params;
                Logger.Info( code );

                var exists = code in this.rooms;

                return res.status(OK).json({
                    roomExists: exists,
                })

            }
            catch (err)
            {
                Logger.Err(err, true);
                return res.status(BAD_REQUEST).json({
                    error: err.message,
                });
            }
        }  

    @Get('join/:code')
        private joinRoom(req: Request, res: Response) 
        {
            try {
                return;
            }
            catch (err)
            {
                Logger.Err(err, true);
                return res.status(BAD_REQUEST).json({
                    error: err.message,
                });
            }

        }

}


export default BeetAPIController;
