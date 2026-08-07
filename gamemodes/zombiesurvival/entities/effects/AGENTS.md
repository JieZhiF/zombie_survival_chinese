# Effects (entities/effects/)

## OVERVIEW
Client-side Lua EFFECTs (particles, beams, sprites, world-space text) spawned from weapon/entity code.

## STRUCTURE
Flat: one `.lua` per effect, filename (no ext) = effect name. Three folder-effects hold `init.lua`, folder name = effect name:
- `spearpierce/init.lua`
- `sillytracer/init.lua`
- `stundeflection/init.lua`

## WHERE TO LOOK
| Need | Files | Notes |
|------|-------|-------|
| Projectile tracers/beams | `tracer_*` (18) | Render() draws beams/sprites; use `self:GetTracerShootPos()`; see `tracer_gluon.lua` |
| Bullet/projectile impacts | `hit_*` (20) | One-shot particle bursts; `hit_flesh.lua`, `hit_hunter.lua` |
| Explosions | `explosion_*` (15) | Multi-group particle burst + decaying glow sprite; `explosion_rocket.lua` |
| Zombie death | `death_*` (5) | `death_wraith.lua`, `death_shade.lua` |
| Floating score/damage text | `floatingscore_*` (5), `damagenumber.lua`, `melee_*_text.lua` | 3D2D text via render hook, not Render() |
| Gore/blood | `bloodstream*`, `gib_player.lua`, `gore_blast.lua`, `dismemberment.lua`, `headshot.lua` | ClientsideModel gibs + `util.Blood` |
| Sigils/decals/misc | `sigil_*`, `decal_scorch.lua`, `nailrepaired.lua`, `redeem.lua`, `corrupted_teleport.lua`, `weapon_shattered.lua` | Assorted one-shots |

## CONVENTIONS
- Each file defines the `EFFECT` table: `Init(data)` (required; read inputs via `data:Get*()`, spawn particles/sounds/clientside models), `Think()` (return `false` for one-shot; return `self.Life < 1` to keep a fading effect alive), `Render()` (empty for particle-only; tracers draw beams/sprites here).
- `data` accessors used: `GetOrigin`, `GetNormal`, `GetEntity`, `GetStart`, `GetAttachment`, `GetMagnitude`, `GetScale`, `GetFlags`.
- Dispatch: server/shared code calls `util.Effect("name", effectData[, allowOverride, ignorePred])`, or a weapon sets `SWEP.TracerName = "name"`. `"name"` must match the filename/folder exactly. Some call sites use GMod built-ins (`"Explosion"`, `"Impact"`, `"RagdollImpact"`, `"TeslaHitBoxes"`) - those are NOT defined here.
- Particle idiom (47 files): `local emitter = ParticleEmitter(pos)`, loops of `emitter:Add(mat, pos)` + setter calls, then end with `emitter:Finish() emitter = nil collectgarbage("step", 64)`.
- Cache `Material(...)` and localize globals (`local draw = draw`) at file top, never inside Render.
- One-shot: all work in Init, `Think` returns `false`. Fading: store `self.Life`/`self.Alpha`/`self.StartTime` in Init, decay in Think, draw in Render.
- Newer files (`explosion_rocket.lua`, `death_*`) carry a Chinese `-- ====` banner header + Chinese inline comments; older files are English-only.
- Variant suffixes are distinct registered names, not overrides: `_sb`, `_alt`, `_com`/`_heal`/`_rep`/`_und`, trailing `2` (`hit_healdart2.lua`).

## ANTI-PATTERNS
- C-style `//` comments and `!=` operator in `spearpierce/init.lua` and `stundeflection/init.lua` - forbidden here; use `--` and `~=`.
- `trancer_laser.lua` is a filename typo (trancer, not tracer) but load-bearing: `weapon_zs_tokamak.lua` sets `SWEP.TracerName = "trancer_laser"`. Do not rename without updating the weapon.
- `damagenumber.lua` / `floatingscore_*` do not render in `EFFECT:Render`; they push particles into a module-level table drawn by a `PostDrawTranslucentRenderables` hook. Copy that pattern only for world-space text, not for ordinary particle effects.
