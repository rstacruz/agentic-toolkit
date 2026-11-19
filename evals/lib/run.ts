#!/usr/bin/env bun
import { $ } from "bun";
import { parseArgs } from "node:util";
import { exists, mkdir, mkdtemp, rm } from "node:fs/promises";
import { tmpdir } from "node:os";
import { changedPaths, hashFiles, treeHash } from "./files";
import { ensureFixture } from "./fixtures";
import { lockdown, parseTranscript } from "./omp";
import type { Suite } from "./suite";

const ROOT = `${import.meta.dir}/..`;
const REPO = `${ROOT}/..`;
const { values: opt, positionals: [skill] } = parseArgs({
  args: Bun.argv.slice(2),
  allowPositionals: true,
  options: {
    iteration: { type: "string" },
    model: { type: "string" },
    runs: { type: "string", default: "1" },
    only: { type: "string" },
  },
});
if (!skill || !opt.iteration) throw new Error("usage: run.ts <skill> --iteration N --model p/m [--runs n] [--only id]");
if (!opt.model?.includes("/")) throw new Error("--model must be an exact provider/model ID");

const sdir = `${ROOT}/${skill}`;
// suite is selected by CLI arg, so it can't be a static import
const suite: Suite<unknown> = (await import(`${sdir}/suite.ts`)).default;
const preamble = (await exists(`${sdir}/preamble.md`)) ? (await Bun.file(`${sdir}/preamble.md`).text()).trim() : "";
const ws = `${ROOT}/.workspace/${skill}/iteration-${opt.iteration}`;

const ARMS: Record<string, string[]> = {
  with_skill: [`--skills=${suite.skill}`],
  without_skill: ["--no-skills"],
};

for (const c of suite.cases.filter((c) => !opt.only || c.id === opt.only)) {
  for (let n = 1; n <= +opt.runs!; n++) {
    const pair = `${ws}/${c.id}/pair-${n}`;
    await mkdir(`${ws}/${c.id}`, { recursive: true });
    await mkdir(pair); // exclusive: throws EEXIST if the pair is taken

    const stage = await mkdtemp(`${tmpdir()}/${skill}-stage-`);
    try {
      const fixture = c.fixture ?? c.id;
      const remote = suite.fixtures?.[fixture];
      const src = remote ? await ensureFixture(`${ROOT}/.workspace/.cache/fixtures`, remote) : `${sdir}/fixtures/${fixture}`;
      await $`cp -R ${src}/. ${stage}/ && mkdir -p ${stage}/outputs`;
      for (const [name, body] of Object.entries(suite.files ?? {})) await Bun.write(`${stage}/${name}`, body);
      // users invoke the skill explicitly, so the with_skill arm does too
      const prompts: Record<string, string> = {
        with_skill: [preamble, `/${suite.skill} ${c.prompt}`].filter(Boolean).join("\n\n"),
        without_skill: [preamble, c.prompt].filter(Boolean).join("\n\n"),
      };
      const input = {
        model: opt.model,
        prompts,
        fixture,
        fixture_source: remote ? { repo: remote.repo, sha: remote.sha } : undefined,
        input_digest: await treeHash(stage),
      };
      const skill_digest = await Promise.all(
        Object.entries(ARMS).map(([arm, flags]) => runArm(arm, flags, stage, prompts[arm], `${pair}/${arm}`)),
      );
      await Bun.write(`${pair}/input.json`, JSON.stringify({ ...input, skill_digest: skill_digest[0] }, null, 2));
      console.log(`${c.id}/pair-${n} done`);
    } finally {
      await rm(stage, { recursive: true, force: true });
    }
  }
}

async function runArm(arm: string, flags: string[], stage: string, prompt: string, dir: string) {
  await mkdir(dir);
  const cwd = await mkdtemp(`${tmpdir()}/${skill}-eval-`);
  const conf = await mkdtemp(`${tmpdir()}/${skill}-conf-`);
  const t0 = performance.now();
  let skillDigest: string | undefined;
  try {
    await $`cp -R ${stage}/. ${cwd}/`;
    if (arm === "with_skill") {
      await $`mkdir -p ${cwd}/.omp/skills && cp -R ${REPO}/skills/${suite.skill} ${cwd}/.omp/skills/`;
      skillDigest = await treeHash(`${cwd}/.omp/skills/${suite.skill}`); // hash what the agent actually gets
    }
    const before = await hashFiles(cwd); // after setup, so injected files never count as changes
    const lock = await lockdown(conf, suite.tools);

    const res = await $`omp -p --no-session --no-context-files --no-rules --no-extensions ${flags} \
        --tools=${suite.tools.join(",")} ${lock} --max-cost=${suite.maxCost} \
        --model=${opt.model} --mode=json ${prompt}`
      .cwd(cwd)
      .nothrow()
      .quiet();

    // evidence first, deliverable last
    await Bun.write(`${dir}/transcript.jsonl`, res.stdout);
    if (res.exitCode !== 0) await Bun.write(`${dir}/stderr.txt`, res.stderr);
    const completed = res.exitCode === 0 || res.exitCode === 3; // 3 = --max-cost reached; graded as-is
    await Bun.write(
      `${dir}/run.json`,
      JSON.stringify(
        {
          status: completed ? "completed" : "incomplete",
          exit_code: res.exitCode,
          duration_ms: Math.round(performance.now() - t0),
          changed: changedPaths(before, await hashFiles(cwd)).filter((p) => !p.startsWith("outputs/")),
          cwd,
          ...evidence(res.stdout.toString()),
        },
        null,
        2,
      ),
    );
    if (await exists(`${cwd}/outputs`)) await $`cp -R ${cwd}/outputs ${dir}/`;
  } catch (e) {
    await Bun.write(`${dir}/run.json`, JSON.stringify({ status: "incomplete", error: String(e) }, null, 2));
  } finally {
    await rm(cwd, { recursive: true, force: true });
    await rm(conf, { recursive: true, force: true });
  }
  return skillDigest;
}

/** First-run safeguard evidence from the json event stream */
function evidence(jsonl: string) {
  const t = parseTranscript(jsonl);
  const skillFile = t.messages
    .values()
    .filter((m) => m.role === "toolResult")
    .map((m) => m.text.match(/\[Skill file: ([^\]\n]+)/)?.[1]?.trim())
    .find(Boolean);
  return {
    tools_used: [...new Set(t.tools.map((x) => x.name))].sort(),
    skill_file: skillFile ?? null,
    uris_read: t.tools.flatMap((x) => (x.name === "read" && x.path?.startsWith("mcp://") ? [x.path] : [])),
  };
}
