import { EventName } from 'shared_events';

export interface IEventBus {
  publish(eventName: EventName, payload: any): Promise<void>;
  subscribe(eventName: EventName, handler: (payload: any) => Promise<void>): void;
}
