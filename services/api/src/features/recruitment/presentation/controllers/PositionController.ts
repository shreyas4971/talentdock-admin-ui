import { Request, Response, NextFunction } from 'express';
import { PublishPositionUseCase, PublishPositionCommand } from '../../application/commands/PublishPositionUseCase';
import { IUnitOfWork } from '../../infrastructure/unitOfWork/IUnitOfWork';
import { PrismaUnitOfWork } from '../../infrastructure/unitOfWork/PrismaUnitOfWork';
import { eventBus } from '../../../../events/dispatcher';
import { ApiSuccessResponse } from 'shared_contracts';

const uow: IUnitOfWork = new PrismaUnitOfWork();
const publishPositionUseCase = new PublishPositionUseCase(uow, eventBus);

export class PositionController {
  static async publish(req: Request, res: Response, next: NextFunction) {
    try {
      const positionId = req.params.id;
      const correlationId = req.id;
      const organizationId = 'org-123'; // Mocked auth
      
      const command = new PublishPositionCommand(positionId, correlationId, organizationId);
      await publishPositionUseCase.execute(command);
      
      const response: ApiSuccessResponse<null> = {
        success: true,
        requestId: correlationId,
        message: 'Position published successfully',
        data: null
      };

      res.status(200).json(response);
    } catch (error) {
      next(error);
    }
  }
}
