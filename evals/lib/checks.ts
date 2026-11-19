import type { Result } from "./suite";

export const r = (name: string, passed: boolean, evidence: string): Result => ({ name, passed, evidence });

export type Md = { text: string; headings: string[]; section(h: string): string | undefined };

type Heading = { level: number; text: string; line: number };

/** ATX headings outside fenced code blocks */
function scanHeadings(lines: string[]): Heading[] {
  const out: Heading[] = [];
  let fence: string | undefined;
  lines.forEach((line, i) => {
    const f = line.match(/^ {0,3}(`{3,}|~{3,})/)?.[1];
    if (fence) {
      if (f && f[0] === fence[0] && f.length >= fence.length && !line.trim().slice(f.length)) fence = undefined;
      return;
    }
    if (f) return void (fence = f);
    const h = line.match(/^ {0,3}(#{1,6})\s+(.*?)\s*#*\s*$/);
    if (h) out.push({ level: h[1].length, text: h[2].trim(), line: i });
  });
  return out;
}

export function md(text: string): Md {
  const lines = text.split("\n");
  const hs = scanHeadings(lines);
  const h2 = hs.filter((h) => h.level === 2);
  return {
    text,
    headings: h2.map((h) => h.text),
    section(name) {
      const i = h2.findIndex((h) => h.text === name);
      if (i < 0) return undefined;
      const end = hs.find((h) => h.line > h2[i].line && h.level <= 2)?.line ?? lines.length;
      return lines.slice(h2[i].line + 1, end).join("\n");
    },
  };
}

export function matches(text: string, re: RegExp): Result {
  const m = text.match(re);
  return r(`matches(${re})`, !!m, m ? m[0].slice(0, 200) : "no match");
}

export function lacks(text: string, re: RegExp): Result {
  const m = text.match(re);
  return r(`lacks(${re})`, !m, m ? m[0].slice(0, 200) : "absent");
}

export function headingsInOrder(doc: Md, hs: string[]): Result {
  const missing = hs.filter((h) => !doc.headings.includes(h));
  const present = hs.filter((h) => doc.headings.includes(h));
  const outOfOrder = present.filter((h, i) => i > 0 && doc.headings.indexOf(h) < doc.headings.indexOf(present[i - 1]));
  const problems = [...missing.map((h) => `missing: ${h}`), ...outOfOrder.map((h) => `out of order: ${h}`)];
  return r("headingsInOrder", problems.length === 0, problems.join("; ") || "all in order");
}
