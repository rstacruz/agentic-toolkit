import { matches } from "../lib/checks";
import type { Result } from "../lib/suite";

/** `text`: one line per `<text>`, or per positioned (`x`/`dy`) `<tspan>` inside it, joined by "\n" */
export type Svg = { raw: string; text: string };

const ENTITIES: Record<string, string> = { amp: "&", lt: "<", gt: ">", quot: '"', apos: "'", nbsp: " " };
const decode = (s: string) =>
  s.replace(/&(#x[\da-f]+|#\d+|\w+);/gi, (m, e: string) =>
    e[0] !== "#" ? (ENTITIES[e] ?? m) : String.fromCodePoint(/^#x/i.test(e) ? parseInt(e.slice(2), 16) : parseInt(e.slice(1), 10)),
  );
const strip = (s: string) => decode(s.replace(/<[^>]*>/g, "")).trim();

export function svg(raw: string): Svg {
  if (!/<svg[\s>]/.test(raw)) throw new Error("no <svg> root");
  // Positioned tspans start a new line; inline tspans stay joined with the surrounding text
  const lines = [...raw.matchAll(/<text\b[^>]*>([\s\S]*?)<\/text>/g)].flatMap(([, inner]) =>
    inner.replace(/<tspan\b[^>]*\s(?:x|dy)=[^>]*>/g, "\n").split("\n").map(strip),
  );
  return { raw, text: lines.filter(Boolean).join("\n") };
}

const named = (name: string, res: Result): Result => ({ ...res, name: `${name}: ${res.name}` });

export const panelsNumbered = (s: Svg) => named("panelsNumbered", matches(s.text, /\b1 · [\s\S]*\b2 · /));
export const skippedStepStyled = (s: Svg) => [
  named("skippedStepStyled", matches(s.raw, /stroke-dasharray|line-through/)),
  named("skippedStepStyled", matches(s.raw, /#cf222e/i)),
];
export const hotspotRefs = (s: Svg) => [
  named("hotspotRefs", matches(s.text, /\b(D|FP)\d+\b/)),
  // `!` as its own marker, not ending a sentence
  named("hotspotRefs", matches(s.text, /(^|[ \t])!([ \t]|$)/m)),
];
// models often draw ✓ instead of the ✅ emoji
export const safetyChecklist = (s: Svg) => named("safetyChecklist", matches(s.text, /[✅✓✔]/));
export const lightBackground = (s: Svg) => named("lightBackground", matches(s.raw, /#F0F0F3/i));
