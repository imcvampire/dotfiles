# Testing discipline

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

<!-- CODEGRAPH_START -->
## CodeGraph

In repositories indexed by CodeGraph (a `.codegraph/` directory exists at the repo root), reach for it BEFORE grep/find or reading files when you need to understand or locate code:

- **MCP tool** (when available): `codegraph_explore` answers most code questions in one call — the relevant symbols' verbatim source plus the call paths between them, including dynamic-dispatch hops grep can't follow. Name a file or symbol in the query to read its current line-numbered source. If it's listed but deferred, load it by name via tool search.
- **Shell** (always works): `codegraph explore "<symbol names or question>"` prints the same output.

If there is no `.codegraph/` directory, skip CodeGraph entirely — indexing is the user's decision.
<!-- CODEGRAPH_END -->
