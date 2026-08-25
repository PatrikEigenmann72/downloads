# downloads

## About

I'm Patrik Eigenmann, a sound engineer and former software engineer - nine years in software
before I moved into sound. These days I write software again in my spare time, partly to keep my
brain from rusting and slowing down. This repo is where I publish the compiled binaries and
buildable source archives for those personal tools - everything here is free to download, use,
and study. If you'd like to get in touch, reach me at <p.eigenmann72@gmail.com>.

## What's in each release

One folder per tool, one `v<major>.<minor>/` folder per release, holding a `_bin.zip` and/or
`_src.zip` for whichever platform built it.

- **`<tool>_<os>_bin.zip`** - the compiled binary, its manual (`<tool>.pdf`), and a `Notes.pdf`
  covering the one-time Gatekeeper/SmartScreen approval an unsigned binary needs on first run.
- **`<tool>_<os>_src.zip`** - the tool's own source code, a small build tool (`pmake`) bundled so
  you can compile it right away, and a `Notes.txt` covering that same approval step - or how to
  skip it and compile by hand instead.

## Folder Structure

```text
downloads/
└── terminal/
    ├── enigma/                # CLI version of the WWII Enigma cipher machine
    │   └── v01.04/
    │       ├── enigma_mac_bin.zip
    │       └── enigma_mac_src.zip
    ├── pmake/                 # CLI version of the classic Make build tool
    │   └── v01.07/
    │       ├── pmake_mac_bin.zip
    │       └── pmake_mac_src.zip
    └── treeclone/             # CLI clone of the UNIX tree tool
        └── v01.03/
            ├── treeclone_mac_bin.zip
            └── treeclone_mac_src.zip
```

"Version" and "clone" above are deliberate: a version gives me artistic and architectural
freedom - it only has to match the original conceptually, filtered through my own
interpretation. A clone stays much closer to a copy - it may vary a little in execution, but
the result and behavior match the original exactly.

## Support

This software is free, and always will be - but if you use it and feel my time was worth
something, I'd gladly accept a donation. Just send me an email and I'll happily share my PayPal,
Venmo, or Zelle.
