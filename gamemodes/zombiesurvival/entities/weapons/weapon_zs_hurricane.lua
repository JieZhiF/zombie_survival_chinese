-- ============================================================================
-- weapon_zs_hurricane.lua - 飓风脉冲步枪（SMG1 造型脉冲武器）
-- 负责：定义全自动脉冲步枪属性、"蓄能过载"改装分支（按住开火蓄能增伤）
--       以及命中僵尸时的腿部减速效果
-- ============================================================================

-- 客户端共享加载声明（本文件双端加载）
AddCSLuaFile()

-- 武器显示名称（本地化）
SWEP.PrintName = ""..translate.Get("weapon_zs_hurricane")
-- 武器商店中的描述文本（本地化）
SWEP.Description = ""..translate.Get("weapon_zs_hurricane_description")

-- 客户端专用属性：栏位分组与拼装模型外观
if CLIENT then

	-- 武器栏位：冲锋枪栏
	SWEP.Slot = GAMEMODE:GetWeaponSlot("WeaponSelectSlotSMGs")
	SWEP.SlotGroup = WEPSELECT_SMG	
	SWEP.SlotPos = 0

	-- HUD 3D 预览图标：挂在根骨骼上
	SWEP.HUD3DBone = "ValveBiped.base"
	SWEP.HUD3DPos = Vector(2.2, -0.85, 1)
	SWEP.HUD3DScale = 0.02

	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 60

	-- 第一人称附加模型：用零件拼装出黄色科幻枪身
	SWEP.VElements = {
		["base"] = { type = "Model", model = "models/props_combine/combine_train02a.mdl", bone = "ValveBiped.base", rel = "", pos = Vector(0, -0.301, 4.731), angle = Angle(0, 180, 90), size = Vector(0.025, 0.025, 0.014), color = Color(255, 228, 0, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["base+++"] = { type = "Model", model = "models/props_c17/light_domelight01_off.mdl", bone = "ValveBiped.base", rel = "", pos = Vector(0.559, -1.04, -3.651), angle = Angle(-90, -164.752, 0), size = Vector(0.043, 0.037, 0.052), color = Color(255, 255, 255, 255), surpresslightning = true, material = "models/error/new light1", skin = 0, bodygroup = {} },
		["base+"] = { type = "Model", model = "models/props_combine/eli_pod_inner.mdl", bone = "ValveBiped.base", rel = "", pos = Vector(0.079, -2.368, -6.355), angle = Angle(-0.703, -90.113, 0), size = Vector(0.12, 0.075, 0.116), color = Color(255, 204, 0, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["base++"] = { type = "Model", model = "models/props_combine/combine_teleportplatform.mdl", bone = "ValveBiped.base", rel = "", pos = Vector(-0.002, -0.489, -8.968), angle = Angle(0, -90, -0), size = Vector(0.056, 0.019, 0.052), color = Color(255, 209, 0, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}

	-- 第三人称附加模型：同样的枪身，供他人视角显示
	SWEP.WElements = {
		["base+++"] = { type = "Model", model = "models/props_c17/light_domelight01_off.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(2.773, 2.071, -5.448), angle = Angle(0, 0, -80.556), size = Vector(0.043, 0.037, 0.052), color = Color(255, 255, 255, 255), surpresslightning = true, material = "models/error/new light1", skin = 0, bodygroup = {} },
		["base++++"] = { type = "Model", model = "models/props_c17/light_domelight01_off.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(2.69, 0.799, -5.528), angle = Angle(0, 0, 80.789), size = Vector(0.043, 0.037, 0.052), color = Color(255, 255, 255, 255), surpresslightning = true, material = "models/error/new light1", skin = 0, bodygroup = {} },
		["base++"] = { type = "Model", model = "models/props_combine/combine_teleportplatform.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(-1.594, 1.468, -3.698), angle = Angle(103.306, 180, 0), size = Vector(0.056, 0.019, 0.052), color = Color(255, 209, 0, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["base"] = { type = "Model", model = "models/props_combine/combine_train02a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(10.47, 1.462, -6.394), angle = Angle(-175.984, -88.995, 11.291), size = Vector(0.025, 0.019, 0.014), color = Color(255, 228, 0, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["base+"] = { type = "Model", model = "models/props_combine/eli_pod_inner.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(-0.541, 1.491, -6.099), angle = Angle(98.305, 179.197, 0), size = Vector(0.12, 0.075, 0.116), color = Color(255, 204, 0, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}
end

-- 注册自定义开火音效：低沉的 AR2 枪声（音调随机 70-80）
sound.Add(
{
	name = "Weapon_Hurricane.Single",
	channel = CHAN_WEAPON,
	volume = 0.7,
	soundlevel = 100,
	pitch = {70,80},
	sound = {"weapons/ar2/fire1.wav"}
})

-- 继承武器基础类
SWEP.Base = "weapon_zs_base"
DEFINE_BASECLASS("weapon_zs_base")

-- 持枪姿势：冲锋枪
SWEP.HoldType = "smg"

-- 第一人称视角模型（SMG1）
SWEP.ViewModel = "models/weapons/c_smg1.mdl"
-- 第三人称世界模型
SWEP.WorldModel = "models/weapons/w_smg1.mdl"
-- 使用玩家手臂模型握持
SWEP.UseHands = true

-- 不使用 CS 样式枪口闪光
SWEP.CSMuzzleFlashes = false

-- 换弹音效与开火音效
SWEP.ReloadSound = Sound("Weapon_SMG1.Reload")
SWEP.Primary.Sound = Sound("Weapon_Hurricane.Single")
-- 单发伤害
SWEP.Primary.Damage = 12.5
-- 每次射击的子弹数量
SWEP.Primary.NumShots = 1
-- 射击间隔（高射速）
SWEP.Primary.Delay = 0.12

-- 弹匣容量
SWEP.Primary.ClipSize = 35
-- 全自动射击
SWEP.Primary.Automatic = true
-- 使用的弹药类型：脉冲弹药
SWEP.Primary.Ammo = "pulse"
-- 武器类型：脉冲
SWEP.WeaponType = "pulse"
-- 按游戏规则填充默认备弹
GAMEMODE:SetupDefaultClip(SWEP.Primary)

-- 子弹曳光效果
SWEP.TracerName = "AR2Tracer"

-- 开火与换弹时播放的姿态动作
SWEP.Primary.Gesture = ACT_HL2MP_GESTURE_RANGE_ATTACK_SMG1
SWEP.ReloadGesture = ACT_HL2MP_GESTURE_RELOAD_SMG1

-- 换弹动画速度倍率
SWEP.ReloadSpeed = 0.9

-- 扩散范围：最大/最小准星
SWEP.ConeMax = 4.5
SWEP.ConeMin = 2.5

-- 手持移动速度（正常）
SWEP.WalkSpeed = SPEED_NORMAL

-- 武器等级
SWEP.Tier = 2

-- 得分倍率（脉冲武器加成）
SWEP.PointsMultiplier = GAMEMODE.PulsePointsMultiplier

-- 机瞄时的准星偏移
SWEP.IronSightsPos = Vector(-6.425, 5, 1.02)

-- 附加改装：最大/最小扩散降低、弹匣容量 +1
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_MAX_SPREAD, -0.5375, 1)
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_MIN_SPREAD, -0.3125, 1)
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_CLIP_SIZE, 1, 1)
-- 注册"蓄能过载"改装分支：伤害降低 20%、射速大幅降低，但持续开火会蓄能（DT 浮点 9），
-- 蓄能越高射速越快且伤害越高
GAMEMODE:AddNewRemantleBranch(SWEP, 1, ""..translate.Get("weapon_zs_hurricane_r1"), ""..translate.Get("weapon_zs_hurricane_r1_description"), function(wept)
	wept.Primary.Damage = wept.Primary.Damage * 0.8
	wept.Primary.Delay = wept.Primary.Delay * 2.3
	wept.ConeMax = wept.ConeMax * 0.5
	wept.ConeMin = wept.ConeMin * 0.7

	-- 开火间隔随蓄能等级缩短（最高 -15%）
	wept.GetFireDelay = function(self) return BaseClass.GetFireDelay(self) - (self:GetDTFloat(9) * 0.15) end
	-- 伤害随蓄能等级提升（最高 +60%）
	wept.ShootBullets = function(self, dmg, numbul, cone)
		dmg = dmg + dmg * self:GetDTFloat(9) * 0.6

		BaseClass.ShootBullets(self, dmg, numbul, cone)
	end

	-- 每帧更新蓄能等级：持续按住开火且非换弹收尾时缓慢蓄能，否则快速衰减
	wept.Think = function(self)
		if self:GetReloadFinish() == 0 and self:GetOwner():KeyDown(IN_ATTACK) then
			self:SetDTFloat(9, math.min(self:GetDTFloat(9) + FrameTime() * 0.12, 1))
		else
			self:SetDTFloat(9, math.max(0, self:GetDTFloat(9) - FrameTime() * 0.5))
		end

		BaseClass.Think(self)
	end
end)

-- ==== BulletCallback - 子弹命中回调（僵尸腿部减速 + 脉冲特效） ====
function SWEP.BulletCallback(attacker, tr, dmginfo)
	local ent = tr.Entity
	-- 命中僵尸玩家时施加腿部伤害（脉冲减速）
	if ent:IsValid() and ent:IsPlayer() and ent:Team() == TEAM_UNDEAD then
		ent:AddLegDamageExt(3.6, attacker, attacker:GetActiveWeapon(), SLOWTYPE_PULSE)
	end

	-- 仅预测端播放命中脉冲特效
	if IsFirstTimePredicted() then
		util.CreatePulseImpactEffect(tr.HitPos, tr.HitNormal)
	end
end
