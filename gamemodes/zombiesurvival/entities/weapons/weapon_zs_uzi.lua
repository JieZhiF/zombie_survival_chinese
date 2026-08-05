-- ============================================================================
-- weapon_zs_uzi.lua - 乌兹冲锋枪（SMG）
-- 负责：高射速冲锋枪属性、改装分支（弹匣减半 + 墙壁跳弹）
-- ============================================================================
AddCSLuaFile()

SWEP.PrintName = ""..translate.Get("weapon_zs_uzi") -- 武器显示名称
SWEP.Description = ""..translate.Get("weapon_zs_uzi_description") -- 武器描述

SWEP.SlotPos = 0 -- 武器栏中的槽位

if CLIENT then
	SWEP.Slot = GAMEMODE:GetWeaponSlot("WeaponSelectSlotSMGs") -- 冲锋枪武器栏
	SWEP.SlotGroup = WEPSELECT_SMG -- 武器选择组（冲锋枪）
	SWEP.ViewModelFlip = false -- 不翻转第一人称模型
	SWEP.ViewModelFOV = 50 -- 第一人称镜头大小

	SWEP.HUD3DBone = "v_weapon.mac10_bolt" -- 3D HUD 挂点骨骼（枪机）
	SWEP.HUD3DPos = Vector(-1.45, 1.25, 0) -- 3D HUD 位置偏移
	SWEP.HUD3DAng = Angle(0, 0, 0) -- 3D HUD 角度
	SWEP.HUD3DScale = 0.015 -- 3D HUD 缩放
end

SWEP.Base = "weapon_zs_base" -- 继承武器基础类

SWEP.HoldType = "pistol" -- 持枪姿势（手枪式）

SWEP.ViewModel = "models/weapons/cstrike/c_smg_mac10.mdl" -- 第一人称模型（MAC10）
SWEP.WorldModel = "models/weapons/w_smg_mac10.mdl" -- 第三人称模型
SWEP.UseHands = true -- 使用玩家手部模型

SWEP.Primary.Sound = Sound("Weapon_MAC10.Single") -- 开火音效
SWEP.Primary.Damage = 17 -- 单发伤害
SWEP.Primary.NumShots = 1 -- 一次射击的子弹数
SWEP.Primary.Delay = 0.075 -- 射击间隔（秒，极高射速）

SWEP.Primary.ClipSize = 35 -- 弹匣容量
SWEP.Primary.Automatic = true -- 全自动
SWEP.Primary.Ammo = "smg1" -- 消耗的弹药类型（冲锋枪弹药）
GAMEMODE:SetupDefaultClip(SWEP.Primary) -- 按游戏模式规则设置默认弹药

SWEP.Primary.Gesture = ACT_HL2MP_GESTURE_RANGE_ATTACK_SMG1 -- 开火动作手势
SWEP.ReloadGesture = ACT_HL2MP_GESTURE_RELOAD_SMG1 -- 换弹动作手势

SWEP.ConeMax = 5.5 -- 最大扩散
SWEP.ConeMin = 2.5 -- 最小扩散

SWEP.FireAnimSpeed = 1.5 -- 开火动画播放速度

SWEP.WalkSpeed = SPEED_NORMAL -- 持枪移动速度（正常）

SWEP.Tier = 2 -- 武器等级（2 级）

SWEP.IronSightsPos = Vector(-7, 15, 0) -- 机瞄时视角位置偏移
SWEP.IronSightsAng = Vector(3, -3, -10) -- 机瞄时视角角度偏移

-- 附加武器修饰符：降低扩散、弹匣容量 +3
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_MAX_SPREAD, -0.58, 1)
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_MIN_SPREAD, -0.27, 1)
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_CLIP_SIZE, 3, 1)
-- 添加改装分支：弹匣减半、射速提升，弹匣较少时子弹可穿墙反弹
GAMEMODE:AddNewRemantleBranch(SWEP, 1, ""..translate.Get("weapon_zs_uzi_r1"), ""..translate.Get("weapon_zs_uzi_r1_description"),function(wept)
	wept.Primary.ClipSize = math.floor(wept.Primary.ClipSize * 0.53)
	wept.Primary.Delay = 0.06

	-- 跳弹逻辑：沿入射方向反弹一发子弹
	local function DoRicochet(attacker, hitpos, hitnormal, normal, damage)
		attacker.RicochetBullet = true
		if attacker:IsValid() then
			attacker:FireBulletsLua(hitpos, 2 * hitnormal * hitnormal:Dot(normal * -1) + normal, 0, 1, damage, nil, nil, "tracer_rico", nil, nil, nil, nil, nil, attacker:GetActiveWeapon())
		end
		attacker.RicochetBullet = nil
	end
	-- 子弹命中回调：弹匣剩余不足 8 发时，命中墙面产生跳弹
	wept.BulletCallback = function(attacker, tr, dmginfo)
		if SERVER and tr.HitWorld and not tr.HitSky and attacker:GetActiveWeapon():Clip1() < 8 then
			local hitpos, hitnormal, normal, dmg = tr.HitPos, tr.HitNormal, tr.Normal, dmginfo:GetDamage() * 1.5
			timer.Simple(0, function() DoRicochet(attacker, hitpos, hitnormal, normal, dmg) end)
		end
	end
end)
