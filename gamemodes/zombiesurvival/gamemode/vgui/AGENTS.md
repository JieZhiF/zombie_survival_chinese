# VGUI Panels

## OVERVIEW

All custom UI for the gamemode: HUD elements, menu windows, and a small reusable control library, loaded client-side via `cl_init.lua`.

## STRUCTURE

Filename prefix groups panels by role:

- `d*.lua`: Derma-style widgets and side menus (dammocounter, dpingmeter, dteamcounter, dteamheading, dsidemenu, dspawnmenu, dmodelkillicon, dmodelpanelex)
- `p*.lua`: full-screen game panels, each with a `GM:Open*` or `Makep*` entry point (pworth, parsenal, pclassselect, pendboard, pmainmenu, phelp, poptions, ptutorial, pweapons, pmutationshop, premantle)
- `zs*.lua`: always-on HUD areas (zsgamestate, zshealtharea, zsstatusarea, zschanginglabel)
- `dex*.lua`: DEX reusable control library (dexroundedframe, dexroundedpanel, dexrotatedimage, dexnotificationslist, dexchanginglabel)
- `mainmenu.lua`: legacy NOX-era main menu, unused in the current version

## WHERE TO LOOK

| Task | Location | Notes |
|------|----------|-------|
| Starting-shop (Worth) menu | `pworth.lua` | 3-column layout; opened by `GM:OpenWorth()` in `cl_init.lua` |
| Zombie class selection | `pclassselect.lua` | Registers ClassSelect, ClassButton, ClassDetailPanel, ZombieClassPreview; entry `GM:OpenClassSelect()` |
| Arsenal / item viewer | `parsenal.lua` | Entry `GM:OpenArsenalMenu()`; defines `GAMEMODE:CreateItemInfoViewer()` reused by pworth |
| End-of-round board | `pendboard.lua` | `MakepEndBoard()` + `GM:AddHonorableMention()`; rows are DEndBoardPlayerPanel |
| F1 help / main menu | `pmainmenu.lua` | `GM:ShowHelp()`; player model and color pickers |
| Options | `poptions.lua` | Registers ZSOptions |
| Mutation shop | `pmutationshop.lua` | MutationShopFrame + ZSMutationItemRow |
| Remantle paths | `premantle.lua` | ZSRemantlePath panel |
| Wave/game-state HUD | `zsgamestate.lua` | ZSGameState; created once as `self.GameStatePanel` in cl_init (~line 1739) |
| Health HUD | `zshealtharea.lua` | ZSHealthArea; `self.HealthHUD` in cl_init |
| Status effect HUD | `zsstatusarea.lua` | ZSStatusArea + ZSStatusModern; `self.StatusHUD` in cl_init |
| Kill/icon notifications | `dexnotificationslist.lua` | DEXNotificationsList; instantiated twice (top + center) in cl_init |
| Ammo counter | `dammocounter.lua` | DAmmoCounter, embedded in the human side menu |
| Side menus | `dsidemenu.lua`, `dspawnmenu.lua` | DSideMenu (human) and DZombieSpawnMenu (zombie) both derive from DZSSideMenuBase; built in cl_init (~lines 2014, 2120) |

## CONVENTIONS

- Registration: `vgui.Register("Name", PANEL, "BaseClass")` at file bottom; registered names often differ from filenames (pworth.lua registers ZSWorthButton, pclassselect.lua registers ClassSelect).
- Instantiation: HUD panels are created once in `cl_init.lua` and stored on the GM table; menus are built on demand by `GM:Open*`/`Makep*` functions and guarded by an `IsValid()` popup check.
- DEX controls are the shared widget set; prefer DEXRoundedFrame/DEXRoundedPanel over raw DFrame/DPanel for new windows.
- Large `p*` files open with a Chinese region map (区域地图, four fields: [区域]/[位置]/[作用]/[常改]) mapping each window section to its function; keep this map in sync when editing.
- Fonts referenced here (HarmonyOS Sans SC, etc.) live in `content/resource/fonts/`; CJK text is expected throughout.

## ANTI-PATTERNS

- `zschanginglabel.lua` re-registers the name "DEXChangingLabel" with itself as base, overwriting the registration in `dexchanginglabel.lua`. Load order decides which wins; do not add a third registration of this name.
- `mainmenu.lua` is dead code kept for reference; new menu work goes in `pmainmenu.lua`.
- Do not create HUD panels per-frame or inside Paint hooks; they are singletons created once at client init.
