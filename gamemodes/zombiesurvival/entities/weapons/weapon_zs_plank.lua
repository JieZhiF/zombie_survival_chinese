-- ============================================================================
-- weapon_zs_plank.lua - 木板近战武器
-- 负责：基础近战武器，具有连击系统（命中玩家时缩短攻击间隔），
--       支持格挡（防御伤害减免），使用 SCK 自定义木板外观
-- ============================================================================
AddCSLuaFile()

-- 武器显示名称与描述（本地化键）
SWEP.PrintName = ""..translate.Get("weapon_zs_plank")
SWEP.Description = ""..translate.Get("weapon_zs_plank_description")

if CLIENT then
	-- 第一人称视角设置
	SWEP.ViewModelFOV = 55
	SWEP.ViewModelFlip = false

	-- 隐藏原始模型，使用 SCK 元素自定义外观
	SWEP.ShowViewModel = false
	SWEP.ShowWorldModel = false
	-- 第一人称视角模型元素（木板碎片挂在右手骨上）
	SWEP.VElements = {
		["base"] = { type = "Model", model = "models/props_debris/wood_chunk03a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(1.363, 1.363, -11.365), angle = Angle(180, 90, 0), size = Vector(0.5, 0.5, 0.5), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}
	-- 世界模型元素（第三人称显示的木板）
	SWEP.WElements = {
		["base"] = { type = "Model", model = "models/props_debris/wood_chunk03a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(2.273, 1.363, -12.273), angle = Angle(180, 90, 0), size = Vector(0.5, 0.5, 0.5), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}
end

-- 继承近战武器基类
SWEP.Base = "weapon_zs_basemelee"

-- 伤害类型：钝击
SWEP.DamageType = DMG_CLUB

-- 第一人称/世界模型
SWEP.ViewModel = "models/weapons/c_crowbar.mdl"
SWEP.WorldModel = "models/props_debris/wood_chunk03a.mdl"
-- 模型缩放
SWEP.ModelScale = 0.5
-- 使用 C 模型手部
SWEP.UseHands = true
-- 物理碰撞盒边界（用于碰撞检测）
SWEP.BoxPhysicsMin = Vector(-0.5764, -2.397225, -20.080572) * SWEP.ModelScale
SWEP.BoxPhysicsMax = Vector(0.70365, 2.501825, 19.973375) * SWEP.ModelScale

-- 近战伤害、攻击范围、攻击判定大小
SWEP.MeleeDamage = 16
SWEP.MeleeRange = 48
SWEP.MeleeSize = 0.875
-- 攻击延迟
SWEP.Primary.Delay = 0.37
-- 格挡音效音调
SWEP.BlockSoundPitch  = 130
-- 格挡时防御伤害减免倍率
SWEP.DefendingDamageBlocked = 1.15
SWEP.DefendingDamageBlockedDefault = 1.15
-- 格挡时武器位置与角度偏移
SWEP.BlockPos = Vector(-1, -5, -5)
SWEP.BlockAng = Angle(0, 20, -25)

-- 持有时的移动速度（较快）
SWEP.WalkSpeed = SPEED_FASTER

-- 使用近战1号攻击模式
SWEP.UseMelee1 = true

-- 命中与挥空手势动画
SWEP.HitGesture = ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE
SWEP.MissGesture = SWEP.HitGesture

-- 允许强化
SWEP.AllowQualityWeapons = true
-- 格挡音效（随机木板撞击音）
SWEP.BlockSound = "physics/wood/wood_solid_impact_bullet"..math.random(5)..".wav"
-- 连击计数器与最大连击数
SWEP.ComboStack = 0
SWEP.MaxComboStack = 20

-- 武器修饰符：近战范围+4
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_MELEE_RANGE, 4)

-- ==== PlaySwingSound - 播放挥砍音效 ====
function SWEP:PlaySwingSound()
	-- 随机播放匕首挥砍音效
	self:EmitSound("weapons/knife/knife_slash"..math.random(2)..".wav")
end

-- ==== PlayHitSound - 播放命中墙壁音效 ====
function SWEP:PlayHitSound()
	-- 随机播放木板硬撞击音效
	self:EmitSound("physics/wood/wood_plank_impact_hard"..math.random(5)..".wav")
end

-- ==== PlayHitFleshSound - 播放命中肉体音效 ====
function SWEP:PlayHitFleshSound()
	-- 随机播放肉体子弹冲击音效
	self:EmitSound("physics/flesh/flesh_impact_bullet"..math.random(5)..".wav")
end

-- ==== PostOnMeleeHit - 近战命中后回调（连击系统） ====
function SWEP:PostOnMeleeHit(hitent, hitflesh, tr)
	-- 命中有效玩家时触发连击加速
	if hitent:IsValid() and hitent:IsPlayer() then
		-- 获取当前连击数
		local combo = self:GetDTInt(2)
		local owner = self:GetOwner()
		-- 获取持有者近战速度倍率
		local armdelay = owner:GetMeleeSpeedMul()
		-- 连击数越高，下次攻击间隔越短（最低0.2秒）
		self:SetNextPrimaryFire(CurTime() + math.max(0.2, self.Primary.Delay * (1 - combo / 10)) * armdelay)

		-- 连击数+1
		self:SetDTInt(2, combo + 1)
	end
end

-- ==== PostOnMeleeMiss - 近战挥空后回调（重置连击） ====
function SWEP:PostOnMeleeMiss(tr)
	-- 挥空时重置连击计数器
	self:SetDTInt(2, 0)
end
