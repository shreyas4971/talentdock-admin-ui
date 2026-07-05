// src/interfaces/StorageProvider.ts
export interface IStorageProvider {
  uploadFile(buffer: Buffer, key: string, mimeType: string): Promise<string>;
  downloadFile(key: string): Promise<Buffer>;
  deleteFile(key: string): Promise<void>;
}

// src/interfaces/NotificationProvider.ts
export interface INotificationProvider {
  sendEmail(to: string, subject: string, html: string): Promise<void>;
  sendSMS(to: string, message: string): Promise<void>;
}

// src/interfaces/SearchProvider.ts
export interface ISearchProvider {
  indexDocument(indexName: string, document: any): Promise<void>;
  search(indexName: string, query: string, filters?: any): Promise<any[]>;
}

// src/interfaces/AIProvider.ts
export interface IAIProvider {
  generateText(prompt: string, maxTokens?: number): Promise<string>;
  extractJSON<T>(prompt: string, schema: any): Promise<T>;
}

// src/interfaces/AuthProvider.ts
export interface IAuthProvider {
  hashPassword(password: string): Promise<string>;
  comparePassword(password: string, hash: string): Promise<boolean>;
  generateToken(payload: any): string;
  verifyToken(token: string): any;
}
