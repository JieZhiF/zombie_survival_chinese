-- ============================================================================
-- weapon_zs_glassbottle.lua - 玻璃瓶（一次性近战武器，命中后碎裂为碎瓶）
-- 负责：SCK 拼装外观（玻璃瓶模型）、近战数值与挥砍音效、命中后移除自身
--       并切换为 weapon_zs_crackedbottle（碎瓶）
-- ============================================================================

-- 共享文件：客户端也需要下载本文件
AddCSLuaFile()

-- 武器显示名与描述（走翻译表）
SWEP.PrintName = ""..translate.Get("weapon_zs_glassbottle")
SWEP.Description = ""..translate.Get("weapon_zs_glassbottle_description")

-- 客户端专属属性（SCK 视图/世界模型元素）
if CLIENT then
	-- 视图模型视场角
	SWEP.ViewModelFOV = 70
	-- SCK 视图模型元素：手持的玻璃瓶模型
	SWEP.VElements = {
		["base"] = { type = "Model", model = "models/props_junk/glassbottle01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(3.799, 0.899, -7), angle = Angle(8.182, -12.858, 8.182), size = Vector(1.144, 1.144, 1.144), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}
	-- SCK 世界模型元素：第三人称下的玻璃瓶外观
	SWEP.WElements = {
		["base"] = { type = "Model", model = "models/props_junk/glassbottle01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(3.4, 1.557, -5.715), angle = Angle(0, 0, 0), size = Vector(1.274, 1.274, 1.274), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}
end

-- 继承近战武器基类
SWEP.Base = "weapon_zs_basemelee"

-- 持枪姿势（单手握持近战姿势）
SWEP.HoldType = "melee"

-- 伤害类型：钝器打击
SWEP.DamageType = DMG_CLUB

-- 不翻转视图模型；使用警棍模型作为持握骨架
SWEP.ViewModelFlip = false
SWEP.ViewModel = "models/weapons/c_stunstick.mdl"
SWEP.WorldModel = "models/props_junk/glassbottle01a.mdl"
-- 隐藏原始视图/世界模型（外观由 SCK 元素拼装）
SWEP.ShowViewModel = false
SWEP.ShowWorldModel = false
SWEP.UseHands = true

-- 近战数值：40 伤害、48 距离、0.875 判定尺寸
SWEP.MeleeDamage = 40
SWEP.MeleeRange = 48
SWEP.MeleeSize = 0.875

-- 持枪移动速度（最快）
SWEP.WalkSpeed = SPEED_FASTEST

-- 主攻击间隔 0.85 秒；无挥击前摇（瞬发），持手雷姿势挥动
SWEP.Primary.Delay = 0.85
SWEP.SwingTime = 0
SWEP.SwingHoldType = "grenade"

-- 命中肉体时不播放通用肉体命中音（改用自定义音效）
SWEP.NoHitSoundFlesh = true

-- 不是玻璃武器（不触发玻璃碎裂通用规则，碎裂逻辑由本武器自行处理）
SWEP.NoGlassWeapons = true

-- ==== PlaySwingSound - 挥击音效（刀锋挥击声） ====
function SWEP:PlaySwingSound()
	self:EmitSound("weapons/knife/knife_slash"..math.random(2)..".wav")
end

-- ==== PlayHitSound - 命中音效（玻璃瓶碎裂声） ====
function SWEP:PlayHitSound()
	self:EmitSound("physics/glass/glass_bottle_break2.wav")
end

-- ==== PlayHitFleshSound - 命中肉体音效（玻璃瓶碎裂声） ====
function SWEP:PlayHitFleshSound()
	self:EmitSound("physics/glass/glass_bottle_break2.wav")
end

-- ==== OnMeleeHit - 命中任意实体后：卸下玻璃瓶并替换为碎瓶武器 ====
function SWEP:OnMeleeHit(hitent, hitflesh, tr)
	if hitent:IsValid() then
		-- 服务端负责武器切换
		if SERVER then
			local owner = self:GetOwner()
			-- 下一帧移除玻璃瓶（等待本次伤害结算完成）
			timer.Simple(0, function()
				owner:StripWeapon(self:GetClass())
			end)

			-- 给予碎瓶并自动装备
			owner:Give("weapon_zs_crackedbottle")
			owner:SelectWeapon("weapon_zs_crackedbottle")
		end
	end
end
