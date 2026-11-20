import { saveRecord } from "../db/uploads";
import { generateThumbnails, resizeVariants } from "../images/transform";
import { scanForMalware } from "../security/scan";
import { putObject } from "../storage/objects";
import type { UploadOptions } from "./options";
import { validate } from "./validate";

export const VARIANTS = ["large", "medium", "small"] as const;
export const THUMBNAIL_SIZES = [64, 128, 256] as const;

export interface UploadedFile {
  name: string;
  mimeType: string;
  bytes: Uint8Array;
}

/** Steps run in order; each one throws to abort the upload. */
export async function runUploadPipeline(file: UploadedFile, opts: UploadOptions) {
  validate(file, opts);
  await scanForMalware(file);
  const variants = await resizeVariants(file, opts.fastPath ? ["large"] : VARIANTS);
  const thumbnails = opts.fastPath ? [] : await generateThumbnails(file, THUMBNAIL_SIZES);
  const key = await putObject(file, [...variants, ...thumbnails]);
  return saveRecord({
    key,
    name: file.name,
    variants: variants.map((v) => v.name),
    thumbnails: thumbnails.length,
  });
}
