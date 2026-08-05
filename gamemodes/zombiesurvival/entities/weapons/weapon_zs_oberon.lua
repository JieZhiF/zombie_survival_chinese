-- ============================================================================
-- weapon_zs_oberon.lua - 奥伯龙脉冲霰弹枪
-- 负责：发射脉冲能量的霰弹枪：每发 5 颗弹丸、命中僵尸附加脉冲腿部减速
--       （SLOWTYPE_PULSE），并带脉冲冲击特效与强化分支
-- ============================================================================
AddCSLuaFile()

-- 显示名称与描述
SWEP.PrintName = "'"..translate.Get("weapon_zs_oberon")
SWEP.Description = ""..translate.Get("weapon_zs_oberon_description")

if CLIENT then
	-- 武器栏：霰弹枪槽
	SWEP.Slot = GAMEMODE:GetWeaponSlot("WeaponSelectSlotShotguns")
	SWEP.SlotGroup = WEPSELECT_SHOTGUN
	SWEP.SlotPos = 0

	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 60

	-- HUD 3D 图标（大图标预览）参数
	SWEP.HUD3DBone = "ValveBiped.Gun"
	SWEP.HUD3DPos = Vector(2.12, -1, -8)
	SWEP.HUD3DScale = 0.025

	SWEP.ShowViewModel = true

	-- 视图模型拼装件
	SWEP.VElements = {
		["base+++"] = { type = "Model", model = "models/Items/boxflares.mdl", bone = "ValveBiped.Gun", rel = "", pos = Vector(-1.283, -2.158, 1.508), angle = Angle(90, -90, -90), size = Vector(0.437, 0.226, 0.446), color = Color(255, 255, 255, 255), surpresslightning = true, material = "models/error/new light1", skin = 0, bodygroup = {} },
		["base+"] = { type = "Model", model = "models/props_combine/combine_mortar01a.mdl", bone = "ValveBiped.Pump", rel = "", pos = Vector(-1.313, 1.697, -20.396), angle = Angle(0.476, 90, 0), size = Vector(0.172, 0.179, 0.256), color = Color(255, 147, 0, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["base++"] = { type = "Model", model = "models/props_combine/combinetrain01a.mdl", bone = "ValveBiped.Gun", rel = "", pos = Vector(0.197, 3.431, 3.428), angle = Angle(-90, 0, -90.676), size = Vector(0.071, 0.019, 0.025), color = Color(255, 180, 123, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}

	-- 世界模型拼装件
	SWEP.WElements = {
		["base++"] = { type = "Model", model = "models/props_combine/combinetrain01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(18.329, 1.085, -3.164), angle = Angle(175.024, 0.411, 0), size = Vector(0.037, 0.02, 0.017), color = Color(255, 180, 123, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["base+++"] = { type = "Model", model = "models/Items/boxflares.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(17.725, -0.431, -6.599), angle = Angle(6.518, 180, -90), size = Vector(0.277, 0.277, 0.469), color = Color(255, 255, 255, 255), surpresslightning = true, material = "models/error/new light1", skin = 0, bodygroup = {} },
		["base+"] = { type = "Model", model = "models/props_combine/combine_mortar01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(6.356, 0.796, -2.659), angle = Angle(-94.139, 1.621, 0), size = Vector(0.129, 0.136, 0.108), color = Color(255, 147, 0, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}
end

-- 注册自定义开火音效（高斯炮声，随机音高）
sound.Add(
{
	name = "Weapon_Oberon.Single",
	channel = CHAN_WEAPON,
	volume = 1.0,
	soundlevel = 100,
	pitch = {85, 92},
	sound = "weapons/gauss/fire1.wav"
})

SWEP.Base = "weapon_zs_baseshotgun"

-- 持枪姿势
SWEP.HoldType = "shotgun"

-- 模型与手臂
SWEP.ViewModel = "models/weapons/c_shotgun.mdl"
SWEP.WorldModel = "models/weapons/w_shotgun.mdl"
SWEP.UseHands = true

-- 关闭 CS 风格枪口闪光
SWEP.CSMuzzleFlashes = false

-- 每发 5 颗弹丸
SWEP.Primary.Sound = Sound("Weapon_Oberon.Single")
SWEP.Primary.Damage = 12
SWEP.Primary.NumShots = 5
SWEP.Primary.Delay = 0.8

-- 开火动画速度倍率
SWEP.FireAnimSpeed = 0.55

-- 弹匣（脉冲弹药）
SWEP.Primary.ClipSize = 7
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "pulse"
-- 武器类型：脉冲
SWEP.WeaponType = "pulse"
SWEP.Primary.DefaultClip = 30

-- 扩散
SWEP.ConeMax = 7.5
SWEP.ConeMin = 5

-- 换弹延迟
SWEP.ReloadDelay = 0.4

-- 移动速度
SWEP.WalkSpeed = SPEED_SLOWER

-- 子弹曳光
SWEP.TracerName = "AR2Tracer"

-- 泵动/换弹音效
SWEP.PumpSound = Sound("Weapon_Shotgun.Special1")
SWEP.ReloadSound = Sound("Weapon_Shotgun.Reload")

-- 腿部伤害与武器等级
SWEP.LegDamage = 9
SWEP.Tier = 3

-- 积分倍率（脉冲武器通用）
SWEP.PointsMultiplier = GAMEMODE.PulsePointsMultiplier

-- 强化：腿部伤害 +1
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_LEG_DAMAGE, 1)
-- ==== 强化分支 1：三连发脉冲霰弹 ====
-- 改为 21 发弹匣三连发模式，射速与换弹更快
GAMEMODE:AddNewRemantleBranch(SWEP, 1, ""..translate.Get("weapon_zs_oberon_r1"), ""..translate.Get("weapon_zs_oberon_r1_description"), function(wept)
	wept.RequiredClip = 3
	wept.Primary.ClipSize = 21
	wept.Primary.Delay = 0.6
	wept.ReloadDelay = 0.1
	wept.ReloadSound = Sound("npc/scanner/scanner_scan4.wav")

	-- 分支开火音效（电击声 + 高斯炮声）
	wept.EmitFireSound = function(self)
		self:EmitSound("weapons/stunstick/alyx_stunner2.wav", 72, 115, 0.65, CHAN_AUTO)
		self:EmitSound("weapons/gauss/fire1.wav", 72, 108, 0.65)
	end

	if CLIENT then
		-- 分支外观：信号盒灯光变青色
		wept.VElements["base+++"].color = Color(0, 255, 255)
	end
end)

-- ==== BulletCallback - 子弹命中回调 ====
-- 对命中的僵尸附加脉冲腿部伤害；客户端播放脉冲冲击特效
function SWEP.BulletCallback(attacker, tr, dmginfo)
	local ent = tr.Entity
	if ent:IsValidLivingZombie() then
		ent:AddLegDamageExt(dmginfo:GetInflictor().LegDamage, attacker, attacker:GetActiveWeapon(), SLOWTYPE_PULSE)
	end

	if IsFirstTimePredicted() then
		util.CreatePulseImpactEffect(tr.HitPos, tr.HitNormal)
	end
end

-- ==== EmitFireSound - 开火音效 ====
-- 主开火音 + 高频手枪声叠加
function SWEP:EmitFireSound()
	self:EmitSound(self.Primary.Sound)
	self:EmitSound("weapons/glock/glock18-1.wav", 75, math.random(162, 168), 0.7, CHAN_WEAPON + 20)
end
