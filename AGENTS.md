# PROJECT KNOWLEDGE BASE

**Generated:** 2026-08-06
**Commit:** d2fdc96
**Branch:** main

## OVERVIEW

Zombie Survival — a Garry's Mod PvP gamemode where humans survive escalating waves of zombies. Forked from JetBoom's original, with Chinese-localized comments and modernized systems. Lua-only; assets live inside the gamemode folder.

## STRUCTURE

```
.
└── gamemodes/zombiesurvival/
    ├── gamemode/          # Core Lua: init, shared, client, VGUI, subsystems
    │   ├── zombieclasses/ # Zombie class definitions
    │   ├── vgui/          # HUD & menu panels
    │   ├── maps/          # Per-map configuration scripts
    │   ├── profiler_premade/ # Map performance profiles
    │   └── weapons/        # (referenced as ../entities/weapons/)
    ├── entities/          # Scripted entities, weapons, effects
    │   ├── weapons/       # All weapons (SWEPs) and zombie attack weapons
    │   ├── entities/       # Props, projectiles, status effects, logic entities
    │   └── effects/        # Visual effects
    ├── content/           # Materials, models, sounds, fonts, particles
    ├── backgrounds/       # Loading screen images
    └── *.txt              # Convars, mapping guide, license, readme
```

## WHERE TO LOOK

| Task | Location | Notes |
|------|----------|-------|
| Server entry & round logic | `gamemode/init.lua` | 5417 lines; GM:Initialize, GM:Think, GM:EndRound, GM:PlayerSpawn |
| Client entry & rendering | `gamemode/cl_init.lua` | 2646 lines; HUD, fog, VGUI, deferred hook activation |
| Shared game rules | `gamemode/shared.lua` | Team setup, waves, ammo, dynamic spawn, collision |
| Global constants | `gamemode/sh_globals.lua` | TEAM_*, DT_PLAYER_*, SPEED_*, ammo names/icons |
| Net message IDs | `gamemode/net_messages.lua` | NET_MSG table ("zs_" prefixed strings) |
| Module loader | `gamemode/loader.lua` | `include_library(folder)` auto-loads server/client/shared subfolders |
| Translation system | `gamemode/sh_translate.lua` + `gamemode/languages/` | 11 languages, Chinese/English primary |
| Weapons | `entities/weapons/` | 327 files; base classes + individual SWEPs |
| Zombie classes | `gamemode/zombieclasses/` | 72 files; normal + boss variants |
| VGUI panels | `gamemode/vgui/` | 29 custom panels, many registered with `vgui.Register()` |
| Map configs | `gamemode/maps/` | 119 per-map Lua scripts; also see `prepackagedmapprofiles/` |
| Effects | `entities/effects/` | 88 visual effects (tracers, hits, explosions) |
| Scripted entities | `entities/entities/` | 248 props, projectiles, status effects, logic entities |

## CODE MAP

LSP unavailable for Lua; centrality measured via CodeGraph.

| Symbol | Type | Location | Role |
|--------|------|----------|------|
| `GM:Initialize` | method | `gamemode/init.lua` | Server bootstrap: resources, ammo, skills, networks, modes |
| `GM:Think` | method | `gamemode/init.lua` | Server main loop: waves, timers, player effects |
| `GM:EndRound` | method | `gamemode/init.lua` + `cl_init.lua` | Winner handling, cleanup, end-of-round UI |
| `GM:PlayerSpawn` | method | `gamemode/init.lua` | Spawn logic, team loadout |
| `GM:EntityTakeDamage` | method | `gamemode/init.lua` | Central damage processing hook |
| `GM:RestartRound` | method | `gamemode/init.lua` | Round reset orchestration |
| `GM:LocalPlayerFound` / deferred hooks | pattern | `gamemode/cl_init.lua` | Client hooks start empty and swap to real impl after local player exists |
| `include_library` | function | `gamemode/loader.lua` | Auto-loads `folder/*.lua`, then `server/`, `client/`, `shared/` subfolders |
| `meta:ChangeTeam` | method | `obj_player_extend_sv.lua` | Player team switch with pre/post hooks |
| `meta:ResetSpeed` | method | `obj_player_extend.lua` | Speed recalculation for both teams |
| `BetterScreenScale` | function | `cl_util.lua` | 1080p-based UI scaling used across all VGUI |
| `NET_MSG` | table | `net_messages.lua` | Central net message name constants |
| `GAMEMODE.ZombieClasses` | table | `sh_zombieclasses.lua` | Zombie class registry indexed by class ID |
| `translate.Get` / `translate.Format` | function | `sh_translate.lua` | i18n lookups used by client and shared code |

## CONVENTIONS

- **Realm prefixes**: `cl_` client, `sv_` server, `sh_` shared, `obj_` metatable extensions; each `obj_*` has `_cl` and `_sv` variants where needed.
- **File registration**: `init.lua` manually calls `AddCSLuaFile()` for every shared/client file before `include()`.
- **Module folders**: `inventory/`, `ammoexpand/`, `perf/`, `player_movement/`, `statistics/`, `skillweb/`, `itemstocks/`, `vault/`, `gmapex/` use `include_library()`.
- **Chinese comments**: Most inline and header comments are Simplified Chinese; code identifiers remain English.
- **Global localization**: Heavy pattern of `local pairs = pairs`, `local CurTime = CurTime`, `local M_Player = FindMetaTable("Player")` for performance.
- **Gamemode table aliases**: `GAMEMODE` is valid anywhere after load; global `GM` is load-time-only (see ANTI-PATTERNS). For closures that need the table later, capture at load scope: `local gm = GM or GAMEMODE`. Inside `function GM:Method()` bodies use `self`, never the `GM` global.
- **Naming**: `SCREAMING_SNAKE_CASE` for constants (`TEAM_HUMAN`, `HM_LASTHUMAN`, `SPEED_NORMAL`), `GM:MethodName` for hooks, `weapon_zs_*` for SWEPs, `prop_*`/`logic_*` for custom entities.

## ANTI-PATTERNS (THIS PROJECT)

- **Global `GM` in deferred contexts**: Per GMod wiki, `GM` ("the loading gamemode") is **only available while gamemode files are loading** — it is `nil` in every deferred callback on both realms (`cvars.AddChangeCallback`, `timer.*`, `hook.Add`, `net.Receive`, `concommand.Add`) and inside `function GM:Method()` bodies invoked later. Any `GM.foo` / `GM:foo()` read there crashes with `attempt to index global 'GM' (a nil value)`. Use `GAMEMODE`, `self`, or a load-captured `local gm = GM or GAMEMODE`. Bug history: `cl_options.lua` transparency-radius transform closures (fixed) and `skillweb/registry.lua` `GM.Skills` inside `GM:GetTrinketSkillID` (fixed).
- **GMod-only operators**: `!` (not), `!=` (not equal), `&&` (and), `||` (or) are forbidden by CFC style; use `not`, `~=`, `and`, `or`. Concentrated in `entities/weapons/swep_construction_kit/` and weapon animation files.
- **C-style comments**: `//` and `/* */` are forbidden in Lua; use `--` and `--[[ ]]`. Found in `entities/effects/` and `swep_construction_kit/shared.lua`.
- **`continue` keyword**: Forbidden by CFC style; appears in ~42 files. Replace with `if/else` or early returns.
- **`TrueVisibleFilters`**: Marked `DEPRECATED` in `sh_util.lua` (line 210); migrate to function-based filtering.
- **Do not rely on return values from `draw.SimpleText` / `draw.DrawText`**: `perf/client/buffthefps.lua` hooks these and warns it removes return-value behavior.
- **Do not use the custom `table.Copy` replacement on self-referencing tables**: `weapon_zs_base/cl_model.lua` and `weapon_zs_basemelee/animations.lua` warn this causes infinite loops.
- **Do not add gameplay-advantage revenue**: Project uses a custom JBGM license (`license.txt`) that explicitly forbids this.

## UNIQUE STYLES

- **Deferred client activation**: `cl_init.lua` defines hooks like `GM.Think` as empty initially, then swaps them to `GM:_Think` only after `LocalPlayer()` is valid.
- **Bilingual codebase**: English identifiers and Chinese comments; `workshopdesc.txt` / readme are Chinese-facing.
- **Map-driven config**: `maps/<mapname>.lua` is auto-included by `shared.lua`; three profile folders tune spawn/props per map.
- **Zombie class dual representation**: Each class is defined in `gamemode/zombieclasses/` AND has a corresponding weapon entity under `entities/weapons/`.
- **Chinese font support**: `content/resource/fonts/` includes HarmonyOS Sans SC and Naskh for CJK/Arabic UI.

## COMMANDS

```bash
# Manual deployment (no build step)
cp -r gamemodes/zombiesurvival /path/to/garrysmod/gamemodes/
# In GMod console on a supported map:
gamemode zombiesurvival
map zs_somemap

# List all project ConVars
find zs_

# Git info
git log --oneline -10
git status
```

## NOTES

- **No CI/CD, no tests, no linter**: Purely manual in-game testing. No `.github/workflows/`, no test framework, no `glualint.json`/`.luacheckrc`.
- **Content path is non-standard**: Assets are under `gamemodes/zombiesurvival/content/` instead of the addon root; this is valid for gamemodes.
- **Gamemode (2).7z**: Backup archive inside `gamemodes/zombiesurvival/` is gitignored and likely stale.
- **Workshop incompatibility**: `workshopdesc.txt` warns the gamemode will not work from Steam Workshop; SVN/manual install is intended.
- **Tooling directories**: `.omo/` and `.codegraph/` are ignored by git and hold AI/session indexes; do not commit them.
