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
