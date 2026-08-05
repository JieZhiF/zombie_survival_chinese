-- ============================================================================
-- shared.lua - 地图武器基类（共享端）
-- 负责：ZE 地图上的自定义武器拾取物基类，无攻击能力，拾取后切换回近战武器
-- ============================================================================
SWEP.PrintName = ""..translate.Get("weapon_map_base") -- 武器显示名称

SWEP.AnimPrefix = "none" -- 无动画前缀
SWEP.HoldType = "normal" -- 持枪姿势（默认）

SWEP.Spawnable = true -- 可生成
SWEP.AdminSpawnable = true -- 管理员可生成

SWEP.Primary.ClipSize = -1 -- 无限弹匣
SWEP.Primary.DefaultClip = -1 -- 无限默认弹药
SWEP.Primary.Automatic = false -- 单发
SWEP.Primary.Ammo = "none" -- 不消耗弹药

SWEP.Secondary.ClipSize = -1 -- 无限弹匣
SWEP.Secondary.DefaultClip = -1 -- 无限默认弹药
SWEP.Secondary.Automatic = false -- 单发
SWEP.Secondary.Ammo = "none" -- 不消耗弹药

SWEP.DrawCrosshair = false -- 不绘制准星
SWEP.Primary.Sound = Sound("") -- 无开火音效

SWEP.WorldModel	= "models/weapons/w_crowbar.mdl" -- 第三人称模型（撬棍）

SWEP.WalkSpeed = SPEED_NORMAL -- 持枪移动速度（正常）

-- ==== Initialize - 空初始化 ====
function SWEP:Initialize()
end

-- ==== Equip - 拾取时广播 ZE 武器拾取消息（仅 ZE 模式） ====
function SWEP:Equip()
	local owner = self:GetOwner()
	local children = self:GetChildren()

	if GAMEMODE.ZombieEscape then
		if #children > 0 then
			GAMEMODE:CenterNotifyAll(COLOR_GREEN, owner:GetName() .. " has picked up a ZE Weapon. ("..children[math.random(#children)]:GetName()..")")
			PrintMessage(HUD_PRINTTALK, owner:GetName() .. " has picked up a ZE Weapon. ("..children[math.random(#children)]:GetName()..")")
			if SERVER then
				gamemode.Call("OnZEWeaponPickup", owner, self)
			end
		end
	end
end

-- ==== SetWeaponHoldType - 空实现（不改变持枪姿势） ====
function SWEP:SetWeaponHoldType()
end

-- ==== PrimaryAttack - 空实现（地图武器不可攻击） ====
function SWEP:PrimaryAttack()
end

-- ==== SecondaryAttack - 空实现（地图武器不可攻击） ====
function SWEP:SecondaryAttack()
end

-- ==== Reload - 空实现（不可换弹） ====
function SWEP:Reload()
end

-- ==== Deploy - 部署后立即切回对应模式的近战武器 ====
function SWEP:Deploy()
	if SERVER then
		local owner = self:GetOwner()

		if GAMEMODE.ZombieEscape then
			owner:SelectWeapon("weapon_zs_zeknife")
		else
			owner:SelectWeapon("weapon_zs_fists")
		end
	end
	return true
end

-- ==== CanPrimaryAttack - 禁止左键攻击 ====
function SWEP:CanPrimaryAttack()
	return false
end

-- ==== CanSecondaryAttack - 禁止右键攻击 ====
function SWEP:CanSecondaryAttack()
	return false
end
