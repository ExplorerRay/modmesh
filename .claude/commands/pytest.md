---
description: Run Python tests (pytest)
argument-hint: [optional pytest args or test file/function paths]
allowed-tools: Bash(make pytest:*), Bash(make run_pilot_pytest:*), Bash(find:*), Bash(ls:*)
---

Run the modmesh Python test suite.

- If `$ARGUMENTS` is empty, run `make pytest` (full suite; builds
  the extension first if needed).
- If `$ARGUMENTS` contains pytest args or a path, forward them via
  `make pytest PYTEST_OPTS='$ARGUMENTS'`. This is the project's
  documented entry point (see comments in `Makefile`) and preserves
  the `PYTHONPATH=$(MODMESH_ROOT)` env that bare `pytest` would
  miss on macOS (SIP strips `DYLD_LIBRARY_PATH`).

Report:
- Pass / fail / time on one line.
- For failures, list `test_id -- first failure line` (no full
  tracebacks). If the failure is in a fixture or setup, say so.

End with: `verdict: clean | issues found | blocking`. `blocking`
iff the test run could not start (build failure, import error).
