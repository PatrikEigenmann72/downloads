# downloads

## About

Compiled binaries and buildable source archives for the personal software tools I build in my
spare time. Everything here is free to download, use, and study.

## Folder Structure

```
downloads/
└── terminal/
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

One folder per tool, one `v<major>.<minor>/` folder per release, holding a `_bin.zip` and/or
`_src.zip` for whichever platform built it.

## What's in each release

- **`<tool>_<os>_bin.zip`** - the compiled binary, its manual (`<tool>.pdf`), and a `Notes.pdf`
  covering the one-time Gatekeeper/SmartScreen approval an unsigned binary needs on first run.
- **`<tool>_<os>_src.zip`** - the tool's own source code, a small build tool (`pmake`) bundled so
  you can compile it right away, and a `Notes.txt` covering that same approval step - or how to
  skip it and compile by hand instead.

## Available tools

- **enigma** - a modern, software-based reimplementation of the WWII Enigma cipher machine.
- **pmake** - a small C build tool: reads a plain-text recipe file and hands the compiler exactly
  what it needs, no DSL, no ceremony.
- **treeclone** - a compact reimplementation of the Unix `tree` command.

## About Me

Hi, I'm Patrik. I build small, personal software projects in my spare time - mostly to
understand how things work, not to ship a product. Everything here is free to use.

If you find any of it useful and want to support the work, I'd genuinely appreciate a donation -
just send me an email and I'll gladly share my PayPal, Venmo, or Zelle.

**Contact:** <p.eigenmann72@gmail.com>
