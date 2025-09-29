# ShellKit

A tiny Swift utility for running shell commands safely and conveniently. ShellKit executes commands using `/usr/bin/env`, captures both stdout and stderr, and returns trimmed stdout on success. On failure (non‑zero exit), it throws a rich `Shell.CommandError` containing the exit code and captured output so you can make informed decisions upstream.

## Why ShellKit?
- Safer by default: No implicit shell. Your arguments are passed directly to the process, avoiding shell expansion unless you explicitly opt into it (e.g. `sh -c ...`).
- Clear error handling: Get the exit status, stderr, and any stdout even when a command fails.
- Minimal surface area: A single `Shell.run` API you can drop into scripts, CLIs, and apps.
- Predictable output: Trims trailing newlines and whitespace for straightforward comparisons.

## Installation

### Add via Xcode
1. File → Add Packages…
2. Enter the repository URL:
