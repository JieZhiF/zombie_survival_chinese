-- ============================================================================
-- weapon_zs_inquisitor/shared.lua - 审判者（人类远程武器）
-- 负责：定义弩枪基础属性、重铸分支与换弹/开火音效
-- ============================================================================
-- 武器名称与描述（从翻译表读取）
SWEP.PrintName = ""..translate.Get("weapon_zs_inquisitor")
SWEP.Description = ""..translate.Get("weapon_zs_inquisitor_description")

-- 基于投射物武器母本
SWEP.Base = "weapon_zs_baseproj"

-- 持握姿势
SWEP.HoldType = "pistol"

-- 视图模型与第三人称模型（借用格洛克与手枪模型）
SWEP.ViewModel = "models/weapons/cstrike/c_pist_glock18.mdl"
SWEP.WorldModel = "models/weapons/w_pistol.mdl"
-- 隐藏视图模型与第三人称模型，仅显示手臂
SWEP.ShowViewModel = false
SWEP.ShowWorldModel = false
SWEP.UseHands = true

-- 不使用 CS 风格枪口闪光
SWEP.CSMuzzleFlashes = false

-- 开火音效
SWEP.Primary.Sound = Sound("weapons/crossbow/fire1.wav")
-- 单发弹匣、全自动、消耗弩箭弹药
SWEP.Primary.ClipSize = 1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "XBowBolt"
-- 射击间隔与初始备弹
SWEP.Primary.Delay = 1.25
SWEP.Primary.DefaultClip = 15
-- 单发伤害
SWEP.Primary.Damage = 69

-- 武器扩散（最大/最小）
SWEP.ConeMax = 0.5
SWEP.ConeMin = 0

-- 后坐力
SWEP.Recoil = 5

-- 换弹速度倍率
SWEP.ReloadSpeed = 0.6

-- 持枪移动速度
SWEP.WalkSpeed = SPEED_SLOW

-- 武器等级
SWEP.Tier = 2

-- 弹体飞行速度
SWEP.Primary.ProjVelocity = 1600
-- 附加武器修正：提升换弹速度
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_RELOAD_SPEED, 0.06)
-- 新增重铸分支：提升伤害与弹速，并换用混沌箭弹体
GAMEMODE:AddNewRemantleBranch(SWEP, 1, ""..translate.Get("weapon_zs_inquisitor_r1"), ""..translate.Get("weapon_zs_inquisitor_r1_description"), function(wept)
	wept.Primary.Damage = wept.Primary.Damage * 1.2
	wept.Primary.ProjVelocity = 2100
	wept.Primary.Projectile = "projectile_arrow_cha"
	wept.ReloadSpeed = wept.ReloadSpeed * 0.85
end)

-- ==== SendReloadAnimation - 换弹动画：播放拔出武器动作 ====
function SWEP:SendReloadAnimation()
	self:SendWeaponAnim(ACT_VM_DRAW)
end

-- ==== EmitReloadSound - 播放换弹音效（仅首次预测时） ====
function SWEP:EmitReloadSound()
	if IsFirstTimePredicted() then
		self:EmitSound("weapons/crossbow/reload1.wav", 70, 130, 1, CHAN_WEAPON + 22)
	end
end

-- ==== EmitReloadFinishSound - 播放换弹完成音效（拉栓声） ====
function SWEP:EmitReloadFinishSound()
	if IsFirstTimePredicted() then
		self:EmitSound("weapons/galil/galil_boltpull.wav", 70, 150)
	end
end

-- ==== EmitFireSound - 播放开火音效：发射声 + 穿刺声 ====
function SWEP:EmitFireSound()
	self:EmitSound("weapons/crossbow/fire1.wav", 70, 180, 0.7, CHAN_WEAPON + 20)
	self:EmitSound("weapons/crossbow/bolt_skewer1.wav", 70, 243, 0.7, CHAN_WEAPON + 21)
end
