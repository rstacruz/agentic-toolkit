import { z } from "zod";

/** omp config overlay and flags that lock down tools */
export async function lockdown(dir: string, tools: string[]): Promise<string[]> {
  const path = `${dir}/lockdown.yml`;
  const overlay = { tools: { xdev: false, approval: Object.fromEntries(tools.map((t) => [t, "allow"])) } };
  await Bun.write(path, JSON.stringify(overlay)); // JSON is valid YAML
  return [`--config=${path}`, "--approval-mode=always-ask"];
}

const ToolStart = z.object({
  type: z.literal("tool_execution_start"),
  toolName: z.string(),
  args: z.object({ path: z.string().optional().catch(undefined) }).catch({}),
});

const MessageEnd = z.object({
  type: z.literal("message_end"),
  message: z.object({
    role: z.string(),
    content: z
      .union([z.string(), z.array(z.object({ text: z.string().optional() }))])
      .transform((c) => (Array.isArray(c) ? c.map((p) => p.text ?? "").join("") : c)),
  }),
});

export type Transcript = {
  tools: { name: string; path?: string }[];
  messages: { role: string; text: string }[];
};

export function parseTranscript(jsonl: string): Transcript {
  const out: Transcript = { tools: [], messages: [] };
  for (const line of jsonl.split("\n")) {
    if (!line.trim()) continue;
    const ev: unknown = JSON.parse(line);
    const t = ToolStart.safeParse(ev);
    if (t.success) out.tools.push({ name: t.data.toolName, path: t.data.args.path });
    const m = MessageEnd.safeParse(ev);
    if (m.success) out.messages.push({ role: m.data.message.role, text: m.data.message.content });
  }
  return out;
}
