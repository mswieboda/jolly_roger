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

## Coding / Convention Standards
- Do not run `crystal format`
- Trim all whitespace for any changes or new files

## Compiling, and Testing
  - Command: `make build` to compile
- **Functional Testing:** Run a specific example to exercise changes. Capture logs and exit automatically:
  - Command: `timeout 5s make run || true`
- **Error Resolution:** The `Makefile` includes `--error-trace`. Focus on the first few lines of a compile error to identify the root cause.
- **Validation Mandate:** Frequent compilation checks are mandatory. A task is not complete until behavioral correctness is verified through a successful build and run.

## Development Flow
- Define new entities in `src/jr/`.
- Manage inputs and update logic in the `update(dt)` methods.
- Delegate rendering to `draw(draw, @camera)` or `draw(draw)` methods.
- Pass `GSDL::TileMap` references to entities for collision detection.

## Trello Card Refinement
- When refining Trello cards using the `trello-refine-card` skill, always reference [GAME_CONTEXT.md](GAME_CONTEXT.md) for project-specific technical patterns, system interdependencies, and card IDs.
- Follow the established "Goal", "Context", "Technical Details", and "Definition of Done" structure for all refinements.

## Do Not Do
- **Library Files:** NEVER edit files in `./lib/`. Summarize proposed changes for the user to apply to the source repositories (e.g., `sdl3`).
- **Git Operations:** NO write commands (`git add`, `git commit`, `git stage`). Use read-only commands only.
- **Trello:** ONLY modify Trello cards when specifically asked to refine them using the `trello-refine-card` skill. Refer to [GAME_CONTEXT.md](GAME_CONTEXT.md) for established refinement patterns and card IDs.
