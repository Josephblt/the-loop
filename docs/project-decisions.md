# Project Decisions

This file records decisions that are stable enough to guide implementation.

## 2026-10-05: Project Foundation

The Loop is now an official project repository:

<https://github.com/Josephblt/the-loop>

Locked decisions:

- The game is about grief and grief's never-ending loop.
- The experience resembles the five stages of grief in a never-ending cycle.
- The only characters are the player and the smoke antagonist.
- The smoke's main goal is to hunt and engulf the player.
- Smoke hunting behavior reflects the current grief stage.
- The level has six authored rooms plus a generated maze.
- The central room is the player spawn and loop reset anchor.
- Four static cardinal rooms on the north, south, east, and west edges represent Denial, Anger, Bargaining, and Depression.
- The maze surrounds the central room and sits between spawn and the four cardinal grief rooms.
- The maze has four fixed inner gateways connecting it to the central room.
- The maze has four fixed outer cardinal gateways connecting it to Denial, Anger, Bargaining, and Depression.
- Acceptance is a separate sixth room reached through gateways on the corner edges of the maze.
- The final room memory must feel like part of the person's lived experience, not a summary or authorial explanation.
- The game should express itself through the feelings of the person living the premise rather than through authorial explanation.
- Only one grief-stage destination is active at a time.
- The maze body is generated randomly each time.
- Maze generation should be tailored to the active smoke behavior.

## 2026-11-01: Maze And Room Smoke Roles

The original closure-only room design has been superseded.

- Each stage uses a Maze Hunter to teach the player a stage-specific survival response.
- The corresponding Room Guardian makes that learned response dangerous and forces the player to break it.
- Maze memories remain in the maze, while each cardinal grief room holds its Closing Memory on an altar.
- After collecting the required maze memories, the player enters the active grief room, resolves its Room Guardian encounter, reaches the altar, and views the Closing Memory to end the stage.
- Acceptance is different: the smoke must be willingly embraced, its engulfment is nonlethal, and the altar materializes afterward for the Story Reveal.
- The smoke represents grief and suffering rather than an evil force to be defeated.
