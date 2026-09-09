# UI requirements traced from the original code

## Working-screen target

`BuilderScreen` normally gets `mcBuilderScreen` from a UI library and passes its `mcBuilderZone` child to BuilderManager. This prototype creates the zone directly rather than invoking the missing step-screen wrappers.

Required zone structure:

```text
editorSurface (MovieClip; replacement for mcBuilderZone)
  mcRenderArea (MovieClip; explicit bounds)
  mcGoalDisplay (MovieClip)
    mcIcon (MovieClip)
    mcText (MovieClip)
      txtText (TextField)
```

The named children are registered as both display children and dynamic properties because the original code uses direct property access. BuilderRenderer allocates its backbuffer from mcRenderArea dimensions and inserts the Bitmap immediately above it. BuilderManager accesses the goal display even when the selected goal does not show an icon, so hiding that display does not remove its structural requirements.

Background is null in this prototype. Original BuilderRenderer already supports this; no background bypass patch is required. A grid in the replacement render-area MovieClip remains visible beneath its transparent backbuffer.

## Original ToolManager: v2 connected through a host adapter

Its initialization requires `mcTools` with `btnEraser`, `btnTrash`, `btnZoom`, and `btnHero`, each compatible with the original Button wrapper. It also creates ToolCursor, registers localized tooltips, uses selection-grid definitions, and references StepManager for step-specific behavior. Recreating only four rectangles would not satisfy those contracts.

The first prototype supplied click/drag input directly. v2 calls the original ToolManager operations instead. Prototype initialization uses the replacement toolbar and a translucent bitmap preview; it does not instantiate mcTools, tooltip bindings or the animated ToolCursor. Original paint, erase, selection/drag, flip, panning and scroll methods remain unchanged. The prototype active-screen condition replaces the missing step/popup wrappers, and tool sound playback is silent because the sound assets are missing.

## Original GamePlayer: v2 level construction

GameData and the reserved MediaList enter the original bounds/container/staged-creation pipeline. TileSurface requires its asset's bitmap frame to be registered before StillElement.fromClass; TileSurfaceMedia supplies that static frame for the procedural tile. Original StillGenerator, TileManager and Viewport then handle rendering panels, edge geometry and camera movement. GamePlayerHUD has a prototype text-display branch. Background and initial goal/help presentation are host boundaries; the full step screen and media loading service flow remain future work.

## Remaining original screen hierarchy

StepManager eagerly constructs the step header, builder/test/publish screens, selection popups, test-loading popup and tutorial. Restoring that full path requires recreating exported classes, child hierarchies, button wrappers and timeline state labels. The 17-symbol diagnostic checklist was only an initial missing-symbol check, not a complete asset contract.

Preservation rule: reconstruct asset contracts where possible. Keep any host-only adaptations separate and documented. Do not reintroduce empty catches or substitute empty objects for required structures.
