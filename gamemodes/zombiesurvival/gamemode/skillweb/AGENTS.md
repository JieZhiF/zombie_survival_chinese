# SKILLWEB KNOWLEDGE BASE

## OVERVIEW

Skill tree (perk web) for the human team: 165 skills across 6 trees, unlocked with SP earned from XP levels, effects applied on human spawn.
Fully data-driven: everything registers into GM.Skills / GM.SkillModifiers / GM.SkillFunctions at load through the 4 API functions below.

## FILES

| File | Realm | Role |
|------|-------|------|
| `registry.lua` (1651 ln) | SHARED | Data bible. SKILL_* ids (0-164), SKILLMOD_* (1-99), TREE_* (1-6) constants; AddSkill block ~450-956; SetSkillModifierFunction ~958-1283; AddSkillModifier/AddSkillFunction ~1285-1651 |
| `sh_skillweb.lua` | SHARED | XP/level curve, unlock adjacency, Player meta state queries, meta:ApplySkills, meta:ApplyTrinkets |
| `sv_registry.lua` | SERVER | Server-only modifier handlers (SKILLMOD_HEALTH current-HP rescale, SKILLMOD_POINTS one-time grant, turret/drone/deployable/field mods) + building-tree AddSkillModifier block |
| `sv_skillweb.lua` | SERVER | net.Receive handlers + Player meta mutators syncing via GM:WriteSkillBits (one bit per skill id) |
| `cl_skillweb.lua` (1814 ln) | CLIENT | ZSSkillWeb 3D panel (ClientsideModel hoverball nodes at (0, x*20, y*20), state-colored beam connections, edge-scroll camera, context menu, remort node, quick-stats), loadout save/load/delete via Serialize to GAMEMODE.SkillLoadoutsFile, ZSExperienceHUD XP bar, GM:GenerateFromSkillWebGrid debug tool (reads skillwebgrid.png pixels) |

Load order:
- gamemode `shared.lua` includes `sh_skillweb.lua`, which includes `registry.lua` (registry is SHARED).
- `init.lua` includes `sv_registry.lua` + `sv_skillweb.lua`.
- `cl_init.lua` includes `cl_skillweb.lua`.

## REGISTRATION API

All four functions are defined in registry.lua. Handlers for server-only effects live in sv_registry.lua.

- `GM:AddSkill(id, name, description, x, y, connections, tree)` returns the skill table. `name = ""` makes a disabled placeholder (named "Skill N", cannot be unlocked). `connections` = adjacent SKILL_* ids; `SKILL_NONE` (0) marks a tree root. `tree` = TREE_HEALTHTREE (1) .. TREE_GUNTREE (6). x, y and Description are stored only on CLIENT.
- `GM:AddSkillModifier(skillid, SKILLMOD_*, amount)`. Amounts STACK across skills; the handler receives the SUM.
- `GM:AddSkillFunction(skillid, function(pl, active) end)`. Runtime toggle, fired with active=true/false on state delta.
- `GM:SetSkillModifierFunction(modid, function(pl, amount) end)`. One handler per SKILLMOD_*. Use the `GM:MkGenericMod("FieldName")` shorthand for clamped additive fields.

Modifier semantics: `_MUL` handlers run `math.Clamp(amount + 1.0, ...)`, so 0.1 = +10% and -0.25 = -25%. Flat modifiers (e.g. SKILLMOD_HEALTH) add directly to the base value.

Description markup: prefix each line with `"^"..COLORID_GREEN` (buff) or `"^"..COLORID_RED` (debuff) for colored tooltip lines.

## ADDING A SKILL

1. Define the next `SKILL_*` constant in registry.lua (ids currently run 0-164).
2. New modifier? Define its `SKILLMOD_*` constant plus a `SetSkillModifierFunction` handler. Put the handler in sv_registry.lua when it is server-only (SetMaxHealth, point grants, turret/deployable touches).
3. Call `GM:AddSkill` with translate keys, grid x,y (multiples of ~2), connections, and tree.
4. Attach effects with `AddSkillModifier` and/or `AddSkillFunction`.
5. Optional flags on the returned table: `.AlwaysActive = true` (cannot be toggled off, survives deactivate-all), `.RemortLevel = N` (checked in SkillCanUnlock).

## CONVENTIONS

- Names and descriptions go through translate.Get with keys added to BOTH english.lua and chinese_simple.lua. Legacy raw strings exist around registry.lua:915+; do not copy them.
- Grid x,y are client-only visuals; the server never reads them.
- Trinkets use `GM:AddTrinket` (no tree, no grid) and activate from inventory ownership via meta:ApplyTrinkets, not through the unlock web.
- Never write to GM.Skills / GM.SkillModifiers directly after registration; always use the 4 API functions.
- The server validates every client request: SP balance, adjacency via SkillCanUnlock, Disabled flag, remort gate. Never trust cl_skillweb state.
- Declare each connection once; GM:FixSkillConnections makes edges bidirectional at load. Connections are stored as assoc tables (table.ToAssoc).
- SP formula: GetZSSPRemaining = (level + remortLevel) - #unlockedSkills.
- meta:ApplySkills(override) is the heart of the system: runs on human spawn, validates desired vs unlocked, ApplyAssocModifiers, toggles SkillFunctions by state delta. It is the only valid entry point for applying skill state.
- XP curve: level = floor(1 + 0.2673*sqrt(xp)); xp = 14*(level-1)^2; GM.MaxLevel = 60; GM.MaxXP auto-computed.
- Skill reset (zs_skills_reset) requires level >= 10 and has a 1h cooldown.
- sv_skillweb net handlers: zs_skill_is_desired, zs_skills_desired (bulk bit-array), zs_skills_all_desired, zs_skill_set_desired (loadout), zs_skill_is_unlocked, zs_skills_remort, zs_skills_reset, zs_skills_refunded.
- Client entry points: GM:ToggleSkillWeb opens the panel; GM:DrawXPBar renders the HUD bar.
- Disabled placeholders (empty name) still occupy their grid slot in the client panel.
- Loadouts are client-side presets saved with Serialize; applying one just re-sends desire/unlock requests, which the server re-validates.
- Roots are marked by SKILL_NONE in their Connections list; test membership instead of hardcoding root ids.
