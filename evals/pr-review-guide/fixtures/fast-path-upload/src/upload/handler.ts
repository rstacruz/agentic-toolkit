import type { Request, Response } from "../http/types";
import { runUploadPipeline } from "./pipeline";

const MAX_BYTES = 20 * 1024 * 1024;

export async function handleUpload(req: Request, res: Response) {
  if (!req.file) return res.status(400).json({ error: "missing file" });
  const record = await runUploadPipeline(req.file, {
    maxBytes: MAX_BYTES,
    fastPath: req.query.fast === "1",
  });
  res.status(201).json(record);
}
