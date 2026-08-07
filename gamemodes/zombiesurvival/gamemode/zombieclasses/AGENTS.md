# zombieclasses/

## OVERVIEW

Zombie class definitions, one global `CLASS` table per file or folder, loaded and registered by `GM:RegisterZombieClasses()` in `../sh_zombieclasses.lua`.

## STRUCTURE

- `<name>.lua`: single-file class, both realms in one file (most entries).
- `<name>/`: multi-file class split into `shared.lua` + `server.lua` + `client.lua`.
- Subdirectories: `bloated_zombie/`, `boss_asskicker/`, `boss_coolwisp/`, `boss_doomcrab/`, `boss_extinctioncrab/`, `boss_giga_shadow_child/`, `boss_red_marrow/`, `boss_shitslapper/`, `boss_willowisp/`, `chem_burster/`, `shadow_gore_child/`, `vile_bloated_zombie/`, `wild_poison_zombie/`.

## WHERE TO LOOK

| Task | Location | Notes |
|------|----------|-------|
| Loading, inheritance, sorting | `GM:RegisterZombieClasses` in `../sh_zombieclasses.lua` | Scans this dir, wraps each file in global `CLASS`, resolves `Base`, sorts by Order, Wave, Name |
| Unlock check | `GM:IsClassUnlocked` in `../sh_zombieclasses.lua` | Boss always unlocked; else custom `IsClassUnlocked`, `Unlocked`, `Wave`, `Sanity` (sigils) |
| Infliction unlock | `GM:CalculateInfliction` in `../init.lua` | zombies/players ratio >= `CLASS.Infliction` unlocks mid-round, fires `infliction_reached` notify |
| Common base class | `freshdead.lua` | Default `CLASS.Base` target for humanoid zombies |
| Boss example | `boss_nightmare.lua` | Server `OnKilled` weapon drop plus client bone distortion and dark render |
| Multi-file example | `bloated_zombie/` | `server.lua` and `client.lua` each `include("shared.lua")` |
| Paired attack weapon | `../../entities/weapons/<CLASS.SWEP>` | `CLASS.SWEP = "weapon_zs_fastzombie"` maps to `entities/weapons/weapon_zs_fastzombie.lua` |
| Display strings | `../languages/` | `TranslationName`, `Description`, `Help` are translation keys, not literals |

## CONVENTIONS

- Loader sets global `CLASS = {}`, includes the file, registers by `CLASS.Name`. Missing `CLASS.Name` raises ErrorNoHalt and skips the class.
- Filename need not match `CLASS.Name` (`classic_zombie.lua` registers "Classic Zombie"). All lookups key on `CLASS.Name`.
- `CLASS.Base = "freshdead"` inherits missing fields via `table.Inherit`. Base is the other class's filename or folder name without `.lua`; folder bases work (`vile_bloated_zombie` uses `Base = "bloated_zombie"`).
- Never inherited from base: `BetterVersion`, `Infliction`, `Hidden`, `Unlocked`, `Disabled`, `Order`, `IsDefault`.
- Boss class: `CLASS.Boss = true`, filename prefix `boss_`. Bosses skip wave and infliction unlock checks.
- `CLASS.Wave` is a fraction of total waves (`2/6`), floored against `NumberOfWaves` at registration.
- `CLASS.Infliction = 0.5` unlocks the class once half the humans have died, independent of wave.
- `CLASS.BetterVersion = "Lacerator"` sets an evolution target; the loader back-links `BetterVersionOf` on the target.
- `CLASS.SWEP` weapon holds attack logic (claws, projectiles); the class holds stats, model, sounds, animation, movement hooks.
- Realm split in single files: `if SERVER then` blocks, client tail after `if not CLIENT then return end` (`Icon`, `PrePlayerDraw`, `BuildBonePositions`).
- Typical `CLASS:` hooks: `Move`, `CalcMainActivity`, `UpdateAnimation`, `DoAnimationEvent`, `PlayerFootstep`, `OnSpawned` (SV), `OnKilled` (SV), `AltUse`, `PrePlayerDraw`/`PostPlayerDraw` (CL), `BuildBonePositions` (CL).
- Multi-file classes: the loader includes only `client.lua` (CL) or `server.lua` (SV); both must `AddCSLuaFile`/`include("shared.lua")` themselves.
- Inheritance chains are short and linear: `ghoul` > `elder_ghoul` > `noxious_ghoul`, `titan` > `titan2` > `titan3`.

## ANTI-PATTERNS

- Do not key class lookups by filename; registration and all `ZombieClasses[...]` string keys use `CLASS.Name`.
- New folder class without `include("shared.lua")` in both realm files loads with stats missing on one realm.
- Typo in `CLASS.Base` only raises ErrorNoHalt; the class still registers with inherited fields silently missing.
- Client-only code placed before the `if not CLIENT then return end` guard in single-file classes runs on the server.
