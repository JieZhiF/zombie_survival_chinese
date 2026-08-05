-- ============================================================================
-- weapon_zs_magnum.lua - 马格南左轮手枪
-- 负责：定义高伤害左轮属性；实现"弹射弹"强化分支（Branch 1）——子弹击中
--       墙面会反射弹射，命中僵尸越多次准星越集中；附带扩散/射速强化修饰符
-- ============================================================================
-- 全端加载（服务端 + 客户端）；定义父类引用（武器总基类）
AddCSLuaFile()
DEFINE_BASECLASS("weapon_zs_base")

-- 武器显示名称与描述（本地化文本）
SWEP.PrintName = ""..translate.Get("weapon_zs_magnum")
SWEP.Description = ""..translate.Get("weapon_zs_magnum_description")

-- 武器在槽位内的位置
SWEP.SlotPos = 0

if CLIENT then
-- 武器栏位（手枪槽）
SWEP.Slot = GAMEMODE:GetWeaponSlot("WeaponSelectSlotPistols")
-- 武器类型（手枪）
SWEP.WeaponType = "pistol"
	-- 武器选择组（手枪）
	SWEP.SlotGroup = WEPSELECT_PISTOL
	-- 模型方向与镜头视野
	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 60

	-- HUD 3D 预览的骨骼/位置/缩放
	SWEP.HUD3DBone = "Python"
	SWEP.HUD3DPos = Vector(0.85, 0, -2.5)
	SWEP.HUD3DScale = 0.015
end

-- 继承自武器总基类
SWEP.Base = "weapon_zs_base"

-- 持枪姿势（左轮式）
SWEP.HoldType = "revolver"

-- 第一人称/第三人称模型（借用 .357 左轮模型）
SWEP.ViewModel = "models/weapons/c_357.mdl"
SWEP.WorldModel = "models/weapons/w_357.mdl"
-- 使用玩家手部模型
SWEP.UseHands = true

-- 不使用 CS 风格枪口闪光
SWEP.CSMuzzleFlashes = false

-- 主攻击：左轮枪声、0.7 秒间隔、59 伤害、单发
SWEP.Primary.Sound = Sound("Weapon_357.Single")
SWEP.Primary.Delay = 0.7
SWEP.Primary.Damage = 59
SWEP.Primary.NumShots = 1

-- 弹匣 6 发、半自动、消耗手枪弹药、开火手势
SWEP.Primary.ClipSize = 6
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "pistol"
SWEP.Primary.Gesture = ACT_HL2MP_GESTURE_RANGE_ATTACK_PISTOL
-- 按游戏模式规则设置默认弹药
GAMEMODE:SetupDefaultClip(SWEP.Primary)

-- 武器等级
SWEP.Tier = 2

-- 扩散：最大/最小准星范围
SWEP.ConeMax = 3.75
SWEP.ConeMin = 2
-- 弹射伤害倍率（弹射弹继承伤害的比例）
SWEP.BounceMulti = 1.5

-- 机瞄时视图模型位置与角度偏移
SWEP.IronSightsPos = Vector(-4.65, 4, 0.25)
SWEP.IronSightsAng = Vector(0, 0, 1)

-- 附加武器强化修饰符：减小最大/最小扩散、缩减射速间隔（仅作用于第 1 强化分支）
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_MAX_SPREAD, -0.7, 1)
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_MIN_SPREAD, -0.35, 1)
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_FIRE_DELAY, -0.07, 1)
-- 注册"弹射弹"强化分支（Branch 1）：伤害降低 15%，但弹射伤害倍率提升，
-- 且弹射命中僵尸越多（DT 9 号位计数）准星越集中；换弹后重置计数
GAMEMODE:AddNewRemantleBranch(SWEP, 1, ""..translate.Get("weapon_zs_magnum_r1"), ""..translate.Get("weapon_zs_magnum_r1_description"), function(wept)
	wept.Primary.Damage = wept.Primary.Damage * 0.85
	wept.BounceMulti = 1.764
	-- 准星随弹射命中计数（DT 9 号位，上限 13）成比例收缩
	wept.GetCone = function(self)
		return BaseClass.GetCone(self) * (1 - self:GetDTInt(9)/13)
	end
	-- 换弹完成时清零弹射命中计数
	wept.FinishReload = function(self)
		self:SetDTInt(9, 0)
		BaseClass.FinishReload(self)
	end
end)

-- ==== DoRicochet - 生成反弹弹 ====
-- 在命中点沿镜面反射方向发射一颗反弹子弹；反弹弹命中僵尸时为 Branch 1 武器 +2 命中计数
local function DoRicochet(attacker, hitpos, hitnormal, normal, damage)
	local RicoCallback = function(att, tr, dmginfo)
		local ent = tr.Entity
		local wep = att:GetActiveWeapon()
		if wep.Branch == 1 and ent:IsValidZombie() then
			wep:SetDTInt(9, wep:GetDTInt(9) + 2)
		end
	end

	-- 标记当前子弹为反弹弹（供伤害路由识别），随后按反射方向发射
	attacker.RicochetBullet = true
	if attacker:IsValid() then
		attacker:FireBulletsLua(hitpos, 2 * hitnormal * hitnormal:Dot(normal * -1) + normal, 0, 1, damage, nil, nil, "tracer_rico", RicoCallback, nil, nil, nil, nil, attacker:GetActiveWeapon())
	end
	attacker.RicochetBullet = nil
end

-- ==== BulletCallback - 子弹命中回调：墙面弹射与僵尸命中计数 ====
function SWEP.BulletCallback(attacker, tr, dmginfo)
	local ent = tr.Entity
	-- 命中世界表面（非天空）：延迟一帧生成带弹射伤害倍率的反弹弹
	if SERVER and tr.HitWorld and not tr.HitSky then
		local hitpos, hitnormal, normal, dmg = tr.HitPos, tr.HitNormal, tr.Normal, dmginfo:GetDamage() * attacker:GetActiveWeapon().BounceMulti
		timer.Simple(0, function() DoRicochet(attacker, hitpos, hitnormal, normal, dmg) end)
	end

	-- Branch 1：直击命中僵尸时弹射命中计数 +1
	if SERVER then
		local wep = attacker:GetActiveWeapon()
		if wep.Branch == 1 and ent:IsValidZombie() then
			wep:SetDTInt(9, wep:GetDTInt(9) + 1)
		end
	end
end
