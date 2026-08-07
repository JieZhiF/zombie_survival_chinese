# entities/weapons/

## OVERVIEW

All SWEP code: human guns/melee/deployables, zombie attack weapons, and the base-class hierarchy they inherit.

## STRUCTURE

- `weapon_zs_base/` — gun base, feature-split into realm-prefixed sub-files
- `weapon_zs_basemelee/` — melee base, swing + animation system
- `weapon_zs_baseproj/` — projectile-firing gun base (extends `weapon_zs_base`)
- `weapon_zs_basethrown/` — grenade/throwable base (extends `weapon_zs_base`)
- `weapon_zs_basetrinket/` — trinket base (extends `weapon_zs_basemelee`)
- `weapon_zs_basefood/` — consumable base (extends `weapon_zs_basemelee`)
- `weapon_zs_zombie/` — zombie claw-attack base; every zombie class weapon derives from it
- `weapon_map_base/` — ZE map pickup base, no attack capability
- `swep_construction_kit/` — SCK: view/world model attachment runtime + spawn-menu editor
- Remaining `weapon_zs_*.lua` single files — individual weapons beside the folders

## WHERE TO LOOK

| Task | Location |
|------|----------|
| Gun logic (shoot/reload/recoil/sights/think) | `weapon_zs_base/sh_shoot.lua`, `sh_reload.lua`, `sh_recoil.lua`, `sh_sights.lua`, `sh_think.lua` |
| Gun client rendering | `weapon_zs_base/cl_model.lua`, `cl_viewmodel.lua`, `cl_hud.lua`, `cl_inspect.lua` |
| Default gun property blocks (tier, walkspeed, models) | `weapon_zs_base/shared.lua` (heavily commented, Chinese) |
| Melee swings + anims | `weapon_zs_basemelee/shared.lua`, `animations.lua` |
| Zombie attack core (climb, moan, primary/secondary) | `weapon_zs_zombie/shared.lua` |
| Shotgun spread base | `weapon_zs_baseshotgun.lua` (single file, not a folder) |
| New gun template | copy a sibling, e.g. `weapon_zs_akbar.lua` |
| New zombie weapon template | `weapon_zs_classiczombie.lua` |
| Model attachment tables (VElements/WElements) | `swep_construction_kit/base_code.lua` |

## CONVENTIONS

- Inheritance via `SWEP.Base`; usage: ~70 guns on `weapon_zs_base`, ~53 melee, ~41 zombie claws, rest on proj/thrown/shotgun bases.
- Folder weapons use the classic realm split: `shared.lua` + `init.lua` + `cl_init.lua`. Single-file weapons use one `.lua` with `AddCSLuaFile()` on top and `if CLIENT then` blocks inline.
- `weapon_zs_base` alone splits further by feature with `sh_`/`cl_` prefixes; match that when extending it.
- Names/descriptions always via `translate.Get("weapon_zs_<name>")`, never hardcoded strings.
- Weapon select slot: `GAMEMODE:GetWeaponSlot("WeaponSelectSlot*")` plus `WEPSELECT_*` constant, CLIENT-only.
- Variant suffixes: `_boss` boss version, `_ex` upgraded, trailing `z` zombie-side remake (`graveshovelz`), `_r`/`_sp` hammer tiers, `_arc` zapper branch.
- Zombie weapons pair with `gamemode/zombieclasses/`: class file sets `CLASS.SWEP = "weapon_zs_<class>"`; boss classes reuse the base with overrides.
- SCK attachments live in `SWEP.VElements`, `SWEP.WElements`, `SWEP.ViewModelBoneMods` inside `if CLIENT then`.

## ANTI-PATTERNS

- `swep_construction_kit/` and `weapon_zs_basemelee/animations.lua` are the concentration zones for the project's forbidden style (`!`, `!=`, `&&`, `||`, `//` comments, `continue`). Legacy; don't propagate into new code.
- `weapon_zs_base/cl_model.lua` and `weapon_zs_basemelee/animations.lua` carry in-file warnings about self-referencing tables vs the custom `table.Copy`; read those headers before editing.
