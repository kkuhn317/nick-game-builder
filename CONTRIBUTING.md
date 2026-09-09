# Restoration workflow

Preserve as much original code as possible. Build from `BuilderMain unmodified.swf`; keep adaptations in `editor/scripts` and document each changed bytecode block. Reconstruct missing asset contracts rather than broadly swallowing errors. Original SWFs and dummy-file markers are evidence and should not be overwritten.

The active build is `BuilderMain-editor.swf`. Run `editor/build.ps1`, then `node editor/audit-music.cjs`. The build verifies allowed bytecode changes against the original, and compares recovered editing and level-construction methods against `analysis/original/scripts`.

Flash runtime checks: paint and erase a stroke, drag a tile and the hero, pan and zoom, enter Test, move/jump, restart, return to Edit, repeat, change/mute music, and export XML. Compilation and decompilation are not substitutes for these checks. Report the build URL/version and the first F2 error stack.

Keep logs, intermediate SWFs and verification exports local; `.gitignore` excludes them. Root runnable builds and versioned baselines are intentionally included. Use `node releases/verify-baseline.cjs` before changing a preserved baseline. Future work should get a new baseline directory rather than replacing the existing one.

No blanket license is asserted for recovered Nickelodeon/Sarbakan code or artwork. Keep provenance clear and do not label replacements as original assets.
