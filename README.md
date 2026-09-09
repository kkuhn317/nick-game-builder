# Nickelodeon Game Builder restoration

A preservation-focused attempt to revive Nickelodeon Game Builder using its surviving Flash code. The editor prototype runs original editing, level construction, tile collision, camera and character systems with replacement visuals. It also includes playback controls for 13 archived music tracks.

## Run the working editor

From this repository folder, start the local server:

```sh
python server.py
```

Open this URL in a standalone Flash Player:

```text
http://localhost:8000/BuilderMain-editor.swf?v=editorMusic4&builderType=spongebob&propertyAlias=gb_danimals&dataPath=data/&slotID=-1&debug=true
```

Alternatively, open `http://localhost:8000/play_editor.html` in a Flash-capable browser. Modern browsers do not run the Flash plugin. The bundled Ruffle pages are experiments, not the validated runtime.

- **Paint / Erase:** draw or remove tiles.
- **Move:** drag a tile or hero; drag empty space to pan. Dropping nonunique objects outside the canvas deletes them.
- **Hero / Zoom:** center on the hero or change zoom. Arrow keys scroll in edit mode.
- **Test / Edit:** switch modes. In Test, arrows/A-D move, Space jumps, R restarts. Allow a few seconds for level construction.
- **Music > / Mute:** select among 13 archived tracks or mute music.
- **Export XML:** save the current level. Import is not implemented yet.
- **F2:** show diagnostic logs; errors reveal the panel automatically.

## Current state

The user confirmed the editor and gameplay prototype working, including the fix for repeated background-update errors. This is a restoration prototype, not the complete original game. The interface and character/tile visuals are replacements. Most UI assets are absent or dummies; archived music pack 13 is a malformed placeholder and is excluded from playback. Goals, enemies, full asset selection, original step screens, local import/save slots and website services still need restoration.

`server.py` preserves the existing development behavior of substituting dummy SWF/PNG files for some missing requests. A successful HTTP response does not prove an asset is original or usable.

## Build and verify

Requirements: Java, JPEXS FFDec (developed with 26.2.1), Node.js, and PowerShell. Python is used by the local server. Flash Player is needed for runtime checks; external executables are not bundled.

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File editor/build.ps1
# Supply a different JPEXS installation if needed:
# ./editor/build.ps1 -FfdecJar 'D:/tools/ffdec/ffdec.jar'
node editor/audit-music.cjs
node releases/verify-baseline.cjs
```

The build starts from the unmodified SWF and verifies exactly nine adapted bytecode blocks; all other tags remain intact. The verifier also compares core editing and level-construction methods against the original source export. See [the editor notes](editor/README.md) and [contributing guide](CONTRIBUTING.md).

## Repository map

- `BuilderMain unmodified.swf`: original build input. `BuilderMain.swf` is an older heavily patched experiment.
- `editor/scripts`: active ActionScript adaptations; `editor/build.ps1` and verification tools reproduce/check the build.
- `BuilderMain-editor.swf`: current runnable editor.
- `releases/editor-music4`: frozen working SWF, source snapshot and hash manifest.
- `analysis/original/scripts`: reference decompilation; `analysis/RESTORATION-ASSESSMENT.md`: initial findings.
- `diagnostic`, `harness`: earlier diagnostic and engine-only prototypes, with separate runnable SWFs.
- `assets`, `data`, `gameBuilder110222`: recovered files, configuration and known placeholders. Existing dummy-file markers are retained.

Logs, intermediate builds, verification exports and superseded experiments remain local and are ignored by Git.

## Provenance

Archive references supplied with the project:

- [Nick game-builder archive index](https://web.archive.org/web/*/https://www.nick.com/nick-assets/gamebuilder/*)
- [Builder Main archive](https://archive.org/details/builder-main/)

Recovered code and assets retain their original ownership. Replacement source is identified in the restoration notes; this repository does not claim that dummy files reproduce the original artwork or apply a new license to archived material.
