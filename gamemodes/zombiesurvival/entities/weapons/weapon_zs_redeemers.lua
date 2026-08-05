-- ============================================================================
-- weapon_zs_redeemers.lua - 救赎者双持手枪
-- 负责：定义双持精英手枪的高射速属性；按剩余弹数的奇偶交替使用
--       左右手动画与枪口（曳光出处），营造左右交替射击效果
-- ============================================================================
AddCSLuaFile()

-- 武器显示名称（本地化）
SWEP.PrintName = ""..translate.Get("weapon_zs_redeemers")

-- 武器栏位中的位置
SWEP.SlotPos = 0

if CLIENT then
-- 武器槽位：手枪类
SWEP.Slot = GAMEMODE:GetWeaponSlot("WeaponSelectSlotPistols")
SWEP.WeaponType = "pistol"
	SWEP.SlotGroup = WEPSELECT_PISTOL
	-- 视模型不翻转，第一人称镜头 FOV
	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 50

	-- 枪身 3D2D HUD 挂点（滑套右侧骨骼）
	SWEP.HUD3DBone = "v_weapon.slide_right"
	SWEP.HUD3DPos = Vector(1, 0.1, -1)
	SWEP.HUD3DScale = 0.015
end

-- 继承通用武器基底
SWEP.Base = "weapon_zs_base"

-- 持枪姿势：双持
SWEP.HoldType = "duel"

-- 视/世界模型（CS 精英双枪），使用玩家手臂
SWEP.ViewModel = "models/weapons/cstrike/c_pist_elite.mdl"
SWEP.WorldModel = "models/weapons/w_pist_elite.mdl"
SWEP.UseHands = true

-- 主攻击：单发伤害与快速射击间隔，全自动
SWEP.Primary.Sound = Sound("Weapon_ELITE.Single")
SWEP.Primary.Damage = 22
SWEP.Primary.NumShots = 1
SWEP.Primary.Delay = 0.15

-- 弹匣 30 发，初始备弹 150 发，消耗手枪弹药
SWEP.Primary.ClipSize = 30
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "pistol"
SWEP.Primary.DefaultClip = 150

-- 扩散范围（较稳定）
SWEP.ConeMax = 2.75
SWEP.ConeMin = 2.5

-- 附加 10% 换弹速度修改器
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_RELOAD_SPEED, 0.1)

-- ==== SecondaryAttack - 右键（空实现：无副攻击） ====
function SWEP:SecondaryAttack()
end

-- ==== SendWeaponAnimation - 射击动画：按弹数奇偶切换左右手开枪动画 ====
function SWEP:SendWeaponAnimation()
	-- 弹数偶数用左手动画、奇数用右手动画，形成交替射击
	self:SendWeaponAnim(self:Clip1() % 2 == 0 and ACT_VM_PRIMARYATTACK or ACT_VM_SECONDARYATTACK)
end

-- 以下仅为客户端内容，服务器端到此结束
if not CLIENT then return end

-- ==== GetTracerOrigin - 曳光起点：从对应左右枪口的附件位置返回 ====
function SWEP:GetTracerOrigin()
	local owner = self:GetOwner()
	if owner:IsValid() then
		local vm = owner:GetViewModel()
		if vm and vm:IsValid() then
			-- 附件 3/4 号分别对应左右枪口，与动画奇偶规则一致
			local attachment = vm:GetAttachment(self:Clip1() % 2 + 3)
			if attachment then
				return attachment.Pos
			end
		end
	end
end
