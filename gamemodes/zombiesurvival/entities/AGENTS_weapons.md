# entities/weapons/ KNOWLEDGE BASE

## OVERVIEW
~326 SWEP classes: 221 loose .lua files + 105 folder definitions, covering all human firearms, melee, throwables, trinkets, food, and zombie claws. Shop/loadout registration is explicit in sh_options.lua, never automatic from file presence.

## BASE CLASSES
Chain: weapon_base (engine) → weapon_zs_base (root of ALL human firearms, 13 files) → sub-bases:

- weapon_zs_basemelee: melee; itself parents weapon_zs_basetrinket (passive trinkets) and weapon_zs_basefood (consumables)
- weapon_zs_baseproj: projectile launchers
- weapon_zs_baseshotgun: shell-by-shell reload (single file)
- weapon_zs_basethrown: grenades/throwables
- weapon_zs_zombie: zombie claws, separate branch outside the firearm flow

Variant chains where a concrete weapon is the Base of others: butcherknife→butcherknifez/evilknight, longsword→firesword/longsword_z, grenade→zegrenade→hegrenade, hammer→electrohammer/hammer_sp/hammer_r, m4→zem4, gunturret→gunturret_buckshot/pulse/rocket. Children set SWEP.Base to the parent class and override only deltas.

weapon_zs_base itself carries the shared implementation: recoil system, iron sights, quality/modifier hooks, HUD 3D model, SCK integration. Its shared.lua header doubles as the annotated field reference (Chinese comments).

## FILE LAYOUTS
- Pattern A, single file (~100, older/simple): one weapon_zs_x.lua with AddCSLuaFile() on line 1; CLIENT blocks inline for viewmodel/HUD/SlotGroup.
- Pattern B, folder (~100): weapon_zs_x/{shared.lua, init.lua, cl_init.lua} plus optional sv_*/cl_*/sh_* extras.
- Only weapon_zs_base/shared.lua has an auto-loader (lines 138-169) scanning its own folder by prefix; files dropped into weapon_zs_base/ load automatically. Other folder weapons use the plain 3-file form, no auto-scan.

## CUSTOM SWEP FIELDS
Grouped by subsystem; all set as SWEP.* at file top (Primary.* where noted).

- Shop/economy: Tier (wave-lock), MaxStock (per-match global limit), WalkSpeed
- Spread: ConeMax/ConeMin/ConeRamp, FixedAccuracy (true = always ConeMin, ignores move/state)
- Ballistics: Primary.KnockbackScale, Primary.MaxDistance, Primary.HullSize, TracerName, BulletCallback, EmptyWhenPurchased
- Default clip: call GAMEMODE:SetupDefaultClip(SWEP.Primary) after ClipSize/Ammo
- Recoil (ARC9-style, 30+ fields in base): Recoil_Enabled gates it; heat curve RecoilPerShot/RecoilMax/RecoilResetTime/RecoilDissipationRate/RecoilModifierCap; per-shot RecoilUp/Side/RecoilRandomUp/Side, RecoilFirstShotMult, RecoilSideBias, RecoilMaxTotalUp; auto-return RecoilAutoControl(+Time/_PerShot/_DontTryToReturnBack); camera CamRecoilUp/Side/Roll/FOV(+FOVStiffness/FOVDamping/LerpSpeed); viewmodel UseVisualRecoil, VisualRecoilPunch/Up/Roll/Stiffness/Damping/Center; stance mults RecoilMultSights/Crouch/MidAir/Move
- Iron sights: IronEnable, IronSightsPos/Ang, IronsightsMultiplier (zoom), Breathmult, IronSightsHoldType
- Melee (basemelee): MeleeDamage, MeleeRange/MeleeSize, MeleeKnockBack, SwingTime/MeleeDelay, SwingRotation/SwingOffset, DamageType, MeleePuch* (12 viewpunch fields), DefendingDamageBlocked, BlockHoldType/BlockPos/BlockAng, IsMelee, AllowQualityWeapons
- Food (basefood): FoodHealth, FoodEatTime, SugarRushFood
- Zombie (zs_zombie): ZombieOnly, MeleeReach, MeleeForceScale, AlertDelay, FrozenWhileSwinging
- Flags: Undroppable, NoDismantle, NoPickupNotification, NoGlassWeapons, WeaponType (ammo/UI tag string), SlotGroup (WEPSELECT_*)
- HUD 3D model: HUD3DBone/HUD3DPos/HUD3DAng/HUD3DScale, CooldownExtraSize
- SCK viewmodels: VElements, WElements, ViewModelBoneMods
- Viewmodel offset/sway: VMPos/VMAng, ViewModelFOV/ViewModelFlip, BobScale/SwayScale, SwayAmount/BobAmount/MovementLerpSpeed
- Anim/feel: FireAnimSpeed, ReloadSpeed, IronSpeed, InspectOnDeploy/DeployInspectTime/InspectSpeed, IdleActivity
- Misc: CSMuzzleFlashes, RequiredClip, DryFireSound, Weight, RecoilRecoveryPercentage
- Quality/remantle: GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_*, value); GAMEMODE:AddNewRemantleBranch(SWEP, id, name, desc, fn)

## SHOP REGISTRATION
Two explicit steps in gamemode/sh_options.lua, both keyed by a string signature:

- GM:AddStartingItem("sig", ITEMCAT_GUNS, cost, "weapon_zs_x") for the worth/loadout shop
- GM:AddPointShopItem("sig", ITEMCAT_GUNS, cost, "weapon_zs_x", ..., giveFn) for the in-wave point shop

Item inherits Tier/MaxStock/Description from the SWEP via GM:AssignItemProperties. Optional item flags: .SkillRequirement, .NoClassicMode, .Countables, .SubCategory.
Crafting lives in gamemode/inventory/shared/sh_inventory.lua: GM.Assemblies["weapon_zs_target"] = {...} and GM:AddWeaponBreakdownRecipe.

## EXAMPLES TO COPY
- weapon_zs_crowbar.lua: simple melee, 67 ln
- weapon_zs_deagle.lua: simple firearm, 105 ln, single-file, full recoil config with Chinese comments
- weapon_zs_gluon/: folder weapon with heat system, DT vars, AttachWeaponModifier, remantle branch
- weapon_zs_grenade/shared.lua: 6 lines, minimal basethrown child

## WARNINGS
- The two root-AGENTS.md anti-patterns live in this dir: self.BaseClass (scoped-weapon crashes) and table.FullCopy (no cycle detection). Avoid both in new code.
