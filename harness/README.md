# Original-engine harness v3

This is a separate prototype, built from `BuilderMain unmodified.swf`. It does not overwrite the original, previously patched, or diagnostic builds.

Version 3 fixes the harness restart teardown order. The previous code destroyed the character, then called `PhysEngine.update()`, which steps the world before removing queued bodies. Collision callbacks could therefore reach a partially destroyed character. Restart now unregisters the harness update listener, destroys the player and old physics world without stepping it, disposes the old rendering container, and recreates the scene and controller. The original physics and controller classes remain unchanged. Version 2 is preserved in this folder.

Version 2 addresses the reported `VectorToBitmapConverter.extractFrame` failure. The procedural pose is now rasterized explicitly into a real static frame, with normal/flipped images and body/crouch collider metadata registered through the original `BitmapDataCollection.insertData` API. This avoids requiring an authored Flash timeline on a code-drawn MovieClip. Bounds, collider dimensions, and visible pixels are checked before registration; failures remain errors. The original converter is unchanged but no longer used to prepare this procedural pose. Version 1 is preserved in this folder.

## Run

Start `python server.py` from the repository folder. In standalone Flash Player, File → Open:

```text
http://localhost:8000/BuilderMain-harness.swf?v=harness3&builderType=spongebob&propertyAlias=gb_danimals&dataPath=data/&slotID=-1&debug=true
```

Alternatively use `play_harness.html` in a Flash-capable browser. `play_harness_ruffle.html` is an optional Ruffle page and downloads its emulator from unpkg; it has not been runtime-tested.

Expected scene: a yellow character falls onto a dark floor, with two raised obstacles and a green finish zone on the right. Click the game to focus it. Arrows/A-D move, Space jumps, Down crouches, R recreates the player at spawn, and F2 toggles the selectable log. Audio is intentionally unconfigured and silent.

The log reports position and vertical velocity every 70 simulation updates. Expected landing is approximately feetY=440 and vy=0. Moving right and jumping should allow passage over the first obstacle. Entering the green area logs FINISH and disables movement; R starts again. The finish test is new harness logic, not a restoration of the original collectible-goal implementation.

## Scope and code changes

Only three original bytecode blocks change:

- `BuilderMain`: uses the existing application/update bootstrap and original config loading, then prepares procedural media and starts the harness. No external UI libraries, proxy, music files, or media previews are requested by this path.
- `GamePlayer`: adds a null-game-data harness initialization branch and small methods for a fixed scene, floor fixtures, player spawning, physics stepping, telemetry, finish detection and restart. The original level/editor orchestration is retained in the file but not exercised by this branch.
- `PlayableCharacterMedia`: the reserved `__harness` alias supplies one procedural MovieClip class for all 19 character game linkages. It has visible art and `_body` / `_crouch` collision markers. The normal asset behavior remains for other aliases. This intentionally does not reproduce original animation timing or appearance.

The actual `PlayableCharacter`, `AbstractMovingCharacter`, head/foot/cling sensors, `PhysEngine`, Box2D, input managers, bitmap renderer, and animation state machinery remain byte-for-byte unchanged. The platform bodies use the original surface category/filter constants and `SurfaceType` objects so the original sensors can recognize ground. This tests the original controller and physics, not a newly written movement approximation.

It is not yet a restored editor, original level loader, animated character pack, or original win/lose flow. It tests a single fixed scene without enemies, pits, sound, or scrolling. Crouching uses the original body logic, but the placeholder drawing remains the same pose.

## Build and validation

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File harness/build.ps1
```

Requires Java, JPEXS (default path in the script), and Node.js. Editable ActionScript is under `scripts`. Compilation and selected re-decompilation have succeeded. The build script checks that exactly the three intended bytecode blocks changed and all other SWF tags and stage settings match the original.

Browser automation could not launch in this environment (CreateProcessWithLogonW error 1056). The assistant could not perform a live run; the user subsequently confirmed version 2 gameplay. Send the first runtime error and the on-screen log if startup fails; otherwise report falling/landing, movement/jumping, finish, and restart behavior.

The user's version 1 run reached frame extraction and failed there. The user subsequently confirmed the version 2 demo runs. Its log includes the pose's actual timeline frame counts and `STATIC FRAME READY` after static frame registration.

Update: the user confirmed that the version 2 demo works, and supplied a restart failure stack. Version 3 addresses that failure and passes compilation/structural checks; repeated live restarts remain to be verified.
