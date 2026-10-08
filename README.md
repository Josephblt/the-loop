# The Loop

The Loop is a horror game about grief and grief's ever-revolving loop.

The player is trapped in a maze built around the five stages of grief. The experience is not about clearing those stages in a clean line. It is about being pulled through a repeating emotional structure where recognition, pursuit, avoidance, and return keep reshaping the path.

## Core Premise

- Genre: horror
- Theme: grief as a recurring cycle
- Characters: the player and the antagonist only
- Antagonist: a shapeless smoke that hunts, tracks, and tries to engulf the player
- Structure: a maze with fixed grief landmarks and generated paths

## Design Pillars

1. **Two-character horror**
   The game has only the player and the smoke. The smoke does not imitate, speak, transform into characters, or perform extra narrative tricks. Its threat comes from how it hunts.

2. **Stage-shaped pursuit**
   The smoke's hunting behavior changes according to the current grief stage.

3. **Fixed emotional anchors**
   The center, grief landmarks, and acceptance boundary are stable. The maze around them changes.

4. **Generated instability**
   Each loop or run regenerates the space between landmarks while preserving the level's grief structure.

## Current Locked Rules

- The player always starts at the center of the maze.
- Four static landmarks are evenly distributed around the maze.
- Those landmarks represent Denial, Anger, Bargaining, and Depression.
- The outer edge of the maze represents Acceptance.
- Each grief stage has exactly one active destination.
- Other grief-stage destinations remain inactive while a stage is active.
- The landmarks are static, but everything else in the maze is randomly generated each time.
- Maze generation should be tailored to the active smoke behavior.

## Open Questions

- Exact smoke behavior for Anger, Bargaining, Depression, and Acceptance.
- Whether Acceptance is reached through normal navigation, special maze conditions, or stage mastery.
- Engine and implementation stack.
- Visual style, camera perspective, and control scheme.

See [Level Model](docs/level-model.md), [Smoke Behavior](docs/smoke-behavior.md), and [Project Decisions](docs/project-decisions.md).
