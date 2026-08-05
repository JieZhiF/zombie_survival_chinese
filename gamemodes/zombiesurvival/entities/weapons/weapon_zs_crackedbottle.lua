-- ============================================================================
-- weapon_zs_crackedbottle.lua - 破裂玻璃瓶近战武器
-- 负责：一次性近战武器，命中实体后自动销毁武器（玻璃瓶碎裂）
-- ============================================================================
AddCSLuaFile()

-- 武器显示名称与描述（本地化键）
SWEP.PrintName = ""..translate.Get("weapon_zs_crackedbottle")
SWEP.Description = ""..translate.Get("weapon_zs_crackedbottle_description")

if CLIENT then
	-- 第一人称视角设置
	SWEP.ViewModelFOV = 55
	-- 第一人称视角模型元素（破裂玻璃瓶碎片挂在右手骨上）
	SWEP.VElements = {
		["base"] = { type = "Model", model = "models/props_junk/glassbottle01a_chunk01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(3.635, 1.557, -4.676), angle = Angle(180, -111.04, 155.455), size = Vector(1.144, 1.144, 1.144), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}
	-- 世界模型元素（第三人称显示的破裂玻璃瓶）
	SWEP.WElements = {
		["base"] = { type = "Model", model = "models/props_junk/glassbottle01a_chunk01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(5.714, 2.596, -2.597), angle = Angle(38.57, -68.961, 22.208), size = Vector(1.274, 1.274, 1.274), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}
end

-- 继承近战武器基类
SWEP.Base = "weapon_zs_basemelee"

-- 持握姿势：匕首
SWEP.HoldType = "knife"

-- 伤害类型：切割
SWEP.DamageType = DMG_SLASH

-- 第一人称视角设置
SWEP.ViewModelFlip = false
-- 第一人称/世界模型
SWEP.ViewModel = "models/weapons/cstrike/c_knife_t.mdl"
SWEP.WorldModel = "models/props_junk/glassbottle01a_chunk01a.mdl"
-- 隐藏原始模型，使用 SCK 元素自定义外观
SWEP.ShowViewModel = false
SWEP.ShowWorldModel = false
-- 使用 C 模型手部
SWEP.UseHands = true

-- 自动切换离开此武器（一次性武器）
SWEP.AutoSwitchFrom	= true

-- 近战伤害、攻击范围、攻击判定大小
SWEP.MeleeDamage = 20
SWEP.MeleeRange = 45
SWEP.MeleeSize = 0.875

-- 持有时的移动速度（最快）
SWEP.WalkSpeed = SPEED_FASTEST

-- 攻击延迟
SWEP.Primary.Delay = 0.8

-- 命中贴花类型（砍痕）
SWEP.HitDecal = "Manhackcut"

-- 命中与挥空手势动画
SWEP.HitGesture = ACT_HL2MP_GESTURE_RANGE_ATTACK_KNIFE
SWEP.MissGesture = SWEP.HitGesture

-- 命中与挥空武器动画
SWEP.HitAnim = ACT_VM_MISSCENTER
SWEP.MissAnim = ACT_VM_PRIMARYATTACK

-- 不播放命中肉体音效（使用自定义音效）
SWEP.NoHitSoundFlesh = true

-- 不是玻璃武器（避免被玻璃武器系统处理）
SWEP.NoGlassWeapons = true

-- ==== PlaySwingSound - 播放挥砍音效 ====
function SWEP:PlaySwingSound()
	-- 随机播放匕首挥砍音效
	self:EmitSound("weapons/knife/knife_slash"..math.random(2)..".wav")
end

-- ==== PlayHitSound - 播放命中墙壁音效 ====
function SWEP:PlayHitSound()
	-- 播放玻璃瓶碎裂音效
	self:EmitSound("physics/glass/glass_bottle_break2.wav")
end

-- ==== PlayHitFleshSound - 播放命中肉体音效 ====
function SWEP:PlayHitFleshSound()
	-- 播放玻璃瓶碎裂音效
	self:EmitSound("physics/glass/glass_bottle_break2.wav")
end

-- ==== OnMeleeHit - 近战命中回调（命中后销毁武器） ====
function SWEP:OnMeleeHit(hitent, hitflesh)
	-- 命中有效实体时在下一帧销毁武器（模拟玻璃瓶碎裂后丢弃）
	if hitent:IsValid() and SERVER then
		timer.Simple(0, function() self:GetOwner():StripWeapon(self:GetClass()) end)
	end
end
