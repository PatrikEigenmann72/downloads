# pmake

```text
NAME:
      pmake - Version: 01.07

SYNOPSIS:
      pmake [makefile] [--debug[:level]] [--keywords:csv] [-h | -H | -help | -Help | -?]

DESCRIPTION:
      pmake reads a <project>.pmake file and translates its contents into compiler
      instructions. There is no scripting language, no hidden behavior, and no
      abstraction layer. The file is intentionally simple so the developer stays
      in control and always understands what the compiler is doing.

      pmake is designed for people who prefer clarity over complexity. If you want a
      build tool that behaves exactly as it saysΓÇönothing more, nothing lessΓÇöpmake
      stays out of your way.


OPTIONS:
      makefile
          A project makefile is named <project>.pmake. It contains the compiler
          settings for the project in a minimal, human-readable format. There are
          no conditionals, loops, or DSL constructsΓÇöjust straightforward
          configuration.

      --debug, --debug:<level>, --debug=<level>
          Enables pmake's own runtime diagnostic output while it compiles your
          project - not a flag passed to the project's own compiler. --debug alone
          shows everything; --debug:<level> narrows it to verbose, info, warn,
          error, or all. Either : or = works.

      --keywords:<csv>, --keywords=<csv>
          Narrows pmake's own diagnostic output (see --debug above) to lines tagged
          with one of the given comma-separated keywords. Either : or = works.

      -h, -H, -help, -Help, -?
          Displays the integrated manpage. All variants are accepted for
          convenience.

      --version
          Prints the tool's identity block and exits.


LICENSE:
      Copyright 2024 Free Software Foundation, Inc. License GPLv3+: GNU GPL
      version 3 or later <https://gnu.org/licenses/gpl.html>. This is free
      software: you are free to change and redistribute it. There is NO WARRANTY,
      to the extent permitted by law.
```
