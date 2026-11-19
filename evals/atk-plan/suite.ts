import { headingsInOrder, md } from "../lib/checks";
import { defineSuite } from "../lib/suite";
import { designHasChangeMarkers, everyDecisionHasRisk, noCodeBlocksInSteps, redRiskImpliesL4 } from "./checks";

export default defineSuite({
  skill: "atk-plan",
  deliverable: "plan.md",
  parse: md,
  tools: ["read", "write", "grep", "glob"],
  maxCost: 2,
  fixtures: {
    "p-queue": {
      repo: "https://github.com/sindresorhus/p-queue",
      sha: "7f272ab5ff2254c0dc2537b7977e88ede1cd55e8",
      tag: "v10.0.0",
      license: "MIT",
      exclude: [".github"],
    },
  },
  format: (doc) => [
    headingsInOrder(doc, [
      "Context",
      "Goals",
      "Review effort",
      "Decisions",
      "Design",
      "Implementation steps",
      "PR's",
      "Risks",
      "Appendix: Grounded facts",
    ]),
    ...everyDecisionHasRisk(doc),
    ...redRiskImpliesL4(doc),
    ...designHasChangeMarkers(doc),
    ...noCodeBlocksInSteps(doc),
  ],
  cases: [
    {
      id: "remove-by-id",
      fixture: "p-queue",
      prompt:
        "Plan PQ-12: add a public `queue.remove(id)` so users can drop a queued task by id without wiring up an AbortSignal. Running tasks are out of scope.",
      judge: [
        "Reuses the existing PriorityQueue.remove rather than designing a new removal mechanism",
        "States what happens to the removed task's promise, consistent with clear() (AbortError)",
        "Notes that the Queue type already requires remove, so custom queueClass users aren't broken",
        "Decides the return value or no-op behavior when the id is not queued (eg already running or unknown)",
      ],
    },
    {
      id: "vague-perf",
      fixture: "p-queue",
      prompt: "adding ~100k tasks with mixed priorities is really slow. plan something",
      judge: [
        "Makes a concrete decision grounded in the code, rather than leaving the choice to the user",
        "Identifies Array#splice on enqueue as the cost and picks a concrete data structure, with at least one rejected alternative",
        "Uses or extends the repo's existing `bench.ts` (or an equivalent benchmark of many mixed-priority enqueues) to measure before and after",
        "Preserves FIFO order for equal priorities, or explicitly decides on it",
      ],
    },
    {
      id: "rename-public-api",
      fixture: "p-queue",
      prompt: "Plan PQ-15: rename `onSizeLessThan` to `onSizeBelow`.",
      judge: [
        "Rates the risk by semver breakage (public API), not by the size of the change",
        "Decides between a deprecated alias (minor) and a breaking rename (major), and says why",
        "Updates the type tests and the readme, not just the source",
      ],
    },
  ],
});
