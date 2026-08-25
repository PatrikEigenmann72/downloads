# downloads

## About

Compiled binaries and buildable source archives for Patrik's personal tools, organized by the
project repo each tool comes from. This repo is a pure distribution point - no source code lives
here directly, just versioned zip releases pushed here by each project's own
`scripts/pack.sh`/`pack.ps1`.

## Folder Structure

```
downloads/
└── terminal/                        # https://github.com/PatrikEigenmann72/terminal
    ├── enigma/
    │   └── v01.04/
    │       ├── enigma_mac_bin.zip    # compiled binary + manual + release notes
    │       └── enigma_mac_src.zip    # buildable source + pmake + compile scripts
    ├── pmake/
    │   └── v01.07/
    │       ├── pmake_mac_bin.zip
    │       └── pmake_mac_src.zip
    └── treeclone/
        └── v01.03/
            ├── treeclone_mac_bin.zip
            └── treeclone_mac_src.zip
```

Each top-level folder (`terminal/` today; more will show up as other project repos start
publishing releases here) matches the project a tool was built from. Below that: one folder per
tool, one `v<major>.<minor>/` folder per release, holding whichever `_bin.zip`/`_src.zip` pairs
that release shipped.

## What's in each release

- **`<tool>_<os>_bin.zip`** - the compiled binary, its manual (`<tool>.pdf`), and a `Notes.pdf`
  covering the one-time Gatekeeper/SmartScreen approval an unsigned binary needs on first run.
- **`<tool>_<os>_src.zip`** - the tool's own source plus every shared library file it depends on,
  the `pmake` build tool itself, `scripts/compile.sh`/`compile.ps1`, and a `Notes.txt` covering
  that same approval step for the bundled `pmake` binary - or how to skip it and hand-build the
  compiler command yourself from the project's own `.pmake` recipe instead.

## Available tools

- **enigma** - a modern, software-based reimplementation of the WWII Enigma cipher machine.
- **pmake** - a small C build tool: reads a plain-text `<project>.pmake` recipe and hands the
  compiler exactly what it needs, no DSL, no ceremony.
- **treeclone** - a compact reimplementation of the Unix `tree` command.

## Author

Patrik Eigenmann. Same spirit as [terminal](https://github.com/PatrikEigenmann72/terminal),
[legacy](https://github.com/PatrikEigenmann72/legacy), and
[arcade](https://github.com/PatrikEigenmann72/arcade) - small, personal, spare-time projects
built to understand how things work, not to ship a product.
