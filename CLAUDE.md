# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with
code in this repository.

## Project Overview

modmesh is a hybrid C++/Python library for solving conservation laws using the
space-time Conservation Element and Solution Element (CESE) method with
unstructured meshes. The codebase emphasizes:

- High-performance numerical computing through C++ with Python bindings
- Multi-dimensional array operations and contiguous buffer management
- One-dimensional solvers demonstrating the CESE method
- Qt-based GUI (pilot) for spatial data visualization
- Integrated runtime profiler for performance analysis

## Claude Code Tooling

This repository ships a `.claude/` directory with permissions, hooks, slash
commands, and subagents tuned to this codebase. General behavioral rules live
in `contrib/prompt/general-rule.md` (not auto-imported). This section indexes
the tools.

### Slash commands (`.claude/commands/`)

| Command           | Wraps                          | Notes                                              |
| ----------------- | ------------------------------ | -------------------------------------------------- |
| `/build [args]`   | `make $ARGUMENTS`              | Builds the Python extension by default.            |
| `/pytest [args]`  | `make pytest PYTEST_OPTS=...`  | Forwards args via `PYTEST_OPTS`; default is full suite. |
| `/gtest [args]`   | `make gtest` or `run_gtest`    | Forwards `--gtest_filter=...` to the built binary. |
| `/lint [target]`  | `make lint`                    | Or a single sub-target (`flake8`, `cinclude`, ...). |
| `/format [pyformat]` | `make format`               | `pyformat` runs Python-only.                       |

All commands end with `verdict: clean | issues found | blocking`.

### Subagents (`.claude/agents/`)

- `cpp-style-reviewer` -- judgment-call C++ review (`m_` prefix, function-body
  placement, `SimpleCollector` preference, pybind11 binding split,
  `const_cast`). Scoped to `git diff`. Pinned `model: sonnet`.
- `python-style-reviewer` -- judgment-call Python review (naming, test intent,
  project conventions). Scoped to `git diff`. Pinned `model: sonnet`.

Deterministic style checks (ASCII, trailing whitespace, modeline, 79-char
Python lines) are owned by hooks, not subagents.

### Hooks (`.claude/hooks/`)

- `check-source.sh` -- PostToolUse on `Write|Edit` of source files.  Surfaces
  non-ASCII bytes, trailing whitespace, missing modeline, and Python `>79`
  chars; exits 2 with `path:line -- rule -- fix`.

### Settings (`.claude/settings.json`)

- `permissions.allow` whitelists the safe `make` targets, `cmake`, `pytest`,
  lint/format tools, and read-only git/gh. `make clean` and `make cmakeclean`
  deliberately prompt.
- `permissions.deny` blocks force-push, `git reset --hard`, `git clean -fd`,
  `sudo`, and `rm -rf` of root/home.
- `hooks` wires the script above.
- `statusLine` runs `.claude/statusline.sh` -- shows model, project, branch
  (with `*` if dirty), and context-window usage.

## Build Commands

Prefer the slash commands listed above (`/build`, `/pytest`, `/gtest`,
`/lint`, `/format`). The underlying `make` targets are: `make` (Python
extension; default), `make pytest`, `make gtest`, `make pilot`,
`make run_pilot_pytest`, `make pyprof`, `make lint` (or individual:
`cinclude`, `flake8`, `checkascii`, `checktws`, `cformat`), `make pyformat`,
`make format` (in-place C++ + Python), `make clean`, `make cmakeclean`.

Any target whose tool (`clang-format`, `flake8`, `black`) is missing prints an
install hint and exits 1. `make cformat` also warns when the local
`clang-format` major version differs from the CI pin (`CLANG_FORMAT_CI_VERSION`
in the Makefile).

### Build Configuration

Key build variables (set in `setup.mk` or as environment variables):
- `CMAKE_BUILD_TYPE`: `Release` (default) or `Debug`
- `BUILD_QT`: `ON` (default) or `OFF` - build Qt GUI components
- `BUILD_METAL`: `OFF` (default) or `ON` - build Metal GPU support
- `MODMESH_PROFILE`: `OFF` (default) or `ON` - enable profiler
- `USE_CLANG_TIDY`: `OFF` (default) or `ON` - use clang-tidy
- `HIDE_SYMBOL`: `ON` (default) - hide Python wrapper symbols
- `DEBUG_SYMBOL`: `ON` (default) - add debug information

Build paths (`$(pyvminor)` is the active Python major+minor, e.g. `314`):
- Release builds (default): `build/rel<pyvminor>` (e.g., `build/rel314`)
- Debug builds: `build/dbg<pyvminor>` (e.g., `build/dbg314`)

## Architecture

### Hybrid C++/Python Design

modmesh uses a dual-layer hybrid architecture:

1. **C++ Core** (`cpp/modmesh/`): High-performance numerical code
   - Compiled to native libraries with pybind11 bindings
   - Exposed to Python through the `_modmesh` extension module

2. **Python Interface** (`modmesh/`): High-level API and utilities
   - Imports C++ components via `from .core import *`
   - Provides Python-native functionality (plotting, utilities, etc.)

### C++ Component Structure

C++ core lives in `cpp/modmesh/`. Load-bearing pieces:

- `buffer/` -- `ConcreteBuffer`, `SimpleArray`, `BufferExpander`,
  `small_vector`.
- `mesh/` -- `StaticMesh` (unstructured meshes with mixed element types).
- `pilot/` -- Qt GUI (entry point under `cpp/binary/pilot/`; needs Qt6
  and PySide6).
- `python/` -- `module.cpp` is the main pybind11 module.

Other subdirectories cover what their names suggest: `linalg/`
(BLAS/LAPACK wrappers), `inout/` (Gmsh, Plot3D), `onedim/` (1D CESE
solvers), `profiling/` (runtime profiler), `simd/` (NEON/SSE/AVX),
`transform/` (integral transform), `universe/` (3D geometry), `toggle/`
(feature toggle), and per-component `pymod/` subdirs for pybind11
wrappers. `spacetime/` is an old, incorrect CESE implementation kept
for reference only -- do not extend it.

See `cpp/modmesh/` for the current tree.

### Python Package Structure

Python interface in `modmesh/`:

- `core.py`: Main Python API wrapping the C++ extension
- `onedim/`: One-dimensional solver utilities
- `pilot/`: GUI application Python components
- `plot/`: Plotting utilities
- `profiling/`: Profiling result analysis
- `testing.py`: Test utilities
- `toggle.py`: Feature toggle Python interface

### Testing Structure

- **Python tests** (`tests/`): pytest-based
  - Named `test_*.py`
  - Run with `make pytest`

- **C++ tests** (`gtests/`): googletest-based
  - Named `test_nopython_*.cpp`
  - Run with `make gtest`

- **Profiling benchmarks** (`profiling/`): performance tests
  - Named `profile_*.py`
  - Run with `make pyprof`; outputs to `profiling/results/`

## Code Style

`STYLE.md` is the canonical source. At a glance:

- **C++**: 4-space indent, `m_` prefix on member vars, angle-bracket includes,
  C++23, prefer `SimpleCollector` / `small_vector` over STL for fundamentals.
- **Python**: PEP-8, 79-char hard limit, flake8.
- **All source**: UTF-8, Unix LF, ASCII-only, no trailing whitespace, modeline
  at EOF.

How style is enforced in this repo:

- `.claude/hooks/check-source.sh` owns the deterministic checks (ASCII bytes,
  trailing whitespace, modeline at EOF, Python `>79`-char lines).
- The `cpp-style-reviewer` and `python-style-reviewer` subagents in
  `.claude/agents/` own the judgment-call rules (`m_` prefix in context,
  function-body placement, container choice, pybind11 binding split, test
  intent). They are scoped to `git diff`.

For the full rule set with examples, see `STYLE.md`.

## Pull Request Guidelines

When opening a pull request, reference the related issue (e.g., "Related to
#725") instead of using closing keywords like "close #725", "closes #725", or
"fixes #725". We do not let PR and commit log comments to mandate the
management.

## Development Workflow

### Running Single Tests

Prefer the slash commands (`/pytest <path or args>`,
`/gtest --gtest_filter=Suite.Test`). Direct invocations:

```bash
make pytest PYTEST_OPTS="tests/test_buffer.py::SimpleArrayBasicTC::test_sort"
./build/rel<pyvminor>/gtests/run_gtest --gtest_filter=Suite.Test
```

### Build System Notes

- CMake is the primary build system (minimum version 3.27)
- Makefile wraps CMake for convenience
- Python extension built via setuptools with custom CMake integration
- Build output: `_modmesh.cpython-<version>-<platform>.so` in `modmesh/`

### Dependencies

Core dependencies:
- Python 3 with development headers
- pybind11 >= 2.12.0 (for NumPy 2.0 support)
- NumPy
- CMake >= 3.27
- C++23 compiler (gcc, clang, or MSVC)

Optional dependencies:
- Qt6 and PySide6 (for GUI)
- clang-tidy (for linting)
- googletest (auto-fetched by CMake)
- Metal (for macOS GPU support)

Install scripts available in `contrib/dependency/`

### Virtual Environments

**IMPORTANT**: Using Python virtual environments (venv, conda) is **strongly
discouraged** for modmesh development. The project is designed to work with
system Python. Virtual environment bugs are not actively resolved.

Use https://github.com/solvcon/devenv to build dependency from source and
install in user space. Do not install dependency system-wide. Installation of
any dependency requires user review and consent.

### Platform-Specific Notes

**macOS**: System Integrity Protection (SIP) may interfere with
`DYLD_LIBRARY_PATH`. The Makefile sets `PYTHONPATH` as a workaround.

## Profiling System

modmesh includes an integrated runtime profiler:

1. Enable with `MODMESH_PROFILE=ON` during build
2. Use `toggle.py` API to enable/disable profiling regions
3. Run profiling scripts with `make pyprof`
4. Results written to `profiling/results/`

## Qt GUI Development

The pilot application (`cpp/binary/pilot/`) is a standalone Qt6-based viewer:

- Requires `BUILD_QT=ON` (default)
- Uses PySide6 for Python-Qt integration
- Resource files in `resources/pilot/`
- Can be disabled with `BUILD_QT=OFF` for headless builds

## Common Development Patterns

### Adding a New C++ Component

1. Create a directory under `cpp/modmesh/`.
2. Add header files with proper include guards.
3. Update `cpp/modmesh/CMakeLists.txt` to include new sources.
4. Add pybind11 bindings if Python access is needed.
5. Write tests in both `gtests/` and `tests/`.

### Adding Python-Only Functionality

1. Add a module to `modmesh/`.
2. Update `modmesh/__init__.py` if needed.
3. Write tests in `tests/`.
4. Update `setup.py` packages list if adding a new package.

### Memory Management

- Use `ConcreteBuffer` for raw memory.
- Use `SimpleArray` for typed multi-dimensional arrays.
- Buffers support both ownership and non-owning views.
- Python and C++ share the same buffer memory (zero-copy).

<!-- vim: set ff=unix fenc=utf8 et sw=4 ts=4 sts=4 tw=79: -->
