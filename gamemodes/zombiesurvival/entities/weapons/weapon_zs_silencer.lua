-- ============================================================================
-- weapon_zs_silencer.lua - 消音冲锋枪（TMP 消音型）
-- 负责：高速低伤害的消音冲锋枪；拥有"静默光环"（GetAuraRange），
--       在光环范围内不会被僵尸感知到（配合游戏模式逻辑）
-- ============================================================================
AddCSLuaFile() -- 将该文件同时发送到客户端

-- 武器显示名称（本地化）
SWEP.PrintName =  ""..translate.Get("weapon_zs_silencer")
-- 武器描述（本地化）
SWEP.Description = ""..translate.Get("weapon_zs_silencer_description")

-- 武器在栏位中的位置序号
SWEP.SlotPos = 0

if CLIENT then -- 客户端专属设置

	-- 武器栏位：放入"冲锋枪"分类
	SWEP.Slot = GAMEMODE:GetWeaponSlot("WeaponSelectSlotSMGs")
	-- 栏位组：冲锋枪栏
	SWEP.SlotGroup = WEPSELECT_SMG
	SWEP.ViewModelFlip = false -- 不翻转第一人称模型
	SWEP.ViewModelFOV = 60 -- 第一人称视野大小

	-- HUD 3D 武器展示图：绑定骨骼与位置/角度/缩放
	SWEP.HUD3DBone = "v_weapon.TMP_Parent"
	SWEP.HUD3DPos = Vector(-1, -3.5, -1)
	SWEP.HUD3DAng = Angle(0, 0, 0)
	SWEP.HUD3DScale = 0.015
end

-- 继承武器母本
SWEP.Base = "weapon_zs_base"

-- 手持姿势：手枪姿势
SWEP.HoldType = "pistol"

-- 第一人称模型（TMP 冲锋枪）
SWEP.ViewModel = "models/weapons/cstrike/c_smg_tmp.mdl"
-- 世界模型
SWEP.WorldModel = "models/weapons/w_smg_tmp.mdl"
SWEP.UseHands = true -- 使用玩家手臂模型握持

SWEP.Primary.Sound = Sound("Weapon_TMP.Single") -- 开火音效
SWEP.Primary.Damage = 20 -- 单发伤害
SWEP.Primary.NumShots = 1 -- 每次射击的子弹数
SWEP.Primary.Delay = 0.06 -- 射击间隔（射速极快）

SWEP.Primary.ClipSize = 25 -- 弹匣容量
SWEP.Primary.Automatic = true -- 全自动
SWEP.Primary.Ammo = "smg1" -- 弹药类型：冲锋枪弹药
GAMEMODE:SetupDefaultClip(SWEP.Primary) -- 按游戏模式规则设置默认备弹

SWEP.ReloadSpeed = 0.72 -- 换弹速度倍率
SWEP.FireAnimSpeed = 3 -- 开火动画播放速度

-- 开火与换弹时的肢体手势动画
SWEP.Primary.Gesture = ACT_HL2MP_GESTURE_RANGE_ATTACK_SMG1
SWEP.ReloadGesture = ACT_HL2MP_GESTURE_RELOAD_SMG1

SWEP.ConeMax = 6.5 -- 最大扩散（移动中射击）
SWEP.ConeMin = 3.6 -- 最小扩散（静止射击）

SWEP.WalkSpeed = SPEED_NORMAL -- 手持时正常移动速度

SWEP.Tier = 3 -- 武器等级（3 级武器）

SWEP.IronSightsPos = Vector(-7, 3, 2.5) -- 机瞄时视角位置

-- 附加武器修正：降低最大/最小扩散（比白板更精准）
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_MAX_SPREAD, -0.8125)
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_MIN_SPREAD, -0.45)

-- ==== GetAuraRange - 获取静默光环范围 ====
-- 512 单位内开枪不会引起僵尸注意
function SWEP:GetAuraRange()
	return 512
end
