-- ============================================================================
-- shared.lua - 解毒剂注射枪（共享端）
-- 负责：治疗型武器属性、音效与医疗光环（部署/收起时开关）逻辑
-- ============================================================================
SWEP.PrintName = ""..translate.Get("weapon_zs_antidoteshot") -- 武器显示名称
SWEP.Description = ""..translate.Get("weapon_zs_antidoteshot_description") -- 武器描述

SWEP.SlotPos = 0 -- 武器栏中的槽位

SWEP.Base = "weapon_zs_baseproj" -- 继承投射物武器基类
DEFINE_BASECLASS("weapon_zs_baseproj") -- 定义基类引用

SWEP.HoldType = "revolver" -- 持枪姿势（左轮手枪）

SWEP.ViewModel = "models/weapons/cstrike/c_pist_deagle.mdl" -- 第一人称模型
SWEP.WorldModel = "models/weapons/w_pist_deagle.mdl" -- 第三人称模型
SWEP.ShowViewModel = false -- 不显示默认第一人称模型（使用自定义部件拼装）
SWEP.ShowWorldModel = false -- 不显示默认第三人称模型

SWEP.UseHands = true -- 使用玩家手部模型

SWEP.CSMuzzleFlashes = false -- 不使用 CS 风格枪口闪光

SWEP.ReloadSound = Sound("Weapon_Pistol.Reload") -- 换弹音效

SWEP.Primary.Delay = 0.4 -- 射击间隔（秒）

SWEP.Primary.ClipSize = 21 -- 弹匣容量
SWEP.Primary.DefaultClip = 150 -- 默认赠送的弹匣倍数
SWEP.Primary.Ammo = "Battery" -- 消耗的弹药类型（电池）
SWEP.RequiredClip = 3 -- 每次射击消耗的弹药数

SWEP.WalkSpeed = SPEED_NORMAL -- 持枪移动速度（正常）

SWEP.ConeMax = 0 -- 最大扩散（固定精确）
SWEP.ConeMin = 0 -- 最小扩散

SWEP.ReloadSpeed = 0.43 -- 换弹速度倍率
SWEP.FireAnimSpeed = 1.3 -- 开火动画播放速度

SWEP.IronSightsPos = Vector(-5.95, 3, 2.75) -- 机瞄时视角位置偏移
SWEP.IronSightsAng = Vector(-0.15, -1, 2) -- 机瞄时视角角度偏移

SWEP.AllowQualityWeapons = true -- 允许品质强化

-- 附加武器修饰符：弹匣容量 +5、投射物速度 +50
GAMEMODE:SetPrimaryWeaponModifier(SWEP, WEAPON_MODIFIER_CLIP_SIZE, 5)
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_PROJECTILE_VELOCITY, 50)

-- ==== EmitFireSound - 播放开火音效（医疗包声 + 枪声） ====
function SWEP:EmitFireSound()
	self:EmitSound("items/smallmedkit1.wav", 70, math.random(135, 140), 0.65, CHAN_WEAPON + 21)
	self:EmitSound("weapons/galil/galil-1.wav", 75, math.random(122, 128), 0.7, CHAN_WEAPON + 20)
end

-- ==== EmitReloadSound - 播放换弹开始音效（仅首次预测时） ====
function SWEP:EmitReloadSound()
	if IsFirstTimePredicted() then
		self:EmitSound("weapons/357/357_reload1.wav", 75, 75, 1, CHAN_WEAPON + 21)
	end
end

-- ==== EmitReloadFinishSound - 播放换弹完成音效（仅首次预测时） ====
function SWEP:EmitReloadFinishSound()
	if IsFirstTimePredicted() then
		self:EmitSound("weapons/357/357_spin1.wav", 70, 90)
	end
end

-- ==== SendReloadAnimation - 换弹时播放抽出武器的动画 ====
function SWEP:SendReloadAnimation()
	self:SendWeaponAnim(ACT_VM_DRAW)
end

-- ==== Deploy - 部署武器时开启医疗光环（客户端注册绘制钩子） ====
function SWEP:Deploy()
	if CLIENT then
		hook.Add("PostPlayerDraw", "PostPlayerDrawMedical", GAMEMODE.PostPlayerDrawMedical)
		GAMEMODE.MedicalAura = true
	end

	return BaseClass.Deploy(self)
end

-- ==== Holster - 收起武器时关闭医疗光环 ====
function SWEP:Holster()
	if CLIENT and self:GetOwner() == MySelf then
		hook.Remove("PostPlayerDraw", "PostPlayerDrawMedical")
		GAMEMODE.MedicalAura = false
	end

	return true
end

-- ==== OnRemove - 武器移除时关闭医疗光环 ====
function SWEP:OnRemove()
	if CLIENT and self:GetOwner() == MySelf then
		hook.Remove("PostPlayerDraw", "PostPlayerDrawMedical")
		GAMEMODE.MedicalAura = false
	end
end
