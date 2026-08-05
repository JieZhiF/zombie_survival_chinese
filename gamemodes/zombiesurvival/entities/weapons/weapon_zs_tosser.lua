-- ============================================================================
-- weapon_zs_tosser.lua - 抛掷者：SMG 冲锋枪
-- 负责：冲锋枪基础属性、客户端栏位/HUD3D 配置，以及三连发改造分支逻辑
-- ============================================================================
AddCSLuaFile()
DEFINE_BASECLASS("weapon_zs_base")

-- 武器显示名称与描述（本地化）
SWEP.PrintName = ""..translate.Get("weapon_zs_tosser")
SWEP.Description = ""..translate.Get("weapon_zs_tosser_description")


-- 栏位内位置
SWEP.SlotPos = 0

if CLIENT then
	-- 客户端：归类到冲锋枪选择栏，并配置 HUD3D 挂载信息
	SWEP.Slot = GAMEMODE:GetWeaponSlot("WeaponSelectSlotSMGs")
	SWEP.SlotGroup = WEPSELECT_SMG
	SWEP.HUD3DBone = "ValveBiped.base"
	SWEP.HUD3DPos = Vector(1.5, 0.25, -2)
	SWEP.HUD3DScale = 0.02

	-- 客户端第一人称视角配置
	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 60
end

-- 基于武器基础母本
SWEP.Base = "weapon_zs_base"

-- 持握姿势：冲锋枪
SWEP.HoldType = "smg"

-- 第一人称与第三人称模型，使用玩家手部模型
SWEP.ViewModel = "models/weapons/c_smg1.mdl"
SWEP.WorldModel = "models/weapons/w_smg1.mdl"
SWEP.UseHands = true

-- 不使用 CS 风格枪口闪光
SWEP.CSMuzzleFlashes = false

-- 换弹与开火音效
SWEP.ReloadSound = Sound("Weapon_SMG1.Reload")
SWEP.Primary.Sound = Sound("Weapon_AR2.NPC_Single")
-- 单发伤害 14，每次射击 1 颗子弹，间隔 0.15 秒
SWEP.Primary.Damage = 14
SWEP.Primary.NumShots = 1
SWEP.Primary.Delay = 0.15

-- 弹匣 24 发，全自动，使用 SMG1 弹药（默认弹匣由游戏模式统一配置）
SWEP.Primary.ClipSize = 24
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "smg1"
GAMEMODE:SetupDefaultClip(SWEP.Primary)

-- 射击与换弹的动作手势
SWEP.Primary.Gesture = ACT_HL2MP_GESTURE_RANGE_ATTACK_SMG1
SWEP.ReloadGesture = ACT_HL2MP_GESTURE_RELOAD_SMG1

-- 换弹速度与射击动画速度倍率
SWEP.ReloadSpeed = 0.78
SWEP.FireAnimSpeed = 0.55

-- 扩散范围（未瞄准最大 / 瞄准最小）
SWEP.ConeMax = 4.5
SWEP.ConeMin = 2.5

-- 机瞄位置
SWEP.IronSightsPos = Vector(-6.425, 5, 1.02)

-- 附加射击间隔强化模组（每级 -0.015 秒）
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_FIRE_DELAY, -0.015)

-- 附加改造分支：三连发模式（伤害 +10%，间隔 ×3.9，一次按键连射 3 发）
GAMEMODE:AddNewRemantleBranch(SWEP, 1, ""..translate.Get("weapon_zs_tosser_r1"), ""..translate.Get("weapon_zs_tosser_r1_description"), function(wept)
	wept.Primary.Damage = wept.Primary.Damage * 1.1
	wept.Primary.Delay = wept.Primary.Delay * 3.9
	wept.Primary.BurstShots = 3

	-- 覆盖开火：扣下扳机只打出第一发，并记录剩余连发数
	wept.PrimaryAttack = function(self)
		if not self:CanPrimaryAttack() then return end

		self:SetNextPrimaryFire(CurTime() + self:GetFireDelay())
		self:EmitFireSound()

		self:SetNextShot(CurTime())
		self:SetShotsLeft(self.Primary.BurstShots)

		self.IdleAnimation = CurTime() + self:SequenceDuration()
	end

	-- 覆盖 Think：按连发间隔（开火间隔的 1/6）补射剩余两发
	wept.Think = function(self)
		BaseClass.Think(self)

		local shotsleft = self:GetShotsLeft()
		if shotsleft > 0 and CurTime() >= self:GetNextShot() then
			self:SetShotsLeft(shotsleft - 1)
			self:SetNextShot(CurTime() + self:GetFireDelay()/6)

			-- 弹匣有弹且不在换弹中才补射，否则清空剩余连发
			if self:Clip1() > 0 and self:GetReloadFinish() == 0 then
				self:EmitFireSound()
				self:TakeAmmo()
				self:ShootBullets(self.Primary.Damage, self.Primary.NumShots, self:GetCone())

				self.IdleAnimation = CurTime() + self:SequenceDuration()
			else
				self:SetShotsLeft(0)
			end
		end
	end
end)

-- ==== SetNextShot - 记录下一次补射时间（DT 浮点字段 5） ====
function SWEP:SetNextShot(nextshot)
	self:SetDTFloat(5, nextshot)
end

-- ==== GetNextShot - 读取下一次补射时间 ====
function SWEP:GetNextShot()
	return self:GetDTFloat(5)
end

-- ==== SetShotsLeft - 记录剩余连发次数（DT 整数字段 1） ====
function SWEP:SetShotsLeft(shotsleft)
	self:SetDTInt(1, shotsleft)
end

-- ==== GetShotsLeft - 读取剩余连发次数 ====
function SWEP:GetShotsLeft()
	return self:GetDTInt(1)
end
