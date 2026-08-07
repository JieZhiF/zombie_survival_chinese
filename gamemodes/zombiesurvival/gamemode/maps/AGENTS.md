# MAP PATCH SCRIPTS (gamemode/maps/)

## OVERVIEW

Per-map Lua patches that add, remove, or rewire entities and gamemode rules for one specific map.

## STRUCTURE

```
maps/
└── <mapname>.lua   # flat, no subfolders
```

Filename must equal `game.GetMap()` byte-for-byte, version suffix included (`zs_storm_v1`, `zs_stormier_b1`, `zs_stormiest_b1` are three distinct files). Prefixes mark origin: `zs_` native survival, `zm_` CS:S zombie ports, `ze_` escape maps, `zs_obj_*` objective mode, `cs_`/`de_`/`rp_`/`ka_`/`gm_` conversions.

Loader mechanics (shared.lua:160-164): `file.Exists(GM.FolderName.."/gamemode/maps/"..game.GetMap()..".lua", "LUA")` then `include()`. Runs in the shared realm at gamemode load, before map entities exist.

Related data directories (not scripts):

- `../prepackagedmapprofiles/<map>.lua`: serialized spawn tables, `SRL={{Class="info_player_human"|"info_player_undead", Angles, Position}, ...}`, read by `mapeditor.lua:396`.
- `../profiler_premade/<map>.lua`: serialized profiler node graphs, `SRL={Nodes={Vector...}, Version=...}`, loaded via `GM.ProfilerFolderPreMade` in `sv_profiling.lua:45`.

## WHERE TO LOOK

| Task | Files | Notes |
|------|-------|-------|
| Add props/fires to a map | `zs_stadium.lua`, `zs_placid.lua` | Canonical `InitPostEntityMap` + `ents.Create` pattern |
| Remove doors, hurts, weapons | `zs_raunchyhouse.lua`, `ka_soccer_2006_v1.lua`, `zs_obj_mental_hospital_v6.lua` | `ents.FindByClass` + `Remove()` inside the hook |
| Override spawn points | `cf_haunted_b1.lua`, `zm_duke3d_l1_v1.lua`, `abandonned_building.lua` | Create/replace `info_player_human`/`info_player_zombie`, `team.SetSpawnPoint`, convert CS:S T/CT spawns |
| Objective-mode tweaks | `zs_obj_*.lua` | Strip `prop_weapon` entities via `SetupProps` hook |
| Full behavior override | `ze_shadow_moses.lua` | Self `AddCSLuaFile()`, `GAMEMODE:` hook chaining, SERVER-only zone timers |
| Player-join tweaks | `zm_infected.lua`, `de_residentevil2_final.lua` | `PlayerInitialSpawn` |

## CONVENTIONS

- Standard body: `hook.Add("InitPostEntityMap", "Adding", function() ... end)`. The name `"Adding"` is a literal reused verbatim across most files; do not uniquify it per map.
- Spawn pattern: `local ent = ents.Create(class)`, then `if ent:IsValid() then ent:SetPos(Vector(...)); ent:SetKeyValue(...); ent:Spawn() end`. The `IsValid()` guard is mandatory.
- Coordinates are hardcoded floats measured in game; preserve full precision.
- `InitPostEntityMap` fires server-side only, so entity patches need no `if SERVER` guard even though the file is shared realm.
- Files with client-realm needs self-register via bare `AddCSLuaFile()` on line 1 (see `ze_shadow_moses.lua`).
- Override a `GAMEMODE` hook by saving the original first: `GAMEMODE.PlayerSpawnO = GAMEMODE.PlayerSpawnO or GAMEMODE.PlayerSpawn`, then call it inside the new function.
- Other hooks in use: `SetupProps` (weapon stripping), `PlayerInitialSpawn`, `Initialize`.
- Newer files open with a Chinese banner comment (`-- ====...`) stating filename and responsibility; match it when editing those files.

## ANTI-PATTERNS

- Never "fix" a filename typo: `abandonned_building.lua` matches the actual BSP name; renaming breaks the loader.
- No top-level entity queries. File scope runs at include time, before map entities exist; all `ents.FindByClass`/`ents.Create` belong inside the hook.
- No `timer.Simple(0, ...)` wrappers around spawns; `InitPostEntityMap` already runs after entity init.
- No sigil logic exists in this directory (verified by search); do not add it here, sigil handling lives in the core gamemode.
