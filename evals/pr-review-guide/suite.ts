import { defineSuite } from "../lib/suite";
import {
  hotspotRefs,
  lightBackground,
  panelsNumbered,
  safetyChecklist,
  skippedStepStyled,
  svg,
} from "./checks";

export default defineSuite({
  skill: "pr-review-guide",
  // Guide is written too so D#/FP# refs resolve; ungraded
  deliverable: "infographic.svg",
  parse: svg,
  tools: ["read", "write", "grep", "glob"],
  maxCost: 2,
  format: (s) => [
    panelsNumbered(s),
    ...skippedStepStyled(s),
    ...hotspotRefs(s),
    safetyChecklist(s),
    lightBackground(s),
  ],
  judge: [
    "Draws the changed pipeline as its real steps in code order, as a before row and an after row, with the skipped and narrowed steps styled in place rather than described in a list",
    "Has a review hotspots panel whose cards carry an amber `!` marker and a reference to a decision or feedback point (D#, FP#), and leaves trivial plumbing off it",
    "States the PR's no-change claim for the default path as a short checklist (✅ or ✓ marks) of what stays identical, plus what verifies it (eg, the test that pins it)",
    "Apart from the title and subheading, no panel restates a fact another panel already shows: each panel answers a different question",
    "A single count that drops to zero is shown as a big-number label, not as a one-row bar chart (bar charts comparing several numbers are fine)",
  ],
  cases: [
    {
      id: "fast-path-upload",
      prompt:
        "Write the PR review guide for the pull request in pr.json, with an at-a-glance SVG infographic a reviewer can understand without reading the guide.",
      judge: [
        "The before/after rows list validate, scanForMalware, resizeVariants, generateThumbnails, putObject, saveRecord in that order",
        "generateThumbnails is styled as skipped on the after row, and resizeVariants is styled as narrowed with a 'large only' sublabel",
        "The hotspots panel references D2 (skipping thumbnails) and D3 (narrowed resize)",
        "The thumbnail-jobs count 3 → 0 appears as a large number, not a bar",
      ],
    },
  ],
});
