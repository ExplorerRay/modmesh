---
description: Build modmesh (defaults to the Python extension)
argument-hint: [optional make args, e.g. VERBOSE=1 or target name]
allowed-tools: Bash(make:*)
---

Build modmesh by running `make $ARGUMENTS` from the repo root. If
`$ARGUMENTS` is empty, run `make` (default target builds the
`_modmesh` Python extension into `modmesh/`).

Report:
- On success, a one-line summary; surface any non-fatal warnings.
- On failure, list the first few errors as
  `path:line -- error -- one-line diagnosis`. Do not paste full
  logs.

End with: `verdict: clean | issues found | blocking`. `blocking`
iff the build failed.
