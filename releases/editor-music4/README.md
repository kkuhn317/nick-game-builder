# Preserved editorMusic4 baseline

This snapshot preserves the working build accepted by the user after the background-update fix. It includes the SWF and the nine adapted source files, plus the build and verification scripts as they stood at capture time.

Run `node releases/verify-baseline.cjs` from the repository root to verify the snapshot and original build input. Hashes cover raw bytes; source files in this snapshot are excluded from line-ending conversion.

To reproduce or restore it, copy this folder's `scripts`, `build.ps1`, `verify-swf.cjs` and `audit-music.cjs` into `editor` in a separate checkout, then run the normal root build instructions. The scripts assume their normal location under `editor`; do not execute the captured build script directly in this directory.

The original SWF and reference decompilation remain at their normal repository paths. The snapshot does not duplicate external Java, JPEXS or Flash executables. Music files remain under the archived media directory.
