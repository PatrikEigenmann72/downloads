# treeclone

```text
NAME:
      treeclone - Version: 01.03

SYNOPSIS:
      treeclone [--exclude:csv] [--debug[:level]] [--keywords:csv]
      treeclone [-h | -H | -help | -Help | -?] [--version]

DESCRIPTION:
      treeclone - as the name suggests, this is a simple clone of the CLI tree.


OPTIONS:
      --exclude:csv, --exclude=csv
      Comma-separated patterns to exclude from the tree, matched as a plain
      substring against each entry's name (no globbing). ".txt" excludes
      every file whose name contains it (e.g. any *.txt file); ".git/" (a
      trailing slash) excludes that exact directory name; a bare word like
      "bin" excludes anything matching that pattern - a bin/ directory or
      any file containing "bin" in its name. Merges with the built-in
      defaults (*.tmp, tmp/, .vscode, .git/, .DS_Store, bin/, build/), not
      a replacement for them. Either : or = works.

      --debug, --debug:<level>, --debug=<level>
      Enables treeclone's own runtime diagnostic output. --debug alone shows
      everything; --debug:<level> narrows it to verbose, info, warn, error, or all.
      Either : or = works.

      --keywords:<csv>, --keywords=<csv>
      Narrows treeclone's own diagnostic output (see --debug above) to lines
      tagged with one of the given comma-separated keywords. Either : or = works.

      -h, -H, -help, -Help, -?
      Do you need help? Any of these flags will open the application's manpage.
      This UNIX-style help file, familiar to developers and system administrators,
      is integrated into treeclone itself. The beauty of this approach is that anyone
      working on macOS, BSD, UNIX, or Linux will instantly feel at home with the layout.
      Think of it as your built-in guide whenever you need more insight into the
      program treeclone.

      --version
      Prints the tool's identity block and exits.


LICENSE:
      Copyright 2024 Free Software Foundation, Inc. License GPLv3+: GNU GPL version 3
      or later <https://gnu.org/licenses/gpl.html>. This is free software: you are free
      to change and redistribute it. There is NO WARRANTY, to the extent permitted by law.
```
