#!/usr/bin/env bun
import { $ } from "bun";
import { parseArgs } from "node:util";
import { exists, mkdtemp, readdir, rm } from "node:fs/promises";
import { tmpdir } from "node:os";
import { z } from "zod";
import { lockdown, parseTranscript } from "./omp";
import type { Case, Result, Suite } from "./suite";

const ROOT = `${import.meta.dir}/..`;
const { values: opt, positionals: [skill] } = parseArgs({
  args: Bun.argv.slice(2),
  allowPositionals: true,
  options: { iteration: { type: "string" }, "judge-model": { type: "string" } },
});
const judgeModel = opt["judge-model"];
if (!skill || !opt.iteration) throw new Error("usage: grade.ts <skill> --iteration N --judge-model p/m");
if (!judgeModel?.includes("/")) throw new Error("--judge-model must be an exact provider/model ID");

const suite: Suite<unknown> = (await import(`${ROOT}/${skill}/suite.ts`)).default;
const ws = `${ROOT}/.workspace/${skill}/iteration-${opt.iteration}`;
const ARMS = ["with_skill", "without_skill"] as const;
type Arm = (typeof ARMS)[number];

const Input = z.object({ model: z.string() });
const RunJson = z.object({
  status: z.enum(["completed", "incomplete"]),
  changed: z.array(z.string()).default([]),
  cwd: z.string().optional(),
  tools_used: z.array(z.string()).default([]),
  skill_file: z.string().nullable().default(null),
  uris_read: z.array(z.string()).default([]),
});
const JudgeOut = z.array(z.object({ criterion: z.number().int(), passed: z.boolean(), evidence: z.string() }));
const JudgeJson = z.object({ key: z.string(), model: z.string(), results: JudgeOut });

type Grading = {
  outcome: "scored" | "unusable" | "incomplete" | "judge_error";
  reason: string | null;
  behavior: Result[];
  format: Result[];
  behavior_score: number | null;
  format_score: number | null;
  judge_error: string | null;
};

const score = (rows: Result[]) => (rows.length ? rows.filter((x) => x.passed).length / rows.length : null);
const mean = (xs: number[]) => (xs.length ? xs.reduce((a, b) => a + b, 0) / xs.length : null);

async function gradeArm(c: Case<unknown>, arm: Arm, dir: string): Promise<Grading> {
  const base = { reason: null, behavior: [], format: [], behavior_score: null, format_score: null, judge_error: null };
  const runFile = Bun.file(`${dir}/run.json`);
  if (!(await runFile.exists())) return { ...base, outcome: "incomplete", reason: "run.json missing" };
  const run = RunJson.parse(await runFile.json());
  if (run.status === "incomplete") return { ...base, outcome: "incomplete", reason: "run incomplete" };

  // a harness fault, not agent behavior: keep it out of the delta, even if the agent also misbehaved
  if (arm === "with_skill" && run.skill_file && !run.skill_file.startsWith(`${run.cwd}/.omp/skills/${suite.skill}/`))
    return { ...base, outcome: "incomplete", reason: "skill loaded from outside the run cwd" };

  const unusable = (reason: string): Grading => ({ ...base, outcome: "unusable", reason, behavior_score: 0 });
  const stray = run.tools_used.find((t) => !suite.tools.includes(t));
  if (stray) return unusable(`tool outside suite.tools: ${stray}`);
  if (run.uris_read.length) return unusable("mcp resource read");
  if (run.changed.length) return unusable(`changed fixture files: ${run.changed.join(", ")}`);
  const file = Bun.file(`${dir}/outputs/${suite.deliverable}`);
  if (!(await file.exists())) return unusable("deliverable missing");
  const raw = await file.text();
  let out: unknown;
  try {
    out = suite.parse(raw);
  } catch (e) {
    return unusable(`parse error: ${String(e).slice(0, 200)}`);
  }

  const behavior = c.behavior?.(out) ?? [];
  const criteria = [...(c.judge ?? []), ...(suite.judge ?? [])];
  if (criteria.length) {
    try {
      behavior.push(...(await judge(criteria, raw, dir)));
    } catch (e) {
      return { ...base, outcome: "judge_error", judge_error: String(e).slice(0, 500) };
    }
  }
  const format = arm === "with_skill" ? [...(suite.format?.(out) ?? []), ...(c.format?.(out) ?? [])] : [];
  return {
    ...base,
    outcome: "scored",
    behavior,
    format,
    behavior_score: score(behavior),
    format_score: score(format),
  };
}

/** Throws on any failure */
async function judge(criteria: string[], deliverable: string, dir: string): Promise<Result[]> {
  const prompt = [
    "You are grading a deliverable against numbered criteria. Judge only from the deliverable text.",
    "",
    "Criteria:",
    ...criteria.map((c, i) => `${i}. ${c}`),
    "",
    "<deliverable>",
    deliverable,
    "</deliverable>",
    "",
    'Reply with ONLY a JSON array, one entry per criterion: [{ "criterion": <index>, "passed": <bool>, "evidence": "<≤200 chars, quoted from the deliverable>" }]',
  ].join("\n");
  const key = new Bun.CryptoHasher("sha256").update(`${judgeModel}\0${prompt}`).digest("hex");
  const rows = (results: z.infer<typeof JudgeOut>) =>
    results
      .toSorted((a, b) => a.criterion - b.criterion)
      .map((x) => ({ name: `judge: ${criteria[x.criterion]}`, passed: x.passed, evidence: x.evidence.slice(0, 200) }));

  const cached = Bun.file(`${dir}/judge.json`);
  if (await cached.exists()) {
    const prev = JudgeJson.safeParse(await cached.json());
    if (prev.success && prev.data.key === key) return rows(prev.data.results);
  }

  const cwd = await mkdtemp(`${tmpdir()}/${skill}-judge-`);
  const conf = await mkdtemp(`${tmpdir()}/${skill}-conf-`);
  try {
    const lock = await lockdown(conf, []);
    const res = await $`omp -p --no-session --no-tools --no-extensions --no-skills --no-context-files --no-rules \
        ${lock} --model=${judgeModel} --mode=json ${prompt}`
      .cwd(cwd)
      .nothrow()
      .quiet();
    await Bun.write(`${dir}/judge.transcript.jsonl`, res.stdout);
    if (res.exitCode !== 0) throw new Error(`judge exited ${res.exitCode}: ${res.stderr.toString().slice(0, 300)}`);
    const reply = parseTranscript(res.stdout.toString()).messages.findLast((m) => m.role === "assistant")?.text ?? "";
    const json = reply.match(/```(?:json)?\s*\n([\s\S]*?)\n\s*```/)?.[1] ?? reply;
    const parsed = JudgeOut.parse(JSON.parse(json));
    const seen = parsed.map((x) => x.criterion).toSorted((a, b) => a - b);
    if (seen.join() !== criteria.map((_, i) => i).join()) throw new Error(`judge criteria mismatch: [${seen.join(", ")}]`);
    await Bun.write(`${dir}/judge.json`, JSON.stringify({ key, model: judgeModel, results: parsed }, null, 2));
    return rows(parsed);
  } finally {
    await rm(cwd, { recursive: true, force: true });
    await rm(conf, { recursive: true, force: true });
  }
}

const report = {
  skill,
  iteration: +opt.iteration,
  judge_model: judgeModel,
  overall_delta: null as number | null,
  incomplete_pairs: 0,
  unusable: [] as { case: string; pair: number; arm: Arm; reason: string | null }[],
  incomplete: [] as { case: string; pair: number; arm: Arm | null; reason: string | null }[],
  judge_errors: [] as { case: string; pair: number; arm: Arm; error: string | null }[],
  skill_not_loaded: [] as { case: string; pair: number }[],
  cases: [] as {
    id: string;
    pairs: number;
    delta: number | null;
    behavior: { name: string; with: string; without: string }[];
    format: { name: string; passed: string }[] | "n/a";
  }[],
};

for (const c of suite.cases) {
  const cdir = `${ws}/${c.id}`;
  if (!(await exists(cdir))) continue;
  const pairs = (await readdir(cdir))
    .flatMap((d) => (/^pair-\d+$/.test(d) ? [+d.slice(5)] : []))
    .sort((a, b) => a - b);
  const deltas: number[] = [];
  const behavior = new Map<string, Record<Arm, number>>();
  const format = new Map<string, [number, number]>();
  let valid = 0;

  for (const n of pairs) {
    const pdir = `${cdir}/pair-${n}`;
    const inputFile = Bun.file(`${pdir}/input.json`);
    if (!(await inputFile.exists())) {
      report.incomplete_pairs++;
      report.incomplete.push({ case: c.id, pair: n, arm: null, reason: "input.json missing" });
      continue;
    }
    const input = Input.parse(await inputFile.json());
    if (input.model === judgeModel) {
      console.error(`judge model ${judgeModel} must differ from the runner model`);
      process.exit(1);
    }
    const g = {} as Record<Arm, Grading>;
    for (const arm of ARMS) {
      g[arm] = await gradeArm(c, arm, `${pdir}/${arm}`);
      await Bun.write(`${pdir}/${arm}/grading.json`, JSON.stringify(g[arm], null, 2));
      if (g[arm].outcome === "unusable") report.unusable.push({ case: c.id, pair: n, arm, reason: g[arm].reason });
      if (g[arm].outcome === "incomplete") report.incomplete.push({ case: c.id, pair: n, arm, reason: g[arm].reason });
      if (g[arm].outcome === "judge_error")
        report.judge_errors.push({ case: c.id, pair: n, arm, error: g[arm].judge_error });
    }
    const withRun = RunJson.safeParse(await Bun.file(`${pdir}/with_skill/run.json`).json().catch(() => null));
    if (withRun.success && withRun.data.status === "completed" && withRun.data.skill_file === null)
      report.skill_not_loaded.push({ case: c.id, pair: n });
    if (ARMS.some((a) => g[a].outcome === "incomplete")) report.incomplete_pairs++;
    if (!ARMS.every((a) => g[a].outcome === "scored" || g[a].outcome === "unusable")) continue;

    valid++;
    deltas.push(g.with_skill.behavior_score! - g.without_skill.behavior_score!);
    for (const arm of ARMS)
      for (const row of g[arm].behavior) {
        const counts = behavior.get(row.name) ?? { with_skill: 0, without_skill: 0 };
        if (row.passed) counts[arm]++;
        behavior.set(row.name, counts);
      }
    for (const row of g.with_skill.format) {
      const name = row.name.replace(/\(.*$/s, "");
      const [p, t] = format.get(name) ?? [0, 0];
      format.set(name, [p + (row.passed ? 1 : 0), t + 1]);
    }
  }

  report.cases.push({
    id: c.id,
    pairs: valid,
    delta: mean(deltas),
    behavior: [...behavior].map(([name, k]) => ({
      name,
      with: `${k.with_skill}/${valid}`,
      without: `${k.without_skill}/${valid}`,
    })),
    format: format.size ? [...format].map(([name, [p, t]]) => ({ name, passed: `${p}/${t}` })) : "n/a",
  });
}
report.overall_delta = mean(report.cases.flatMap((c) => (c.delta === null ? [] : [c.delta])));

await Bun.write(`${ws}/report.json`, JSON.stringify(report, null, 2));

const pct = (x: number | null) => (x === null ? "n/a" : `${x >= 0 ? "+" : ""}${Math.round(x * 100)}%`);
const lines = [`${skill} iteration ${opt.iteration} (judge ${judgeModel})`, `overall behavior delta: ${pct(report.overall_delta)}`];
for (const c of report.cases) {
  lines.push("", `## ${c.id} — ${c.pairs} pair(s), delta ${pct(c.delta)}`, "behavior (with / without):");
  for (const b of c.behavior) lines.push(`  ${b.with.padEnd(5)} ${b.without.padEnd(5)} ${b.name}`);
  lines.push("format (with_skill):");
  if (c.format === "n/a") lines.push("  n/a");
  else for (const f of c.format) lines.push(`  ${f.passed.padEnd(5)} ${f.name}`);
}
lines.push("", `incomplete pairs: ${report.incomplete_pairs}`);
for (const i of report.incomplete)
  lines.push(`incomplete: ${i.case}/pair-${i.pair}${i.arm ? `/${i.arm}` : ""}: ${i.reason}`);
lines.push(`with_skill arms that never loaded the skill: ${report.skill_not_loaded.length}`);
for (const s of report.skill_not_loaded) lines.push(`skill not loaded: ${s.case}/pair-${s.pair}/with_skill`);
for (const u of report.unusable) lines.push(`unusable: ${u.case}/pair-${u.pair}/${u.arm}: ${u.reason}`);
for (const j of report.judge_errors) lines.push(`judge error: ${j.case}/pair-${j.pair}/${j.arm}: ${j.error}`);
console.log(lines.join("\n"));
