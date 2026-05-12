---
description: Auto-format C++ (clang-format -i) and Python (black)
argument-hint: [optional: pyformat, or leave empty for both]
allowed-tools: Bash(make format:*), Bash(make pyformat:*), Bash(make cformat:*), Bash(git diff:*), Bash(git status:*)
---

Auto-format modmesh sources.

- If `$ARGUMENTS` is empty, run `make format` (formats both C++
  and Python).
- If `$ARGUMENTS` is `pyformat`, run `make pyformat` (Python only).
- If `$ARGUMENTS` is `cformat`, note that `make cformat` only
  checks formatting; running `make format` is the correct way to
  apply C++ fixes.

After formatting, run `git status --short` and list which files
were modified. If nothing changed, say "already formatted".

End with: `verdict: clean | issues found | blocking`. `clean` iff
`make format` succeeded (whether or not files changed). `blocking`
iff the formatter tooling is missing or errored.
