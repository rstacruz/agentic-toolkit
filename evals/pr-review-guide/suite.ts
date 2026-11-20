import { defineSuite } from "../lib/suite";
import {
  beforeAfterRow,
  hotspotRefs,
  lightBackground,
  panelsNumbered,
  safetyChecklist,
  skippedStepStyled,
  svg,
} from "./checks";

export default defineSuite({
  skill: "pr-review-guide",
  // the guide is written too, so D#/FP# refs have a target, but only the infographic is graded
  deliverable: "infographic.svg",
  parse: svg,
  tools: ["read", "write", "grep", "glob"],
  maxCost: 2,
  format: (s) => [
    panelsNumbered(s),
    beforeAfterRow(s),
    ...skippedStepStyled(s),
    ...hotspotRefs(s),
    safetyChecklist(s),
    lightBackground(s),
  ],
  // the infographic structure rules, graded for both arms on every case
  judge: [
    "Draws the changed pipeline as its real steps in code order, as a before row and an after row, with the skipped and narrowed steps styled in place rather than described in a list",
    "Has a review hotspots panel whose cards carry an amber `!` marker and a reference to a decision or feedback point (D#, FP#), and leaves trivial plumbing off it",
    "States the PR's no-change claim for the default path as a short ✅ checklist of what stays identical, plus how it was verified",
    "No fact is restated across panels: each panel answers a different question",
    "A single count that drops to zero is shown as a big-number label, not as a one-row bar chart",
  ],
  cases: [
    {
      id: "fast-path-upload",
      prompt:
        "Write the PR review guide for the pull request in pr.json, with an at-a-glance SVG infographic a reviewer can understand without reading the guide.",
      judge: [
        "The before/after rows list validate, scanForMalware, resizeVariants, generateThumbnails, putObject, saveRecord in that order",
        "generateThumbnails is marked skipped on the after row and resizeVariants is marked narrowed (large only)",
        "The hotspots panel references D2 (skipping thumbnails) and D3 (narrowed resize), and the unauthenticated query-string opt-in in handler.ts",
        "The thumbnail-jobs count 3 → 0 appears as a large number, not a bar",
      ],
    },
  ],
});
