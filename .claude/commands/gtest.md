---
description: Build and run C++ tests (googletest)
argument-hint: [optional --gtest_filter=Suite.Test or other gtest flags]
allowed-tools: Bash(make gtest:*), Bash(./build/*/gtests/run_gtest:*), Bash(find:*), Bash(ls:*)
---

Run modmesh's C++ tests.

- If `$ARGUMENTS` is empty, run `make gtest` (builds and runs the
  full suite).
- If `$ARGUMENTS` contains gtest flags (e.g. `--gtest_filter=...`),
  locate the gtest binary under `build/*/gtests/run_gtest` (build
  first with `make gtest` if it's missing) and invoke it with
  `$ARGUMENTS`.

Report:
- Run / fail / time on one line.
- For failures, list `Suite.Test -- first assertion failure with
  file:line`. No full output.

End with: `verdict: clean | issues found | blocking`. `blocking`
iff the binary failed to build.
