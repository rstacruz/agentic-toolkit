import { r, type Md } from "../lib/checks";
import type { Result } from "../lib/suite";

const RISK = /\*\*Risk:\*\*\s*(🟢 low|🟡 med|🔴 high)\s*[—-]\s*\S.*/;

function decisions(doc: Md) {
  const body = doc.section("Decisions");
  if (!body) return [];
  return body
    .split(/^### /m)
    .slice(1)
    .map((chunk) => {
      const [title, ...rest] = chunk.split("\n");
      const text = rest.join("\n");
      return { title: title.trim(), text, risk: text.match(RISK)?.[1] };
    });
}

/** One row per `###` decision */
export const everyDecisionHasRisk = (doc: Md): Result[] =>
  decisions(doc).map((d) =>
    r(`everyDecisionHasRisk(### ${d.title})`, !!d.risk, d.risk ? (d.text.match(RISK)?.[0] ?? d.risk) : "no **Risk:** line"),
  );

/** Worst-hit-wins: a row only when some decision is 🔴 high */
export function redRiskImpliesL4(doc: Md): Result[] {
  const red = decisions(doc).filter((d) => d.risk === "🔴 high");
  if (!red.length) return [];
  const level = doc.section("Review effort")?.match(/\*\*L(\d)\b/)?.[1];
  return [
    r("redRiskImpliesL4", !!level && +level >= 4, `L${level ?? "?"} with 🔴 high: ${red.map((d) => d.title).join(", ")}`),
  ];
}

export function designHasChangeMarkers(doc: Md): Result[] {
  const body = doc.section("Design");
  if (body === undefined) return [];
  const m = body.match(/🟢 New|🟡 Updated|🔴 Removed/);
  return [r("designHasChangeMarkers", !!m, m ? m[0] : "no change markers")];
}

export function noCodeBlocksInSteps(doc: Md): Result[] {
  const body = doc.section("Implementation steps");
  if (body === undefined) return [];
  const m = body.match(/^ {0,3}(`{3,}|~{3,}).*$/m);
  return [r("noCodeBlocksInSteps", !m, m ? m[0] : "no fenced blocks")];
}
