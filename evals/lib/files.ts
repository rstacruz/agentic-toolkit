import { Glob } from "bun";

/** rel path -> sha256, hidden files included */
export async function hashFiles(dir: string): Promise<Map<string, string>> {
  const out = new Map<string, string>();
  for await (const rel of new Glob("**/*").scan({ cwd: dir, dot: true, onlyFiles: true })) {
    const bytes = await Bun.file(`${dir}/${rel}`).arrayBuffer();
    out.set(rel, new Bun.CryptoHasher("sha256").update(bytes).digest("hex"));
  }
  return out;
}

export async function treeHash(dir: string): Promise<string> {
  const files = [...(await hashFiles(dir))].sort(([a], [b]) => (a < b ? -1 : a > b ? 1 : 0));
  return new Bun.CryptoHasher("sha256").update(files.map(([p, h]) => `${p}\0${h}\n`).join("")).digest("hex");
}

/** added, removed or modified paths, sorted */
export function changedPaths(a: Map<string, string>, b: Map<string, string>): string[] {
  const keys = new Set([...a.keys(), ...b.keys()]);
  return [...keys].filter((k) => a.get(k) !== b.get(k)).sort();
}
