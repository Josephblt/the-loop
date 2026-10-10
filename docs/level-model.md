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

All active threat, chase, and battle pressure happens inside the maze section. The smoke belongs to the maze as the primary hostile force.

The authored rooms are not combat arenas. They are closure spaces reached after the player gathers the required memories for the active stage in the current loop. Their job is to present the collected maze memories back to the player in an intentional order, then give the player one loop-specific room closing memory that lets the emotional shape of those memories land.

The closing memory should give meaning to the stage without giving it away entirely. It should feel like another piece of the person's lived experience, not a summary or authorial explanation. The rooms must not reveal the loop premise, name the stage of grief, or give concrete interpretation. The game should express itself through the feelings of the person living the premise.

Room flow:

1. The player gathers memories in the maze.
2. The player reaches the active grief room.
3. The room quiets the threat pressure.
4. The collected memories are shown together.
5. The memories are arranged into a felt sequence.
6. A loop-specific room closing memory ties the sequence together emotionally while preserving ambiguity.
7. The next stage or transition opens.

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
