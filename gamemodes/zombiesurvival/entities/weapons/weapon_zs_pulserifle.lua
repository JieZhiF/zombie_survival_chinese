-- ============================================================================
-- weapon_zs_pulserifle.lua - 脉冲步枪
-- 负责：脉冲步枪属性、腿部减速累积机制、改造分支（电击器联动）与命中特效
-- ============================================================================
AddCSLuaFile()
DEFINE_BASECLASS("weapon_zs_base")

-- 武器显示名称与描述（本地化）
SWEP.PrintName = ""..translate.Get("weapon_zs_pulserifle")
SWEP.Description = ""..translate.Get("weapon_zs_pulserifle_description")


-- 栏位内位置
SWEP.SlotPos = 0

if CLIENT then
	
    -- 客户端：归类到突击步枪选择栏（武器类型：步枪），第一人称视野 60
    SWEP.Slot = GAMEMODE:GetWeaponSlot("WeaponSelectSlotAssaultRifles")
SWEP.WeaponType = "rifle"
    SWEP.SlotGroup = WEPSELECT_ASSAULT_RIFLE
	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 60

	-- HUD3D：HUD 内武器图标的挂载骨骼与位置缩放
	SWEP.HUD3DBone = "Vent"
	SWEP.HUD3DPos = Vector(1, 0, 0)
	SWEP.HUD3DScale = 0.018
end

-- 基于武器基础母本
SWEP.Base = "weapon_zs_base"

-- 持握姿势：AR2 步枪
SWEP.HoldType = "ar2"

-- 第一人称与第三人称模型，使用玩家手部模型
SWEP.ViewModel = "models/weapons/c_irifle.mdl"
SWEP.WorldModel = "models/weapons/w_IRifle.mdl"
SWEP.UseHands = true

-- 不使用 CS 风格枪口闪光（自带能量射击特效）
SWEP.CSMuzzleFlashes = false

-- 换弹与开火音效
SWEP.ReloadSound = Sound("Weapon_SMG1.Reload")
SWEP.Primary.Sound = Sound("Airboat.FireGunHeavy")
-- 单发伤害 29，每次 1 颗子弹，间隔 0.2 秒
SWEP.Primary.Damage = 29
SWEP.Primary.NumShots = 1
SWEP.Primary.Delay = 0.2

-- 弹匣 20 发，全自动，使用脉冲弹药（默认弹匣由游戏模式统一配置）
SWEP.Primary.ClipSize = 20
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "pulse"
SWEP.WeaponType = "pulse"
GAMEMODE:SetupDefaultClip(SWEP.Primary)

-- 扩散范围（未瞄准最大 / 瞄准最小）
SWEP.ConeMax = 3
SWEP.ConeMin = 1

-- 持枪移动速度：慢速
SWEP.WalkSpeed = SPEED_SLOW

-- 机瞄位置
SWEP.IronSightsPos = Vector(-3, 1, 1)

-- 武器等级与商店最大库存
SWEP.Tier = 5
SWEP.MaxStock = 2

-- 击杀得分倍率（与所有脉冲武器共享的倍率）
SWEP.PointsMultiplier = GAMEMODE.PulsePointsMultiplier

-- 子弹曳光特效
SWEP.TracerName = "AR2Tracer"

-- 射击动画速度倍率与每次命中累积的腿部伤害（用于脉冲减速）
SWEP.FireAnimSpeed = 0.4
SWEP.LegDamage = 5.5

-- 附加射击间隔强化模组（每级 -0.014 秒，上限 1 级）
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_FIRE_DELAY, -0.014, 1)

-- 附加改造分支：过载枪管（扩散增大、装填加速、腿部伤害提升；击杀僵尸刷新己方电击器冷却）
GAMEMODE:AddNewRemantleBranch(SWEP, 1, ""..translate.Get("weapon_zs_pulserifle_r1"), ""..translate.Get("weapon_zs_pulserifle_r1_description"), function(wept)
	wept.ConeMin = 2.25
	wept.ConeMax = 3.75
	wept.ReloadSpeed = 0.85
	wept.LegDamage = 8

	-- 击杀僵尸时：重置所有归属自己的电击器的下一次电击时间
	wept.OnZombieKilled = function(self)
		local killer = self:GetOwner()

		if killer:IsValid() then
			for _,v in pairs(ents.FindByClass("prop_zapper*")) do
				if v:GetObjectOwner() == killer then
					v:SetNextZap(0)
				end
			end
		end
	end
end)

-- ==== BulletCallback - 子弹命中回调：对僵尸累积腿部伤害（脉冲减速），并创建脉冲命中特效 ====
function SWEP.BulletCallback(attacker, tr, dmginfo)
	local ent = tr.Entity
	if ent:IsValidZombie() then
		local activ = attacker:GetActiveWeapon()
		ent:AddLegDamageExt(activ.LegDamage, attacker, activ, SLOWTYPE_PULSE)
	end

	if IsFirstTimePredicted() then
		util.CreatePulseImpactEffect(tr.HitPos, tr.HitNormal)
	end
end
