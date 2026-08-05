-- ============================================================================
-- weapon_zs_quicksilver.lua - 水银（G3SG1 狙击步枪）
-- 负责：高伤害半自动狙击、开镜瞄准/狙击镜 HUD、强化分支
-- ============================================================================
-- 注册为共享文件（客户端与服务端都加载）
AddCSLuaFile()
-- 定义基类（供 BaseClass 调用）
DEFINE_BASECLASS("weapon_zs_base")

-- 武器名称 / 描述（本地化）
SWEP.PrintName = ""..translate.Get("weapon_zs_quicksilver")
SWEP.Description = ""..translate.Get("weapon_zs_quicksilver_description")


-- 武器栏中的位置
SWEP.SlotPos = 0

if CLIENT then
	-- 客户端专属：武器槽位（步枪槽）
	SWEP.Slot = GAMEMODE:GetWeaponSlot("WeaponSelectSlotRifles")
	-- 武器类型与槽位分组（单行多语句，保持原样）
SWEP.WeaponType = "rifle"	SWEP.SlotGroup = WEPSELECT_RIFLE
	-- 第一人称模型不翻转
	SWEP.ViewModelFlip = false

	-- 武器栏 3D 预览：骨骼 / 位置 / 角度 / 缩放
	SWEP.HUD3DBone = "v_weapon.g3sg1_Parent"
	SWEP.HUD3DPos = Vector(-1.2, -5.75, -1)
	SWEP.HUD3DAng = Angle(0, 0, 0)
	SWEP.HUD3DScale = 0.015
end

-- 继承基础武器
SWEP.Base = "weapon_zs_base"

-- 持枪姿势（AR2 步枪姿势）
SWEP.HoldType = "ar2"

-- 第一人称 / 第三人称模型
SWEP.ViewModel = "models/weapons/cstrike/c_snip_g3sg1.mdl"
SWEP.WorldModel = "models/weapons/w_snip_g3sg1.mdl"
-- 使用玩家自己的手臂模型
SWEP.UseHands = true

-- 开火音效 / 单发伤害 / 单次射击弹数 / 射击间隔
SWEP.Primary.Sound = Sound("Weapon_G3SG1.Single")
SWEP.Primary.Damage = 78.5
SWEP.Primary.NumShots = 1
SWEP.Primary.Delay = 0.38

-- 弹匣容量 / 半自动 / 弹药类型
SWEP.Primary.ClipSize = 10
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "357"
-- 按游戏模式规则设置初始弹匣
GAMEMODE:SetupDefaultClip(SWEP.Primary)

-- 开火动作手势 / 换弹动作手势
SWEP.Primary.Gesture = ACT_HL2MP_GESTURE_RANGE_ATTACK_CROSSBOW
SWEP.ReloadGesture = ACT_HL2MP_GESTURE_RELOAD_SHOTGUN

-- 扩散：站定后逐渐收敛至 0（狙击枪特性）
SWEP.ConeMax = 6.5
SWEP.ConeMin = 0

-- 机瞄位置与角度
SWEP.IronSightsPos = Vector(11, -9, -2.2)
SWEP.IronSightsAng = Vector(0, 0, 0)

-- 持枪移动速度（慢速）
SWEP.WalkSpeed = SPEED_SLOW

-- 武器等级（Tier 4）/ 携带上限
SWEP.Tier = 4
SWEP.MaxStock = 3

-- 强化词条：射击间隔 -0.05 秒
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_FIRE_DELAY, -0.05)
-- 强化分支（散射连发）：伤害降为 1/5，但一次发射 6 颗子弹，最小扩散 3
GAMEMODE:AddNewRemantleBranch(SWEP, 1, ""..translate.Get("weapon_zs_quicksilver_r1"), ""..translate.Get("weapon_zs_quicksilver_r1_description"), function(wept)
	wept.Primary.Damage = wept.Primary.Damage / 5 
	wept.Primary.NumShots = 6
	wept.ConeMin = 3
end)

-- ==== IsScoped - 判断是否已完成开镜 ====
-- 进入机瞄并经过 0.25 秒后视为已开镜
function SWEP:IsScoped()
	return self:GetIronsights() and self.fIronTime and self.fIronTime + 0.25 <= CurTime()
end
-- 标记为狙击步枪（系统对狙击枪的通用处理）
SWEP.SniperRifle = true
if CLIENT then
	-- 客户端专属：机瞄缩放倍率
	SWEP.IronsightsMultiplier = 0.25

	-- ==== GetViewModelPosition - 开镜时锁定第一人称视角 ====
	function SWEP:GetViewModelPosition(pos, ang)
		-- 游戏模式禁用狙击镜时恢复默认
		if GAMEMODE.DisableScopes then return end

		-- 开镜期间返回 nil（保持当前镜头位置，模拟狙击镜）
		if self:IsScoped() then return end

		return BaseClass.GetViewModelPosition(self, pos, ang)
	end

	-- ==== DrawHUDBackground - 开镜时绘制狙击镜黑幕 ====
	function SWEP:DrawHUDBackground()
		if GAMEMODE.DisableScopes then return end

		-- 已开镜时绘制圆形狙击镜遮罩
		if self:IsScoped() then
			self:DrawRegularScope()
		end
	end
end
