# Level Model

The Loop uses six authored rooms connected through a generated maze. The rooms give the grief cycle stable emotional anchors, while the maze between them changes on each run.

## Spatial Structure

- **Central room:** the player's spawn point and loop reset anchor.
- **Maze:** a generated ring surrounding the central room.
- **Four cardinal grief rooms:** Anger, Denial, Bargaining, and Depression sit outside the maze on the north, south, east, and west edges.
- **Acceptance room:** a separate sixth room reached from the corner edges of the maze.

The rooms and their gateway positions are static. The maze paths, walls, shortcuts, branches, and traversal geometry between those gateways are generated each time.

## Gateway Layout

The maze has two fixed gateway layers:

- **Inner gateways:** four gates in the middle of the maze's inner north, south, east, and west sides. These connect the central room to the maze.
- **Outer gateways:** four gates in the middle of the maze's outer north, south, east, and west sides. Each connects the maze to one of Anger, Denial, Bargaining, or Depression.

The Acceptance room is not reached through a cardinal outer gateway. It is reached through gateways on the corner edges of the maze.

Conceptual layout:

```text
          [North grief room]
                  |
        +---------G---------+
        | A?             A? |
        |                   |
[West]--G    +---G---+    G--[East]
[room]  |    |Spawn  |    |  [room]
        |    +---G---+    |
        |                   |
        | A?             A? |
        +---------G---------+
                  |
          [South grief room]
```

`G` marks fixed cardinal gateways. `A?` marks corner-edge acceptance gateway positions. The exact number of usable acceptance gateways can be tuned, but acceptance should remain spatially different from the four grief-stage rooms.

## Active Destination Rule

Each grief stage has one active destination.

When a stage is active:

- Its matching grief room is active.
- The other grief-stage rooms remain physically present but inactive.
- Inactive rooms do not complete objectives or resolve the stage.
- The maze can still route the player near inactive outer gateways if that supports tension.

Acceptance is structurally different from the four cardinal grief rooms. It is reached through the maze's corner edges rather than the north, south, east, or west outer gateway.

## Maze And Room Roles

Each active stage uses two smoke encounters with different purposes. The Maze Hunter creates sustained pressure and teaches a stage-specific survival response. The Room Guardian then makes that response dangerous, forcing the player to break it before reaching the altar.

The authored rooms are focused behavioral encounters reached after the player gathers the required memories for the active stage in the current loop. Maze memories remain in the maze; the grief room contains one loop-specific Closing Memory on its altar.

The active grief room entrance becomes available only after the player collects all required maze memories for that stage. Once the player enters, the room locks behind them. The player cannot return to the maze. They must resolve the Room Guardian encounter, reach the altar, and view the Closing Memory. Viewing it ends the stage and starts the next transition.

The closing memory should give meaning to the stage without giving it away entirely. It should feel like another piece of the person's lived experience, not a summary or authorial explanation. The rooms must not reveal the loop premise, name the stage of grief, or give concrete interpretation. The game should express itself through the feelings of the person living the premise.

Room flow:

1. The player gathers memories in the maze.
2. The active grief room entrance unlocks.
3. The player enters the grief room and the room locks behind them.
4. The Room Guardian turns the survival response learned in the maze against the player.
5. The player breaks that behavior and reaches the altar.
6. The Closing Memory ties the collected maze memories together emotionally while preserving ambiguity.
7. Viewing the Closing Memory ends the stage and starts the next transition.

Acceptance is the exception. Its room begins as an apparently infinite expanse of sand without an altar. After the player willingly allows the smoke to engulf them, the smoke dissolves and the altar materializes for the Story Reveal.

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
