export type Result = { name: string; passed: boolean; evidence: string };

export type Case<O> = {
  id: string;
  prompt: string;
  /** Remote fixture name or dir under fixtures/; default = id */
  fixture?: string;
  /** Both arms */
  behavior?: (out: O) => Result[];
  /** with_skill only; conventions for actions this case expects */
  format?: (out: O) => Result[];
  /** Prose criteria for the LLM judge; none skips it */
  judge?: string[];
};

export type RemoteFixture = { repo: string; sha: string; tag?: string; license?: string; exclude?: string[] };

export type Suite<O> = {
  skill: string;
  /** Path under outputs/, same for both arms */
  deliverable: string;
  /** Throws if unusable */
  parse: (raw: string) => O;
  /** Extra files written into the staged input */
  files?: Record<string, string>;
  /** omp --tools */
  tools: string[];
  /** USD per run */
  maxCost: number;
  /** with_skill; conventions that apply to every case */
  format?: (out: O) => Result[];
  fixtures?: Record<string, RemoteFixture>;
  cases: Case<O>[];
};

export const defineSuite = <O>(s: Suite<O>) => s;
