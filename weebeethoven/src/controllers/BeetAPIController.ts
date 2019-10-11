import { OK, BAD_REQUEST } from 'http-status-codes';
import { Controller, Get } from '@overnightjs/core';
import { Logger } from '@overnightjs/logger';
import { Request, Response } from 'express';

@Controller('api/say-hello')
class BeetAPIController {

  public static readonly SUCCESS_MSG = 'Hello, ';

  @Get(':name')
  private sayHello(req: Request, res: Response) {

    try {

      // Pull the name from the request's parameters
      const { name } = req.params;

      // If the name is specifically "make_it_fail" throw error			
      if (name === "make_it_fail")
      {
        throw Error('User Triggered Failure')
      }
      
      // Log the success and name.
      Logger.Info(BeetAPIController.SUCCESS_MSG + name);

      return res.status(OK).json(
        {
          message: BeetAPIController.SUCCESS_MSG + name,
        });
    }
    catch (err)
    {
      Logger.Err(err, true);

      return res.status(BAD_REQUEST).json(
          {
              error: err.message,
          });

    }
  }
}

export default BeetAPIController;
