# ZOMBIE CLASSES

## OVERVIEW

Zombie player classes: stats, model, SWEP, unlock rule, and behavior hooks, one `CLASS` table per file or folder. Registry lives in `../sh_zombieclasses.lua`. ~98 files: ~59 single-file classes (`zombie.lua`, `fast_zombie.lua`, `ghoul.lua`) + ~13 directory classes (`boss_asskicker/`, `bloated_zombie/`, `chem_burster/`).

## HOW CLASSES ARE LOADED

`GM:RegisterZombieClasses()` (sh_zombieclasses.lua) scans `zombieclasses/*` in 4 passes:

1. **Single files**: fresh global `CLASS = {}`, `AddCSLuaFile` + `include`, register only if `CLASS.Name` set (`ErrorNoHalt` otherwise).
2. **Directories**: same, but includes `client.lua` on CLIENT / `server.lua` on SERVER. `shared.lua` is NOT auto-included; each realm file does `AddCSLuaFile("shared.lua")` + `include("shared.lua")` itself, first lines.
3. **Inheritance**: `CLASS.Base = "<parent Name>"` resolved against loaded files, `table.Inherit` fills only missing fields. NOT inherited (saved and restored around the merge): `BetterVersion`, `Infliction`, `Hidden`, `Unlocked`, `Disabled`, `Order`, `IsDefault`.
4. **Back-refs + sort**: target of each `BetterVersion` gets `BetterVersionOf = <source Name>`; sort by `Order` > `Wave` > `Name` (missing sorts as 255). Then `Index` assigned, name alias `ZombieClasses[name]` built, `IsDefault` → `DefaultZombieClass`, deep-copy snapshot into `RevertableZombieClasses`.

`GM:RegisterZombieClass(name, tab)` converts fractional `Wave` to absolute: `math.floor(tab.Wave * GM.NumberOfWaves)`. Client default `Icon = "zombiesurvival/killicons/genericundead"`; fallbacks `TranslationName = Name`, `Points = 0`. Loader auto-runs on include when `GAMEMODE.ZombieClasses` is nil. `GM:RevertZombieClasses()` restores the snapshot.

Registry shape: `GAMEMODE.ZombieClasses` is list AND map at once. Numeric keys = sorted list, string keys = name aliases. `CLASS.Name`, not the filename, is identity; `Base` also references the parent's `Name` (loader appends `.lua`).

## DEFINING A CLASS

Contract fields:

- `Name` (required): display name and lookup key. `TranslationName` / `Description` / `Help`: translation keys.
- Stats: `Health`, `Speed`, `Model`, `SWEP` (weapon class string, e.g. `"weapon_zs_fastzombie"`), `Points` (kill reward; common pattern `Health / GM.NoHeadboxZombiePointRatio`), `KnockbackScale` (0 = immune), `BloodColor`, `VoicePitch`, `FearPerInstance`.
- Body: `ModelScale`, `Hull` / `HullDuck` (Vector min/max pairs), `ViewOffset` / `ViewOffsetDucked`, `JumpPower`.
- Flags: `CanTaunt`, `CanFeignDeath`, `Revives`, `NoFallDamage`, `NoFallSlowdown`, `Boss`, `MiniBoss`, `SuperBoss`, `MegaBoss`, `Hidden`, `Unlocked`, `IsDefault` (only "Zombie"), `Order`, `Disabled`, `Locked`, `NotRandomStart`.
- Progression: `Wave` (0-1 fraction of total waves), `Infliction` (0-1 zombie-ratio unlock), `Sanity` (0-1 sigil-corruption unlock), `BetterVersion` (Name this evolves into), `Base` (parent Name).
- `Icon`: CLIENT kill icon. Sounds: `PainSounds`, `DeathSounds` (sound-script names or file paths).

Copy `fast_zombie.lua` (single file, Infliction unlock, ReviveCallback split, `BetterVersion = "Lacerator"`) or `boss_asskicker/` (directory layout, `Base = "zombie_legs"`, ModelScale).

## UNLOCK SYSTEM

`GM:IsClassUnlocked(name)` (server, sh_zombieclasses.lua): Boss → always true. `CLASS:IsClassUnlocked()` override wins when it returns non-nil. `Locked` → false. Else ANY of: `Unlocked`; wave reached (`GetWave() >= Wave`, or next wave during intermission); `Sanity` threshold vs `NumSigilsCorrupted() / MaxSigils` (sigils enabled only).

- Wave classes rechecked on SetWave. Infliction via `GM:CalculateInfliction` every 2 s in init.lua. Changes pushed by `GM:ClassUnlocksUpdate` → net `zs_classunlockstate` (index u8 + bool, broadcast or per-player).
- `Unlocked` or `Wave == 0` at load sets `UnlockedNotify = true`, suppressing the "new class unlocked" toast.
- `GM:GetBestAvailableZombieClass` (shared.lua) walks the `BetterVersion` chain: dead zombies auto-upgrade to the best unlocked evolution (Zombie → Eradicator, Fast Zombie → Lacerator). `pl.DeathClass` stores pre-death class so the respawn upgrade resumes from the right link.
- Round start: starting zombies get a random class among `Unlocked`, not `Hidden`, not `NotRandomStart`.

## BOSSES

`Boss = true`. Always unlocked, HP 2400-2600+, `KnockbackScale = 0`, cannot be redeemed. Health is NOT wave-scaled (regular classes scale 0.75x on wave 1).

Assignment: `GM:CalculateNextBoss` picks the top `BossZombieSort()` score among living non-boss zombies, honors `zs_nobosspick`, max 9 living bosses. Player preference: `zs_bossclass` convar → `GetBossZombieIndex` (default "Red Marrow").

## MINI BOSSES & SUPER BOSSES

Tier flags that are independent of `Boss` (a class is exactly one of: regular / `Boss` / `MiniBoss` / `SuperBoss` / `MegaBoss`):

- `MiniBoss = true`: purchasable in the zombie shop (ZOMBIESHOP, "MiniBoss" category) with BTokens. `GM:SpawnMiniBoss(pl, classname)` (init.lua) performs the transformation (kills → sets class → respawns → reverts on death, same flow as `SpawnBossZombie`). Purchases are `Repeatable` in the shop (not recorded into `UsedMutations`). Currently: Ass Kicker, Shit Slapper, Giga Gore Child, Giga Shadow Child, Night Butcher, Human Traitor (all `Boss = false` + `Hidden = true`).
- `SuperBoss = true`: framework only, no class marked yet. Generation method TBD — hook into `GM:SpawnSuperBoss(pl, classname)` (init.lua). Hidden from regular class select unless its tab is shown.
- `MegaBoss = true`: framework only, reserved for the MEGABOSSES select tab.

pclassselect.lua groups classes into 7 tabs: Classes / Other / Mutations / Mini Bosses / Bosses / Super Bosses / MEGABOSSES, matching the visual design.

## CALLBACKS

Optional `function CLASS:X(pl, ...)` hooks, called with the player:

- Movement/anim: `Move`, `CreateMove` (client), `CalcMainActivity`, `UpdateAnimation`, `DoAnimationEvent`, `BuildBonePositions`.
- Sound: `PlayerFootstep` (return true to replace), `PlayerStepSoundTime` (return ms).
- Damage: `ScalePlayerDamage`, `IgnoreLegDamage`, `ProcessDamage`, `KnockedDown`, `DoesntGiveFear`.
- Lifecycle: `OnSpawned`, `OnKilled` (return true to suppress default corpse handling), `ReviveCallback` (death-split into Legs/Torso classes, see fast_zombie), `AltUse`, `SwitchedTo` / `SwitchedAway`, `IsClassUnlocked`.
- Render (client): `PrePlayerDraw`, `PostPlayerDraw`.

## CONVENTIONS

- One definition per file/folder. The file only fills the global `CLASS` table; never touch `GM.ZombieClasses` directly.
- Single-file realm split: shared fields on top, server code behind `if SERVER then`, client-only code (`Icon`, `CreateMove`, draw hooks) after `if SERVER then return end`.
- Directory classes: realm files must `AddCSLuaFile("shared.lua")` + `include("shared.lua")` as their first lines or `CLASS` stays empty on that realm.
- Class behavior that needs the weapon duck-types through `pl:GetActiveWeapon()` (`wep.GetClimbing`, `wep.GetPounceTime`, `wep.IsRoaring`); the SWEP named by `CLASS.SWEP` owns actual attacks, the class owns body/anim/sound.
- Server-only callbacks (`ReviveCallback`, `OnKilled`) belong behind the SERVER gate so the client copy of the file stays lean.
