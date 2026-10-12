## Testing discipline

- Test behavior your application actually owns.
- Start with linting and type-checking.
- Run the smallest test related to the change.
- Expand to integration tests only when needed.
- Reserve the full suite for release gates.
- Run sequentially by default.
- Use E2E, race, load, and stress tests intentionally.
- Never retry failures blindly.
- Read the evidence and fix the root cause.
- Never weaken tests just to make CI green.

The goal is not to run fewer tests. The goal is to run the right
tests, at the right layer, at the right time.

## Search tools — prefer `rg`

Use `rg` (ripgrep) for every shell-level text or file search. It respects `.gitignore`,
skips hidden/binary files, and is far faster on large trees.

- Content search: `rg PATTERN [PATH]`, not `grep -r`, `grep -R`, `ack`, `ag`, or `git grep`.
- File discovery: `rg --files [PATH]`, filtered with `-g '<glob>'` or piped to `rg PATTERN`,
  not `find`, `ls -R`, or `locate`.
- Narrow early: `-t <type>`, `-g '!<glob>'`, `-l` (filenames only), `-m N` (cap hits), `-F` (literal).
- Include ignored/hidden files only on purpose: `--hidden`, `--no-ignore`, `-uu`.
- Plain `grep` is fine for filtering a pipe (`cmd | grep x`), but `rg` works there too.
- Fall back to `find` only for metadata predicates rg lacks (`-mtime`, `-size`, `-perm`, `-newer`, `-empty`).
- When the harness has dedicated search tools (e.g. Grep/Glob), prefer those over shell search.
  ripwire (below) comes first for code orientation; `rg` is for raw text and file lookup.

## ripwire — deterministic codebase maps (on PATH as `ripwire`)

Reach for it BEFORE blind grep + whole-file reads. First call ~1s cold; after that warm, ~0.1s.

- Orient on a task: `ripwire <dir> --for="<task in words>"` — ranked, quality-annotated
  signatures. Paste symbol/file names from the issue verbatim; named mentions get anchored.
- One task: `--pack-task="<task>"`; before parallel agents: `--plan-lanes=N --task="<goal>"`, then read `lanes[].execution`.
- Have a stack trace / build error: `ripwire <dir> --from-trace=FILE` (`-` = stdin) —
  paste the error, don't paraphrase it into a query.
- Who calls X: `--callers=SYM`. "Is it safe to change X?" needs the full blast radius:
  `--impact=SYM` (transitive) plus `--uses=SYM` (every read/write/import site).
- Apply a whole-symbol edit without a whole-file Read: `--replace-symbol-body=SYM` plus `--edit-payload=FILE|-`
  (or insert-before/after); the receipt carries region, blob_sha, edit_check, tests_to_run + ONE next= — no re-read after it; `--edit-check=SYM` is for a contract question WITHOUT an edit in hand.
- Before writing a new fn/class/helper: `--exemplar="<what you're writing>"` — duplicates are born on small tasks.
- Before calling work done: `--quality-delta` (what you made worse), then `--test-gate`.
- Trust notes: counts marked counts_floor are floors, not totals; a zero means "none
  found", never "none exists".
Defaults to break (less context is measurably MORE accurate, not just cheaper — code-repair
accuracy fell 29% -> 3% as context grew 32K -> 256K tokens, LongCodeBench):
- Do NOT open a file you have not located first: rank with `--for`/`--grep`, then read what it names.
- Do NOT read a whole file to understand one symbol: `--expand=SYM` gives the body + callee sigs.
- Do NOT fan reads across several files to learn one thing: `--pack-task="<task>"` is one call.
