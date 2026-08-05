-- ============================================================================
-- weapon_zs_boomstick.lua - 霰弹轰击枪（Boomstick）
-- 负责：4 发弹仓泵动霰弹枪：一次扣扳机打光整个弹仓（弹丸数随剩余
--       弹药成倍增加），伴随巨大后坐力、视角冲击和自身击退；带改装分支
-- ============================================================================
AddCSLuaFile() -- 将该文件同时发送到客户端

-- 继承霰弹枪武器母本
SWEP.Base = "weapon_zs_baseshotgun"

-- 武器显示名称（本地化）
SWEP.PrintName = ""..translate.Get("weapon_zs_boomstick")
-- 武器描述（本地化）
SWEP.Description = ""..translate.Get("weapon_zs_boomstick_description")

if CLIENT then -- 客户端专属设置
	-- HUD 3D 武器展示图：绑定骨骼与位置/缩放
	SWEP.HUD3DBone = "ValveBiped.Gun"
	SWEP.HUD3DPos = Vector(1.65, 0, -8)
	SWEP.HUD3DScale = 0.025

	SWEP.ViewModelFlip = false -- 不翻转第一人称模型
end

-- 第一人称模型（霰弹枪）
SWEP.ViewModel = "models/weapons/c_shotgun.mdl"
-- 世界模型
SWEP.WorldModel = "models/weapons/w_shotgun.mdl"
SWEP.UseHands = true -- 使用玩家手臂模型握持

SWEP.CSMuzzleFlashes = false -- 不使用 CS 样式枪口闪光

SWEP.ReloadDelay = 0.5 -- 单发装填间隔

SWEP.Primary.Sound = Sound("weapons/shotgun/shotgun_dbl_fire.wav") -- 开火音效（双管声）
SWEP.Primary.Damage = 27 -- 单粒弹丸伤害
SWEP.Primary.NumShots = 6 -- 每发基础弹丸数
SWEP.Primary.Delay = 1 -- 射击间隔

SWEP.Recoil = 7.5 -- 后坐力系数

SWEP.Primary.ClipSize = 4 -- 弹仓容量
SWEP.Primary.Automatic = false -- 半自动（单发）
SWEP.Primary.Ammo = "buckshot" -- 弹药类型：鹿弹
SWEP.Primary.DefaultClip = 28 -- 默认备弹数

SWEP.ConeMax = 11.5 -- 最大扩散（弹幕极散）
SWEP.ConeMin = 10 -- 最小扩散

SWEP.Tier = 5 -- 武器等级（5 级高级武器）
SWEP.MaxStock = 2 -- 商店最大库存量

SWEP.WalkSpeed = SPEED_SLOWER -- 手持时移动速度（较慢）
SWEP.FireAnimSpeed = 0.4 -- 开火动画播放速度（慢动作回放感）
SWEP.Knockback = 80 -- 开火时自身的击退力度

SWEP.PumpActivity = ACT_SHOTGUN_PUMP -- 上膛动画
SWEP.PumpSound = Sound("Weapon_Shotgun.Special1") -- 上膛音效
SWEP.ReloadSound = Sound("Weapon_Shotgun.Reload") -- 换弹音效

-- 附加武器修正：换弹速度 +0.07/级；弹仓容量 +1
GAMEMODE:SetPrimaryWeaponModifier(SWEP, WEAPON_MODIFIER_RELOAD_SPEED, 0.07)
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_CLIP_SIZE, 1)
-- 注册改装分支（速射散射改造）：伤害 x0.75、换弹更快、间隔减半、
-- 击退提升、移动更快
GAMEMODE:AddNewRemantleBranch(SWEP, 1, ""..translate.Get("weapon_zs_boomstick_r1"), ""..translate.Get("weapon_zs_boomstick_r1_description"), function(wept)
	wept.Primary.Damage = wept.Primary.Damage * 0.75
	wept.ReloadSpeed = wept.ReloadSpeed * 1.25
	wept.Primary.Delay = wept.Primary.Delay * 0.5
	wept.Knockback = 100
	wept.WalkSpeed = SPEED_SLOW
end)

-- ==== PrimaryAttack - 左键：打光整个弹仓 ====
-- 一次射击倾泻全部剩余弹药，弹丸数 = 基础 6 粒 × 剩余弹数，
-- 并按弹数放大后坐力、视角冲击和自身击退
function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end

	local owner = self:GetOwner()

	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay) -- 攻击冷却
	self:EmitSound(self.Primary.Sound) -- 播放开火音效

	local clip = self:Clip1() -- 当前剩余弹数

	-- 弹丸总数 = 基础弹丸数 × 剩余弹数（弹仓越满越猛）
	self:ShootBullets(self.Primary.Damage, self.Primary.NumShots * clip, self:GetCone())

	self:TakePrimaryAmmo(clip) -- 清空整个弹仓
	-- 视角冲击随弹数放大（强烈上跳）
	owner:ViewPunch(clip * 0.5 * self.Recoil * Angle(math.Rand(-0.1, -0.1), math.Rand(-0.1, 0.1), 0))

	-- 自身被击退（抵消后坐力，甚至击飞）
	owner:SetGroundEntity(NULL)
	owner:SetVelocity(-self.Knockback * clip * owner:GetAimVector())

	self.IdleAnimation = CurTime() + self:SequenceDuration() -- 延迟待机动画
end
