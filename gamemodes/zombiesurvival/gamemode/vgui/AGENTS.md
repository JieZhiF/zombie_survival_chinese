# VGUI KNOWLEDGE BASE

## OVERVIEW

Client-side UI layer for the gamemode: 29 files, all client realm, loaded by cl_init.lua. Covers full-screen menus, always-on HUD components, and reusable widget primitives.

## REGISTRATION PATTERNS

**A - vgui.Register class (dominant, 26/29 files)**: `local PANEL = {}` + methods + `vgui.Register("ClassName", PANEL, "BaseClass")`; instantiate via `vgui.Create("ClassName", parent)`. One PANEL table per registered class. Multi-registration files use a separate PANEL table per class: pclassselect (4), zsstatusarea (2), dexnotificationslist (2).

**B - Make* factory (9 files)**: global functions building ad-hoc UIs from stock Derma controls, storing the instance in a matching singleton global: MakepWorth (pWorth), MakepEndBoard, MakepWeapons, MakepOptions, MakepHelp, MakepCredits, MakepTutorial, MakepPlayerModel, MakepPlayerColor.

**C - GM method (2 files)**: `GM:OpenArsenalMenu` (parsenal.lua) stores the frame in `self.ArsenalInterface`. Patterns overlap within files; counts above are per-file usage, not exclusive buckets.

## NAMING

File prefix taxonomy:

| Prefix | Meaning | Examples |
|--------|---------|----------|
| p* | full-screen menu | pmainmenu, parsenal, pworth, pweapons, pclassselect, poptions, phelp, ptutorial, pendboard, premantle, pmutationshop |
| zs* | game HUD component | zshealtharea -> ZSHealthArea, zsgamestate -> ZSGameState, zsstatusarea -> ZSStatusArea / ZSStatusModern |
| dex* | reusable primitive, legacy DEX framework | dexroundedframe -> DEXRoundedFrame (extends DFrame), dexroundedpanel -> DEXRoundedPanel, dexchanginglabel -> DEXChangingLabel, dexrotatedimage -> DEXRotatedImage, dexnotificationslist -> DEXNotification / DEXNotificationsList |
| d* | generic Derma component | dmodelpanelex -> DModelPanelEx (extends DModelPanel), dmodelkillicon -> DModelKillIcon, dspawnmenu -> DZombieSpawnMenu, dsidemenu -> DSideMenu, dammocounter, dpingmeter, dteamcounter, dteamheading |

Registered class names: ZS* for game panels, D*/DEX* for reusable widgets, descriptive names for complex menus (ModernClassSelect, MutationShopFrame, ZSRemantlePath).

## KEY MENUS

| Trigger | File / entry | Panel / purpose |
|---------|--------------|-----------------|
| F1 | pmainmenu.lua | hub to help / weapons / options / playermodel |
| F2 (in-wave) | parsenal.lua, `GM:OpenArsenalMenu` | point shop; auto-closes on mouse leave |
| F2 (pre-wave) | pworth.lua, `MakepWorth()` | starting loadout shop |
| F3 | pclassselect.lua, ModernClassSelect | zombie class select with evolution chains |
| ALT hold (zombie) | dspawnmenu.lua, DZombieSpawnMenu | spawn point select |
| ALT hold (human) | dsidemenu.lua, DSideMenu | ammo give / drop |
| Round end | pendboard.lua, `MakepEndBoard(winner)` | scoreboard with honorable mentions |
| Mutation shop | pmutationshop.lua, MutationShopFrame | zombie mutations |
| Weapon upgrade | premantle.lua, ZSRemantlePath | remantle path tree |
| Tutorial | ptutorial.lua, `MakepTutorial()` | server-triggered, typewriter effect |

Always-on HUD components: zshealtharea (bottom-left health + armor with damage trail), zsgamestate (top: wave / countdown / team counts), zsstatusarea (status effect icons), dexnotificationslist (toasts).

mainmenu.lua is LEGACY / unused (NOX era). Do not wire it in.

## CONVENTIONS

- Singleton guard before opening any menu: `if pXxx and pXxx:IsValid() then pXxx:Remove() end`.
- Arsenal and remantle auto-close via `hook.Add("Think")` polling `gui.MousePos()` against panel bounds with a 16px margin.
- Inheritance chain: DModelKillIcon -> DModelPanelEx -> DModelPanel.
- zschanginglabel.lua re-registers DEXChangingLabel: historical alias, keep it.
- One definition per file; class name must match the table passed to vgui.Register exactly.
- translate.Get, BetterScreenScale sizing, MySelf global, file-realm prefixes: see root AGENTS.md.
