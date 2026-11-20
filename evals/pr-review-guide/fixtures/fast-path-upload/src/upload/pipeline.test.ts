import { beforeEach, expect, test, vi } from "vitest";
import { runUploadPipeline } from "./pipeline";

const { calls, step } = vi.hoisted(() => {
  const calls: string[] = [];
  const step =
    (name: string, result?: unknown) =>
    (..._args: unknown[]) => {
      calls.push(name);
      return result;
    };
  return { calls, step };
});

vi.mock("./validate", () => ({ validate: step("validate") }));
vi.mock("../security/scan", () => ({ scanForMalware: step("scanForMalware") }));
vi.mock("../images/transform", () => ({
  resizeVariants: step("resizeVariants", [{ name: "large" }]),
  generateThumbnails: step("generateThumbnails", []),
}));
vi.mock("../storage/objects", () => ({ putObject: step("putObject", "uploads/abc") }));
vi.mock("../db/uploads", () => ({ saveRecord: step("saveRecord") }));

const file = { name: "cat.jpg", mimeType: "image/jpeg", bytes: new Uint8Array(8) };

beforeEach(() => {
  calls.length = 0;
});

test("default options run every step in the same order as before", async () => {
  await runUploadPipeline(file, {});
  expect(calls).toEqual([
    "validate",
    "scanForMalware",
    "resizeVariants",
    "generateThumbnails",
    "putObject",
    "saveRecord",
  ]);
});

test("fastPath skips thumbnails", async () => {
  await runUploadPipeline(file, { fastPath: true });
  expect(calls).toEqual(["validate", "scanForMalware", "resizeVariants", "putObject", "saveRecord"]);
});
