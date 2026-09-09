# Diagnostic build v3

`BuilderMain-diagnostic.swf` is derived from `BuilderMain unmodified.swf`. Three scripts change: BuilderMain (logging and an initial UI-symbol checklist), LoadedScreen (an asset-independent loading view), and ProxyManager (opt-in local development mode and explicit missing-proxy errors). Versions 1 and 2 are preserved in this directory.

Version 2 replaces the confirmed failing preloader UI. It waits for configuration, UI assets, media loading and rendering completion before scheduling startup once. It subscribes to all four signals up front so synchronous completion cannot be missed. It cancels pending startup on a reported loading error, hide, or destruction. It does not pretend missing assets are valid.

Version 3 adds `localProxy=true`: with `fakedService_path` configured, it deliberately uses the original development data routes without loading the absent website bridge. Website tracking/callbacks are disabled in this mode; unexpected requests for a production proxy service fail explicitly. This is not a working save/publish backend. Omit the flag to retain version 2's strict external-proxy check.

After UI libraries finish downloading, version 3 checks an initial list of 17 required exported symbols and lists all missing entries before stopping. This avoids one run per missing UI symbol, but does not yet validate child structures, timelines, or every editor component.

## Run

Start the existing server from the repository folder:

```powershell
python server.py
```

In standalone Flash Player, choose File → Open and paste:

```text
http://localhost:8000/BuilderMain-diagnostic.swf?v=diagnostic3&builderType=spongebob&propertyAlias=gb_danimals&dataPath=data/&slotID=-1&debug=true&localProxy=true
```

For a Flash-capable browser, open `http://localhost:8000/play_diagnostic.html`.

The dark text panel records elapsed time, startup method entries, the loading-screen URL, preload errors, and uncaught errors. Select its text and copy with Ctrl+C; scroll with the mouse wheel. F2 hides/shows it. Output also goes to Flash `trace`. Stack traces are included when the runtime supplies them; a standard player may report only the error name/message/number. The uncaught-error listener does not prevent the player's default error handling.

Send the panel text (especially the first error), together with the server request log. The existing server still substitutes dummy files, so HTTP 200 is not proof that an asset is usable. A stalled stage without an exception is also useful evidence.

## Build

Editable sources are under `scripts`. The decompiler's Embed annotation was removed from BuilderMain when importing the script; the existing embedded build-info class and binary tag remain in the SWF. Version 2 also reads `getStackTrace()` directly on the captured error: calling `Error(detail)` in version 1 constructed a new error and produced a misleading handler stack.

```powershell
powershell -ExecutionPolicy Bypass -File diagnostic/build.ps1
```

The build uses the installed JPEXS jar and Java. An optional `-FfdecJar` argument selects another installation. A temporary application-data profile prevents it from changing your normal JPEXS settings. The original and previously patched SWFs are never overwritten.

## Validation

Compilation and re-decompilation succeeded. `verified/scripts` records the compiled source reconstruction. `verify-swf.cjs` checks that only the three intended bytecode tags differ from the original and every other tag is preserved. Version 1 was run by the user and confirmed the missing preloader child failure; version 2 confirmed the missing root.proxy object. Version 3 still needs a live Flash Player run.
