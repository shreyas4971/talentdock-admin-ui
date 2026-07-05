import { IUnitOfWork } from '../../infrastructure/unitOfWork/IUnitOfWork';
import { NotFoundError } from '../../domain/errors/DomainErrors';
import { IEventBus } from '../../../../events/IEventBus';
import { EventNames, EventVersions } from 'shared_events';
import { v4 as uuidv4 } from 'uuid';

export class PublishPositionCommand {
  constructor(
    public readonly positionId: string,
    public readonly correlationId: string,
    public readonly organizationId: string
  ) {}
}

export class PublishPositionUseCase {
  constructor(
    private uow: IUnitOfWork,
    private eventBus: IEventBus
  ) {}

  async execute(command: PublishPositionCommand): Promise<void> {
    await this.uow.execute(async (context) => {
      const position = await context.positions.findById(command.positionId);
      
      if (!position) {
        throw new NotFoundError(`Position ${command.positionId} not found`);
      }

      // Encapsulated domain logic enforcing state transition
      position.publish();

      // Persist the entity
      await context.positions.save(position);
    });

    // Domain event published after successful transaction commit
    await this.eventBus.publish(EventNames.CANDIDATE_APPLICATION_CREATED, {
      jobId: uuidv4(),
      eventName: 'position.published',
      eventVersion: EventVersions.V1,
      correlationId: command.correlationId,
      organizationId: command.organizationId,
      timestamp: new Date().toISOString(),
      payloadVersion: '1.0',
      data: { positionId: command.positionId }
    });
  }
}
