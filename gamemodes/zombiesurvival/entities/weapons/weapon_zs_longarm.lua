-- ============================================================================
-- weapon_zs_longarm.lua - 长臂左轮手枪
-- 负责：定义高伤害左轮手枪的属性、铁瞄参数、改造分支，
--       以及独特的"子弹弹跳"机制——击中世界表面后按反射方向再射一发
-- ============================================================================
AddCSLuaFile()

-- 武器显示名称与描述（本地化）
SWEP.PrintName = ""..translate.Get("weapon_zs_longarm")
SWEP.Description = ""..translate.Get("weapon_zs_longarm_description")

-- 武器栏位中的位置
SWEP.SlotPos = 0

if CLIENT then
-- 武器槽位：手枪类
SWEP.Slot = GAMEMODE:GetWeaponSlot("WeaponSelectSlotPistols")
SWEP.WeaponType = "pistol"
	SWEP.SlotGroup = WEPSELECT_PISTOL
	-- 视模型不翻转，第一人称镜头 FOV
	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 60

	-- 枪身 3D2D HUD 挂点（Python 骨骼）
	SWEP.HUD3DBone = "Python"
	SWEP.HUD3DPos = Vector(0.85, 0, -2.5)
	SWEP.HUD3DScale = 0.015

	-- 第三人称附加模型：金属枪管 + 握把盒
	SWEP.WElements = {
		["base"] = { type = "Model", model = "models/props_pipes/pipe02_straight01_short.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(23, 1, -6.5), angle = Angle(0, -90, -5), size = Vector(0.2, 1, 0.2), color = Color(75, 75, 75, 255), surpresslightning = false, material = "models/props_pipes/pipemetal004a", skin = 0, bodygroup = {} },
		["base+"] = { type = "Model", model = "models/props_lab/powerbox02c.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(0, 9, 3), angle = Angle(90, 90, 0), size = Vector(0.5, 0.2, 1), color = Color(155, 160, 165, 255), surpresslightning = false, material = "models/weapons/v_grenade/rim", skin = 0, bodygroup = {} }
	}

	-- 第一人称附加模型：挂在 Python 骨骼上的同款枪管 + 握把
	SWEP.VElements = {
		["base"] = { type = "Model", model = "models/props_pipes/pipe02_straight01_short.mdl", bone = "Python", rel = "", pos = Vector(0, -1.5, 16), angle = Angle(0, 0, 90), size = Vector(0.2, 1, 0.2), color = Color(75, 75, 75, 255), surpresslightning = false, material = "models/props_pipes/pipemetal004a", skin = 0, bodygroup = {} },
		["base+"] = { type = "Model", model = "models/props_lab/powerbox02c.mdl", bone = "Python", rel = "base", pos = Vector(0, 9, 3), angle = Angle(90, 90, 0), size = Vector(0.5, 0.2, 1), color = Color(155, 160, 165, 255), surpresslightning = false, material = "models/weapons/v_grenade/rim", skin = 0, bodygroup = {} }
	}
end

-- 继承通用武器基底
SWEP.Base = "weapon_zs_base"

-- 持枪姿势：左轮
SWEP.HoldType = "revolver"

-- 视/世界模型（左轮），使用玩家手臂
SWEP.ViewModel = "models/weapons/c_357.mdl"
SWEP.WorldModel = "models/weapons/w_357.mdl"
SWEP.UseHands = true

-- 不绘制 CS 样式枪口闪光
SWEP.CSMuzzleFlashes = false

-- 主攻击：自定义开火音效、单发伤害与射击间隔
SWEP.Primary.Sound = Sound("weapons/zs_longarm/longarm_fire.ogg")
SWEP.Primary.Delay = 0.73
SWEP.Primary.Damage = 120
SWEP.Primary.NumShots = 1

-- 弹匣 10 发，至少 2 发才能换弹，半自动，消耗手枪弹药
SWEP.Primary.ClipSize = 10
SWEP.RequiredClip = 2
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "pistol"
-- 射击手势动画
SWEP.Primary.Gesture = ACT_HL2MP_GESTURE_RANGE_ATTACK_PISTOL
-- 按默认规则设置初始弹匣（使用基底配置的默认弹量）
GAMEMODE:SetupDefaultClip(SWEP.Primary)

-- 持枪移动速度（慢速档）
SWEP.WalkSpeed = SPEED_SLOW

-- 扩散范围（最大/最小准星）
SWEP.ConeMax = 3.75
SWEP.ConeMin = 1.65

-- 武器等级与商店最大库存
SWEP.Tier = 4
SWEP.MaxStock = 3

-- 铁瞄（机瞄）偏移
SWEP.IronSightsPos = Vector(-4.65, 4, 0.25)
SWEP.IronSightsAng = Vector(0, 0, 1)

-- 弹跳后伤害衰减除数
SWEP.WallDivide = 6

-- 附加武器修改器：收窄最大/最小扩散、缩短射击间隔
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_MAX_SPREAD, -0.468)
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_MIN_SPREAD, -0.206)
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_FIRE_DELAY, -0.075, 1)
-- 改造分支：降伤害 30%、提速 32%、扩容至 16 发、弹跳衰减降低（更多弹跳伤害）
GAMEMODE:AddNewRemantleBranch(SWEP, 1, ""..translate.Get("weapon_zs_longarm_r1"), ""..translate.Get("weapon_zs_longarm_r1_description"), function(wept)
	wept.Primary.Damage = wept.Primary.Damage * 0.7
	wept.Primary.Delay = wept.Primary.Delay * 0.68
	wept.Primary.ClipSize = 16
	wept.WallDivide = 8
end)

-- ==== DoRicochet - 弹跳射击：以反射方向再发射一发衰减伤害的子弹 ====
local function DoRicochet(attacker, hitpos, hitnormal, normal, damage)
	-- 标记当前子弹为弹跳弹（防止无限递归弹跳）
	attacker.RicochetBullet = true
	if attacker:IsValid() then
		local aw = attacker:GetActiveWeapon()
		-- 反射方向 = 入射方向的镜面反射；伤害按 WallDivide 衰减，带弹跳曳光
		attacker:FireBulletsLua(hitpos, 2 * hitnormal * hitnormal:Dot(normal * -1) + normal, 5, 6, damage / aw.WallDivide, nil, nil, "tracer_rico", nil, nil, nil, nil, nil, aw)
	end
	attacker.RicochetBullet = nil
end
-- ==== BulletCallback - 子弹命中回调：命中世界表面（非天空）时延迟一帧触发弹跳 ====
function SWEP.BulletCallback(attacker, tr, dmginfo)
	if SERVER and tr.HitWorld and not tr.HitSky then
		local hitpos, hitnormal, normal, dmg = tr.HitPos, tr.HitNormal, tr.Normal, dmginfo:GetDamage()
		-- 下一帧再弹跳，避免在子弹回调内部嵌套发射
		timer.Simple(0, function() DoRicochet(attacker, hitpos, hitnormal, normal, dmg) end)
	end
end
