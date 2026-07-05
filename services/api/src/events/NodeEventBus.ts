import { EventEmitter } from 'events';
import { IEventBus } from './IEventBus';
import { EventName } from 'shared_events';

export class NodeEventBus implements IEventBus {
  private emitter = new EventEmitter();

  async publish(eventName: EventName, payload: any): Promise<void> {
    this.emitter.emit(eventName, payload);
  }

  subscribe(eventName: EventName, handler: (payload: any) => Promise<void>): void {
    this.emitter.on(eventName, async (payload) => {
      try {
        await handler(payload);
      } catch (error) {
        console.error(`Error processing event ${eventName}:`, error);
      }
    });
  }
}
