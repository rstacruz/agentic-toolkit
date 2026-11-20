import { matches } from "../lib/checks";
import type { Result } from "../lib/suite";

/** `text`: each `<text>` element's content (one line per `<tspan>`), joined by "\n" */
export type Svg = { raw: string; text: string };

const ENTITIES: Record<string, string> = { amp: "&", lt: "<", gt: ">", quot: '"', apos: "'", nbsp: " " };
const decode = (s: string) =>
  s.replace(/&(#x[\da-f]+|#\d+|\w+);/gi, (m, e: string) =>
    e[0] !== "#" ? (ENTITIES[e] ?? m) : String.fromCodePoint(parseInt(e.slice(e[1] === "x" ? 2 : 1), e[1] === "x" ? 16 : 10)),
  );
const strip = (s: string) => decode(s.replace(/<[^>]*>/g, "")).trim();

export function svg(raw: string): Svg {
  if (!/<svg[\s>]/.test(raw)) throw new Error("no <svg> root");
  const lines = [...raw.matchAll(/<text\b[^>]*>([\s\S]*?)<\/text>/g)].flatMap(([, inner]) => {
    const spans = [...inner.matchAll(/<tspan\b[^>]*>([\s\S]*?)<\/tspan>/g)].map(([, t]) => strip(t));
    return spans.length ? spans : [strip(inner)];
  });
  return { raw, text: lines.filter(Boolean).join("\n") };
}

const named = (name: string, res: Result): Result => ({ ...res, name: `${name}: ${res.name}` });

export const panelsNumbered = (s: Svg) => named("panelsNumbered", matches(s.text, /\b1 · [\s\S]*\b2 · /));
export const beforeAfterRow = (s: Svg) => named("beforeAfterRow", matches(s.text, /\bBefore\b[\s\S]*\bAfter\b/i));
export const skippedStepStyled = (s: Svg) => [
  named("skippedStepStyled", matches(s.raw, /stroke-dasharray|line-through/)),
  named("skippedStepStyled", matches(s.raw, /#cf222e/i)),
];
// `!` as its own marker, not ending a sentence
export const hotspotRefs = (s: Svg) => [
  named("hotspotRefs", matches(s.text, /\b(D|FP)\d+\b/)),
  named("hotspotRefs", matches(s.text, /(^|[ \t])!([ \t]|$)/m)),
];
export const safetyChecklist = (s: Svg) => named("safetyChecklist", matches(s.text, /✅/));
export const lightBackground = (s: Svg) => named("lightBackground", matches(s.raw, /#F0F0F3/i));
