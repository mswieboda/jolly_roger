# Jolly Roger: Game Context

This document serves as a persistent technical reference for "Jolly Roger," a 2D Caribbean-themed RPG built using Crystal and SDL3 (GSDL engine).

## Core Systems & Mechanics

- **Inventory & Equipment:** A data-driven system for items and equipment, including a specialized `InventoryManager` and slot-based equipment for players and ships.
- **Quest System:** A centralized `QuestManager` integrated with the dialogue-based `ActionParser`.
- **Navigation & Exploration:**
    - **Sailing:** A steerable pirate ship vehicle with multiple speed states (`None`, `Low`, `Half`, `Full`).
    - **Wind:** A lightweight wind system affecting ship speed and steering.
    - **Docking:** Seamless transitions between sea-based ship navigation and land-based exploration at designated ports.
    - **Overworld:** A large-scale ocean map connecting various island scenes.
- **Economy:** A regional trade system for Caribbean-themed goods (Rum, Sugar, Spices) with dynamic pricing between ports.
- **Traversal:**
    - **Tile Hopping:** Contextual mechanics like hopping over 1-tile gaps.
    - **Ability-Based Traversal:** A Metroidvania-style gating system using abilities (e.g., Cut, Push, Jump) to clear environmental obstacles on islands and the overworld (similar to Pokémon HMs or Golden Sun Psynergy).
- **Player Stats & Progression:** A versatile stat system (HP, Stamina, ATK, DEF, AGI) designed to support either turn-based (Golden Sun/Sea of Stars style) or real-time (A Link to the Past style) combat.
- **Combat Systems:**
    - **Modular Combat:** A `CombatManager` to support land and sea battles, with support for initiative-based turn logic or real-time hitbox detection.
    - **Naval Warfare:** Specific mechanics for ship-to-ship cannon fire, firing arcs, and damage models (Blocked by Combat System decision).
    - **On-Foot Combat:** Mechanics for character-based battles, including attack patterns, special abilities, and enemy character AI (Blocked by Combat System decision).
- **Technical Infrastructure:**
    - **Tile Layers:** Support for Background, Ground, and Foreground layers for depth.
    - **Input:** Unified support for keyboard and Gamepad (D-pad/Analog).

## Refined Trello Cards Reference

These cards have been refined to be implementation-ready. You can fetch their latest descriptions using the `trello-refine-card` skill with the provided IDs.

| Refined Name | Card ID |
| :--- | :--- |
| Implement Equipment and Inventory System | `69a31c5fec53369690f6c92a` |
| Implement Item Database and Consumable Logic | `69a31c55e3898ec413669430` |
| Implement Shop System for Items and Equipment | `69a31cf06ce08f2e7d9d0232` |
| Implement Quest Management System and Action Parser Integration | `69a23b9b229b2c79f767e6b3` |
| Implement Support for Multiple Tile Layers | `69a31cae3767a2df4aaaac8a` |
| Implement Contextual Tile Hopping Mechanic | `69a31cd2326bc707990e7b43` |
| Create Static Water Tileset Assets | `69a1ecdc8731a56ce9de7178` |
| Implement Steerable Pirate Ship Vehicle | `69a31d0ea803cf500e2865fa` |
| Integrate Gamepad Support for Player and Ship Movement | `69a31c471908fb23306f0523` |
| Implement Overworld Ocean Map and Navigation | `69a31d2c274830cbddba17c3` |
| Implement Simple Wind System for Sailing | `69a31d448123737d269bb5e7` |
| Implement Ship Upgrade System at Harbors | `69a31da2670140c56ea1f87e` |
| Implement Ship Docking and Land Transition Mechanics | `69a31d69c70caa5641561660` |
| Implement Caribbean-Themed Trade and Economic System | `69a31d81997b79db07a68473` |
| Implement Versatile Player Stat and Progression System | `69a31ddc461553cb3d67255e` |
| Implement Ability-Based World Traversal and Gating System | `69a31e31c0231162e8f240cd` |
| Architect and Prototype Combat Systems (On-Foot & Sea) | `69a72b6302888d370e10f989` |
| Implement Ship-to-Ship Naval Warfare Mechanics | `69a31e4c4798034a98d91e86` |
| Implement On-Foot Player Combat Mechanics | `69a72c9cafff430ed1c0f2bc` |

## How to use Trello Skills
1. Activate `trello-refine-card`.
2. Search by ID: `node scripts/trello_refine_card.js search "<cardId>"`
3. Update by ID: `node scripts/trello_refine_card.js update "<cardId>" "<newName>" "@<descFile>"`
