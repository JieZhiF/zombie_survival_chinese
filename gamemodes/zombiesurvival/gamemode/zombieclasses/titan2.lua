CLASS.Base = "titan"

CLASS.Name = "Titan2"
CLASS.TranslationName = "class_titan_b" --语言系统中的名字
CLASS.Description = "description_titan" --语言系统中的角色设定和描述
CLASS.Help = "controls_titan" --语言系统中的角色教程

CLASS.Health = 1500
CLASS.Speed = 145
CLASS.Revives = false
CLASS.Hidden = true

CLASS.SWEP = "weapon_zs_titan_b"

CLASS.Points = CLASS.Health/GM.HumanoidZombiePointRatio

CLASS.Wave = 5 / 6

CLASS.Icon = "zombiesurvival/killicons/zombie"
CLASS.IconColor = Color(0.271, 0.271, 0.271)

CLASS.NoFallDamage = true --没有摔落伤害
CLASS.Unlocked = false --是否解锁
CLASS.CanFeignDeath = false --是否可以装死
CLASS.CanTaunt = true --禁止嘲讽

CLASS.VoicePitch = 1.0

CLASS.ModelScale = 1.45

CLASS.Mass = 500
CLASS.ViewOffset = DEFAULT_VIEW_OFFSET * CLASS.ModelScale
CLASS.ViewOffsetDucked = DEFAULT_VIEW_OFFSET_DUCKED * CLASS.ModelScale
CLASS.StepSize = 25
CLASS.Hull = {Vector(-16, -16, 0), Vector(16, 16, 72)}
CLASS.HullDuck = {Vector(-16, -16, 0), Vector(16, 16, 36)}

local math_random = math.random
local math_min = math.min
local math_max = math.max
local math_ceil = math.ceil
local CurTime = CurTime

local DIR_BACK = DIR_BACK
local ACT_HL2MP_ZOMBIE_SLUMP_RISE = ACT_HL2MP_ZOMBIE_SLUMP_RISE
local ACT_HL2MP_SWIM_PISTOL = ACT_HL2MP_SWIM_PISTOL
local ACT_HL2MP_IDLE_CROUCH_ZOMBIE = ACT_HL2MP_IDLE_CROUCH_ZOMBIE
local ACT_HL2MP_WALK_CROUCH_ZOMBIE_01 = ACT_HL2MP_WALK_CROUCH_ZOMBIE_01
local ACT_HL2MP_RUN_ZOMBIE = ACT_HL2MP_RUN_ZOMBIE

local matSkin = Material("models/Zombie_Classic/Zombie_Classic_sheet.vtf")

function CLASS:PrePlayerDraw(pl)
	render.ModelMaterialOverride(matSkin)
	render.SetColorModulation(0.271, 0.271, 0.271)
end

function CLASS:PostPlayerDraw(pl)
	render.ModelMaterialOverride()
	render.SetColorModulation(1, 1, 1)
end
