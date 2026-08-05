# entities/entities/: SCRIPTED ENTITY LAYER

## OVERVIEW

247 SENT classes (44 loose files + 203 folder classes): deployables, status effects, projectiles, map logic. Documents only what this gamemode adds over stock SENT behavior.
Sibling `entities/effects/` holds 85 client-only EFFECT classes (standard `EFFECT:Init/Think/Render` with ParticleEmitter/render.DrawBeam), not covered here.

## BASE CLASSES

| Base | Purpose | Notable children |
|------|---------|------------------|
| status__base | Buff/debuff framework; `ENT.IsStatus=true`, `ENT.Type="anim"`, parented to player; `GetPlayer` aliases `GetParent` | ~50: status_burn/poison/bleed/frost/slow/stun/revive, `*ambience` auras |
| status_ghost_base | Extends status__base; deployable placement preview, wireframe model; `DTBool(0)`=placement valid, `DTFloat(0)`=rotation | ~20, one per deployable |
| prop_baseoutlined | Client-only quality-tier outline rendering | prop_ammo, prop_weapon |
| prop_deployablehitbox | Invisible bullet-proof collision proxy for deployables | prop_hitbox_gunturret, prop_hitbox_camera |
| prop_gunturret | Auto-turret: aim/scan/fire, manual control mode, 12+ DT vars | assault, buckshot, pulse, rocket variants |
| prop_zapper | Electric trap base | arc, arc_ex variants |
| projectile_arrow (+_cha) | Arrow base | _inq/_mini/_sli/_zea variants |
| projectile_ghoulflesh (+chilled) | Zombie flesh projectile base | fr/puke variants |
| projectile_emi | EMP bolt | projectile_emi_sub |
| projectile_healdart | Homing heal projectile | projectile_medicrifle |

## ENTITY INVENTORY

- Deployables: prop_arsenalcrate, prop_resupplybox, prop_gunturret(+4), prop_zapper(+2), prop_medicfield, prop_repairfield, prop_ffemitter(+field), prop_detpack, prop_camera, prop_spotlamp, prop_tv, prop_messagebeacon, prop_remantler, prop_aegisboard, prop_nail (barricade), prop_drone(+pulse/hauler), prop_manhack(+saw), prop_rollermine; zombie-built: prop_creepernest, prop_meathook.
- Objectives: prop_obj_sigil (custom health regen via AccessorFuncDT, TRANSMIT_ALWAYS), prop_obj_exit.
- Projectiles: ~50 classes. Arrows; explosives (rocket/asmd/flak/nova/zsgrenade/molotov); zombie attacks (ghoulflesh/poisonflesh/bonemesh/bristle/bloodshot/doomcrab); human special (healdart/medicrifle/emi/disc/harpoon/proxymine/biorifle).
- Statuses: ~55. DoT (burn/poison/bleed/frost); debuffs (slow/stun/knockdown/confusion/enfeeble); buffs (fastreload/adrenalineamp/strengthdartboost); revive chain (revive/revive_slump/feigndeath); zombie auras (`*ambience`, one per class); item packs (arsenalpack/resupplypack/packup).
- Environment: env_mediccloud, env_nanitecloud, env_molotovflame, env_protrusionspike, zombiegasses, env_shadecontrol (ComputeShadowControl telekinesis).
- Logic (map-placed, `ENT.Type="point"`): logic_waves/wavestart/waveend, logic_infliction, logic_experience/points/worth/brains, logic_difficulty, logic_barricade, logic_antigrief, logic_classunlock, logic_dynamicspawning, logic_beats, logic_winlose/winreward, trigger_bossclass/zombieclass.
- Spawn points: info_player_human/zombie/undead/boss variants, info_zombiespawn, info_sigilnode, point_zombiespawngroup, point_worldhint, point_servercommand.
- Brush: func_arsenalzone, func_noair, func_status.

## SPAWN FLOWS

1. Weapons create deployables/projectiles directly via `ents.Create` in attack/deploy code.
2. Ghost placement: deployable weapon gives owner a status_ghost_xxx; preview follows aim trace; primary attack validates (`DTBool(0)`) then spawns the real prop_xxx.
3. Statuses: `player:GiveStatus("status_xxx")` = `ents.Create` + `SetParent(player)`; owner read back via `GetParent`/`GetPlayer`.
4. Deployables spawn internal helpers: turret spawns prop_hitbox_gunturret and takes prop_ammo; sigil spawns prop_prop_blocker.
5. Projectile -> env chain on impact: projectile_zsmolotov -> env_molotovflame, mediccloudbomb -> env_mediccloud.
6. logic_*/info_*/trigger_*/func_* are placed in Hammer and read KeyValues; mapper reference in root-level `mapping and new entities.txt`.

## CONVENTIONS

- Mixed layouts: folder classes (shared.lua/init.lua/cl_init.lua) and loose single-file classes coexist; folders dominate (203 vs 44).
- Deployables declare their spawning weapon on `ENT.SWEP` (prop_gunturret: `"weapon_zs_gunturret"`).
- Statuses self-hook per instance with `hook.Add("EventName", self, self.EventName)`; entity as listener id means hooks die on removal, no manual unhook.
- Balance flags live on the SENT table itself (prop_gunturret header): NoNails, m_NoNailUnfreeze, IgnoreBullets, CanPackUp, AlwaysGhostable. Copy this pattern for new deployables.
- Placement preview: each deployable pairs with a status_ghost_xxx child; `AlwaysGhostable` forces preview availability.
- Perf idiom applies in hot files: cache globals/metatables at file top (`local MASK_SOLID = MASK_SOLID`, `local M_Player = FindMetaTable("Player")`), see prop_gunturret/shared.lua.
- `ENT.Type`: `"anim"` for nearly everything; logic_* use `"point"`; func_* use `"brush"`.

## WARNINGS

- Any damage-dealing entity must respect the universal damage gate (PlayerShouldTakeDamage) - see root CODE MAP.
- prop_gunturret is heavily DT-networked and splits collision: bullets hit the separate prop_hitbox_gunturret, never the turret itself (`IgnoreBullets=true`). Keep hitbox lifetime synced with the turret.
- prop_obj_sigil flips collision group when corrupted; do not hardcode its collision state elsewhere.
- Drones, manhacks, rollermine ride on phys_keepupright plus dedicated controller weapons; physics changes there cascade into the controllers.
- env_shadecontrol manipulates shadow physics directly via ComputeShadowControl (telekinesis); test against prop-heavy maps before touching.
- status__base stubs (OnInitialize, Touch, AcceptInput, ...) are intentional no-ops; children override selectively, do not add behavior to the base.
