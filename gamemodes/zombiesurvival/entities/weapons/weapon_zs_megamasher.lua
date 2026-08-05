-- ============================================================================
-- weapon_zs_megamasher.lua - 巨型粉碎锤近战武器
-- 负责：以零件拼装的巨锤进行重击：超高伤害、超长挥击时间、
--       命中时产生爆炸特效，并带巨大击退
-- ============================================================================
AddCSLuaFile() -- 将该文件同时发送到客户端

-- 武器显示名称（本地化）
SWEP.PrintName = ""..translate.Get("weapon_zs_megamasher")

if CLIENT then -- 客户端专属设置
	SWEP.ViewModelFOV = 75 -- 第一人称视野大小

	-- 隐藏原始模型，改用自定义元素拼装巨锤
	SWEP.ShowViewModel = false
	SWEP.ShowWorldModel = false
	-- 第一人称手持元素：工字梁+浮标+红桶+大锤零件组成巨锤
	SWEP.VElements = {
		["base2"] = { type = "Model", model = "models/props_wasteland/buoy01.mdl", bone = "ValveBiped.Bip01", rel = "base", pos = Vector(12, 0, 0), angle = Angle(0, 90, 270), size = Vector(0.2, 0.2, 0.2), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["base"] = { type = "Model", model = "models/props_junk/iBeam01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(12.706, 2.761, -22), angle = Angle(13, -12.5, 0), size = Vector(0.15, 0.5, 0.5), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["base3"] = { type = "Model", model = "models/props_borealis/bluebarrel001.mdl", bone = "ValveBiped.Bip01", rel = "base", pos = Vector(-5, 0, 0), angle = Angle(0, 270, 90), size = Vector(0.4, 0.4, 0.4), color = Color(255, 0, 0, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["base4"] = { type = "Model", model = "models/weapons/w_sledgehammer.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(3, 1.299, 11), angle = Angle(0, 0, 180), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}

	-- 第三人称世界元素：同样的巨锤拼装，绑在玩家右手骨骼上
	SWEP.WElements = {
		["base2"] = { type = "Model", model = "models/props_wasteland/buoy01.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(12, 0, 0), angle = Angle(0, 90, 270), size = Vector(0.2, 0.2, 0.2), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["base"] = { type = "Model", model = "models/props_junk/iBeam01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(10, 1, -35), angle = Angle(0, 0, 0), size = Vector(0.15, 0.5, 0.5), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["base3"] = { type = "Model", model = "models/props_borealis/bluebarrel001.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(-5, 0, 0), angle = Angle(0, 90, 270), size = Vector(0.4, 0.4, 0.4), color = Color(255, 0, 0, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["base4"] = { type = "Model", model = "models/weapons/w_sledgehammer.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(3, 1.299, 0), angle = Angle(0, 0, 180), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}
end

-- 继承近战武器母本
SWEP.Base = "weapon_zs_basemelee"

-- 手持姿势：大锤双手持姿势
SWEP.HoldType = "melee2"

-- 伤害类型：钝器敲击伤害
SWEP.DamageType = DMG_CLUB

-- 第一人称模型（大锤骨架）
SWEP.ViewModel = "models/weapons/v_sledgehammer/c_sledgehammer.mdl"
-- 世界模型（撬棍外观占位）
SWEP.WorldModel = "models/weapons/w_crowbar.mdl"
SWEP.UseHands = true -- 使用玩家手臂模型握持

SWEP.MeleeDamage = 190 -- 近战伤害（一击重锤）
SWEP.MeleeRange = 75 -- 近战攻击距离
SWEP.MeleeSize = 4 -- 命中判定范围（巨大锤面）
SWEP.MeleeKnockBack = 420 -- 命中击退力度

SWEP.Primary.Delay = 2.25 -- 两次挥击之间的间隔（动作慢）

SWEP.WalkSpeed = SPEED_SLOWEST * 0.7 -- 手持时移动速度（极慢）

SWEP.SwingRotation = Angle(60, 0, -80) -- 挥击时的模型旋转
SWEP.SwingOffset = Vector(0, -30, 0) -- 挥击时的模型偏移
SWEP.SwingTime = 1.33 -- 挥击动画时长
SWEP.SwingHoldType = "melee" -- 挥击期间的手持姿势
SWEP.BlockPos = Vector(-13.867, -8.54, 7.62) -- 格挡时模型的位置偏移
SWEP.BlockAng = Angle(5.133, 3.448, -57.561) -- 格挡时模型的旋转
SWEP.Tier = 3 -- 武器等级（3 级武器）

SWEP.AllowQualityWeapons = true -- 允许武器强化

-- 附加武器修正：缩短命中判定延迟与开火间隔各 0.15 秒
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_MELEE_IMPACT_DELAY, -0.15, 1)
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_FIRE_DELAY, -0.15, 1)

-- ==== PlaySwingSound - 播放挥击音效 ====
-- 随机低沉的破空声
function SWEP:PlaySwingSound()
	self:EmitSound("weapons/iceaxe/iceaxe_swing1.wav", 75, math.random(20, 25))
end

-- ==== PlayHitSound - 播放命中（非血肉）音效 ====
-- 重型车辆撞击声，随机音调
function SWEP:PlayHitSound()
	self:EmitSound("vehicles/v8/vehicle_impact_heavy"..math.random(4)..".wav", 80, math.Rand(95, 105))
end

-- ==== PlayHitFleshSound - 播放命中血肉音效 ====
function SWEP:PlayHitFleshSound()
	self:EmitSound("physics/flesh/flesh_bloody_break.wav", 80, math.Rand(90, 100))
end

-- ==== OnMeleeHit - 近战命中回调 ====
-- 命中位置生成爆炸特效（表现巨锤重击的冲击力）
function SWEP:OnMeleeHit(hitent, hitflesh, tr)
	if IsFirstTimePredicted() then -- 仅首次预测时生成，避免重复
		local effectdata = EffectData()
			effectdata:SetOrigin(tr.HitPos) -- 爆炸位置：命中点
			effectdata:SetNormal(tr.HitNormal) -- 爆炸方向：命中面法线
		util.Effect("explosion", effectdata) -- 播放爆炸特效
	end
end
