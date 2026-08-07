# entities/entities/ — Scripted Entities

## OVERVIEW

All SENTs for the gamemode: deployable props, weapon-spawned projectiles, per-player status effects, and mapper-facing logic/spawn/trigger entities.

## STRUCTURE

Two layouts, class name equals folder/file name:

- `name/` folder: full SENT with `shared.lua` + `init.lua` + optional `cl_init.lua`; realm files open with `INC_SERVER()` / `INC_CLIENT()`.
- `name.lua` flat file: simpler entities (`func_*`, `point_*`, `info_noskills.lua`, `zs_hands.lua`, a few `prop_*`).

Entity families:

- `prop_*` — world props and human deployables; physics props, often `ENT.Base = "prop_baseoutlined"`.
- `projectile_*` — spawned by SWEPs in `entities/weapons/` via `ents.Create` on fire; entity holds flight/impact, weapon holds tuning.
- `status_*` — buff/debuff entities attached to a player (`ENT.Type = "anim"`, base `status__base`); move with owner, no physics.
- `status_ghost_*` — one per deployable; the "currently placing" preview state, not the prop itself.
- `logic_*` — point entities placed by mappers; drive the gamemode through `AcceptInput`.
- `info_*` / `gmod_player_start` — spawn points and map markers.
- `func_*` / `trigger_*` — brush zones and class-change triggers.
- `point_*` — mapper I/O helpers.
- `env_*`, `zombiegasses` — hazard/cloud volumes.

## WHERE TO LOOK

| Need | Entities |
|------|----------|
| Dropped items | `prop_weapon`, `prop_ammo`, `prop_invitem` |
| Turrets | `prop_gunturret` + `_assault`/`_buckshot`/`_pulse`/`_rocket`, hitboxes in `prop_hitbox_*` |
| Other deployables | `prop_arsenalcrate`, `prop_resupplybox`, `prop_detpack`, `prop_remantler`, `prop_ffemitter`, `prop_medicfield`, `prop_repairfield`, `prop_spotlamp`, `prop_zapper*`, `prop_manhack*`, `prop_drone*`, `prop_nail`, `prop_camera`, `prop_messagebeacon` |
| DoTs / debuffs | `status_burn`, `status_poison`, `status_bleed`, `status_frost`, `status_slow`, `status_stun`, `status_knockdown`, `status_sickness` |
| Buffs | `status_adrenalineamp`, `status_fastreload`, `status_fastshoot`, `status_strengthdartboost`, `status_arsenalpack`, `status_resupplypack` |
| Revival | `status_revive`, `status_revive2`, `status_revive_slump*` |
| Zombie ambience loops | `status_ambience_*`, `status_*ambience` |
| Wave / round control | `logic_waves`, `logic_wavestart`, `logic_waveend`, `logic_winlose`, `logic_winreward`, `logic_beats` |
| Economy / unlocks | `logic_points`, `logic_worth`, `logic_experience`, `logic_classunlock`, `logic_startingloadout`, `logic_pickups`, `logic_pickupdrop` |
| Spawn points | `info_player_human`, `info_player_undead(_boss)`, `info_player_zombie(_boss)`, `info_player_redeemed`, `info_zombiespawn`, `info_sigilnode` |
| Brush zones | `func_arsenalzone`, `func_noair`, `func_status` |
| Class triggers | `trigger_zombieclass`, `trigger_bossclass` |
| Mapper I/O | `point_servercommand`, `point_zsmessage`, `point_worldhint`, `point_zombiespawngroup` |
| Objective mode | `prop_obj_sigil`, `prop_obj_exit` |
| Hazard volumes | `env_mediccloud`, `env_nanitecloud`, `env_molotovflame`, `env_shadecontrol` |

## CONVENTIONS

- Statuses are applied via `pl:GiveStatus("name")` (`obj_player_extend_sv.lua`), never raw `ents.Create`; it wires owner, attacker, and cleanup. State syncs through hard-coded DT slots (`SetDTFloat(0, ...)`). `ENT.Ephemeral = true` clears the status on death/reset.
- `logic_*` use `ENT.Type = "point"`; `AcceptInput` matches lowercased command names (`advancewave`, `setwave`, ...) and calls `gamemode.Call("SetWave*")` / globals. Inputs starting with `on` are re-fired as outputs via `FireOutput`.
- Mappers place `logic_*`/`info_*`/`func_*`/`trigger_*` in Hammer or from `gamemode/maps/<map>.lua` scripts.

## ANTI-PATTERNS

- Don't spawn the real `prop_*` deployable directly during placement; the `status_ghost_*` state runs validation first.
- DT slot indices are fixed per class with no central registry; copy the slot pattern of the nearest sibling file and check for collisions before adding one.
- Keep new `AcceptInput` command names lowercase; `logic_*` lowercases input before matching.
