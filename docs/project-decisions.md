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
- All active threat, chase, and battle pressure happens inside the maze section.
- The grief rooms are closure spaces, not combat arenas: for each loop-stage pair, they show the gathered maze memories in an intentional order, then provide one loop-specific room closing memory that gives the stage emotional meaning without fully giving it away.
- The closing memory must feel like part of the person's lived experience, not a summary or authorial explanation.
- The game should express itself through the feelings of the person living the premise rather than through authorial explanation.
- Only one grief-stage destination is active at a time.
- The maze body is generated randomly each time.
- Maze generation should be tailored to the active smoke behavior.
