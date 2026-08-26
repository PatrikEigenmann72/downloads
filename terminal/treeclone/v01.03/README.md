# treeclone v01.03 - Changelog

```text
Change Log:
Mon 2026-08-24 Versions 00.01-00.11: initial build-out - CLI parsing, Samael          Version: 00.11
               logging/debug integration, config_init() with a default exclusion
               filter, the walk()/is_excluded() kernel (eventually moved into
               treeclone.h/.c), and Windows UTF-8 console support. Full
               entry-by-entry history archived in main.changelog.txt.
Mon 2026-08-24 Major Release.                                                        Version: 01.00
Mon 2026-08-24 MAJOR/MINOR, manpage_display(), and version_display() (renamed        Version: 01.01
               component_display(), fulfilling the shared/toolbox/help/version.h
               contract) moved in from treeclone.c, along with is_version_triggered()
               as a static helper - this file is now the one canonical place for
               this project's identity/version (see pmake's own changelog for the
               full reasoning). Removed the stale -DDEBUG compile-instructions block
               above and the wrong GitHub line - pmake no longer has -DDEBUG at all,
               and the URL will change anyway. Also fixed two real bugs found in the
               moved manpage_display(): the OPTIONS text said "helloc" instead of
               "treeclone" (copy-paste residue), and "-(\)?" was never actually
               checked by manpage_is_help_triggered() - fixed to the real flag, -?.
Mon 2026-08-24 -exclude "csv" (a separate argv token for the value) replaced           Version: 01.02
               with --exclude:csv/--exclude=csv, matching --debug/--keywords'
               convention - one flag, one token, either separator. Manpage OPTIONS
               text rewritten to document the actual matching semantics (plain
               substring, no globbing - ".txt" for an extension, ".git/" for an
               exact directory, a bare word for anything matching that pattern).
Mon 2026-08-24 BugFix: --exclude:.git/ (or any trailing-slash token) was also         Version: 01.03
               hiding files whose name happened to contain the same letters, e.g.
               "bin/" hiding "cabin.txt" too. is_excluded() needs to know whether
               an entry is a directory to honor that distinction, so stat() now
               runs before the exclusion check instead of after - see
               treeclone.c's own changelog for the full reasoning.
```
