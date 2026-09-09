# Nickelodeon Game Builder code assessment

Inspected 2026-09-08 using locally installed JPEXS 26.2.1. Both BuilderMain SWFs exported successfully (409 script blocks each). Readable exports are in `original/scripts` and `patched/scripts`. These are decompiled reconstructions, not original authoring sources or a verified buildable project. No SWFs, server files, or game configuration were changed. No Flash runtime test was performed in this analysis.

## Main finding: the patched startup has a disconnected completion path

Original flow:

1. `BuilderMain.init` creates the view manager and loads config.
2. `onExternalConfigLoaded` initializes game data, the external loading screen, services, and proxy.
3. Proxy readiness leads to sound config, property config, localization, external UI libraries, and the media catalog.
4. Preview assets load and selected game assets are converted to bitmaps.
5. `LoadedScreen` listens to these stages and advances its `SteppedProgressBar`.
6. Progress-bar completion calls `LoadedScreen.onAllComplete`, which calls `BuilderMain.startApplication`.
7. For a new game (`slotID=-1`), startup calls `StepManager.instance.start()`.

The patched `LoadedScreen.onBeforeShow` is empty. It creates no progress bar and registers none of the startup progress listeners. The only explicit call to `BuilderMain.startApplication` in the exported patched scripts remains `LoadedScreen.onAllComplete`. Therefore the normal new-game startup path cannot complete through this mechanism, even if asset loading and rendering finish. This is a definite code defect, not a runtime diagnosis of the first exception in the supplied run.

Also, `LoadedScreen.onHide` still calls `oProgressBar.destroy()` unconditionally despite the initialization having been removed. Simply forcing startup elsewhere can expose this additional null access.

## What the patches change

Eight exported script files differ between versions; not every textual difference changes behavior.

| Script | Material difference |
| --- | --- |
| `BuilderMain` | Empties `showPreloadError`, `initTransitions`, and `initPopups`; removes default UI sound setup, sound auto-balancing, and tooltip asset setup. |
| `ui.screens.LoadedScreen` | Removes progress UI initialization and the event chain that starts the application. |
| `services.ProxyManager` | Calls `onProxyReady(null)` directly after download, instead of obtaining the external proxy, assigning its responder, and loading proxy configuration. |
| `media.type.AbstractMedia` | Substitutes base `MovieClip` for missing game/preview symbol definitions. |
| `media.type.MusicMedia` | Substitutes `MovieClip` for missing `musicPreview`. |
| `SoundConfig` | Replaces four sound classes with `Object`. |
| `VectorToBitmapConverter` | Adds empty clip/bitmap/rectangle/collider fallbacks and catches insertion errors without reporting them. |
| `DisplayAssetFactory` | The exported difference only adds explicit `this` qualifiers to two member accesses; this is not evidence of a functional fix. |

## Dependencies that remain after fixing startup

- `StepManager.init` immediately constructs `mcLoadingOverlay`, the header, screens, selection popups, and tutorial. A direct call to `startApplication` cannot replace their missing exported classes.
- `BuilderScreen` requires `mcBuilderScreen`, then accesses its `mcBuilderZone` child. Matching a class name alone is insufficient; child names, types, and animation states also matter.
- The original loading screen accesses `mcErrorMessage`, `mcPreloader`, and error text fields. Its replacement font SWF supplies none of these.
- Empty MovieClips have no useful preview bounds. `AbstractMedia.createPreview` constructs a bitmap directly from those bounds without a minimum-size clamp.
- Character media names 19 game linkage classes and two preview classes (`mcPreview`, `mcSelectionWheelIcon`). A first prototype can share simple drawings across classes, but must still fulfill the expected interfaces.
- `VectorToBitmapConverter.extractCollider` interprets children whose names begin with `_` as collision markers and strips that prefix. `PlayableCharacter` immediately reads the `body` and `crouch` collider rectangles, so a replacement character needs appropriately sized `_body` and `_crouch` markers, not merely a visible rectangle.
- `MusicMedia` expects a `gameMusic` sound class and a separate `musicPreview` class. The generic preview replacement is not a correct sound implementation.

## Useful surviving mechanisms

- Full method bodies for builder management, game data serialization, character states, Box2D physics, and media loading are readable. This makes an engine-preserving prototype worth attempting, but does not prove the complete application is runnable.
- The original code already supports `fakedService_path`. `MediaService` uses a local media-list response; `GameDataService` requests `templateList/<builder>_<property>.xml` and `template/<alias>.xml` under that path. Those template resources are not supplied at the paths the current development mode expects.
- Media paths are constructed from configured media directory, builder/property/category, alias, and type-specific suffix. `MediaList` does not use each media entry's `file` attribute when constructing these loaders. Editing that attribute alone will not redirect requests.
- Saving is implementable locally: `BuilderService.setGameData` compresses UTF-8 level XML and Base64-encodes it. Development mode targets `savedData/setGameData.php`; local Python handlers could implement the protocol without PHP. Saved games, loading, and publishing are separate endpoints and are not handled by the current static server.

## Recommended work order

1. Create a separate diagnostic SWF from the unmodified baseline. Add a plain on-stage text log and runtime error reporting that do not depend on any missing library. Report stage transitions, requested assets, missing symbols, and the first exception. Keep the existing patched SWF for comparison.
2. Make startup completion explicit and independent of the decorative progress bar. Disable or replace the old loading view coherently, including its lifecycle callbacks. Preserve meaningful failures instead of turning every failure into success. Acceptance: a visible status panel reliably identifies the current stage and missing dependency.
3. Build a narrow asset contract and a small fixture catalog. Start with one background, character, floor, and goal plus whatever interface and SFX dependencies that selected path actually requires. Generate distinct exported classes, valid nonzero bounds, and collision markers. Silence audio explicitly where possible. Do not preload the entire missing catalog.
4. Prove the original gameplay engine with a hand-authored level and minimal host UI. Acceptance: the character falls onto a floor, moves, jumps, collides, reaches a goal, and restarts. This is a bounded way to assess the engine before reconstructing the extensive editor UI.
5. Restore a small editor path with a valid background selection and blank template. Then implement local save/load. Acceptance: place objects, test the level, save it, restart, and load the same level.
6. Expand content and visual fidelity after the mechanics work. Investigate `theater.swf` independently before reusing its symbols; its compatibility was not established by this analysis.

Recommendation: continue toward a diagnostic prototype and one playable test level. Do not begin a full rewrite or a complete art recreation yet. The source supports a concrete recovery attempt, while the full editor remains a substantial reconstruction project.
