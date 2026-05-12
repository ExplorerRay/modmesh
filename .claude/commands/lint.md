---
description: Run every lint check (cformat, cinclude, flake8, checkascii, checktws)
argument-hint: [optional individual target, e.g. flake8, cformat]
allowed-tools: Bash(make lint:*), Bash(make cformat:*), Bash(make cinclude:*), Bash(make flake8:*), Bash(make checkascii:*), Bash(make checktws:*)
---

Run modmesh's lint checks.

- If `$ARGUMENTS` is empty, run `make lint` (runs all of cformat,
  cinclude, flake8, checkascii, checktws).
- If `$ARGUMENTS` names a single target (`cformat`, `cinclude`,
  `flake8`, `checkascii`, `checktws`), run `make $ARGUMENTS`.

Report each failing check as `target -- path:line -- rule`. Do not
suggest fixes for `cformat` violations -- they should be applied
via `/format` (or `make format`) instead.

End with: `verdict: clean | issues found | blocking`. `blocking`
iff any check that gates CI failed (all five do).
