export interface UploadResult {
  key: string;
  size: number;
  mimeType: string;
  etag: string;
}

export class R2StorageService {
  /**
   * Upload a file to R2 bucket
   */
  static async upload(
    bucket: R2Bucket,
    key: string,
    data: ArrayBuffer | ReadableStream | Uint8Array,
    options: {
      contentType?: string;
      customMetadata?: Record<string, string>;
    } = {}
  ): Promise<UploadResult> {
    const object = await bucket.put(key, data, {
      httpMetadata: {
        contentType: options.contentType || 'application/octet-stream',
      },
      customMetadata: options.customMetadata,
    });

    if (!object) {
      throw new Error(`Failed to upload object to R2 at key: ${key}`);
    }

    return {
      key: object.key,
      size: object.size,
      mimeType: options.contentType || 'application/octet-stream',
      etag: object.httpEtag,
    };
  }

  /**
   * Retrieve an object from R2
   */
  static async get(bucket: R2Bucket, key: string): Promise<R2ObjectBody | null> {
    return await bucket.get(key);
  }

  /**
   * Delete an object from R2
   */
  static async delete(bucket: R2Bucket, key: string): Promise<void> {
    await bucket.delete(key);
  }

  /**
   * Generates a structured storage path for resumes and supporting documents
   */
  static buildResumeKey(positionId: string, candidateId: string, originalFileName: string): string {
    const sanitizedFileName = originalFileName.replace(/[^a-zA-Z0-9._-]/g, '_');
    const timestamp = Date.now();
    const randomSuffix = Math.random().toString(36).substring(2, 8);
    return `resumes/${positionId}/${candidateId}/${timestamp}_${randomSuffix}_${sanitizedFileName}`;
  }

  static buildDocumentKey(applicationId: string, originalFileName: string): string {
    const sanitizedFileName = originalFileName.replace(/[^a-zA-Z0-9._-]/g, '_');
    const timestamp = Date.now();
    const randomSuffix = Math.random().toString(36).substring(2, 8);
    return `documents/${applicationId}/${timestamp}_${randomSuffix}_${sanitizedFileName}`;
  }
}
