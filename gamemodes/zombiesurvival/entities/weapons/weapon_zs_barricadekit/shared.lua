-- ============================================================================
-- shared.lua - 搭建包（共享端）
-- 负责：木板搭建工具属性，左键放置木板，使用 RPG 模型外观
-- ============================================================================
SWEP.PrintName = ""..translate.Get("weapon_zs_barricadekit") -- 武器显示名称
SWEP.Description = ""..translate.Get("weapon_zs_barricadekit_description") -- 武器描述

SWEP.SlotPos = 0 -- 武器栏中的槽位

SWEP.ViewModel = "models/weapons/c_rpg.mdl" -- 第一人称模型（火箭筒外观）
SWEP.WorldModel = "models/weapons/w_rocket_launcher.mdl" -- 第三人称模型

SWEP.Primary.ClipSize = 1 -- 弹匣容量
SWEP.Primary.Automatic = false -- 单发（非全自动）
SWEP.Primary.Ammo = "SniperRound" -- 消耗的弹药类型（借用狙击弹药表示木板数）
SWEP.Primary.Delay = 1.25 -- 放置间隔（秒）
SWEP.Primary.DefaultClip = 5 -- 默认赠送的弹匣倍数

SWEP.Secondary.ClipSize = 1 -- 右键弹匣容量
SWEP.Secondary.DefaultClip = 1 -- 右键默认弹匣
SWEP.Secondary.Ammo = "dummy" -- 右键不消耗实际弹药
SWEP.Secondary.Automatic = false -- 右键单发

SWEP.UseHands = true -- 使用玩家手部模型

SWEP.MaxStock = 5 -- 商店最大库存

if CLIENT then
	SWEP.ViewModelFOV = 60 -- 第一人称镜头大小
end

SWEP.WalkSpeed = SPEED_SLOWEST -- 持枪移动速度（最慢）

-- ==== Initialize - 初始化持枪姿势并同步部署速度 ====
function SWEP:Initialize()
	self:SetWeaponHoldType("rpg")
	GAMEMODE:DoChangeDeploySpeed(self)
end

-- ==== Deploy - 部署时同步移动速度 ====
function SWEP:Deploy()
	GAMEMODE:DoChangeDeploySpeed(self)

	return true
end

-- ==== CanPrimaryAttack - 判定能否放置（非持有物/搭建预览且木板数充足） ====
function SWEP:CanPrimaryAttack()
	local owner = self:GetOwner()

	if owner:IsHolding() or owner:GetBarricadeGhosting() then return false end

	if self:GetPrimaryAmmoCount() <= 0 then
		self:EmitSound("Weapon_Shotgun.Empty")
		self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
		return false
	end

	return true
end

-- ==== SecondaryAttack - 禁用右键 ====
function SWEP:SecondaryAttack()
end

-- ==== Reload - 禁用换弹 ====
function SWEP:Reload()
end

util.PrecacheModel("models/props_debris/wood_board05a.mdl") -- 预缓存木板模型
util.PrecacheSound("npc/dog/dog_servo12.wav") -- 预缓存放置音效
