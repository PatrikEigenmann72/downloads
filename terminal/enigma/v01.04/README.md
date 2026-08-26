# enigma v01.04 - Changelog

```text
Change Log:
Mon 2026-08-24 Versions 00.01-00.06: initial build-out - CLI functionality       Version: 00.06
               (-e/-d), manpage functionality, debug/log outputs, UTF-8 Windows
               console support, and the MacOS/Linux flush bugfix. Full
               entry-by-entry history archived in main.changelog.txt.
Mon 2026-08-24 Major Release.                                                    Version: 01.00
Mon 2026-08-24 MAJOR/MINOR, manpage_display(), and component_display() moved     Version: 01.01
               in from enigma.c - this file is now the one canonical place for
               this project's identity/version (see pmake's own changelog for
               the full reasoning). Removed the stale -DDEBUG compile-instructions
               block above and the wrong GitHub line - pmake no longer has
               -DDEBUG at all, and the URL will change anyway.
Mon 2026-08-24 argc safety: mode/input no longer read argv[1]/argv[2]              Version: 01.02
               unconditionally - bare `enigma` with no args read argv[2] past
               the guaranteed-valid range (undefined behavior). Added the same
               argc<2/manpage_is_help_triggered() and --version-anywhere checks
               pmake's main() already has, plus a clear error instead of a NULL
               dereference when -e/-d is given with no input.
Mon 2026-08-24 BugFix: -e/-d segfaulted on every real invocation. output stayed        Version: 01.03
               NULL the whole time - passed by value into enigma_encrypt_string()/
               enigma_encrypt_file() (and the decrypt equivalents), which write
               into it character-by-character with no allocation of their own.
               Those four functions now allocate and return the buffer themselves
               (see enigma.c/enigma.h's own changelogs) - call sites here updated
               to take the return value, check it for NULL, and free() it after
               printing. Also fixed the manpage's "-(\)?" claim (never actually
               checked by manpage_is_help_triggered() - just fell through the
               generic unrecognized-mode fallback) to the real flag, -?.
Mon 2026-08-24 BugFix: encrypt/decrypt round trips grew a blank line every time.    Version: 01.04
               printf("%s\n", output) always appended '\n', but output already
               ends in '\n' whenever the input did (echo'd strings, most text
               files) - '\n' isn't in the rotor alphabet so it passes through
               encryption/decryption unchanged. Added print_output(), which only
               appends '\n' when output doesn't already end with one - still
               covers the original "stray %" fix for output with no trailing
               newline, without doubling up when there already is one.
```
