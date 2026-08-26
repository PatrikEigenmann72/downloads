# pmake v01.07 - Changelog

```text
Mon 2026-08-24 Versions 00.01-00.32: initial build-out - merged cVersion/cManPage       Version: 00.32
               in, target=obj/exec/shared handling, the library-string rewrites,
               the switch to {project}.pmake, a complete overhaul, manpage help
               text passes, the Samael framework port, outsourcing all logic to
               pmake.c (main.c became a thin entry point), --version, UTF-8
               Windows console support, and this cycle's fixes: -DDEBUG removed
               for --debug/--keywords, a missing-file segfault, an argv-order
               filename bug, debug_err()/log_err() on every error exit, and a
               --version argv-position bug. Full entry-by-entry history archived
               in main.changelog.txt.
Mon 2026-08-24 Major Release.                                                          Version: 01.00
Mon 2026-08-24 Added this file's own MAJOR/MINOR - now the version every project's         Version: 01.01
               own main.c carries, read by run() (see pmake.c) to name that project's
               output binary, universally, in place of the old <project>.c convention.
               Independent of pmake.c's own MAJOR/MINOR (pmake's own --version identity).
Mon 2026-08-24 Reverted 01.01's split: two independently-bumpable version numbers      Version: 01.02
               for one binary made no sense. manpage_display() and component_display()
               moved here from pmake.c too, alongside MAJOR/MINOR - both read the same
               pair run() reads from this file, so there's exactly one version number
               for the whole binary, not two that can drift apart. pmake.c is pure
               build-tool logic now (parse/run/Makefile lifecycle/filename handling).
Mon 2026-08-24 component_display() un-static'd and given a formal extern contract          Version: 01.03
               in the new shared/toolbox/help/version.h, mirroring manpage_display()'s
               existing one in manpage.h - every project is now expected to supply its
               own component_display() too, not just pmake.
Mon 2026-08-24 Removed the To Do's block - every item on it was already marked         Version: 01.04
               Done, including one (-DDEBUG) that's since been removed entirely.
Mon 2026-08-24 Fixed a stale comment above #include "pmake.h" claiming a             Version: 01.05
               nonexistent "parse.h" defined the .pmake-reading logic (that's
               pmake.h/pmake.c) and describing debug.h/version.h/manpage.h as if
               they belonged to this one include, when they're already listed
               separately above.
Mon 2026-08-24 Removed GIT/GitHub entirely - the header comment and --version's         Version: 01.06
               printed URL disagreed with each other and with pmake.c/pmake.h's own
               (three different wrong URLs across three files), and the real one
               will change anyway. Simpler to have none than a wrong one.
Mon 2026-08-24 Fixed this file's own header comment: eMail said p.eigenmann@gmx.net,   Version: 01.07
               but the EMAIL macro --version actually prints is p.eigenmann72@gmail.com
               - confirmed that's the correct one, now matching.
```
