# Editor restoration notes — editorMusic4

The root README contains current run instructions and controls. This is the working baseline confirmed by the user after the repeated background-update error was fixed. Its immutable copy and exact source are in `releases/editor-music4`.

## Original behavior retained

The original ToolManager performs painting, erasing, selection/dragging, flipping, overlap protection, panning and scrolling. Replacement toolbar controls select original LibraryItemDefinition objects. A simple translucent preview replaces missing cursor artwork.

Test mode uses original level bounds, staged element creation, StillGenerator, TileSurface, TileManager collision geometry, Viewport, character controllers, GameSession and Box2D. Physics and camera updates remain active; background scrolling runs only when a BackgroundManager exists.

Thirteen archived music SWFs load through unchanged MusicMedia and play through unchanged SfxManager, SoundManager and SoundUnit. Full tracks load before playback to avoid missing preview SWFs. Music > cycles tracks and Mute controls the music category. The selected music alias is included in XML exports. Pack 13 is a malformed 32-byte placeholder and is excluded.

## Nine adapted bytecode blocks

1. BuilderMain: prototype bootstrap, static character frame preparation, controls, sound-category initialization, music selection, editor/test transitions and XML export.
2. BuilderManager: suppress the absent publish-screen notification in prototype mode.
3. PlayableCharacterMedia: reserved procedural hero and preview linkages.
4. TileSurfaceMedia: reserved procedural tile linkages and cached bitmap frame for StillElement.
5. GamePlayer: prototype media list and HUD/background boundary, staged construction entry and safe teardown. Earlier harness methods remain but are not used by current Test mode.
6. ToolManager: replacement control/preview initialization and prototype activation; missing tool effects remain silent. Core editing methods are unchanged.
7. GamePlayerHUD: plain life/score text instead of missing HUD assets.
8. SoundConfig: defer mouse/popup sound class lookup until requested, keeping category names, volumes and fades original.
9. BuilderSoundConfig: prototype tool effects return empty lists to the silent handler; selector sound lookup is deferred.

All other original bytecode and SWF tags are preserved. This includes BuilderData, BuilderRenderer, LibraryItemDefinition, TileElement, TileSurface, TileManager, StillGenerator, Viewport, GameSession, MusicMedia, SfxManager and PlayableCharacter.

## Remaining work

Only the procedural hero and full floor tiles are selectable. Tile variants share a drawing. The original palette, step screens, backgrounds, goals, enemies, end-of-game popup and website services are not restored. XML export works; import and persistent save slots are the next milestone. The old fixed safety floor is absent from current Test mode.

## Build and validation

From the repository root:

```powershell
./editor/build.ps1
node editor/audit-music.cjs
node releases/verify-baseline.cjs
```

The build requires Java, JPEXS and Node.js. Pass `-FfdecJar` for a different installation. It imports the nine source replacements into the unmodified SWF. Verification checks allowed bytecode changes and compares selected original tool and level-construction method bodies against the reference decompilation.

For runtime checks, paint, erase, drag, pan, zoom, enter Test, restart, return to Edit, repeat, switch/mute music and export XML. F2 exposes the log; errors show it automatically. Compilation and preservation checks do not prove every runtime path. See `UI-CONTRACT.md` for remaining asset contracts.
