# PROJECT KNOWLEDGE BASE

**Generated:** 2026-07-28
**Commit:** a327644
**Branch:** main

## OVERVIEW

Chinese-localized fork of JetBoom's Zombie Survival gamemode for Garry's Mod. Pure Lua (1803 files, ~156k lines), runs inside the Source engine — no build, no tests, no lint. Working language of comments/commits is Chinese (zh-CN).

## STRUCTURE

```
zombie_survival_change/
├── gamemodes.7z                  # 50MB distributable snapshot, not source — never edit
└── gamemodes/zombiesurvival/     # the actual gamemode (NOT an addon with lua/autorun)
    ├── zombiesurvival.txt        # gamemode manifest; maps: ^zs_|^zm_|^zh_|^zps_|^zr_|^ze_
    ├── zombiesurvival.fgd        # Hammer entity definitions for mappers
    ├── gamemode/                 # 577 Lua: core logic, entry points, all subsystems → see gamemode/AGENTS.md
    ├── entities/
    │   ├── weapons/              # 326 entries: all SWEPs → see entities/weapons/AGENTS.md
    │   ├── entities/             # 247 entries: props, statuses, projectiles, logic → see entities/entities/AGENTS.md
    │   └── effects/              # 85 client-only VFX (standard GMod EFFECT pattern)
    ├── content/                  # 886 assets (materials/models/sound/fonts/particles)
    ├── backgrounds/              # loading screen JPGs (non-standard location, at gamemode root)
    ├── readme.txt                # install instructions (legacy)
    ├── scripting and addons.txt  # hook API reference for extenders — read before adding GM hooks
    └── mapping and new entities.txt # custom map entity reference
```

## WHERE TO LOOK

| Task | Location | Notes |
|------|----------|-------|
| Round/wave/damage/spawn logic | `gamemode/init.lua` (5384 ln) | Monolithic server entry; ~200 `GM:` hooks |
| HUD/camera/client loop | `gamemode/cl_init.lua` (2674 ln) | Monolithic client entry |
| Wave state, purchase rules, dynamic spawn | `gamemode/shared.lua` (1820 ln) | Shared core; `GM:GetWave*` accessors |
| Global constants (teams, DT idx, balance) | `gamemode/sh_globals.lua` | Read first — referenced everywhere |
| Shop item/weapon registration | `gamemode/sh_options.lua` | `GM:AddStartingItem` / `GM:AddPointShopItem` |
| Player/Entity/Weapon meta extensions | `gamemode/obj_*_extend{,_sv,_cl}.lua` | Server player ext alone is 2138 ln |
| Skill tree | `gamemode/skillweb/` | → skillweb/AGENTS.md |
| Zombie classes | `gamemode/zombieclasses/` | → zombieclasses/AGENTS.md |
| UI panels/menus | `gamemode/vgui/` | → vgui/AGENTS.md |
| Weapons | `entities/weapons/` | → weapons/AGENTS.md |
| Entities/statuses/projectiles | `entities/entities/` | → entities/AGENTS.md |
| Per-map patches | `gamemode/maps/<mapname>.lua` | Filename must equal `game.GetMap()`; hooks `InitPostEntityMap` |
| Localization | `gamemode/languages/` | `translate.Get("key")`; 11 languages |
| ConVars | in-game: `find zs_` | All ConVars use `zs_` prefix |

## CODE MAP

No Lua LSP and codegraph DB was locked during generation — reference centrality **unmeasured**. Bootstrap chain (verified by reading):

**Server** `init.lua`: AddCSLuaFile batch → `sh_globals` → `obj_*_extend_sv` → `loader.lua` → `shared.lua` → `sv_options` → `mapeditor` → `sv_playerspawnentities` → `sv_block_melee_functions` → `sv_profiling` → `sv_sigils` → `sv_concommands` → `itemstocks/sv_stock` → `vault/server` → `skillweb/sv_registry` + `sv_skillweb` → `sv_zombieescape` → `sv_zombieshop` → `sv_tutorial` → `zsbots/init` → `include_library("statistics")`

**Client** `cl_init.lua`: CreateClientConVar shim → `sh_globals` → `obj_*_extend_cl` → `loader.lua` → `shared.lua` → all `cl_*` → `skillweb/cl_skillweb` → `vgui/*` → `itemstocks/cl_stock` → `cl_recoil_handler` → `cl_zombieescape` → `sck/*`

**Shared** `shared.lua`: conditional `maps/<map>.lua` → `obj_*_extend` → `sh_*` batch → `noxapi` → `vault/shared` → `workshopfix` → `include_library("perf"/"player_movement"/"inventory"/"ammoexpand")`

Key architectural facts:
- `gamemode/loader.lua` defines `include_library(folder)` (aliases: `include_folder`, `load_folder`, `load_library`) — auto-loads `<folder>/*.lua` plus `server/`, `client/`, `shared/` subfolders with correct realm handling.
- Custom events go through `gamemode.Call("EventName", ...)` → `GM:EventName()` (~257 call sites, 102 files). `hook.Call` is NOT used (2 exceptions inside third-party SCK).
- Wave/round state lives in engine globals: `GM:GetWave()`, `GM:GetWaveActive()`, `GM:GetWaveStart/End()` wrap `GetGlobal*`. Server-only: `GM.RoundEnded`, `GM.CurrentRound`, `ROUNDWINNER`, `LASTHUMAN`. Escape stages: `ESCAPESTAGE_NONE/ESCAPE/BOSS/DEATH` via `GM:GetEscapeStage()`.
- 105 net strings, 94 registered centrally in `GM:AddNetworkStrings()` (init.lua:658-755); client handlers in `cl_net.lua`.
- Central game loop: `GM:Think()` (init.lua) — wave timers, regen, per-second upkeep. Damage router: `GM:EntityTakeDamage` (~345 lines). Death: `GM:DoPlayerDeath`. Universal damage gate: `gamemode.Call("PlayerShouldTakeDamage", ...)` — every weapon/projectile must respect it.

## CONVENTIONS

- **File prefixes**: `sh_` shared, `sv_` server, `cl_` client, `obj_*_extend` metatable extensions. Entities/weapons additionally use `INC_SERVER()` / `INC_CLIENT()` / `INC_SHARED()` as first line instead of `if SERVER then`.
- **Method definitions**: ALWAYS `function GM:Method()` (452 defs, zero `function GAMEMODE:`). Property access may use `GM.x` or `GAMEMODE.x` interchangeably; inside entities/weapons use `GAMEMODE`.
- **Perf idiom (mandatory in hot code)**: cache globals at file top — `local math_random = math.random`; metatables as `local M_Player = FindMetaTable("Player")`; methods as `local P_Team = M_Player.Team`.
- **Net strings**: `zs_` + snake_case (`zs_gamestate`). `voice_` prefix reserved for voice cues. PascalCase outliers (`DemonBlade_Slay`) are legacy — do not copy.
- **Client global**: `MySelf` = `LocalPlayer()` (set in cl_init InitPostEntity). Use it, not repeated `LocalPlayer()` calls.
- **Definition-file globals**: weapon files set `SWEP.*`, entity files `ENT.*`, zombie classes `CLASS.*`, panels `local PANEL = {}` → `vgui.Register`. One definition per file/folder.
- **All user-visible strings** go through `translate.Get()` / `translate.Format()` (server→player: `translate.ClientGet(pl, ...)`).
- **UI sizing** uses `BetterScreenScale()`.
- Class naming: `weapon_zs_*`, `prop_*`, `status_*`, `logic_*`, `trigger_*`, `projectile_*`, `info_*`.

## ANTI-PATTERNS (THIS PROJECT)

- **Do NOT rely on return values of `surface.*` draw functions** (except `GetFontHeight`) — `perf/*/buffthefps.lua` rewrites them and must load before everything else.
- **Do NOT use `TrueVisibleFilters()`** (sh_util.lua) — DEPRECATED; use function-based visibility filters.
- **Do NOT pass cyclic tables to `table.FullCopy()`** — naive recursion, infinite loops (defined in two places: `weapon_zs_basemelee/animations.lua`, `weapon_zs_base/cl_model.lua`).
- **Avoid `self.BaseClass` in weapon code** — known crash source (scoped weapons); slated for refactor (sh_weaponquality.lua TODO).
- **Do NOT re-add the `zs_waveonezombies` ConVar** — intentionally hardcoded to `0.11` in sh_options.lua.
- **Do NOT re-enable commented-out melee systems blindly**: `LastHeld` prop-shoot prevention (6 files) and `zsw_enable_block`/`IsBlocking()` (3 files) were deliberately removed for balance.
- **Do NOT re-add the sigil-destroyed API** (`Set/GetAllSigilsDestroyed`) or the nest skybox/nodraw trace — intentionally removed.
- **`ammoexpand` stubs `HasAmmo()/Clip1()/Clip2()` are unimplemented** — do not call.
- **Never ship hard-coded user-facing strings** — must go through `translate.Get()` AND be added to both `languages/english.lua` and `languages/chinese_simple.lua`.

## UNIQUE STYLES

- Comments and commit messages are in Chinese; new code should follow suit or be bilingual.
- `DefaultLanguage = "zh-CN"` (sh_translate.lua) — translation fallback chain: player lang → zh-CN → `@key@`. English is NOT the final fallback.
- Monolithic entry files: most logic lives directly in init/cl_init/shared, not split into modules. Match this when extending core loops; new self-contained features may use `include_library` subfolders instead.
- Folder-per-definition with mixed layouts: weapons/entities/zombie classes each allow single-file OR folder (`shared.lua`+`init.lua`+`cl_init.lua`) forms; `weapon_zs_base/shared.lua` auto-scans its folder by prefix (`sv_`/`cl_`/`sh_`).

## COMMANDS

```bash
# No build, no tests, no lint, no CI. Validation = run the server and play.

# Install: copy gamemodes/zombiesurvival into <garrysmod>/gamemodes/
# Listen client console:  gamemode zombiesurvival   then   map zs_oldhouse

# Dedicated server:
srcds.exe -console -game garrysmod +gamemode zombiesurvival +maxplayers 32 +map zs_oldhouse

# List all gamemode ConVars (in-game console):
find zs_
```

## NOTES

- **Gotcha**: `DefaultLanguage` is zh-CN — English-only new strings render as `@key@` for zh-CN players until added to `chinese_simple.lua`.
- **Gotcha**: workshop publishing is broken per `workshopdesc.txt`; distribution is git/archive (`gamemodes.7z` is a snapshot — regenerate it manually if shipping).
- **Gotcha**: `maps/`, `prepackagedmapprofiles/`, `profiler_premade/` are per-map data. Profiles are SRL-serialized (`SRL={...}`), generated by the in-game map editor / auto-profiler — hand-edit only if you know the format. User-saved versions live in DATA (`zsmaps/`, `profiler_premade/*.txt`) and override the packaged ones.
- **Gotcha**: `sv_profiling.lua` is spawn-node generation (for sigils), not performance profiling.
- `sh_options.lua` is the item/shop database, not settings; `sv_options.lua`/`cl_options.lua` hold actual ConVars.
- License is custom "JBGM LICENSE" (license.txt), restrictive/non-commercial — check before reusing code elsewhere.
- GitHub: `JieZhiF/zombie_survival_chinese`, branch `main`.

参考图片优先级：

最高优先级：
目标效果图（Target Reference）

第二优先级：
当前实现截图（Current Screenshot）


禁止：
把Current Screenshot作为设计参考。


修改前必须回答：

Target Reference中：
1. 窗口比例是多少？
2. 武器列表排列方式是什么？
3. 右侧详情结构是什么？
4. 哪些设计需要迁移？

Current Screenshot中：
1. 已存在什么？
2. 哪些需要保留？
3. 哪些需要替换？


如果无法区分两类图片：
必须询问用户。