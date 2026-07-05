import { IStorageProvider, INotificationProvider, ISearchProvider, IAIProvider } from './interfaces';

export class LocalStorageProvider implements IStorageProvider {
  async uploadFile(buffer: Buffer, key: string, mimeType: string): Promise<string> { return `local://${key}`; }
  async downloadFile(key: string): Promise<Buffer> { return Buffer.from(''); }
  async deleteFile(key: string): Promise<void> {}
}

export class MockNotificationProvider implements INotificationProvider {
  async sendEmail(to: string, subject: string, html: string): Promise<void> { console.log(`Mock Email sent to ${to}`); }
  async sendSMS(to: string, message: string): Promise<void> { console.log(`Mock SMS sent to ${to}`); }
}

export class PostgresSearchProvider implements ISearchProvider {
  async indexDocument(indexName: string, document: any): Promise<void> {}
  async search(indexName: string, query: string, filters?: any): Promise<any[]> { return []; }
}

export class MockAIProvider implements IAIProvider {
  async generateText(prompt: string, maxTokens?: number): Promise<string> { return "Mock AI Response"; }
  async extractJSON<T>(prompt: string, schema: any): Promise<T> { return {} as T; }
}

// Simple DI Container
export class DIContainer {
  static storage: IStorageProvider = new LocalStorageProvider();
  static notification: INotificationProvider = new MockNotificationProvider();
  static search: ISearchProvider = new PostgresSearchProvider();
  static ai: IAIProvider = new MockAIProvider();
}
