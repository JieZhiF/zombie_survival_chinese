-- ============================================================================
-- weapon_zs_eminence/shared.lua - 能量弩「至圣」（Eminence）共享端
-- 负责：定义能量弩的基础武器属性与开火/换弹音效
-- ============================================================================

-- 武器显示名称与描述（由语言文件提供）
SWEP.PrintName = "'"..translate.Get("weapon_zs_eminence")
SWEP.Description = ""..translate.Get("weapon_zs_eminence_description")

-- 继承投射物武器基础模板（weapon_zs_baseproj）
SWEP.Base = "weapon_zs_baseproj"

-- 持枪姿势（冲锋枪姿势）
SWEP.HoldType = "smg"

-- 第一人称与第三人称模型（十字弩模型），使用玩家的手部模型
SWEP.ViewModel = "models/weapons/c_crossbow.mdl"
SWEP.WorldModel = "models/weapons/w_crossbow.mdl"
SWEP.UseHands = true

-- 不使用 CS 风格枪口闪光
SWEP.CSMuzzleFlashes = false

-- 弹匣 1 发、全自动连射（实际受延迟控制）、消耗感应地雷弹药
SWEP.Primary.ClipSize = 1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "impactmine"
SWEP.Primary.Delay = 0.7
SWEP.Primary.DefaultClip = 4
SWEP.Primary.Damage = 26
SWEP.Primary.NumShots = 1

-- 扩散范围（最大/最小准星扩散）
SWEP.ConeMax = 3
SWEP.ConeMin = 2

-- 持枪移动速度（慢速）
SWEP.WalkSpeed = SPEED_SLOW

-- 武器等级 5
SWEP.Tier = 5

-- 换弹速度倍率 0.75（更快）
SWEP.ReloadSpeed = 0.75

-- 附加武器改造：换弹速度 +7.5%
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_RELOAD_SPEED, 0.075)

-- ==== EmitFireSound - 播放开火音效（发射声 + 投放警示声） ====
function SWEP:EmitFireSound()
	self:EmitSound("weapons/grenade_launcher1.wav", 75, math.random(67, 74), 0.4)
	self:EmitSound("npc/attack_helicopter/aheli_mine_drop1.wav", 75, 65, 0.8, CHAN_AUTO + 20)
end

-- ==== EmitReloadSound - 播放换弹开始音效（预测时播放） ====
function SWEP:EmitReloadSound()
	if IsFirstTimePredicted() then
		self:EmitSound("weapons/ar2/ar2_reload_rotate.wav", 70, 55)
		self:EmitSound("items/battery_pickup.wav", 70, 77, 0.85, CHAN_AUTO)
	end
end

-- ==== EmitReloadFinishSound - 播放换弹完成音效（预测时播放） ====
function SWEP:EmitReloadFinishSound()
	if IsFirstTimePredicted() then
		self:EmitSound("weapons/ar2/ar2_reload_push.wav", pos, 70, math.Rand(130, 140))
	end
end
