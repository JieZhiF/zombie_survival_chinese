-- ============================================================================
-- weapon_zs_ripper/shared.lua - 撕裂者（人类远程武器）
-- 负责：定义连发弩的基础属性、开火/换弹音效与主攻击逻辑
-- ============================================================================
-- 武器名称与描述（从翻译表读取）
SWEP.PrintName = ""..translate.Get("weapon_zs_ripper")
SWEP.Description = ""..translate.Get("weapon_zs_ripper_description")

-- 基于投射物武器母本
SWEP.Base = "weapon_zs_baseproj"

-- 持握姿势（弩式）
SWEP.HoldType = "crossbow"

-- 视图模型与第三人称模型（借用格洛克与 UMP45 模型）
SWEP.ViewModel = "models/weapons/cstrike/c_pist_glock18.mdl"
SWEP.WorldModel = "models/weapons/w_smg_ump45.mdl"

-- 不使用玩家手臂模型
SWEP.UseHands = false

-- 不使用 CS 风格枪口闪光
SWEP.CSMuzzleFlashes = false

-- 开火音效
SWEP.Primary.Sound = Sound("Weapon_Crossbow.Single")
-- 射击间隔（15/33 秒）与全自动模式
SWEP.Primary.Delay = 15/33
SWEP.Primary.Automatic = true
-- 单发伤害
SWEP.Primary.Damage = 62

-- 弹匣容量与消耗弹药类型
SWEP.Primary.ClipSize = 8
SWEP.Primary.Ammo = "XBowBolt"
-- 初始备弹
SWEP.Primary.DefaultClip = 15

-- 持枪移动速度
SWEP.WalkSpeed = SPEED_SLOWER

-- 武器等级
SWEP.Tier = 4

-- 武器扩散（最大/最小）
SWEP.ConeMax = 1.35
SWEP.ConeMin = 0.95

-- 爆头伤害倍率
SWEP.HeadshotMulti = 2.2

-- 换弹速度倍率
SWEP.ReloadSpeed = 0.72

-- 附加武器修正：缩短射击间隔
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_FIRE_DELAY, -0.04)

-- ==== EmitFireSound - 播放开火音效：刀片切割声 + 机枪声（副攻击音调更低） ====
function SWEP:EmitFireSound(secondary)
	self:EmitSound("npc/roller/blade_cut.wav", 75, secondary and 56 or 66, 0.73)
	self:EmitSound("weapons/m249/m249-1.wav", 75, secondary and 86 or 146, 0.67, CHAN_AUTO+20)
end

-- ==== EmitReloadSound - 播放换弹音效（仅首次预测时） ====
function SWEP:EmitReloadSound()
	if IsFirstTimePredicted() then
		self:EmitSound("weapons/357/357_reload1.wav", 75, 65, 1, CHAN_WEAPON + 21)
		self:EmitSound("weapons/ar2/ar2_reload_push.wav", 70, 67, 0.85, CHAN_WEAPON + 22)
	end
end

-- ==== EmitReloadFinishSound - 播放换弹完成音效（拉栓声） ====
function SWEP:EmitReloadFinishSound()
	if IsFirstTimePredicted() then
		self:EmitSound("weapons/galil/galil_boltpull.wav", 70, 110)
	end
end

-- ==== SetLastFired - 记录最近开火时间（通过 DT 同步到客户端） ====
function SWEP:SetLastFired(float)
	self:SetDTFloat(8, float)
end

-- ==== GetLastFired - 读取最近开火时间 ====
function SWEP:GetLastFired()
	return self:GetDTFloat(8)
end

-- ==== PrimaryAttack - 主攻击：连发射击弩箭 ====
function SWEP:PrimaryAttack()
	-- 弹药与冷却检查
	if not self:CanPrimaryAttack() then return end

	-- 设置射击间隔并记录开火时间
	self:SetNextPrimaryFire(CurTime() + self:GetFireDelay())
	self:SetLastFired(CurTime())

	-- 播放音效、消耗弹药并发射子弹
	self:EmitFireSound()
	self:TakeAmmo()
	self:ShootBullets(self.Primary.Damage, self.Primary.NumShots, self:GetCone())
	self.IdleAnimation = CurTime() + self:SequenceDuration()
end
