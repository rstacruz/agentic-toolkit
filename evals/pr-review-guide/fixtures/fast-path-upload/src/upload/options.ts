export interface UploadOptions {
  /** Reject files larger than this; defaults to 20 MB. */
  maxBytes?: number;
  /**
   * Skip thumbnails and resize to the large variant only, for callers that
   * need the upload stored quickly. Off by default.
   */
  fastPath?: boolean;
}
