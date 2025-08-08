GM.Skills = {}
GM.SkillModifiers = {}
GM.SkillFunctions = {}
GM.SkillModifierFunctions = {}

function GM:AddSkill(id, name, description, x, y, connections, tree)
	local skill = {Connections = table.ToAssoc(connections or {})}

	if CLIENT then
		skill.x = x
		skill.y = y

		-- TODO: Dynamic skill descriptions based on modifiers on the skill.

		skill.Description = description
	end

	if #name == 0 then
		name = "Skill "..id
		skill.Disabled = true
	end

	skill.Name = name
	skill.Tree = tree

	self.Skills[id] = skill

	return skill
end

-- Use this after all skills have been added. It assigns dynamic IDs!
function GM:AddTrinket(name, swepaffix, pairedweapon, veles, weles, tier, description, status, stocks)
	local skill = {Connections = {}}

	skill.Name = name
	skill.Trinket = swepaffix
	skill.Status = status

	local datatab = {PrintName = name, DroppedEles = weles, Tier = tier, Description = description, Status = status, Stocks = stocks}

	if pairedweapon then
		skill.PairedWeapon = "weapon_zs_t_" .. swepaffix
	end

	self.ZSInventoryItemData["trinket_" .. swepaffix] = datatab
	self.Skills[#self.Skills + 1] = skill

	return #self.Skills, self.ZSInventoryItemData["trinket_" .. swepaffix]
end

-- I'll leave this here, but I don't think it's needed.
function GM:GetTrinketSkillID(trinketname)
	for skillid, skill in pairs(GM.Skills) do
		if skill.Trinket and skill.Trinket == trinketname then
			return skillid
		end
	end
end

function GM:AddSkillModifier(skillid, modifier, amount)
	self.SkillModifiers[skillid] = self.SkillModifiers[skillid] or {}
	self.SkillModifiers[skillid][modifier] = (self.SkillModifiers[skillid][modifier] or 0) + amount
end

function GM:AddSkillFunction(skillid, func)
	self.SkillFunctions[skillid] = self.SkillFunctions[skillid] or {}
	table.insert(self.SkillFunctions[skillid], func)
end

function GM:SetSkillModifierFunction(modid, func)
	self.SkillModifierFunctions[modid] = func
end

function GM:MkGenericMod(modifiername)
	return function(pl, amount) pl[modifiername] = math.Clamp(amount + 1.0, 0.0, 1000.0) end
end

-- These are used for position on the screen
TREE_HEALTHTREE = 1
TREE_SPEEDTREE = 2
TREE_SUPPORTTREE = 3
TREE_BUILDINGTREE = 4
TREE_MELEETREE = 5
TREE_GUNTREE = 6

-- Dummy skill used for "connecting" to their trees.
SKILL_NONE = 0

--[[
SKILL_U_AMMOCRATE = 0 -- Unlock alternate arsenal crate that only sells cheap ammo (remove from regular?)
SKILL_U_DECOY = 0 -- "Unlock: Decoy", "Unlocks purchasing the Decoy\nZombies believe it is a human\nCan be destroyed\nExplodes when destroyed"

SKILL_OVERCHARGEFLASHLIGHT = 0 -- Your flashlight now produces a blinding flash that stuns zombies\nYour flashlight now breaks after one use

Unlock: Explosive body armor - Allows you to purchase explosive body armor, which knocks back both you and nearby zombies when you fall below 25 hp.
Olympian - +50% throw power\nsomething bad
Unlock: Antidote Medic Gun - Unlocks purchasing the Antidote Medic Gun\nTarget poison damage resistance +100%\nTarget immediately cleansed of all debuffs\nTarget is no longer healed or hastened
]]

-- unimplemented

SKILL_SPEED1 = 1
SKILL_SPEED2 = 2
SKILL_SPEED3 = 3
SKILL_SPEED4 = 4
SKILL_SPEED5 = 5
SKILL_BACKPEDDLER = 18
SKILL_LOADEDHULL = 20
SKILL_REINFORCEDHULL = 21
SKILL_REINFORCEDBLADES = 22
SKILL_AVIATOR = 23
SKILL_U_BLASTTURRET = 24
SKILL_TWINVOLLEY = 26
SKILL_TURRETOVERLOAD = 27
SKILL_LIGHTCONSTRUCT = 34
SKILL_QUICKDRAW = 39
SKILL_QUICKRELOAD = 41
SKILL_VITALITY2 = 45
SKILL_BARRICADEEXPERT = 77
SKILL_BATTLER1 = 48
SKILL_BATTLER2 = 49
SKILL_BATTLER3 = 50
SKILL_BATTLER4 = 51
SKILL_BATTLER5 = 52
SKILL_HEAVYSTRIKES = 53
SKILL_COMBOKNUCKLE = 62
SKILL_U_CRAFTINGPACK = 64
SKILL_JOUSTER = 65
SKILL_SCAVENGER = 67
SKILL_U_ZAPPER_ARC = 68
SKILL_ULTRANIMBLE = 70
SKILL_D_FRAIL = 71
SKILL_U_MEDICCLOUD = 72
SKILL_SMARTTARGETING = 73
SKILL_GOURMET = 76
SKILL_BLOODARMOR = 79
SKILL_REGENERATOR = 80
SKILL_SAFEFALL = 83
SKILL_VITALITY3 = 84
SKILL_TANKER = 86
SKILL_U_CORRUPTEDFRAGMENT = 87
SKILL_WORTHINESS3 = 78
SKILL_WORTHINESS4 = 88
SKILL_FOCUS = 40
SKILL_WORTHINESS1 = 42
SKILL_WORTHINESS2 = 43
SKILL_WOOISM = 46
SKILL_U_DRONE = 28
SKILL_U_NANITECLOUD = 29
SKILL_STOIC1 = 6
SKILL_STOIC2 = 7
SKILL_STOIC3 = 8
SKILL_STOIC4 = 9
SKILL_STOIC5 = 10
SKILL_SURGEON1 = 11
SKILL_SURGEON2 = 12
SKILL_SURGEON3 = 13
SKILL_HANDY1 = 14
SKILL_HANDY2 = 15
SKILL_HANDY3 = 16
SKILL_MOTIONI = 17
SKILL_PHASER = 19
SKILL_TURRETLOCK = 25
SKILL_HAMMERDISCIPLINE = 30
SKILL_FIELDAMP = 31
SKILL_U_ROLLERMINE = 32
SKILL_HAULMODULE = 33
SKILL_TRIGGER_DISCIPLINE1 = 35
SKILL_TRIGGER_DISCIPLINE2 = 36
SKILL_TRIGGER_DISCIPLINE3 = 37
SKILL_D_PALSY = 38
SKILL_EGOCENTRIC = 44
SKILL_D_HEMOPHILIA = 47
SKILL_LASTSTAND = 54
SKILL_D_NOODLEARMS = 55
SKILL_GLASSWEAPONS = 56
SKILL_CANNONBALL = 57
SKILL_D_CLUMSY = 58
SKILL_CHEAPKNUCKLE = 59
SKILL_CRITICALKNUCKLE = 60
SKILL_KNUCKLEMASTER = 61
SKILL_D_LATEBUYER = 63
SKILL_VITALITY1 = 66
SKILL_TAUT = 69
SKILL_INSIGHT = 74
SKILL_GLUTTON = 75
SKILL_D_WEAKNESS = 81
SKILL_PREPAREDNESS = 82
SKILL_D_WIDELOAD = 85
SKILL_FORAGER = 89
SKILL_LANKY = 90
SKILL_PITCHER = 91
SKILL_BLASTPROOF = 92
SKILL_MASTERCHEF = 93
SKILL_SUGARRUSH = 94
SKILL_U_STRENGTHSHOT = 95
SKILL_STABLEHULL = 96
SKILL_LIGHTWEIGHT = 97
SKILL_AGILEI = 98
SKILL_U_CRYGASGREN = 99
SKILL_SOFTDET = 100
SKILL_STOCKPILE = 101
SKILL_ACUITY = 102
SKILL_VISION = 103
SKILL_U_ROCKETTURRET = 104
SKILL_RECLAIMSOL = 105
SKILL_ORPHICFOCUS = 106
SKILL_IRONBLOOD = 107
SKILL_BLOODLETTER = 108
SKILL_HAEMOSTASIS = 109
SKILL_SLEIGHTOFHAND = 110
SKILL_AGILEII = 111
SKILL_AGILEIII = 112
SKILL_BIOLOGYI = 113
SKILL_BIOLOGYII = 114
SKILL_BIOLOGYIII = 115
SKILL_FOCUSII = 116
SKILL_FOCUSIII = 117
SKILL_EQUIPPED = 118
SKILL_SURESTEP = 119
SKILL_INTREPID = 120
SKILL_CARDIOTONIC = 121
SKILL_BLOODLUST = 122
SKILL_SCOURER = 123
SKILL_LANKYII = 124
SKILL_U_ANTITODESHOT = 125
SKILL_DISPERSION = 126
SKILL_MOTIONII = 127
SKILL_MOTIONIII = 128
SKILL_D_SLOW = 129
SKILL_BRASH = 130
SKILL_CONEFFECT = 131
SKILL_CIRCULATION = 132
SKILL_SANGUINE = 133
SKILL_ANTIGEN = 134
SKILL_INSTRUMENTS = 135
SKILL_HANDY4 = 136
SKILL_HANDY5 = 137
SKILL_TECHNICIAN = 138
SKILL_BIOLOGYIV = 139
SKILL_SURGEONIV = 140
SKILL_DELIBRATION = 141
SKILL_DRIFT = 142
SKILL_WARP = 143
SKILL_LEVELHEADED = 144
SKILL_ROBUST = 145
SKILL_STOWAGE = 146
SKILL_TRUEWOOISM = 147
SKILL_UNBOUND = 148

SKILLMOD_HEALTH = 1
SKILLMOD_SPEED = 2
SKILLMOD_WORTH = 3
SKILLMOD_FALLDAMAGE_THRESHOLD_MUL = 4
SKILLMOD_FALLDAMAGE_RECOVERY_MUL = 5
SKILLMOD_FALLDAMAGE_SLOWDOWN_MUL = 6
SKILLMOD_FOODRECOVERY_MUL = 7
SKILLMOD_FOODEATTIME_MUL = 8
SKILLMOD_JUMPPOWER_MUL = 9
SKILLMOD_RELOADSPEED_MUL = 11
SKILLMOD_DEPLOYSPEED_MUL = 12
SKILLMOD_UNARMED_DAMAGE_MUL = 13
SKILLMOD_UNARMED_SWING_DELAY_MUL = 14
SKILLMOD_MELEE_DAMAGE_MUL = 15
SKILLMOD_HAMMER_SWING_DELAY_MUL = 16
SKILLMOD_CONTROLLABLE_SPEED_MUL = 17
SKILLMOD_CONTROLLABLE_HANDLING_MUL = 18
SKILLMOD_CONTROLLABLE_HEALTH_MUL = 19
SKILLMOD_MANHACK_DAMAGE_MUL = 20
SKILLMOD_BARRICADE_PHASE_SPEED_MUL = 21
SKILLMOD_MEDKIT_COOLDOWN_MUL = 22
SKILLMOD_MEDKIT_EFFECTIVENESS_MUL = 23
SKILLMOD_REPAIRRATE_MUL = 24
SKILLMOD_TURRET_HEALTH_MUL = 25
SKILLMOD_TURRET_SCANSPEED_MUL = 26
SKILLMOD_TURRET_SCANANGLE_MUL = 27
SKILLMOD_BLOODARMOR = 28
SKILLMOD_MELEE_KNOCKBACK_MUL = 29
SKILLMOD_SELF_DAMAGE_MUL = 30
SKILLMOD_AIMSPREAD_MUL = 31
SKILLMOD_POINTS = 32
SKILLMOD_POINT_MULTIPLIER = 33
SKILLMOD_FALLDAMAGE_DAMAGE_MUL = 34
SKILLMOD_MANHACK_HEALTH_MUL = 35
SKILLMOD_DEPLOYABLE_HEALTH_MUL = 36
SKILLMOD_DEPLOYABLE_PACKTIME_MUL = 37
SKILLMOD_DRONE_SPEED_MUL = 38
SKILLMOD_DRONE_CARRYMASS_MUL = 39
SKILLMOD_MEDGUN_FIRE_DELAY_MUL = 40
SKILLMOD_RESUPPLY_DELAY_MUL = 41
SKILLMOD_FIELD_RANGE_MUL = 42
SKILLMOD_FIELD_DELAY_MUL = 43
SKILLMOD_DRONE_GUN_RANGE_MUL = 44
SKILLMOD_HEALING_RECEIVED = 45
SKILLMOD_RELOADSPEED_PISTOL_MUL = 46
SKILLMOD_RELOADSPEED_SMG_MUL = 47
SKILLMOD_RELOADSPEED_ASSAULT_MUL = 48
SKILLMOD_RELOADSPEED_SHELL_MUL = 49
SKILLMOD_RELOADSPEED_RIFLE_MUL = 50
SKILLMOD_RELOADSPEED_XBOW_MUL = 51
SKILLMOD_RELOADSPEED_PULSE_MUL = 52
SKILLMOD_RELOADSPEED_EXP_MUL = 53
SKILLMOD_MELEE_ATTACKER_DMG_REFLECT = 54
SKILLMOD_PULSE_WEAPON_SLOW_MUL = 55
SKILLMOD_MELEE_DAMAGE_TAKEN_MUL = 56
SKILLMOD_POISON_DAMAGE_TAKEN_MUL = 57
SKILLMOD_BLEED_DAMAGE_TAKEN_MUL = 58
SKILLMOD_MELEE_SWING_DELAY_MUL = 59
SKILLMOD_MELEE_DAMAGE_TO_BLOODARMOR_MUL = 60
SKILLMOD_MELEE_MOVEMENTSPEED_ON_KILL = 61
SKILLMOD_MELEE_POWERATTACK_MUL = 62
SKILLMOD_KNOCKDOWN_RECOVERY_MUL = 63
SKILLMOD_MELEE_RANGE_MUL = 64
SKILLMOD_SLOW_EFF_TAKEN_MUL = 65
SKILLMOD_EXP_DAMAGE_TAKEN_MUL = 66
SKILLMOD_FIRE_DAMAGE_TAKEN_MUL = 67
SKILLMOD_PROP_CARRY_CAPACITY_MUL = 68
SKILLMOD_PROP_THROW_STRENGTH_MUL = 69
SKILLMOD_PHYSICS_DAMAGE_TAKEN_MUL = 70
SKILLMOD_VISION_ALTER_DURATION_MUL = 71
SKILLMOD_DIMVISION_EFF_MUL = 72
SKILLMOD_PROP_CARRY_SLOW_MUL = 73
SKILLMOD_BLEED_SPEED_MUL = 74
SKILLMOD_MELEE_LEG_DAMAGE_ADD = 75
SKILLMOD_SIGIL_TELEPORT_MUL = 76
SKILLMOD_MELEE_ATTACKER_DMG_REFLECT_PERCENT = 77
SKILLMOD_POISON_SPEED_MUL = 78
SKILLMOD_PROJECTILE_DAMAGE_TAKEN_MUL = 79
SKILLMOD_EXP_DAMAGE_RADIUS = 80
SKILLMOD_MEDGUN_RELOAD_SPEED_MUL = 81
SKILLMOD_WEAPON_WEIGHT_SLOW_MUL = 82
SKILLMOD_FRIGHT_DURATION_MUL = 83
SKILLMOD_IRONSIGHT_EFF_MUL = 84
SKILLMOD_BLOODARMOR_DMG_REDUCTION = 85
SKILLMOD_BLOODARMOR_MUL = 86
SKILLMOD_BLOODARMOR_GAIN_MUL = 87
SKILLMOD_LOW_HEALTH_SLOW_MUL = 88
SKILLMOD_PROJ_SPEED = 89
SKILLMOD_SCRAP_START = 90
SKILLMOD_ENDWAVE_POINTS = 91
SKILLMOD_ARSENAL_DISCOUNT = 92
SKILLMOD_CLOUD_RADIUS = 93
SKILLMOD_CLOUD_TIME = 94
SKILLMOD_PROJECTILE_DAMAGE_MUL = 95
SKILLMOD_EXP_DAMAGE_MUL = 96
SKILLMOD_TURRET_RANGE_MUL = 97
SKILLMOD_AIM_SHAKE_MUL = 98
SKILLMOD_MEDDART_EFFECTIVENESS_MUL = 99

local GOOD = "^"..COLORID_GREEN
local BAD = "^"..COLORID_RED

-- Health Tree
GM:AddSkill(SKILL_STOIC1, ""..translate.Get("Skill_Stoic1"), GOOD..""..translate.Get("Skill_Stoic1_Good").."\n"..BAD..""..translate.Get("Skill_Stoic1_Bad"),
																-4,			-6,					{SKILL_NONE, SKILL_STOIC2}, TREE_HEALTHTREE)
GM:AddSkill(SKILL_STOIC2, ""..translate.Get("Skill_Stoic2"), GOOD..""..translate.Get("Skill_Stoic2_Good").."\n"..BAD..""..translate.Get("Skill_Stoic2_Bad"),
																-4,			-4,					{SKILL_STOIC3, SKILL_VITALITY1, SKILL_REGENERATOR}, TREE_HEALTHTREE)
GM:AddSkill(SKILL_STOIC3, ""..translate.Get("Skill_Stoic3"), GOOD..""..translate.Get("Skill_Stoic3_Good").."\n"..BAD..""..translate.Get("Skill_Stoic3_Bad"),
																-3,			-2,					{SKILL_STOIC4}, TREE_HEALTHTREE)
GM:AddSkill(SKILL_STOIC4, ""..translate.Get("Skill_Stoic4"), GOOD..""..translate.Get("Skill_Stoic4_Good").."\n"..BAD..""..translate.Get("Skill_Stoic4_Bad"),
																-3,			0,					{SKILL_STOIC5}, TREE_HEALTHTREE)
GM:AddSkill(SKILL_STOIC5, ""..translate.Get("Skill_Stoic5"), GOOD..""..translate.Get("Skill_Stoic5_Good").."\n"..BAD..""..translate.Get("Skill_Stoic5_Bad"),
																-3,			2,					{SKILL_BLOODARMOR, SKILL_TANKER}, TREE_HEALTHTREE)
GM:AddSkill(SKILL_D_HEMOPHILIA, ""..translate.Get("Skill_D_Hemophilia"), GOOD..""..translate.Get("Skill_D_Hemophilia_Good1").."\n"..GOOD..""..translate.Get("Skill_D_Hemophilia_Good2").."\n"..BAD..""..translate.Get("Skill_D_Hemophilia_Bad"),
																4,			2,					{}, TREE_HEALTHTREE)
GM:AddSkill(SKILL_GLUTTON, ""..translate.Get("Skill_Glutton"), GOOD..""..translate.Get("Skill_Glutton_Good1").."\n"..""..GOOD..translate.Get("Skill_Glutton_Good2").."\n"..BAD..""..translate.Get("Skill_Glutton_Bad1").."\n"..BAD..""..translate.Get("Skill_Glutton_Bad2"),
																3,			-2,					{SKILL_GOURMET, SKILL_BLOODARMOR}, TREE_HEALTHTREE)
GM:AddSkill(SKILL_PREPAREDNESS, ""..translate.Get("Skill_Preparedness"), GOOD..""..translate.Get("Skill_Preparedness_Good"),
																4,			-6,					{SKILL_NONE}, TREE_HEALTHTREE)
GM:AddSkill(SKILL_GOURMET, ""..translate.Get("Skill_Gourmet"), GOOD..""..translate.Get("Skill_Gourmet_Good").."\n"..BAD..""..translate.Get("Skill_Gourmet_Bad"),
																4,			-4,					{SKILL_PREPAREDNESS, SKILL_VITALITY1}, TREE_HEALTHTREE)
GM:AddSkill(SKILL_HAEMOSTASIS, ""..translate.Get("Skill_Haemostasis"), GOOD..""..translate.Get("Skill_Haemostasis_Good").."\n"..BAD..""..translate.Get("Skill_Haemostasis_Bad").."\n"..BAD..""..translate.Get("Skill_Haemostasis_Bad2"),
																4,			6,					{}, TREE_HEALTHTREE)
GM:AddSkill(SKILL_BLOODLETTER, ""..translate.Get("Skill_Bloodletter"), GOOD..""..translate.Get("Skill_Bloodletter_Good").."\n"..BAD..""..translate.Get("Skill_Bloodletter_Bad"),
																0,			4,					{SKILL_ANTIGEN}, TREE_HEALTHTREE)
GM:AddSkill(SKILL_REGENERATOR, ""..translate.Get("Skill_Regenerator")		, GOOD..""..translate.Get("Skill_Regenerator_Good").."\n"..BAD..""..translate.Get("Skill_Regenerator_Bad"),	
																-5,			-2,					{}, TREE_HEALTHTREE)
GM:AddSkill(SKILL_BLOODARMOR, ""..translate.Get("Skill_BloodArmor"), GOOD..""..translate.Get("Skill_BloodArmor_Good1").."\n"..GOOD..""..translate.Get("Skill_BloodArmor_Good2").."\n"..GOOD..""..translate.Get("Skill_BloodArmor_Good3").."\n"..BAD..""..translate.Get("Skill_BloodArmor_Bad"),
																2,			2,					{SKILL_IRONBLOOD, SKILL_BLOODLETTER, SKILL_D_HEMOPHILIA}, TREE_HEALTHTREE)
GM:AddSkill(SKILL_IRONBLOOD, ""..translate.Get("Skill_IronBlood"), GOOD..""..translate.Get("Skill_IronBlood_Good1").."\n"..GOOD..""..translate.Get("Skill_IronBlood_Good2").."\n"..BAD..""..translate.Get("Skill_IronBlood_Bad"),
																2,			4,					{SKILL_HAEMOSTASIS, SKILL_CIRCULATION}, TREE_HEALTHTREE)
GM:AddSkill(SKILL_D_WEAKNESS, ""..translate.Get("Skill_D_Weakness"), GOOD..""..translate.Get("Skill_D_Weakness_Good1").."\n"..GOOD..""..translate.Get("Skill_D_Weakness_Good2").."\n"..BAD..""..translate.Get("Skill_D_Weakness_Bad"),
																1,			-1,					{}, TREE_HEALTHTREE)
GM:AddSkill(SKILL_VITALITY1, ""..translate.Get("Skill_Vitality1"), GOOD..""..translate.Get("Skill_Vitality1_Good"),
																0,			-4,					{SKILL_VITALITY2}, TREE_HEALTHTREE)
GM:AddSkill(SKILL_VITALITY2, ""..translate.Get("Skill_Vitality2")	, GOOD..""..translate.Get("Skill_Vitality2_Good"),
																0,			-2,					{SKILL_VITALITY3}, TREE_HEALTHTREE)
GM:AddSkill(SKILL_VITALITY3, ""..translate.Get("Skill_Vitality3")	, GOOD..""..translate.Get("Skill_Vitality3_Good"),
																0,			-0,					{SKILL_D_WEAKNESS}, TREE_HEALTHTREE)
GM:AddSkill(SKILL_TANKER, ""..translate.Get("Skill_Tanker"), GOOD..""..translate.Get("Skill_Tanker_Good").."\n"..BAD..""..translate.Get("Skill_Tanker_Bad"),
																-5,			 4,					{}, TREE_HEALTHTREE)

GM:AddSkill(SKILL_FORAGER, ""..translate.Get("Skill_Forager"), GOOD..""..translate.Get("Skill_Forager_Good").."\n"..BAD..""..translate.Get("Skill_Forager_Bad"),
																5, 			-2,					{SKILL_GOURMET}, TREE_HEALTHTREE)

GM:AddSkill(SKILL_SUGARRUSH, ""..translate.Get("Skill_SugarRush"), GOOD..""..translate.Get("Skill_SugarRush_Good").."\n"..BAD..""..translate.Get("Skill_SugarRush_Bad"),
																4,			 0,					{SKILL_GOURMET}, TREE_HEALTHTREE)

GM:AddSkill(SKILL_CIRCULATION, ""..translate.Get("Skill_Circulation"), GOOD..""..translate.Get("Skill_Circulation_Good"),
																4, 			4, 					{SKILL_SANGUINE}, TREE_HEALTHTREE)

GM:AddSkill(SKILL_SANGUINE, ""..translate.Get("Skill_Sanguine"), GOOD..""..translate.Get("Skill_Sanguine_Good").."\n"..BAD..""..translate.Get("Skill_Sanguine_Bad")
																6,		 	2,					{}, TREE_HEALTHTREE)

GM:AddSkill(SKILL_ANTIGEN, ""..translate.Get("Skill_Antigen"), GOOD..""..translate.Get("Skill_Antigen_Good").."\n"..BAD..""..translate.Get("Skill_Antigen_Bad"),
																-2, 		4, 					{}, TREE_HEALTHTREE)
															
-- Speed Tree
GM:AddSkill(SKILL_SPEED1, ""..translate.Get("Skill_Speed1"), GOOD..""..translate.Get("Skill_Speed1_Good").."\n"..BAD..""..translate.Get("Skill_Speed1_Bad"),
																-4,			6,					{SKILL_NONE, SKILL_SPEED2}, TREE_SPEEDTREE)
GM:AddSkill(SKILL_SPEED2, ""..translate.Get("Skill_Speed2"), GOOD..""..translate.Get("Skill_Speed2_Good").."\n"..BAD..""..translate.Get("Skill_Speed2_Bad"),
																-4,			4,					{SKILL_SPEED3, SKILL_PHASER, SKILL_SPEED2, SKILL_U_CORRUPTEDFRAGMENT}, TREE_SPEEDTREE)
GM:AddSkill(SKILL_SPEED3, ""..translate.Get("Skill_Speed3"), GOOD..""..translate.Get("Skill_Speed3_Good").."\n"..BAD..""..translate.Get("Skill_Speed3_Bad"),
																-4,			2,					{SKILL_SPEED4}, TREE_SPEEDTREE)
GM:AddSkill(SKILL_SPEED4, ""..translate.Get("Skill_Speed4"), GOOD..""..translate.Get("Skill_Speed4_Good").."\n"..BAD..""..translate.Get("Skill_Speed4_Bad"),
																-4,			0,					{SKILL_SPEED5, SKILL_SAFEFALL}, TREE_SPEEDTREE)
GM:AddSkill(SKILL_SPEED5, ""..translate.Get("Skill_Speed5"), GOOD..""..translate.Get("Skill_Speed5_Good").."\n"..BAD..""..translate.Get("Skill_Speed5_Bad"),
																-4,			-2,					{SKILL_ULTRANIMBLE, SKILL_BACKPEDDLER, SKILL_MOTIONI, SKILL_CARDIOTONIC, SKILL_UNBOUND}, TREE_SPEEDTREE)
GM:AddSkill(SKILL_AGILEI, ""..translate.Get("Skill_AgileI"), GOOD..""..translate.Get("Skill_AgileI_Good").."\n"..BAD..""..translate.Get("Skill_AgileI_Bad"),
																4, 6, {SKILL_NONE, SKILL_AGILEII}, TREE_SPEEDTREE)
															
GM:AddSkill(SKILL_AGILEII, ""..translate.Get("Skill_AgileII"), GOOD..""..translate.Get("Skill_AgileII_Good").."\n"..BAD..""..translate.Get("Skill_AgileII_Bad"),
																4, 2, {SKILL_AGILEIII, SKILL_WORTHINESS3}, TREE_SPEEDTREE)
															
GM:AddSkill(SKILL_AGILEIII, ""..translate.Get("Skill_AgileIII"), GOOD..""..translate.Get("Skill_AgileIII_Good").."\n"..BAD..""..translate.Get("Skill_AgileIII_Bad"),
																4, -2, {SKILL_SAFEFALL, SKILL_ULTRANIMBLE, SKILL_SURESTEP, SKILL_INTREPID}, TREE_SPEEDTREE)
															
GM:AddSkill(SKILL_D_SLOW, ""..translate.Get("Skill_D_Slow"), GOOD..""..translate.Get("Skill_D_Slow_Good1").."\n"..GOOD..""..translate.Get("Skill_D_Slow_Good2").."\n"..BAD..""..translate.Get("Skill_D_Slow_Bad"),
																0, -4, {}, TREE_SPEEDTREE)
															
GM:AddSkill(SKILL_MOTIONI, ""..translate.Get("Skill_MotionI"), GOOD..""..translate.Get("Skill_MotionI_Good"),
																-2, -2, {SKILL_MOTIONII}, TREE_SPEEDTREE)
															
GM:AddSkill(SKILL_MOTIONII, ""..translate.Get("Skill_MotionII"), GOOD..""..translate.Get("Skill_MotionII_Good"),
																-1, -1, {SKILL_MOTIONIII}, TREE_SPEEDTREE)
															
GM:AddSkill(SKILL_MOTIONIII, ""..translate.Get("Skill_MotionIII"), GOOD..""..translate.Get("Skill_MotionIII_Good"),
																0, -2, {SKILL_D_SLOW}, TREE_SPEEDTREE)
															
GM:AddSkill(SKILL_BACKPEDDLER, ""..translate.Get("Skill_Backpeddler"), GOOD..""..translate.Get("Skill_Backpeddler_Good").."\n"..BAD..""..translate.Get("Skill_Backpeddler_Bad1").."\n"..BAD..""..translate.Get("Skill_Backpeddler_Bad2"),
																-6, 0, {}, TREE_SPEEDTREE)
															
GM:AddSkill(SKILL_PHASER, ""..translate.Get("Skill_Phaser"), GOOD..""..translate.Get("Skill_Phaser_Good").."\n"..BAD..""..translate.Get("Skill_Phaser_Bad"),
																-1, 4, {SKILL_D_WIDELOAD, SKILL_DRIFT}, TREE_SPEEDTREE)
															
GM:AddSkill(SKILL_DRIFT, ""..translate.Get("Skill_Drift"), GOOD..""..translate.Get("Skill_Drift_Good"),
																1, 3, {SKILL_WARP}, TREE_SPEEDTREE)
															
GM:AddSkill(SKILL_WARP, ""..translate.Get("Skill_Warp"), GOOD..""..translate.Get("Skill_Warp_Good"),
																2, 2, {}, TREE_SPEEDTREE)

GM:AddSkill(SKILL_SAFEFALL, ""..translate.Get("Skill_SafeFall"), GOOD..""..translate.Get("Skill_SafeFall_Good1").."\n"..GOOD..""..translate.Get("Skill_SafeFall_Good2").."\n"..BAD..""..translate.Get("Skill_SafeFall_Bad"),
	0, 0, {}, TREE_SPEEDTREE)

GM:AddSkill(SKILL_D_WIDELOAD, ""..translate.Get("Skill_D_WideLoad"), GOOD..""..translate.Get("Skill_D_WideLoad_Good1").."\n"..GOOD..""..translate.Get("Skill_D_WideLoad_Good2").."\n"..BAD..""..translate.Get("Skill_D_WideLoad_Bad"),
	1, 1, {}, TREE_SPEEDTREE)

GM:AddSkill(SKILL_U_CORRUPTEDFRAGMENT, ""..translate.Get("Skill_U_CorruptedFragment"), GOOD..""..translate.Get("Skill_U_CorruptedFragment_Good"),
	-2, 2, {}, TREE_SPEEDTREE)

GM:AddSkill(SKILL_ULTRANIMBLE, ""..translate.Get("Skill_UltraNimble"), GOOD..""..translate.Get("Skill_UltraNimble_Good").."\n"..BAD..""..translate.Get("Skill_UltraNimble_Bad"),
	0, -6, {}, TREE_SPEEDTREE)

GM:AddSkill(SKILL_WORTHINESS3, ""..translate.Get("Skill_Worthiness3"), GOOD..""..translate.Get("Skill_Worthiness3_Good").."\n"..BAD..""..translate.Get("Skill_Worthiness3_Bad"),
	6, 2, {}, TREE_SPEEDTREE)

GM:AddSkill(SKILL_SURESTEP, ""..translate.Get("Skill_SureStep"), GOOD..""..translate.Get("Skill_SureStep_Good").."\n"..BAD..""..translate.Get("Skill_SureStep_Bad"),
	6, 0, {}, TREE_SPEEDTREE)

GM:AddSkill(SKILL_INTREPID, ""..translate.Get("Skill_Intrepid"), GOOD..""..translate.Get("Skill_Intrepid_Good").."\n"..BAD..""..translate.Get("Skill_Intrepid_Bad"),
	6, -4, {SKILL_ROBUST}, TREE_SPEEDTREE)

GM:AddSkill(SKILL_ROBUST, ""..translate.Get("Skill_Robust"), GOOD..""..translate.Get("Skill_Robust_Good"),
	0, -2, {}, TREE_SPEEDTREE)
															
GM:AddSkill(SKILL_CARDIOTONIC, ""..translate.Get("Skill_Cardiotonic"), GOOD..""..translate.Get("Skill_Cardiotonic_Good1").."\n"..BAD..""..translate.Get("Skill_Cardiotonic_Bad1").."\n"..BAD..""..translate.Get("Skill_Cardiotonic_Bad2").."\n"..translate.Get("Skill_Cardiotonic_Good2"),
    -6, -4, {}, TREE_SPEEDTREE)

GM:AddSkill(SKILL_UNBOUND, ""..translate.Get("Skill_Unbound"), GOOD..""..translate.Get("Skill_Unbound_Good").."\n"..BAD..""..translate.Get("Skill_Unbound_Bad"),
    -4, -4, {}, TREE_SPEEDTREE)


-- Medic Tree
GM:AddSkill(SKILL_SURGEON1, ""..translate.Get("Skill_SURGEON1"), GOOD..""..translate.Get("Skill_SURGEON1_Good"),
																-4,			6,					{SKILL_NONE, SKILL_SURGEON2}, TREE_SUPPORTTREE)
GM:AddSkill(SKILL_SURGEON2, ""..translate.Get("Skill_SURGEON2"), GOOD..""..translate.Get("Skill_SURGEON2_Good"),
																-3,			3,					{SKILL_WORTHINESS4, SKILL_SURGEON3}, TREE_SUPPORTTREE)
GM:AddSkill(SKILL_SURGEON3, ""..translate.Get("Skill_SURGEON3"), GOOD..""..translate.Get("Skill_SURGEON3_Good"),
																-2,			0,					{SKILL_U_MEDICCLOUD, SKILL_D_FRAIL, SKILL_SURGEONIV}, TREE_SUPPORTTREE)
GM:AddSkill(SKILL_SURGEONIV, ""..translate.Get("Skill_SURGEONIV"), GOOD..""..translate.Get("Skill_SURGEONIV_Good"),
																-2,			-3,					{}, TREE_SUPPORTTREE)
GM:AddSkill(SKILL_BIOLOGYI, ""..translate.Get("Skill_BIOLOGYI"), GOOD..""..translate.Get("Skill_BIOLOGYI_Good"),
																4,			6,					{SKILL_NONE, SKILL_BIOLOGYII}, TREE_SUPPORTTREE)
GM:AddSkill(SKILL_BIOLOGYII, ""..translate.Get("Skill_BIOLOGYII"), GOOD..""..translate.Get("Skill_BIOLOGYII_Good"),
																3,			3,					{SKILL_BIOLOGYIII, SKILL_SMARTTARGETING}, TREE_SUPPORTTREE)
GM:AddSkill(SKILL_BIOLOGYIII, ""..translate.Get("Skill_BIOLOGYIII"), GOOD..""..translate.Get("Skill_BIOLOGYIII_Good"),
																2,			0,					{SKILL_U_MEDICCLOUD, SKILL_U_ANTITODESHOT, SKILL_BIOLOGYIV}, TREE_SUPPORTTREE)
GM:AddSkill(SKILL_BIOLOGYIV, ""..translate.Get("Skill_BIOLOGYIV"), GOOD..""..translate.Get("Skill_BIOLOGYIV_Good"),
																2,			-3,					{}, TREE_SUPPORTTREE)
GM:AddSkill(SKILL_D_FRAIL, ""..translate.Get("Skill_D_FRAIL"), GOOD..""..translate.Get("Skill_D_FRAIL_Good").."\n"..GOOD..""..translate.Get("Skill_D_FRAIL_Good2").."\n"..BAD..""..translate.Get("Skill_D_FRAIL_Bad"),
																-4,			-2,					{}, TREE_SUPPORTTREE)
GM:AddSkill(SKILL_U_MEDICCLOUD, ""..translate.Get("Skill_U_MEDICCLOUD"), GOOD..""..translate.Get("Skill_U_MEDICCLOUD_Good"),
																0,			-2,					{SKILL_DISPERSION}, TREE_SUPPORTTREE)
.AlwaysActive = true
GM:AddSkill(SKILL_SMARTTARGETING, ""..translate.Get("Skill_SMARTTARGETING"), GOOD..""..translate.Get("Skill_SMARTTARGETING_Good")..BAD..""..translate.Get("Skill_SMARTTARGETING_Bad")..BAD..""..translate.Get("Skill_SMARTTARGETING_Bad2"),
																0,			2,					{}, TREE_SUPPORTTREE)
GM:AddSkill(SKILL_RECLAIMSOL, ""..translate.Get("Skill_RECLAIMSOL"), GOOD..""..translate.Get("Skill_RECLAIMSOL_Good")..BAD..""..translate.Get("Skill_RECLAIMSOL_Bad")..BAD..""..translate.Get("Skill_RECLAIMSOL_Bad2")..BAD..""..translate.Get("Skill_RECLAIMSOL_Bad3"),
																0,			4,					{SKILL_SMARTTARGETING}, TREE_SUPPORTTREE)
GM:AddSkill(SKILL_U_STRENGTHSHOT, ""..translate.Get("Skill_U_STRENGTHSHOT"), GOOD..""..translate.Get("Skill_U_STRENGTHSHOT_Good"),
																0,			0,					{SKILL_SMARTTARGETING}, TREE_SUPPORTTREE)
GM:AddSkill(SKILL_WORTHINESS4, ""..translate.Get("Skill_WORTHINESS4"), GOOD..""..translate.Get("Skill_WORTHINESS4_Good")..BAD..""..translate.Get("Skill_WORTHINESS4_Bad"),
																-5,			2,					{}, TREE_SUPPORTTREE)
GM:AddSkill(SKILL_U_ANTITODESHOT, ""..translate.Get("Skill_U_ANTITODESHOT"), GOOD..""..translate.Get("Skill_U_ANTITODESHOT_Good"),
																4,			-2,					{}, TREE_SUPPORTTREE)
GM:AddSkill(SKILL_DISPERSION, ""..translate.Get("Skill_DISPERSION"), GOOD..""..translate.Get("Skill_DISPERSION_Good")..BAD..""..translate.Get("Skill_DISPERSION_Bad"),
																0,			-4,					{}, TREE_SUPPORTTREE)

-- Defence Tree
GM:AddSkill(SKILL_HANDY1, ""..translate.Get("Skill_Handy1"), GOOD..""..translate.Get("Skill_Handy1_Good"),
    -5, -6, {SKILL_NONE, SKILL_HANDY2}, TREE_BUILDINGTREE)

GM:AddSkill(SKILL_HANDY2, ""..translate.Get("Skill_Handy2"), GOOD..""..translate.Get("Skill_Handy2_Good"),
    -5, -4, {SKILL_HANDY3, SKILL_U_BLASTTURRET, SKILL_LOADEDHULL}, TREE_BUILDINGTREE)

GM:AddSkill(SKILL_HANDY3, ""..translate.Get("Skill_Handy3"), GOOD..""..translate.Get("Skill_Handy3_Good"),
    -5, -1, {SKILL_TAUT, SKILL_HAMMERDISCIPLINE, SKILL_D_NOODLEARMS, SKILL_HANDY4}, TREE_BUILDINGTREE)

GM:AddSkill(SKILL_HANDY4, ""..translate.Get("Skill_Handy4"), GOOD..""..translate.Get("Skill_Handy4_Good"),
    -3, 1, {SKILL_HANDY5}, TREE_BUILDINGTREE)

GM:AddSkill(SKILL_HANDY5, ""..translate.Get("Skill_Handy5"), GOOD..""..translate.Get("Skill_Handy5_Good"),
    -3, 3, {}, TREE_BUILDINGTREE)

GM:AddSkill(SKILL_HAMMERDISCIPLINE, ""..translate.Get("Skill_HammerDiscipline"), GOOD..""..translate.Get("Skill_HammerDiscipline_Good"),
    0, 1, {SKILL_BARRICADEEXPERT}, TREE_BUILDINGTREE)

	GM:AddSkill(SKILL_BARRICADEEXPERT, ""..translate.Get("Skill_BarricadeExpert"), GOOD..""..translate.Get("Skill_BarricadeExpert_Good1").."\n"..GOOD..""..translate.Get("Skill_BarricadeExpert_Good2").."\n"..BAD..""..translate.Get("Skill_BarricadeExpert_Bad"),
    0, 3, {}, TREE_BUILDINGTREE)

GM:AddSkill(SKILL_LOADEDHULL, ""..translate.Get("Skill_LoadedHull"), GOOD..""..translate.Get("Skill_LoadedHull_Good").."\n"..BAD..""..translate.Get("Skill_LoadedHull_Bad"),
    -2, -4, {SKILL_REINFORCEDHULL, SKILL_REINFORCEDBLADES, SKILL_AVIATOR}, TREE_BUILDINGTREE)

GM:AddSkill(SKILL_REINFORCEDHULL, ""..translate.Get("Skill_ReinforcedHull"), GOOD..""..translate.Get("Skill_ReinforcedHull_Good").."\n"..BAD..""..translate.Get("Skill_ReinforcedHull_Bad1").."\n"..BAD..""..translate.Get("Skill_ReinforcedHull_Bad2"),
    -2, -2, {SKILL_STABLEHULL}, TREE_BUILDINGTREE)

GM:AddSkill(SKILL_STABLEHULL, ""..translate.Get("Skill_StableHull"), GOOD..""..translate.Get("Skill_StableHull_Good").."\n"..BAD..""..translate.Get("Skill_StableHull_Bad"),
    0, -3, {SKILL_U_DRONE}, TREE_BUILDINGTREE)

GM:AddSkill(SKILL_REINFORCEDBLADES, ""..translate.Get("Skill_ReinforcedBlades"), GOOD..""..translate.Get("Skill_ReinforcedBlades_Good").."\n"..BAD..""..translate.Get("Skill_ReinforcedBlades_Bad"),
    0, -5, {}, TREE_BUILDINGTREE)

GM:AddSkill(SKILL_AVIATOR, ""..translate.Get("Skill_Aviator"), GOOD..""..translate.Get("Skill_Aviator_Good").."\n"..BAD..""..translate.Get("Skill_Aviator_Bad"),
    -4, -2, {}, TREE_BUILDINGTREE)

GM:AddSkill(SKILL_U_BLASTTURRET, ""..translate.Get("Skill_U_BlastTurret"), GOOD..""..translate.Get("Skill_U_BlastTurret_Good").."\n"..translate.Get("Skill_U_BlastTurret_Good2"),
    -8, -4, {SKILL_TURRETLOCK, SKILL_TWINVOLLEY, SKILL_TURRETOVERLOAD}, TREE_BUILDINGTREE)
.AlwaysActive = true

GM:AddSkill(SKILL_TURRETLOCK, ""..translate.Get("Skill_TurretLock"), GOOD..""..translate.Get("Skill_TurretLock_Good").."\n"..BAD..""..translate.Get("Skill_TurretLock_Bad"),
    -6, -2, {}, TREE_BUILDINGTREE)

GM:AddSkill(SKILL_TWINVOLLEY, ""..translate.Get("Skill_TwinVolley"), GOOD..""..translate.Get("Skill_TwinVolley_Good").."\n"..BAD..""..translate.Get("Skill_TwinVolley_Bad1").."\n"..BAD..""..translate.Get("Skill_TwinVolley_Bad2"),
    -10, -5, {}, TREE_BUILDINGTREE)

GM:AddSkill(SKILL_TURRETOVERLOAD, ""..translate.Get("Skill_TurretOverload"), GOOD..""..translate.Get("Skill_TurretOverload_Good").."\n"..BAD..""..translate.Get("Skill_TurretOverload_Bad"),
    -8, -2, {SKILL_INSTRUMENTS}, TREE_BUILDINGTREE)

GM:AddSkill(SKILL_U_DRONE, ""..translate.Get("Skill_U_Drone"), GOOD..""..translate.Get("Skill_U_Drone_Good"),
    2, -3, {SKILL_HAULMODULE, SKILL_U_ROLLERMINE}, TREE_BUILDINGTREE)
.AlwaysActive = true
GM:AddSkill(SKILL_U_NANITECLOUD, ""..translate.Get("Skill_U_NaniteCloud"), GOOD..""..translate.Get("Skill_U_NaniteCloud_Good"),
    3, 1, {SKILL_HAMMERDISCIPLINE}, TREE_BUILDINGTREE)
.AlwaysActive = true

GM:AddSkill(SKILL_FIELDAMP, ""..translate.Get("Skill_FieldAmp"), GOOD..""..translate.Get("Skill_FieldAmp_Good").."\n"..BAD..""..translate.Get("Skill_FieldAmp_Bad"),
    6, 4, {}, TREE_BUILDINGTREE)

GM:AddSkill(SKILL_TECHNICIAN, ""..translate.Get("Skill_Technician"), GOOD..""..translate.Get("Skill_Technician_Good").."\n"..GOOD..""..translate.Get("Skill_Technician_Good2"),
    4, 3, {}, TREE_BUILDINGTREE)

GM:AddSkill(SKILL_U_ROLLERMINE, ""..translate.Get("Skill_U_Rollermine"), GOOD..""..translate.Get("Skill_U_Rollermine_Good"),
    3, -5, {}, TREE_BUILDINGTREE)

GM:AddSkill(SKILL_HAULMODULE, ""..translate.Get("Skill_HaulModule"), GOOD..""..translate.Get("Skill_HaulModule_Good"),
    2, -1, {SKILL_U_NANITECLOUD}, TREE_BUILDINGTREE)

GM:AddSkill(SKILL_LIGHTCONSTRUCT, ""..translate.Get("Skill_LightConstruct"), GOOD..""..translate.Get("Skill_LightConstruct_Good").."\n"..BAD..""..translate.Get("Skill_LightConstruct_Bad"),
    8, -1, {}, TREE_BUILDINGTREE)

GM:AddSkill(SKILL_STOCKPILE, ""..translate.Get("Skill_Stockpile"), GOOD..""..translate.Get("Skill_Stockpile_Good").."\n"..BAD..""..translate.Get("Skill_Stockpile_Bad"),
    8, -3, {}, TREE_BUILDINGTREE)

GM:AddSkill(SKILL_ACUITY, ""..translate.Get("Skill_Acuity"), GOOD..""..translate.Get("Skill_Acuity_Good").."\n"..GOOD..""..translate.Get("Skill_Acuity_Good2").."\n"..GOOD..""..translate.Get("Skill_Acuity_Good3"),
    6, -3, {SKILL_INSIGHT, SKILL_STOCKPILE, SKILL_U_CRAFTINGPACK, SKILL_STOWAGE}, TREE_BUILDINGTREE)

	GM:AddSkill(SKILL_VISION, ""..translate.Get("Skill_Vision"), GOOD..""..translate.Get("Skill_Vision_Good1").."\n"..GOOD..""..translate.Get("Skill_Vision_Good2"),
    6, -6, {SKILL_NONE, SKILL_ACUITY}, TREE_BUILDINGTREE)

GM:AddSkill(SKILL_U_ROCKETTURRET, ""..translate.Get("Skill_U_RocketTurret"), GOOD..""..translate.Get("Skill_U_RocketTurret_Good"),
    -8, 0, {SKILL_TURRETOVERLOAD}, TREE_BUILDINGTREE)

GM:AddSkill(SKILL_INSIGHT, ""..translate.Get("Skill_Insight"), GOOD..""..translate.Get("Skill_Insight_Good1").."\n"..GOOD..""..translate.Get("Skill_Insight_Good2").."\n"..GOOD..""..translate.Get("Skill_Insight_Good3"),
    6, 0, {SKILL_U_NANITECLOUD, SKILL_U_ZAPPER_ARC, SKILL_LIGHTCONSTRUCT, SKILL_D_LATEBUYER}, TREE_BUILDINGTREE)
.AlwaysActive = true
GM:AddSkill(SKILL_U_ZAPPER_ARC, ""..translate.Get("Skill_U_ZapperArc"), GOOD..""..translate.Get("Skill_U_ZapperArc_Good"),
    6, 2, {SKILL_FIELDAMP, SKILL_TECHNICIAN}, TREE_BUILDINGTREE)
.AlwaysActive = true
GM:AddSkill(SKILL_D_LATEBUYER, ""..translate.Get("Skill_D_LateBuyer"), GOOD..""..translate.Get("Skill_D_LateBuyer_Good1").."\n"..GOOD..""..translate.Get("Skill_D_LateBuyer_Good2").."\n"..BAD..""..translate.Get("Skill_D_LateBuyer_Bad"),
    8, 1, {}, TREE_BUILDINGTREE)

GM:AddSkill(SKILL_U_CRAFTINGPACK, ""..translate.Get("Skill_U_CraftingPack"), GOOD..""..translate.Get("Skill_U_CraftingPack_Good1").."\n"..GOOD..""..translate.Get("Skill_U_CraftingPack_Good2").."\n"..GOOD..""..translate.Get("Skill_U_CraftingPack_Good3"),
    4, -1, {}, TREE_BUILDINGTREE)
.AlwaysActive = true
GM:AddSkill(SKILL_TAUT, ""..translate.Get("Skill_Taut"), GOOD..""..translate.Get("Skill_Taut_Good").."\n"..BAD..""..translate.Get("Skill_Taut_Bad"),
    -5, 3, {}, TREE_BUILDINGTREE)

GM:AddSkill(SKILL_D_NOODLEARMS, ""..translate.Get("Skill_D_NoodleArms"), GOOD..""..translate.Get("Skill_D_NoodleArms_Good1").."\n"..GOOD..""..translate.Get("Skill_D_NoodleArms_Good2").."\n"..BAD..""..translate.Get("Skill_D_NoodleArms_Bad"),
    -7, 2, {}, TREE_BUILDINGTREE)

GM:AddSkill(SKILL_INSTRUMENTS, ""..translate.Get("Skill_Instruments"), GOOD..""..translate.Get("Skill_Instruments_Good"),
    -10, -3, {}, TREE_BUILDINGTREE)

GM:AddSkill(SKILL_STOWAGE, ""..translate.Get("Skill_Stowage"), GOOD..""..translate.Get("Skill_Stowage_Good").."\n"..BAD..""..translate.Get("Skill_Stowage_Bad"),
    4, -3, {}, TREE_BUILDINGTREE)


-- Gunnery Tree
GM:AddSkill(SKILL_TRIGGER_DISCIPLINE1, ""..translate.Get("Skill_TriggerDiscipline1"), GOOD..""..translate.Get("Skill_TriggerDiscipline1_Good1").."\n"..GOOD..""..translate.Get("Skill_TriggerDiscipline1_Good2"),
    -5, 6, {SKILL_TRIGGER_DISCIPLINE2, SKILL_NONE}, TREE_GUNTREE)

GM:AddSkill(SKILL_TRIGGER_DISCIPLINE2, ""..translate.Get("Skill_TriggerDiscipline2"), GOOD..""..translate.Get("Skill_TriggerDiscipline2_Good1").."\n"..GOOD..""..translate.Get("Skill_TriggerDiscipline2_Good2"),
    -4, 3, {SKILL_TRIGGER_DISCIPLINE3, SKILL_D_PALSY, SKILL_EQUIPPED}, TREE_GUNTREE)

GM:AddSkill(SKILL_TRIGGER_DISCIPLINE3, ""..translate.Get("Skill_TriggerDiscipline3"), GOOD..""..translate.Get("Skill_TriggerDiscipline3_Good1").."\n"..GOOD..""..translate.Get("Skill_TriggerDiscipline3_Good2"),
    -3, 0, {SKILL_QUICKRELOAD, SKILL_QUICKDRAW, SKILL_WORTHINESS1, SKILL_EGOCENTRIC}, TREE_GUNTREE)

GM:AddSkill(SKILL_D_PALSY, ""..translate.Get("Skill_D_Palsy"), GOOD..""..translate.Get("Skill_D_Palsy_Good1").."\n"..GOOD..""..translate.Get("Skill_D_Palsy_Good2").."\n"..BAD..""..translate.Get("Skill_D_Palsy_Bad"),
    0, 4, {SKILL_LEVELHEADED}, TREE_GUNTREE)

GM:AddSkill(SKILL_LEVELHEADED, ""..translate.Get("Skill_LevelHeaded"), GOOD..""..translate.Get("Skill_LevelHeaded_Good"),
    -2, 2, {}, TREE_GUNTREE)

GM:AddSkill(SKILL_QUICKDRAW, ""..translate.Get("Skill_QuickDraw"), GOOD..""..translate.Get("Skill_QuickDraw_Good").."\n"..BAD..""..translate.Get("Skill_QuickDraw_Bad"),
    0, 1, {}, TREE_GUNTREE)

	GM:AddSkill(SKILL_FOCUS, ""..translate.Get("Skill_Focus"), GOOD..""..translate.Get("Skill_Focus_Good").."\n"..BAD..""..translate.Get("Skill_Focus_Bad"),
    5, 6, {SKILL_NONE, SKILL_FOCUSII}, TREE_GUNTREE)

GM:AddSkill(SKILL_FOCUSII, ""..translate.Get("Skill_FocusII"), GOOD..""..translate.Get("Skill_FocusII_Good").."\n"..BAD..""..translate.Get("Skill_FocusII_Bad"),
    4, 3, {SKILL_FOCUSIII, SKILL_SCAVENGER, SKILL_D_PALSY, SKILL_PITCHER}, TREE_GUNTREE)

GM:AddSkill(SKILL_FOCUSIII, ""..translate.Get("Skill_FocusIII"), GOOD..""..translate.Get("Skill_FocusIII_Good").."\n"..BAD..""..translate.Get("Skill_FocusIII_Bad"),
    3, 0, {SKILL_EGOCENTRIC, SKILL_WOOISM, SKILL_ORPHICFOCUS, SKILL_SCOURER}, TREE_GUNTREE)

GM:AddSkill(SKILL_QUICKRELOAD, ""..translate.Get("Skill_QuickReload"), GOOD..""..translate.Get("Skill_QuickReload_Good").."\n"..BAD..""..translate.Get("Skill_QuickReload_Bad"),
    -5, 1, {SKILL_SLEIGHTOFHAND}, TREE_GUNTREE)

GM:AddSkill(SKILL_SLEIGHTOFHAND, ""..translate.Get("Skill_SleightOfHand"), GOOD..""..translate.Get("Skill_SleightOfHand_Good").."\n"..BAD..""..translate.Get("Skill_SleightOfHand_Bad"),
    -5, -1, {}, TREE_GUNTREE)

GM:AddSkill(SKILL_U_CRYGASGREN, ""..translate.Get("Skill_U_CryoGasGrenade"), GOOD..""..translate.Get("Skill_U_CryoGasGrenade_Good"),
    2, -3, {SKILL_EGOCENTRIC}, TREE_GUNTREE)

GM:AddSkill(SKILL_SOFTDET, ""..translate.Get("Skill_SoftDet"), GOOD..""..translate.Get("Skill_SoftDet_Good").."\n"..BAD..""..translate.Get("Skill_SoftDet_Bad"),
    0, -5, {}, TREE_GUNTREE)

GM:AddSkill(SKILL_ORPHICFOCUS, ""..translate.Get("Skill_OrphicFocus"), GOOD..""..translate.Get("Skill_OrphicFocus_Good1").."\n"..GOOD..""..translate.Get("Skill_OrphicFocus_Good2").."\n"..BAD..""..translate.Get("Skill_OrphicFocus_Bad1").."\n"..BAD..""..translate.Get("Skill_OrphicFocus_Bad2"),
    5, -1, {SKILL_DELIBRATION}, TREE_GUNTREE)

GM:AddSkill(SKILL_DELIBRATION, ""..translate.Get("Skill_Delib"), GOOD..""..translate.Get("Skill_Delib_Good"),
    6, -3, {}, TREE_GUNTREE)

GM:AddSkill(SKILL_EGOCENTRIC, ""..translate.Get("Skill_Egocentric"), GOOD..""..translate.Get("Skill_Egocentric_Good").."\n"..BAD..""..translate.Get("Skill_Egocentric_Bad"),
    0, -1, {SKILL_BLASTPROOF}, TREE_GUNTREE)

GM:AddSkill(SKILL_BLASTPROOF, ""..translate.Get("Skill_BlastProof"), GOOD..""..translate.Get("Skill_BlastProof_Good").."\n"..BAD..""..translate.Get("Skill_BlastProof_Bad1").."\n"..BAD..""..translate.Get("Skill_BlastProof_Bad2"),
    0, -3, {SKILL_SOFTDET, SKILL_CANNONBALL, SKILL_CONEFFECT}, TREE_GUNTREE)

GM:AddSkill(SKILL_WOOISM, ""..translate.Get("Skill_Wooism"), GOOD..""..translate.Get("Skill_Wooism_Good").."\n"..BAD..""..translate.Get("Skill_Wooism_Bad"),
    5, 1, {SKILL_TRUEWOOISM}, TREE_GUNTREE)

GM:AddSkill(SKILL_SCAVENGER, ""..translate.Get("Skill_Scavenger"), GOOD..""..translate.Get("Skill_Scavenger_Good"),
    7, 4, {}, TREE_GUNTREE)

GM:AddSkill(SKILL_PITCHER, ""..translate.Get("Skill_Pitcher"), GOOD..""..translate.Get("Skill_Pitcher_Good"),
    6, 2, {}, TREE_GUNTREE)

GM:AddSkill(SKILL_EQUIPPED, ""..translate.Get("Skill_Equipped"), GOOD..""..translate.Get("Skill_Equipped_Good"),
    -6, 2, {}, TREE_GUNTREE)

GM:AddSkill(SKILL_WORTHINESS1, ""..translate.Get("Skill_Worthiness1"), GOOD..""..translate.Get("Skill_Worthiness1_Good").."\n"..BAD..""..translate.Get("Skill_Worthiness1_Bad"),
    -4, -3, {}, TREE_GUNTREE)

GM:AddSkill(SKILL_CANNONBALL, ""..translate.Get("Skill_Cannonball"), GOOD..""..translate.Get("Skill_Cannonball_Good").."\n"..BAD..""..translate.Get("Skill_Cannonball_Bad"),
    -2, -3, {}, TREE_GUNTREE)

GM:AddSkill(SKILL_SCOURER, ""..translate.Get("Skill_Scourer"), GOOD..""..translate.Get("Skill_Scourer_Good").."\n"..BAD..""..translate.Get("Skill_Scourer_Bad"),
    4, -3, {}, TREE_GUNTREE)

GM:AddSkill(SKILL_CONEFFECT, ""..translate.Get("Skill_ConEffect"), GOOD..""..translate.Get("Skill_ConEffect_Good").."\n"..BAD..""..translate.Get("Skill_ConEffect_Bad"),
    2, -5, {}, TREE_GUNTREE)

GM:AddSkill(SKILL_TRUEWOOISM, ""..translate.Get("Skill_TrueWooism"), GOOD..""..translate.Get("Skill_TrueWooism_Good").."\n"..BAD..""..translate.Get("Skill_TrueWooism_Bad"),
    7, 0, {}, TREE_GUNTREE)

-- Melee Tree
GM:AddSkill(SKILL_WORTHINESS2, ""..translate.Get("Skill_Worthiness2"), GOOD..""..translate.Get("Skill_Worthiness2_Good").."\n"..BAD..""..translate.Get("Skill_Worthiness2_Bad"),
    4, 0, {}, TREE_MELEETREE)

GM:AddSkill(SKILL_BATTLER1, ""..translate.Get("Skill_Battler1"), GOOD..""..translate.Get("Skill_Battler1_Good"),
    -6, -6, {SKILL_BATTLER2, SKILL_NONE}, TREE_MELEETREE)

GM:AddSkill(SKILL_BATTLER2, ""..translate.Get("Skill_Battler2"), GOOD..""..translate.Get("Skill_Battler2_Good"),
    -6, -4, {SKILL_BATTLER3, SKILL_LIGHTWEIGHT}, TREE_MELEETREE)

GM:AddSkill(SKILL_BATTLER3, ""..translate.Get("Skill_Battler3"), GOOD..""..translate.Get("Skill_Battler3_Good"),
    -4, -2, {SKILL_BATTLER4, SKILL_LANKY}, TREE_MELEETREE)

GM:AddSkill(SKILL_BATTLER4, ""..translate.Get("Skill_Battler4"), GOOD..""..translate.Get("Skill_Battler4_Good"),
    -2, 0, {SKILL_BATTLER5, SKILL_MASTERCHEF, SKILL_D_CLUMSY}, TREE_MELEETREE)

GM:AddSkill(SKILL_BATTLER5, ""..translate.Get("Skill_Battler5"), GOOD..""..translate.Get("Skill_Battler5_Good"),
    0, 2, {SKILL_GLASSWEAPONS, SKILL_BLOODLUST}, TREE_MELEETREE)

GM:AddSkill(SKILL_LASTSTAND, ""..translate.Get("Skill_LastStand"), GOOD..""..translate.Get("Skill_LastStand_Good").."\n"..BAD..""..translate.Get("Skill_LastStand_Bad"),
    0, 6, {}, TREE_MELEETREE)

GM:AddSkill(SKILL_GLASSWEAPONS, ""..translate.Get("Skill_GlassWeapons"), GOOD..""..translate.Get("Skill_GlassWeapons_Good").."\n"..BAD..""..translate.Get("Skill_GlassWeapons_Bad"),
    2, 4, {}, TREE_MELEETREE)

GM:AddSkill(SKILL_D_CLUMSY, ""..translate.Get("Skill_D_Clumsy"), GOOD..""..translate.Get("Skill_D_Clumsy_Good").."\n"..BAD..""..translate.Get("Skill_D_Clumsy_Bad"),
    -2, 2, {}, TREE_MELEETREE)

GM:AddSkill(SKILL_CHEAPKNUCKLE, ""..translate.Get("Skill_CheapKnuclle"), GOOD..""..translate.Get("Skill_CheapKnuclle_Good").."\n"..BAD..""..translate.Get("Skill_CheapKnuclle_Bad"),
    4, -2, {SKILL_HEAVYSTRIKES, SKILL_WORTHINESS2}, TREE_MELEETREE)

GM:AddSkill(SKILL_CRITICALKNUCKLE, ""..translate.Get("Skill_CriticalKnuclle"), GOOD..""..translate.Get("Skill_CriticalKnuclle_Good").."\n"..BAD..""..translate.Get("Skill_CriticalKnuclle_Bad"),
    6, -2, {SKILL_BRASH}, TREE_MELEETREE)

	GM:AddSkill(SKILL_KNUCKLEMASTER, ""..translate.Get("Skill_KnuckleMaster"), GOOD..""..translate.Get("Skill_KnuckleMaster_Good1").."\n"..GOOD..""..translate.Get("Skill_KnuckleMaster_Good2").."\n"..BAD..""..translate.Get("Skill_KnuckleMaster_Bad"),
    6, -6, {SKILL_NONE, SKILL_COMBOKNUCKLE}, TREE_MELEETREE)

GM:AddSkill(SKILL_COMBOKNUCKLE, ""..translate.Get("Skill_ComboKnuckle"), GOOD..""..translate.Get("Skill_ComboKnuckle_Good").."\n"..BAD..""..translate.Get("Skill_ComboKnuckle_Bad"),
    6, -4, {SKILL_CHEAPKNUCKLE, SKILL_CRITICALKNUCKLE}, TREE_MELEETREE)

GM:AddSkill(SKILL_HEAVYSTRIKES, ""..translate.Get("Skill_HeavyStrikes"), GOOD..""..translate.Get("Skill_HeavyStrikes_Good").."\n"..BAD..""..translate.Get("Skill_HeavyStrikes_Bad1").."\n"..BAD..""..translate.Get("Skill_HeavyStrikes_Bad2"),
    2, 0, {SKILL_BATTLER5, SKILL_JOUSTER}, TREE_MELEETREE)

GM:AddSkill(SKILL_JOUSTER, ""..translate.Get("Skill_Jouster"), GOOD..""..translate.Get("Skill_Jouster_Good").."\n"..BAD..""..translate.Get("Skill_Jouster_Bad"),
    2, 2, {}, TREE_MELEETREE)

GM:AddSkill(SKILL_LANKY, ""..translate.Get("Skill_LankyI"), GOOD..""..translate.Get("Skill_LankyI_Good").."\n"..BAD..""..translate.Get("Skill_LankyI_Bad"),
    -4, 0, {SKILL_LANKYII}, TREE_MELEETREE)

GM:AddSkill(SKILL_LANKYII, ""..translate.Get("Skill_LankyII"), GOOD..""..translate.Get("Skill_LankyII_Good").."\n"..BAD..""..translate.Get("Skill_LankyII_Bad"),
    -4, 2, {}, TREE_MELEETREE)

GM:AddSkill(SKILL_MASTERCHEF, ""..translate.Get("Skill_MasterChef"), GOOD..""..translate.Get("Skill_MasterChef_Good").."\n"..BAD..""..translate.Get("Skill_MasterChef_Bad"),
    0, -3, {SKILL_BATTLER4}, TREE_MELEETREE)

GM:AddSkill(SKILL_LIGHTWEIGHT, ""..translate.Get("Skill_Lightweight"), GOOD..""..translate.Get("Skill_Lightweight_Good").."\n"..BAD..""..translate.Get("Skill_Lightweight_Bad"),
    -6, -2, {}, TREE_MELEETREE)

GM:AddSkill(SKILL_BLOODLUST, ""..translate.Get("Skill_Bloodlust"), ""..translate.Get("Skill_Bloodlust_Description").."\n"..GOOD..""..translate.Get("Skill_Bloodlust_Good").."\n"..BAD..""..translate.Get("Skill_Bloodlust_Bad"),
    -2, 4, {SKILL_LASTSTAND}, TREE_MELEETREE)

GM:AddSkill(SKILL_BRASH, ""..translate.Get("Skill_Brash"), GOOD..""..translate.Get("Skill_Brash_Good").."\n"..BAD..""..translate.Get("Skill_Brash_Bad"),
    6, 0, {}, TREE_MELEETREE)


GM:SetSkillModifierFunction(SKILLMOD_SPEED, function(pl, amount)
	pl.SkillSpeedAdd = amount
end)

GM:SetSkillModifierFunction(SKILLMOD_MEDKIT_EFFECTIVENESS_MUL, function(pl, amount)
	pl.MedicHealMul = math.Clamp(amount + 1.0, 0.0, 1000.0)
end)

GM:SetSkillModifierFunction(SKILLMOD_MEDKIT_COOLDOWN_MUL, function(pl, amount)
	pl.MedicCooldownMul = math.Clamp(amount + 1.0, 0.0, 1000.0)
end)

GM:SetSkillModifierFunction(SKILLMOD_WORTH, function(pl, amount)
	pl.ExtraStartingWorth = amount
end)

GM:SetSkillModifierFunction(SKILLMOD_FALLDAMAGE_THRESHOLD_MUL, function(pl, amount)
	pl.FallDamageThresholdMul = math.Clamp(amount + 1.0, 0.0, 1000.0)
end)

GM:SetSkillModifierFunction(SKILLMOD_FALLDAMAGE_SLOWDOWN_MUL, function(pl, amount)
	pl.FallDamageSlowDownMul = math.Clamp(amount + 1.0, 0.0, 1000.0)
end)

GM:SetSkillModifierFunction(SKILLMOD_FOODEATTIME_MUL, function(pl, amount)
	pl.FoodEatTimeMul = math.Clamp(amount + 1.0, 0, 1000.0)
end)

GM:SetSkillModifierFunction(SKILLMOD_JUMPPOWER_MUL, function(pl, amount)
	pl.JumpPowerMul = math.Clamp(amount + 1.0, 0.0, 10.0)

	if SERVER then
		pl:ResetJumpPower()
	end
end)

GM:SetSkillModifierFunction(SKILLMOD_DEPLOYSPEED_MUL, function(pl, amount)
	pl.DeploySpeedMultiplier = math.Clamp(amount + 1.0, 0.05, 100.0)

	for _, wep in pairs(pl:GetWeapons()) do
		GAMEMODE:DoChangeDeploySpeed(wep)
	end
end)

GM:SetSkillModifierFunction(SKILLMOD_BLOODARMOR, function(pl, amount)
	local oldarmor = pl:GetBloodArmor()
	local oldcap = pl.MaxBloodArmor or 20
	local new = 20 + math.Clamp(amount, -20, 1000)

	pl.MaxBloodArmor = new

	if SERVER then
		if oldarmor > oldcap then
			local overcap = oldarmor - oldcap
			pl:SetBloodArmor(pl.MaxBloodArmor + overcap)
		else
			pl:SetBloodArmor(pl:GetBloodArmor() / oldcap * new)
		end
	end
end)

GM:SetSkillModifierFunction(SKILLMOD_RELOADSPEED_MUL, function(pl, amount)
	pl.ReloadSpeedMultiplier = math.Clamp(amount + 1.0, 0.05, 100.0)
end)

GM:SetSkillModifierFunction(SKILLMOD_MELEE_DAMAGE_MUL, function(pl, amount)
	pl.MeleeDamageMultiplier = math.Clamp(amount + 1.0, 0.0, 100.0)
end)

GM:SetSkillModifierFunction(SKILLMOD_SELF_DAMAGE_MUL, function(pl, amount)
	pl.SelfDamageMul = math.Clamp(amount + 1.0, 0.0, 100.0)
end)

GM:SetSkillModifierFunction(SKILLMOD_MELEE_KNOCKBACK_MUL, function(pl, amount)
	pl.MeleeKnockbackMultiplier = math.Clamp(amount + 1.0, 0.0, 10000.0)
end)

GM:SetSkillModifierFunction(SKILLMOD_UNARMED_DAMAGE_MUL, function(pl, amount)
	pl.UnarmedDamageMul = math.Clamp(amount + 1.0, 0.0, 100.0)
end)

GM:SetSkillModifierFunction(SKILLMOD_UNARMED_SWING_DELAY_MUL, function(pl, amount)
	pl.UnarmedDelayMul = math.Clamp(amount + 1.0, 0.0, 100.0)
end)

GM:SetSkillModifierFunction(SKILLMOD_BARRICADE_PHASE_SPEED_MUL, function(pl, amount)
	pl.BarricadePhaseSpeedMul = math.Clamp(amount + 1.0, 0.05, 1000.0)
end)

GM:SetSkillModifierFunction(SKILLMOD_HAMMER_SWING_DELAY_MUL, function(pl, amount)
	pl.HammerSwingDelayMul = math.Clamp(amount + 1.0, 0.01, 1.0)
end)

GM:SetSkillModifierFunction(SKILLMOD_REPAIRRATE_MUL, function(pl, amount)
	pl.RepairRateMul = math.Clamp(amount + 1.0, 0, 1000.0)
end)

GM:SetSkillModifierFunction(SKILLMOD_AIMSPREAD_MUL, function(pl, amount)
	pl.AimSpreadMul = math.Clamp(amount + 1.0, 0, 1000.0)
end)

GM:SetSkillModifierFunction(SKILLMOD_MEDGUN_FIRE_DELAY_MUL, function(pl, amount)
	pl.MedgunFireDelayMul = math.Clamp(amount + 1.0, 0.0, 100.0)
end)

GM:SetSkillModifierFunction(SKILLMOD_MEDGUN_RELOAD_SPEED_MUL, function(pl, amount)
	pl.MedgunReloadSpeedMul = math.Clamp(amount + 1.0, 0.0, 100.0)
end)

GM:SetSkillModifierFunction(SKILLMOD_DRONE_GUN_RANGE_MUL, function(pl, amount)
	pl.DroneGunRangeMul = math.Clamp(amount + 1.0, 0.0, 100.0)
end)

GM:SetSkillModifierFunction(SKILLMOD_HEALING_RECEIVED, function(pl, amount)
	pl.HealingReceived = math.Clamp(amount + 1.0, 0.0, 100.0)
end)

GM:SetSkillModifierFunction(SKILLMOD_RELOADSPEED_PISTOL_MUL, function(pl, amount)
	pl.ReloadSpeedMultiplierPISTOL = math.Clamp(amount + 1.0, 0.0, 100.0)
end)

GM:SetSkillModifierFunction(SKILLMOD_RELOADSPEED_SMG_MUL, function(pl, amount)
	pl.ReloadSpeedMultiplierSMG1 = math.Clamp(amount + 1.0, 0.0, 100.0)
end)

GM:SetSkillModifierFunction(SKILLMOD_RELOADSPEED_ASSAULT_MUL, function(pl, amount)
	pl.ReloadSpeedMultiplierAR2 = math.Clamp(amount + 1.0, 0.0, 100.0)
end)

GM:SetSkillModifierFunction(SKILLMOD_RELOADSPEED_SHELL_MUL, function(pl, amount)
	pl.ReloadSpeedMultiplierBUCKSHOT = math.Clamp(amount + 1.0, 0.0, 100.0)
end)

GM:SetSkillModifierFunction(SKILLMOD_RELOADSPEED_RIFLE_MUL, function(pl, amount)
	pl.ReloadSpeedMultiplier357 = math.Clamp(amount + 1.0, 0.0, 100.0)
end)

GM:SetSkillModifierFunction(SKILLMOD_RELOADSPEED_XBOW_MUL, function(pl, amount)
	pl.ReloadSpeedMultiplierXBOWBOLT = math.Clamp(amount + 1.0, 0.0, 100.0)
end)

GM:SetSkillModifierFunction(SKILLMOD_RELOADSPEED_PULSE_MUL, function(pl, amount)
	pl.ReloadSpeedMultiplierPULSE = math.Clamp(amount + 1.0, 0.0, 100.0)
end)

GM:SetSkillModifierFunction(SKILLMOD_RELOADSPEED_EXP_MUL, function(pl, amount)
	pl.ReloadSpeedMultiplierIMPACTMINE = math.Clamp(amount + 1.0, 0.0, 100.0)
end)

GM:SetSkillModifierFunction(SKILLMOD_MELEE_ATTACKER_DMG_REFLECT, function(pl, amount)
	pl.BarbedArmor = math.Clamp(amount, 0.0, 1000.0)
end)

GM:SetSkillModifierFunction(SKILLMOD_PULSE_WEAPON_SLOW_MUL, function(pl, amount)
	pl.PulseWeaponSlowMul = math.Clamp(amount + 1.0, 0.0, 1000.0)
end)

GM:SetSkillModifierFunction(SKILLMOD_MELEE_DAMAGE_TAKEN_MUL, function(pl, amount)
	pl.MeleeDamageTakenMul = math.Clamp(amount + 1.0, 0.0, 1000.0)
end)

GM:SetSkillModifierFunction(SKILLMOD_POISON_DAMAGE_TAKEN_MUL, function(pl, amount)
	pl.PoisonDamageTakenMul = math.Clamp(amount + 1.0, 0.0, 1000.0)
end)

GM:SetSkillModifierFunction(SKILLMOD_BLEED_DAMAGE_TAKEN_MUL, function(pl, amount)
	pl.BleedDamageTakenMul = math.Clamp(amount + 1.0, 0.0, 1000.0)
end)

GM:SetSkillModifierFunction(SKILLMOD_MELEE_SWING_DELAY_MUL, function(pl, amount)
	pl.MeleeSwingDelayMul = math.Clamp(amount + 1.0, 0, 1000.0)
end)

GM:SetSkillModifierFunction(SKILLMOD_MELEE_DAMAGE_TO_BLOODARMOR_MUL, function(pl, amount)
	pl.MeleeDamageToBloodArmorMul = math.Clamp(amount, 0, 1000.0)
end)

GM:SetSkillModifierFunction(SKILLMOD_MELEE_MOVEMENTSPEED_ON_KILL, function(pl, amount)
	pl.MeleeMovementSpeedOnKill = math.Clamp(amount, -15, 1000.0)
end)

GM:SetSkillModifierFunction(SKILLMOD_MELEE_POWERATTACK_MUL, function(pl, amount)
	pl.MeleePowerAttackMul = math.Clamp(amount + 1.0, 0, 1000.0)
end)

GM:SetSkillModifierFunction(SKILLMOD_KNOCKDOWN_RECOVERY_MUL, function(pl, amount)
	pl.KnockdownRecoveryMul = math.Clamp(amount + 1.0, 0, 1000.0)
end)

GM:SetSkillModifierFunction(SKILLMOD_MELEE_RANGE_MUL, function(pl, amount)
	pl.MeleeRangeMul = math.Clamp(amount + 1.0, 0, 1000.0)
end)

GM:SetSkillModifierFunction(SKILLMOD_SLOW_EFF_TAKEN_MUL, function(pl, amount)
	pl.SlowEffTakenMul = math.Clamp(amount + 1.0, 0, 1000.0)
end)

GM:SetSkillModifierFunction(SKILLMOD_EXP_DAMAGE_TAKEN_MUL, function(pl, amount)
	pl.ExplosiveDamageTakenMul = math.Clamp(amount + 1.0, 0.0, 1000.0)
end)

GM:SetSkillModifierFunction(SKILLMOD_FIRE_DAMAGE_TAKEN_MUL, function(pl, amount)
	pl.FireDamageTakenMul = math.Clamp(amount + 1.0, 0.0, 1000.0)
end)

GM:SetSkillModifierFunction(SKILLMOD_PROP_CARRY_CAPACITY_MUL, function(pl, amount)
	pl.PropCarryCapacityMul = math.Clamp(amount + 1.0, 0.0, 1000.0)
end)

GM:SetSkillModifierFunction(SKILLMOD_PROP_THROW_STRENGTH_MUL, function(pl, amount)
	pl.ObjectThrowStrengthMul = math.Clamp(amount + 1.0, 0.0, 1000.0)
end)

GM:SetSkillModifierFunction(SKILLMOD_PHYSICS_DAMAGE_TAKEN_MUL, function(pl, amount)
	pl.PhysicsDamageTakenMul = math.Clamp(amount + 1.0, 0.0, 1000.0)
end)

GM:SetSkillModifierFunction(SKILLMOD_VISION_ALTER_DURATION_MUL, function(pl, amount)
	pl.VisionAlterDurationMul = math.Clamp(amount + 1.0, 0.0, 1000.0)
end)

GM:SetSkillModifierFunction(SKILLMOD_DIMVISION_EFF_MUL, function(pl, amount)
	pl.DimVisionEffMul = math.Clamp(amount + 1.0, 0.0, 1000.0)
end)

GM:SetSkillModifierFunction(SKILLMOD_PROP_CARRY_SLOW_MUL, function(pl, amount)
	pl.PropCarrySlowMul = math.Clamp(amount + 1.0, 0.0, 1000.0)
end)

GM:SetSkillModifierFunction(SKILLMOD_BLEED_SPEED_MUL, function(pl, amount)
	pl.BleedSpeedMul = math.Clamp(amount + 1.0, 0.1, 1000.0)
end)

GM:SetSkillModifierFunction(SKILLMOD_MELEE_LEG_DAMAGE_ADD, function(pl, amount)
	pl.MeleeLegDamageAdd = math.Clamp(amount, 0, 1000.0)
end)

GM:SetSkillModifierFunction(SKILLMOD_SIGIL_TELEPORT_MUL, function(pl, amount)
	pl.SigilTeleportTimeMul = math.Clamp(amount + 1.0, 0.1, 1000.0)
end)

GM:SetSkillModifierFunction(SKILLMOD_MELEE_ATTACKER_DMG_REFLECT_PERCENT, function(pl, amount)
	pl.BarbedArmorPercent = math.Clamp(amount, 0, 1000.0)
end)

GM:SetSkillModifierFunction(SKILLMOD_POISON_SPEED_MUL, function(pl, amount)
	pl.PoisonSpeedMul = math.Clamp(amount + 1.0, 0.1, 1000.0)
end)

GM:SetSkillModifierFunction(SKILLMOD_PROJECTILE_DAMAGE_TAKEN_MUL, GM:MkGenericMod("ProjDamageTakenMul"))
GM:SetSkillModifierFunction(SKILLMOD_EXP_DAMAGE_RADIUS, GM:MkGenericMod("ExpDamageRadiusMul"))
GM:SetSkillModifierFunction(SKILLMOD_WEAPON_WEIGHT_SLOW_MUL, GM:MkGenericMod("WeaponWeightSlowMul"))
GM:SetSkillModifierFunction(SKILLMOD_FRIGHT_DURATION_MUL, GM:MkGenericMod("FrightDurationMul"))
GM:SetSkillModifierFunction(SKILLMOD_IRONSIGHT_EFF_MUL, GM:MkGenericMod("IronsightEffMul"))
GM:SetSkillModifierFunction(SKILLMOD_MEDDART_EFFECTIVENESS_MUL, GM:MkGenericMod("MedDartEffMul"))

GM:SetSkillModifierFunction(SKILLMOD_BLOODARMOR_DMG_REDUCTION, function(pl, amount)
	pl.BloodArmorDamageReductionAdd = amount
end)

GM:SetSkillModifierFunction(SKILLMOD_BLOODARMOR_MUL, function(pl, amount)
	local mul = math.Clamp(amount + 1.0, 0.0, 1000.0)

	pl.MaxBloodArmorMul = mul

	local oldarmor = pl:GetBloodArmor()
	local oldcap = pl.MaxBloodArmor or 20
	local new = pl.MaxBloodArmor * mul

	pl.MaxBloodArmor = new

	if SERVER then
		if oldarmor > oldcap then
			local overcap = oldarmor - oldcap
			pl:SetBloodArmor(pl.MaxBloodArmor + overcap)
		else
			pl:SetBloodArmor(pl:GetBloodArmor() / oldcap * new)
		end
	end
end)

GM:SetSkillModifierFunction(SKILLMOD_BLOODARMOR_GAIN_MUL, GM:MkGenericMod("BloodarmorGainMul"))
GM:SetSkillModifierFunction(SKILLMOD_LOW_HEALTH_SLOW_MUL, GM:MkGenericMod("LowHealthSlowMul"))
GM:SetSkillModifierFunction(SKILLMOD_PROJ_SPEED, GM:MkGenericMod("ProjectileSpeedMul"))

GM:SetSkillModifierFunction(SKILLMOD_ENDWAVE_POINTS, function(pl,amount)
	pl.EndWavePointsExtra = math.Clamp(amount, 0.0, 1000.0)
end)

GM:SetSkillModifierFunction(SKILLMOD_ARSENAL_DISCOUNT, GM:MkGenericMod("ArsenalDiscount"))
GM:SetSkillModifierFunction(SKILLMOD_CLOUD_RADIUS, GM:MkGenericMod("CloudRadius"))
GM:SetSkillModifierFunction(SKILLMOD_CLOUD_TIME, GM:MkGenericMod("CloudTime"))
GM:SetSkillModifierFunction(SKILLMOD_EXP_DAMAGE_MUL, GM:MkGenericMod("ExplosiveDamageMul"))
GM:SetSkillModifierFunction(SKILLMOD_PROJECTILE_DAMAGE_MUL, GM:MkGenericMod("ProjectileDamageMul"))
GM:SetSkillModifierFunction(SKILLMOD_TURRET_RANGE_MUL, GM:MkGenericMod("TurretRangeMul"))
GM:SetSkillModifierFunction(SKILLMOD_AIM_SHAKE_MUL, GM:MkGenericMod("AimShakeMul"))

GM:AddSkillModifier(SKILL_SPEED1, SKILLMOD_SPEED, 0.75)
GM:AddSkillModifier(SKILL_SPEED1, SKILLMOD_HEALTH, -1)

GM:AddSkillModifier(SKILL_SPEED2, SKILLMOD_SPEED, 1.5)
GM:AddSkillModifier(SKILL_SPEED2, SKILLMOD_HEALTH, -2)

GM:AddSkillModifier(SKILL_SPEED3, SKILLMOD_SPEED, 3)
GM:AddSkillModifier(SKILL_SPEED3, SKILLMOD_HEALTH, -4)

GM:AddSkillModifier(SKILL_SPEED4, SKILLMOD_SPEED, 4.5)
GM:AddSkillModifier(SKILL_SPEED4, SKILLMOD_HEALTH, -6)

GM:AddSkillModifier(SKILL_SPEED5, SKILLMOD_SPEED, 5.25)
GM:AddSkillModifier(SKILL_SPEED5, SKILLMOD_HEALTH, -7)

GM:AddSkillModifier(SKILL_STOIC1, SKILLMOD_HEALTH, 1)
GM:AddSkillModifier(SKILL_STOIC1, SKILLMOD_SPEED, -0.75)

GM:AddSkillModifier(SKILL_STOIC2, SKILLMOD_HEALTH, 2)
GM:AddSkillModifier(SKILL_STOIC2, SKILLMOD_SPEED, -1.5)

GM:AddSkillModifier(SKILL_STOIC3, SKILLMOD_HEALTH, 4)
GM:AddSkillModifier(SKILL_STOIC3, SKILLMOD_SPEED, -3)

GM:AddSkillModifier(SKILL_STOIC4, SKILLMOD_HEALTH, 6)
GM:AddSkillModifier(SKILL_STOIC4, SKILLMOD_SPEED, -4.5)

GM:AddSkillModifier(SKILL_STOIC5, SKILLMOD_HEALTH, 7)
GM:AddSkillModifier(SKILL_STOIC5, SKILLMOD_SPEED, -5.25)

GM:AddSkillModifier(SKILL_VITALITY1, SKILLMOD_HEALTH, 1)
GM:AddSkillModifier(SKILL_VITALITY2, SKILLMOD_HEALTH, 1)
GM:AddSkillModifier(SKILL_VITALITY3, SKILLMOD_HEALTH, 1)

GM:AddSkillModifier(SKILL_MOTIONI, SKILLMOD_SPEED, 0.75)
GM:AddSkillModifier(SKILL_MOTIONII, SKILLMOD_SPEED, 0.75)
GM:AddSkillModifier(SKILL_MOTIONIII, SKILLMOD_SPEED, 0.75)

GM:AddSkillModifier(SKILL_FOCUS, SKILLMOD_AIMSPREAD_MUL, -0.03)
GM:AddSkillModifier(SKILL_FOCUS, SKILLMOD_RELOADSPEED_MUL, -0.03)

GM:AddSkillModifier(SKILL_FOCUSII, SKILLMOD_AIMSPREAD_MUL, -0.04)
GM:AddSkillModifier(SKILL_FOCUSII, SKILLMOD_RELOADSPEED_MUL, -0.04)

GM:AddSkillModifier(SKILL_FOCUSIII, SKILLMOD_AIMSPREAD_MUL, -0.05)
GM:AddSkillModifier(SKILL_FOCUSIII, SKILLMOD_RELOADSPEED_MUL, -0.05)

GM:AddSkillModifier(SKILL_ORPHICFOCUS, SKILLMOD_RELOADSPEED_MUL, -0.06)
GM:AddSkillModifier(SKILL_ORPHICFOCUS, SKILLMOD_AIMSPREAD_MUL, -0.02)

GM:AddSkillModifier(SKILL_DELIBRATION, SKILLMOD_AIMSPREAD_MUL, -0.01)

GM:AddSkillModifier(SKILL_WOOISM, SKILLMOD_IRONSIGHT_EFF_MUL, -0.25)

GM:AddSkillModifier(SKILL_GLUTTON, SKILLMOD_HEALTH, -5)

GM:AddSkillModifier(SKILL_TANKER, SKILLMOD_HEALTH, 20)
GM:AddSkillModifier(SKILL_TANKER, SKILLMOD_SPEED, -15)

GM:AddSkillModifier(SKILL_ULTRANIMBLE, SKILLMOD_HEALTH, -20)
GM:AddSkillModifier(SKILL_ULTRANIMBLE, SKILLMOD_SPEED, 15)

GM:AddSkillModifier(SKILL_EGOCENTRIC, SKILLMOD_SELF_DAMAGE_MUL, -0.35)
GM:AddSkillModifier(SKILL_EGOCENTRIC, SKILLMOD_HEALTH, -5)

GM:AddSkillModifier(SKILL_BLASTPROOF, SKILLMOD_SELF_DAMAGE_MUL, -0.45)
GM:AddSkillModifier(SKILL_BLASTPROOF, SKILLMOD_RELOADSPEED_MUL, -0.07)
GM:AddSkillModifier(SKILL_BLASTPROOF, SKILLMOD_DEPLOYSPEED_MUL, -0.12)

GM:AddSkillModifier(SKILL_SURGEON1, SKILLMOD_MEDKIT_COOLDOWN_MUL, -0.08)
GM:AddSkillModifier(SKILL_SURGEON2, SKILLMOD_MEDKIT_COOLDOWN_MUL, -0.09)
GM:AddSkillModifier(SKILL_SURGEON3, SKILLMOD_MEDKIT_COOLDOWN_MUL, -0.10)
GM:AddSkillModifier(SKILL_SURGEONIV, SKILLMOD_MEDKIT_COOLDOWN_MUL, -0.11)

GM:AddSkillModifier(SKILL_BIOLOGYI, SKILLMOD_MEDKIT_EFFECTIVENESS_MUL, 0.08)
GM:AddSkillModifier(SKILL_BIOLOGYII, SKILLMOD_MEDKIT_EFFECTIVENESS_MUL, 0.09)
GM:AddSkillModifier(SKILL_BIOLOGYIII, SKILLMOD_MEDKIT_EFFECTIVENESS_MUL, 0.1)
GM:AddSkillModifier(SKILL_BIOLOGYIV, SKILLMOD_MEDKIT_EFFECTIVENESS_MUL, 0.11)

GM:AddSkillModifier(SKILL_HANDY1, SKILLMOD_REPAIRRATE_MUL, 0.04)
GM:AddSkillModifier(SKILL_HANDY2, SKILLMOD_REPAIRRATE_MUL, 0.05)
GM:AddSkillModifier(SKILL_HANDY3, SKILLMOD_REPAIRRATE_MUL, 0.06)
GM:AddSkillModifier(SKILL_HANDY4, SKILLMOD_REPAIRRATE_MUL, 0.07)
GM:AddSkillModifier(SKILL_HANDY5, SKILLMOD_REPAIRRATE_MUL, 0.08)

GM:AddSkillModifier(SKILL_D_SLOW, SKILLMOD_WORTH, 15)
GM:AddSkillModifier(SKILL_D_SLOW, SKILLMOD_ENDWAVE_POINTS, 1)
GM:AddSkillModifier(SKILL_D_SLOW, SKILLMOD_SPEED, -33.75)

GM:AddSkillModifier(SKILL_GOURMET, SKILLMOD_FOODEATTIME_MUL, 2.0)
GM:AddSkillModifier(SKILL_GOURMET, SKILLMOD_FOODRECOVERY_MUL, 1.0)

GM:AddSkillModifier(SKILL_SUGARRUSH, SKILLMOD_FOODRECOVERY_MUL, -0.35)

GM:AddSkillModifier(SKILL_BATTLER1, SKILLMOD_MELEE_DAMAGE_MUL, 0.04)
GM:AddSkillModifier(SKILL_BATTLER2, SKILLMOD_MELEE_DAMAGE_MUL, 0.05)
GM:AddSkillModifier(SKILL_BATTLER3, SKILLMOD_MELEE_DAMAGE_MUL, 0.05)
GM:AddSkillModifier(SKILL_BATTLER4, SKILLMOD_MELEE_DAMAGE_MUL, 0.06)
GM:AddSkillModifier(SKILL_BATTLER5, SKILLMOD_MELEE_DAMAGE_MUL, 0.07)

GM:AddSkillModifier(SKILL_JOUSTER, SKILLMOD_MELEE_DAMAGE_MUL, 0.1)
GM:AddSkillModifier(SKILL_JOUSTER, SKILLMOD_MELEE_KNOCKBACK_MUL, -1.0)

GM:AddSkillModifier(SKILL_QUICKDRAW, SKILLMOD_DEPLOYSPEED_MUL, 0.65)
GM:AddSkillModifier(SKILL_QUICKDRAW, SKILLMOD_RELOADSPEED_MUL, -0.15)

GM:AddSkillModifier(SKILL_QUICKRELOAD, SKILLMOD_RELOADSPEED_MUL, 0.10)
GM:AddSkillModifier(SKILL_QUICKRELOAD, SKILLMOD_DEPLOYSPEED_MUL, -0.25)

GM:AddSkillModifier(SKILL_SLEIGHTOFHAND, SKILLMOD_RELOADSPEED_MUL, 0.10)
GM:AddSkillModifier(SKILL_SLEIGHTOFHAND, SKILLMOD_AIMSPREAD_MUL, 0.05)

GM:AddSkillModifier(SKILL_TRIGGER_DISCIPLINE1, SKILLMOD_RELOADSPEED_MUL, 0.02)
GM:AddSkillModifier(SKILL_TRIGGER_DISCIPLINE1, SKILLMOD_DEPLOYSPEED_MUL, 0.02)

GM:AddSkillModifier(SKILL_TRIGGER_DISCIPLINE2, SKILLMOD_RELOADSPEED_MUL, 0.03)
GM:AddSkillModifier(SKILL_TRIGGER_DISCIPLINE2, SKILLMOD_DEPLOYSPEED_MUL, 0.03)

GM:AddSkillModifier(SKILL_TRIGGER_DISCIPLINE3, SKILLMOD_RELOADSPEED_MUL, 0.04)
GM:AddSkillModifier(SKILL_TRIGGER_DISCIPLINE3, SKILLMOD_DEPLOYSPEED_MUL, 0.04)

GM:AddSkillModifier(SKILL_PHASER, SKILLMOD_BARRICADE_PHASE_SPEED_MUL, 0.15)
GM:AddSkillModifier(SKILL_PHASER, SKILLMOD_SIGIL_TELEPORT_MUL, 0.15)

GM:AddSkillModifier(SKILL_DRIFT, SKILLMOD_BARRICADE_PHASE_SPEED_MUL, 0.05)

GM:AddSkillModifier(SKILL_WARP, SKILLMOD_SIGIL_TELEPORT_MUL, -0.05)

GM:AddSkillModifier(SKILL_HAMMERDISCIPLINE, SKILLMOD_HAMMER_SWING_DELAY_MUL, -0.2)
GM:AddSkillModifier(SKILL_BARRICADEEXPERT, SKILLMOD_HAMMER_SWING_DELAY_MUL, 0.3)

GM:AddSkillModifier(SKILL_SAFEFALL, SKILLMOD_FALLDAMAGE_DAMAGE_MUL, -0.4)
GM:AddSkillModifier(SKILL_SAFEFALL, SKILLMOD_FALLDAMAGE_RECOVERY_MUL, -0.5)
GM:AddSkillModifier(SKILL_SAFEFALL, SKILLMOD_FALLDAMAGE_SLOWDOWN_MUL, 0.4)

GM:AddSkillModifier(SKILL_BACKPEDDLER, SKILLMOD_SPEED, -7)
GM:AddSkillFunction(SKILL_BACKPEDDLER, function(pl, active)
	pl.NoBWSpeedPenalty = active
end)

GM:AddSkillModifier(SKILL_D_CLUMSY, SKILLMOD_WORTH, 20)
GM:AddSkillModifier(SKILL_D_CLUMSY, SKILLMOD_POINTS, 5)
GM:AddSkillFunction(SKILL_D_CLUMSY, function(pl, active)
	pl.IsClumsy = active
end)

GM:AddSkillModifier(SKILL_D_NOODLEARMS, SKILLMOD_WORTH, 5)
GM:AddSkillModifier(SKILL_D_NOODLEARMS, SKILLMOD_SCRAP_START, 1)
GM:AddSkillFunction(SKILL_D_NOODLEARMS, function(pl, active)
	pl.NoObjectPickup = active
end)

GM:AddSkillModifier(SKILL_D_PALSY, SKILLMOD_WORTH, 10)
GM:AddSkillModifier(SKILL_D_PALSY, SKILLMOD_RESUPPLY_DELAY_MUL, -0.03)
GM:AddSkillFunction(SKILL_D_PALSY, function(pl, active)
	pl.HasPalsy = active
end)

GM:AddSkillModifier(SKILL_D_HEMOPHILIA, SKILLMOD_WORTH, 10)
GM:AddSkillModifier(SKILL_D_HEMOPHILIA, SKILLMOD_SCRAP_START, 3)
GM:AddSkillFunction(SKILL_D_HEMOPHILIA, function(pl, active)
	pl.HasHemophilia = active
end)

GM:AddSkillModifier(SKILL_D_LATEBUYER, SKILLMOD_WORTH, 20)
GM:AddSkillModifier(SKILL_D_LATEBUYER, SKILLMOD_ARSENAL_DISCOUNT, -0.02)

GM:AddSkillFunction(SKILL_TAUT, function(pl, active)
	pl.BuffTaut = active
end)

GM:AddSkillModifier(SKILL_BLOODARMOR, SKILLMOD_HEALTH, -13)

GM:AddSkillModifier(SKILL_HAEMOSTASIS, SKILLMOD_BLOODARMOR_DMG_REDUCTION, -0.25)

GM:AddSkillModifier(SKILL_REGENERATOR, SKILLMOD_HEALTH, -6)

GM:AddSkillModifier(SKILL_D_WEAKNESS, SKILLMOD_WORTH, 15)
GM:AddSkillModifier(SKILL_D_WEAKNESS, SKILLMOD_ENDWAVE_POINTS, 1)
GM:AddSkillModifier(SKILL_D_WEAKNESS, SKILLMOD_HEALTH, -45)

GM:AddSkillModifier(SKILL_D_WIDELOAD, SKILLMOD_WORTH, 20)
GM:AddSkillModifier(SKILL_D_WIDELOAD, SKILLMOD_RESUPPLY_DELAY_MUL, -0.05)
GM:AddSkillFunction(SKILL_D_WIDELOAD, function(pl, active)
	pl.NoGhosting = active
end)

GM:AddSkillFunction(SKILL_WOOISM, function(pl, active)
	pl.Wooism = active
end)

GM:AddSkillFunction(SKILL_ORPHICFOCUS, function(pl, active)
	pl.Orphic = active
end)

GM:AddSkillModifier(SKILL_WORTHINESS1, SKILLMOD_WORTH, 5)
GM:AddSkillModifier(SKILL_WORTHINESS2, SKILLMOD_WORTH, 5)
GM:AddSkillModifier(SKILL_WORTHINESS3, SKILLMOD_WORTH, 5)
GM:AddSkillModifier(SKILL_WORTHINESS4, SKILLMOD_WORTH, 5)

GM:AddSkillModifier(SKILL_KNUCKLEMASTER, SKILLMOD_UNARMED_SWING_DELAY_MUL, 0.35)
GM:AddSkillModifier(SKILL_KNUCKLEMASTER, SKILLMOD_UNARMED_DAMAGE_MUL, 0.75)

GM:AddSkillModifier(SKILL_CRITICALKNUCKLE, SKILLMOD_UNARMED_DAMAGE_MUL, -0.25)
GM:AddSkillModifier(SKILL_CRITICALKNUCKLE, SKILLMOD_UNARMED_SWING_DELAY_MUL, 0.25)

GM:AddSkillModifier(SKILL_SMARTTARGETING, SKILLMOD_MEDGUN_FIRE_DELAY_MUL, 0.75)
GM:AddSkillModifier(SKILL_SMARTTARGETING, SKILLMOD_MEDDART_EFFECTIVENESS_MUL, -0.3)

GM:AddSkillModifier(SKILL_RECLAIMSOL, SKILLMOD_MEDGUN_FIRE_DELAY_MUL, 1.5)
GM:AddSkillModifier(SKILL_RECLAIMSOL, SKILLMOD_MEDGUN_RELOAD_SPEED_MUL, -0.4)

GM:AddSkillModifier(SKILL_LANKY, SKILLMOD_MELEE_DAMAGE_MUL, -0.15)
GM:AddSkillModifier(SKILL_LANKY, SKILLMOD_MELEE_RANGE_MUL, 0.1)

GM:AddSkillModifier(SKILL_LANKYII, SKILLMOD_MELEE_DAMAGE_MUL, -0.15)
GM:AddSkillModifier(SKILL_LANKYII, SKILLMOD_MELEE_RANGE_MUL, 0.1)

GM:AddSkillModifier(SKILL_D_FRAIL, SKILLMOD_WORTH, 20)
GM:AddSkillModifier(SKILL_D_FRAIL, SKILLMOD_POINTS, 5)
GM:AddSkillFunction(SKILL_D_FRAIL, function(pl, active)
	pl:SetDTBool(DT_PLAYER_BOOL_FRAIL, active)
end)

GM:AddSkillModifier(SKILL_MASTERCHEF, SKILLMOD_MELEE_DAMAGE_MUL, -0.10)

GM:AddSkillModifier(SKILL_LIGHTWEIGHT, SKILLMOD_MELEE_DAMAGE_MUL, -0.2)

GM:AddSkillModifier(SKILL_AGILEI, SKILLMOD_JUMPPOWER_MUL, 0.04)
GM:AddSkillModifier(SKILL_AGILEI, SKILLMOD_SPEED, -2)

GM:AddSkillModifier(SKILL_AGILEII, SKILLMOD_JUMPPOWER_MUL, 0.05)
GM:AddSkillModifier(SKILL_AGILEII, SKILLMOD_SPEED, -3)

GM:AddSkillModifier(SKILL_AGILEIII, SKILLMOD_JUMPPOWER_MUL, 0.06)
GM:AddSkillModifier(SKILL_AGILEIII, SKILLMOD_SPEED, -4)

GM:AddSkillModifier(SKILL_SOFTDET, SKILLMOD_EXP_DAMAGE_RADIUS, -0.10)
GM:AddSkillModifier(SKILL_SOFTDET, SKILLMOD_EXP_DAMAGE_TAKEN_MUL, -0.4)

GM:AddSkillModifier(SKILL_IRONBLOOD, SKILLMOD_BLOODARMOR_DMG_REDUCTION, 0.25)
GM:AddSkillModifier(SKILL_IRONBLOOD, SKILLMOD_BLOODARMOR_MUL, -0.5)

GM:AddSkillModifier(SKILL_BLOODLETTER, SKILLMOD_BLOODARMOR_GAIN_MUL, 1)

GM:AddSkillModifier(SKILL_SURESTEP, SKILLMOD_SPEED, -4)
GM:AddSkillModifier(SKILL_SURESTEP, SKILLMOD_SLOW_EFF_TAKEN_MUL, -0.35)

GM:AddSkillModifier(SKILL_INTREPID, SKILLMOD_SPEED, -4)
GM:AddSkillModifier(SKILL_INTREPID, SKILLMOD_LOW_HEALTH_SLOW_MUL, -0.35)

GM:AddSkillModifier(SKILL_UNBOUND, SKILLMOD_SPEED, -4)

GM:AddSkillModifier(SKILL_CHEAPKNUCKLE, SKILLMOD_MELEE_RANGE_MUL, -0.1)

GM:AddSkillModifier(SKILL_HEAVYSTRIKES, SKILLMOD_MELEE_KNOCKBACK_MUL, 1)

GM:AddSkillModifier(SKILL_CANNONBALL, SKILLMOD_PROJ_SPEED, -0.25)
GM:AddSkillModifier(SKILL_CANNONBALL, SKILLMOD_PROJECTILE_DAMAGE_MUL, 0.03)

GM:AddSkillModifier(SKILL_CONEFFECT, SKILLMOD_EXP_DAMAGE_RADIUS, -0.2)
GM:AddSkillModifier(SKILL_CONEFFECT, SKILLMOD_EXP_DAMAGE_MUL, 0.05)

GM:AddSkillModifier(SKILL_CARDIOTONIC, SKILLMOD_SPEED, -12)
GM:AddSkillModifier(SKILL_CARDIOTONIC, SKILLMOD_BLOODARMOR_DMG_REDUCTION, -0.2)

GM:AddSkillFunction(SKILL_SCOURER, function(pl, active)
	pl.Scourer = active
end)

GM:AddSkillModifier(SKILL_DISPERSION, SKILLMOD_CLOUD_RADIUS, 0.15)
GM:AddSkillModifier(SKILL_DISPERSION, SKILLMOD_CLOUD_TIME, -0.1)

GM:AddSkillModifier(SKILL_BRASH, SKILLMOD_MELEE_SWING_DELAY_MUL, -0.16)
GM:AddSkillModifier(SKILL_BRASH, SKILLMOD_MELEE_MOVEMENTSPEED_ON_KILL, -15)

GM:AddSkillModifier(SKILL_CIRCULATION, SKILLMOD_BLOODARMOR, 1)

GM:AddSkillModifier(SKILL_SANGUINE, SKILLMOD_BLOODARMOR, 5)
GM:AddSkillModifier(SKILL_SANGUINE, SKILLMOD_HEALTH, 5)
GM:AddSkillModifier(SKILL_SANGUINE, SKILLMOD_WEAPON_WEIGHT_SLOW_MUL, -0.08)--                  额外修改

GM:AddSkillModifier(SKILL_ANTIGEN, SKILLMOD_BLOODARMOR_DMG_REDUCTION, 0.05)
GM:AddSkillModifier(SKILL_ANTIGEN, SKILLMOD_HEALTH, -3)

GM:AddSkillModifier(SKILL_INSTRUMENTS, SKILLMOD_TURRET_RANGE_MUL, 0.05)

GM:AddSkillModifier(SKILL_LEVELHEADED, SKILLMOD_AIM_SHAKE_MUL, -0.05)

GM:AddSkillModifier(SKILL_ROBUST, SKILLMOD_WEAPON_WEIGHT_SLOW_MUL, -0.06)

GM:AddSkillModifier(SKILL_TAUT, SKILLMOD_PROP_CARRY_SLOW_MUL, 0.4)

GM:AddSkillModifier(SKILL_TURRETOVERLOAD, SKILLMOD_TURRET_RANGE_MUL, -0.3)

GM:AddSkillModifier(SKILL_STOWAGE, SKILLMOD_RESUPPLY_DELAY_MUL, 0.15)
GM:AddSkillFunction(SKILL_STOWAGE, function(pl, active)
	pl.Stowage = active
end)

GM:AddSkillFunction(SKILL_TRUEWOOISM, function(pl, active)
	pl.TrueWooism = active
end)
