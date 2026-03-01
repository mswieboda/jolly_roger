# Project: Jolly Roger (GSDL Game)

2D game development project written in Crystal using the `GameSDL` (GSDL) framework.

## Core Guidelines
- **Skill Reference:** Always follow the `game-dev-gsdl` skill for project structure, scene management, and asset standards.
- **Entry Point:** `src/jr.cr`. Modules and classes generally fall under the `JR` namespace.

## Game Architecture (GSDL)
- **Scenes:** Game logic is separated into scenes (e.g., `Scene::Start`).
- **Entities:** Inherit from `GSDL::AnimatedSprite` or similar base classes.
  - `Character` (Abstract): Base class for moving entities; handles tilemap collisions (`move_and_collide`) and animations.
  - `Player` (< `Character`): Driven by user input (`delta_input_movement`).
  - `NPC` (< `Character`): Driven by AI/scripted logic (currently placeholder). Distinguishable via `tint` parameter.

## Commands
- **Compile / Check Errors:** `make build`
- **Run Game:** `make run` (Use only when the user wants to visually check the output)

## Development Flow
- Define new entities in `src/jr/`.
- Manage inputs and update logic in the `update(dt)` methods.
- Delegate rendering to `draw(draw, camera_x, camera_y)` or `draw(draw)` methods.
- Pass `GSDL::TileMap` references to entities for collision detection.

## Do Not Do
- Do not edit files inside the `./lib/` folder, if you need to make those changes, summarize them to me so i can make them in the appropriate library repos (`game_sdl` and `sdl3`) so that they can be released, and our GSDL game will update to the latest version
