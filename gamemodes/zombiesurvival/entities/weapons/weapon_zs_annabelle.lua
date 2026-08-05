-- ============================================================================
-- weapon_zs_annabelle.lua - 安娜贝尔霰弹枪
-- 负责：泵动式霰弹枪：单发高伤、可机瞄、5 发弹仓逐发装填；
--       开火时叠加双层音效；带"改装分支"（改造为 6 粒弹丸散射模式）
-- ============================================================================
AddCSLuaFile() -- 将该文件同时发送到客户端

-- 继承霰弹枪武器母本
SWEP.Base = "weapon_zs_baseshotgun"

-- 武器显示名称（本地化）
SWEP.PrintName = ""..translate.Get("weapon_zs_annabelle")
-- 武器描述（本地化）
SWEP.Description = ""..translate.Get("weapon_zs_annabelle_description")

if CLIENT then -- 客户端专属设置
	SWEP.ViewModelFlip = false -- 不翻转第一人称模型

	-- 机瞄视角位置与角度
	SWEP.IronSightsPos = Vector(-8.8, 10, 4.32)
	SWEP.IronSightsAng = Vector(1.4, 0.1, 5)

	-- HUD 3D 武器展示图：绑定骨骼与位置/角度/缩放
	SWEP.HUD3DBone = "ValveBiped.Gun"
	SWEP.HUD3DPos = Vector(1.75, 1, -5)
	SWEP.HUD3DAng = Angle(180, 0, 0)
	SWEP.HUD3DScale = 0.015
end

-- 手持姿势：AR2 步枪姿势
SWEP.HoldType = "ar2"

-- 第一人称模型（安娜贝尔霰弹枪）
SWEP.ViewModel = "models/weapons/c_annabelle.mdl"
-- 世界模型
SWEP.WorldModel = "models/weapons/w_annabelle.mdl"
SWEP.UseHands = true -- 使用玩家手臂模型握持

SWEP.CSMuzzleFlashes = false -- 不使用 CS 样式枪口闪光

SWEP.Primary.Sound = Sound("Weapon_Shotgun.Single") -- 开火音效
SWEP.Primary.Damage = 74 -- 单发伤害
SWEP.Primary.NumShots = 1 -- 单发独头弹
SWEP.Primary.Delay = 0.9 -- 射击间隔

SWEP.ReloadDelay = 0.4 -- 单发装填间隔

SWEP.Primary.ClipSize = 5 -- 弹仓容量
SWEP.Primary.Automatic = false -- 半自动（单发）
SWEP.Primary.Ammo = "357" -- 弹药类型：马格南子弹
SWEP.Primary.DefaultClip = 25 -- 默认备弹数

SWEP.ConeMax = 4 -- 最大扩散
SWEP.ConeMin = 0.25 -- 最小扩散（机瞄后极精准）

SWEP.ReloadSound = Sound("Weapon_Shotgun.Reload") -- 换弹音效
SWEP.PumpSound = Sound("Weapon_Shotgun.Special1") -- 上膛音效

SWEP.WalkSpeed = SPEED_SLOW -- 手持时移动速度（较慢）

SWEP.Tier = 2 -- 武器等级（2 级武器）

-- 附加武器修正：降低最大/最小扩散、缩短射击间隔
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_MAX_SPREAD, -0.5, 1)
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_MIN_SPREAD, -0.05, 1)
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_FIRE_DELAY, -0.1, 1)
-- 注册改装分支（散射改造）：伤害 ÷5、改为 6 粒弹丸、扩散大幅提高
GAMEMODE:AddNewRemantleBranch(SWEP, 1, ""..translate.Get("weapon_zs_annabelle_r1"), ""..translate.Get("weapon_zs_annabelle_r1_description"), function(wept)
	wept.Primary.Damage = wept.Primary.Damage / 5
	wept.Primary.NumShots = 6
	wept.ConeMin = wept.ConeMin * 8
	wept.ConeMax = wept.ConeMax * 2
end)

-- ==== EmitFireSound - 播放开火音效 ====
-- 主枪声 + 额外霰弹枪声叠加，音调随机
function SWEP:EmitFireSound()
	self:EmitSound(self.Primary.Sound, 75, math.random(95, 103), 0.8)
	self:EmitSound("weapons/shotgun/shotgun_fire6.wav", 75, math.random(78, 81), 0.65, CHAN_WEAPON + 20)
end

-- ==== SecondaryAttack - 右键：进入机瞄 ====
-- 冷却结束、未持握物品且不在换弹中时开启机瞄
function SWEP:SecondaryAttack()
	if self:GetNextSecondaryFire() <= CurTime() and not self:GetOwner():IsHolding() and self:GetReloadFinish() == 0 then
		self:SetIronsights(true)
	end
end

-- ==== Think - 思考帧 ====
-- 松开右键后自动关闭机瞄
function SWEP:Think()
	if self:GetIronsights() and not self:GetOwner():KeyDown(IN_ATTACK2) then
		self:SetIronsights(false)
	end

	self.BaseClass.Think(self)
end
