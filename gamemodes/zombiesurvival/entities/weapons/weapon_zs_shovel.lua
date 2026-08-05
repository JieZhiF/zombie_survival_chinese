-- ============================================================================
-- weapon_zs_shovel.lua - 铁锹近战武器（劳工加成）
-- 负责：铁锹近战数值（伤害随劳工时间成长）、挥击/格挡参数，以及对倒地
--       待复活玩家的处决击杀
-- ============================================================================
AddCSLuaFile()

-- 显示名称与描述
SWEP.PrintName = ""..translate.Get("weapon_zs_shovel")
SWEP.Description = ""..translate.Get("weapon_zs_shovel_description")

if CLIENT then
	SWEP.ViewModelFOV = 60

	-- 隐藏原生模型，全部由拼装件构成
	SWEP.ShowViewModel = false
	SWEP.ShowWorldModel = false

	-- 第一人称铁锹模型
	SWEP.VElements = {
		["base"] = { type = "Model", model = "models/props_junk/shovel01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(1.363, 1.363, -7.728), angle = Angle(0, 0, 0), size = Vector(0.899, 0.899, 0.899), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}
	-- 第三人称铁锹模型
	SWEP.WElements = {
		["base"] = { type = "Model", model = "models/props_junk/shovel01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(5, 1.363, -15), angle = Angle(-3, 180, 0), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}
end

SWEP.Base = "weapon_zs_basemelee"

-- 持枪姿势
SWEP.HoldType = "melee2"

-- 伤害类型：钝器
SWEP.DamageType = DMG_CLUB

-- 模型与手臂
SWEP.ViewModel = "models/weapons/c_crowbar.mdl"
SWEP.WorldModel = "models/props_junk/shovel01a.mdl"
SWEP.UseHands = true

-- 近战数值（伤害随劳工时间成长）
SWEP.MeleeDamage = 50 * GAMEMODE.LabourTime
SWEP.MeleeRange = 68
SWEP.MeleeSize = 1.5
SWEP.MeleeKnockBack = 230

-- 攻击间隔
SWEP.Primary.Delay = 1.2

-- 武器等级
SWEP.Tier = 2

-- 移动速度
SWEP.WalkSpeed = SPEED_SLOWER

-- 挥击动画参数
SWEP.SwingRotation = Angle(0, -90, -60)
SWEP.SwingOffset = Vector(0, 30, -40)
SWEP.SwingTime = 0.65
SWEP.SwingHoldType = "melee"

-- 可强化；拆除收益减半
SWEP.AllowQualityWeapons = true
SWEP.DismantleDiv = 2

-- 格挡动画位置
SWEP.BlockPos = Vector(-12.19, -8.29, 2.319)
SWEP.BlockAng = Angle(10.732, -4.687, -46.086)

-- 格挡减伤倍率
SWEP.DefendingDamageBlockedDefault = 2.1
SWEP.DefendingDamageBlocked = 2.1

-- 格挡音效（随机音高/音效文件）
SWEP.BlockSoundPitch  = math.random(120,150)
local BlockSoundPitch  = "physics/metal/metal_sheet_impact_hard"..math.random(6,8)..".wav"

-- 强化：攻击间隔缩短 + 近战判定提前
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_FIRE_DELAY, -0.09, 1)
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_MELEE_IMPACT_DELAY, -0.06, 1)

-- ==== PlaySwingSound - 挥击音效 ====
function SWEP:PlaySwingSound()
	self:EmitSound("weapons/iceaxe/iceaxe_swing1.wav", 75, math.random(65, 70))
end

-- ==== PlayHitSound - 命中非肉体音效（金属声） ====
function SWEP:PlayHitSound()
	self:EmitSound("weapons/melee/shovel/shovel_hit-0"..math.random(4)..".ogg")
end

-- ==== PlayHitFleshSound - 命中肉体音效 ====
function SWEP:PlayHitFleshSound()
	self:EmitSound("physics/body/body_medium_break"..math.random(2, 4)..".wav")
end

-- ==== PostOnMeleeHit - 命中后的处决逻辑 ====
-- 命中正在被复活（倒地）的玩家时，直接造成等于其当前血量的必杀伤害
function SWEP:PostOnMeleeHit(hitent, hitflesh, tr)
	if hitent:IsValid() and hitent:IsPlayer() and hitent.Revive and hitent.Revive:IsValid() and gamemode.Call("PlayerShouldTakeDamage", hitent, self:GetOwner()) then
		hitent:TakeSpecialDamage(hitent:Health(), DMG_DIRECT, self:GetOwner(), self, tr.HitPos)
	end
end
