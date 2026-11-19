import { $ } from "bun";
import { exists, mkdir, mkdtemp, rm } from "node:fs/promises";
import { tmpdir } from "node:os";
import type { RemoteFixture } from "./suite";

/** Fetches fixture at its pinned sha once; returns its dir */
export async function ensureFixture(cacheRoot: string, f: RemoteFixture): Promise<string> {
  const [owner, repo] = new URL(f.repo).pathname.replace(/^\/|\.git$/g, "").split("/");
  const dir = `${cacheRoot}/${owner}-${repo}@${f.sha}`;
  const marker = `${dir}.complete`; // beside the tree, so staging never copies it
  if (await exists(marker)) return dir;

  await rm(dir, { recursive: true, force: true });
  await mkdir(dir, { recursive: true });
  const git = await mkdtemp(`${tmpdir()}/fixture-git-`);
  try {
    await $`git init -q && git fetch -q --depth 1 ${f.repo} ${f.sha}`.cwd(git).quiet();
    const head = (await $`git rev-parse FETCH_HEAD`.cwd(git).text()).trim();
    if (head !== f.sha) throw new Error(`${f.repo}: fetched ${head}, expected ${f.sha}`);
    const excludes = (f.exclude ?? []).flatMap((e) => ["--exclude", e]);
    await $`git archive FETCH_HEAD | tar -x -C ${dir} ${excludes}`.cwd(git).quiet();
  } finally {
    await rm(git, { recursive: true, force: true });
  }
  await Bun.write(marker, "");
  return dir;
}
