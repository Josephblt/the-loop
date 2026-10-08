# Level Model

The Loop uses a maze with stable emotional anchors and unstable generated paths.

## Spatial Structure

- **Center:** the player's start point and loop reset anchor.
- **Four static landmarks:** fixed destinations for Denial, Anger, Bargaining, and Depression.
- **Outer edge:** the Acceptance destination.
- **Generated maze body:** all paths, walls, shortcuts, branches, and traversal geometry between the anchors.

The landmarks are static. Everything else is generated each time.

## Active Destination Rule

Each grief stage has one active destination.

When a stage is active:

- Its matching landmark is active.
- The other grief-stage landmarks remain physically present but inactive.
- Inactive landmarks do not complete objectives or resolve the stage.
- The maze can still route the player near inactive landmarks if that supports tension.

Acceptance is structurally different from the four inner destinations. It is represented by the outer edge of the maze rather than a normal landmark.

## Generation Principle

The generator should not produce a generic random maze. It should produce a stage-specific maze that supports the active smoke behavior.

Each grief stage should define:

- Active destination
- Smoke behavior
- Maze generation biases
- Required traversal features
- Forbidden or discouraged traversal features

This keeps the maze random while preserving authored horror.

## Denial Maze Bias

Denial's smoke behavior requires flanking and re-entry into the player's field of view.

The Denial maze should prefer:

- Looping paths
- Parallel corridors
- Side passages that reconnect ahead of the player
- Short flank routes near the active destination
- Corners, openings, and bends where the smoke can naturally become visible again

The Denial maze should avoid overusing:

- Long straight corridors
- Isolated dead ends
- Single-file paths with no side access
- Layouts where the smoke cannot circle the player without teleporting
