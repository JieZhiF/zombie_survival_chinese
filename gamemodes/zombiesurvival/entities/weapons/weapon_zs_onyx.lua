-- ============================================================================
-- weapon_zs_onyx.lua - 黑曜石（SG550 改造狙击步枪，SCK 模型拼装外观）
-- 负责：狙击属性定义（高伤害慢射速/6 发弹匣/机瞄狙击镜）、开火音效、
--       机瞄判定（IsScoped）与客户端狙击镜绘制
-- ============================================================================

-- 共享文件：客户端也需要下载本文件
AddCSLuaFile()
-- 声明基类，供 BaseClass 调用
DEFINE_BASECLASS("weapon_zs_base")

-- 武器显示名与描述（走翻译表）
SWEP.PrintName = ""..translate.Get("weapon_zs_onyx")
SWEP.Description = ""..translate.Get("weapon_zs_onyx_description")

-- 武器选择栏中的位置序号
SWEP.SlotPos = 0

-- 客户端专属属性（槽位、SCK 模型元素）
if CLIENT then
	-- 武器栏位（步枪位）
	SWEP.Slot = GAMEMODE:GetWeaponSlot("WeaponSelectSlotRifles")
-- 武器类型为步枪，归入步枪选择组（原代码为单行多语句，保持原样）
SWEP.WeaponType = "rifle"	SWEP.SlotGroup = WEPSELECT_RIFLE
	-- 不翻转视图模型
	SWEP.ViewModelFlip = false

	-- 3D 图标（HUD 商店展示）挂在视图模型父骨骼上
	SWEP.HUD3DBone = "v_weapon.sg550_Parent"
	SWEP.HUD3DPos = Vector(-1, -5.2, -2)
	SWEP.HUD3DAng = Angle(0, 0, 0)
	SWEP.HUD3DScale = 0.02

	-- SCK 视图模型元素：用多个道具模型拼装出"黑曜石"枪身（svu 系列组件）
	SWEP.VElements = {
		["svu++"] = { type = "Model", model = "models/props_wasteland/gaspump001a.mdl", bone = "v_weapon.sg550_Parent", rel = "svu", pos = Vector(2, 0, 0.5), angle = Angle(-90, 0, 73.636), size = Vector(0.029, 0.059, 0.1), color = Color(49, 54, 52, 255), surpresslightning = false, material = "models/props_pipes/pipemetal001a", skin = 0, bodygroup = {} },
		["svu+++++++"] = { type = "Model", model = "models/hunter/tubes/tube1x1x2.mdl", bone = "v_weapon.sg550_Parent", rel = "svu", pos = Vector(9, -2.6, 0.5), angle = Angle(90, 0, 0), size = Vector(0.034, 0.034, 0.034), color = Color(90, 85, 75, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
		["svu+++"] = { type = "Model", model = "models/props_wasteland/laundry_washer001a.mdl", bone = "v_weapon.sg550_Parent", rel = "svu", pos = Vector(-2, 0.6, 0.5), angle = Angle(92.337, -90, -90), size = Vector(0.019, 0.039, 0.15), color = Color(69, 94, 138, 255), surpresslightning = false, material = "models/props_pipes/pipeset_metal", skin = 0, bodygroup = {} },
		["svu++++++++++"] = { type = "Model", model = "models/hunter/blocks/cube1x1x1.mdl", bone = "v_weapon.sg550_Clip", rel = "", pos = Vector(0, 1.6, 0.5), angle = Angle(0, 0, 11), size = Vector(0.013, 0.109, 0.068), color = Color(27, 31, 34, 255), surpresslightning = false, material = "phoenix_storms/concrete2", skin = 0, bodygroup = {} },
		["svu++++++++++++"] = { type = "Model", model = "models/props_junk/ibeam01a.mdl", bone = "v_weapon.sg550_Parent", rel = "svu", pos = Vector(2.5, -1, 0.5), angle = Angle(0, 0, 90), size = Vector(0.009, 0.09, 0.15), color = Color(128, 113, 94, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
		["svu+++++++++++"] = { type = "Model", model = "models/props_wasteland/laundry_washer001a.mdl", bone = "v_weapon.sg550_Parent", rel = "svu", pos = Vector(11, 0.6, 0.5), angle = Angle(92.337, -90, -90), size = Vector(0.017, 0.035, 0.14), color = Color(85, 113, 160, 255), surpresslightning = false, material = "models/props_pipes/pipeset_metal", skin = 0, bodygroup = {} },
		["svu"] = { type = "Model", model = "models/props_phx/torpedo.mdl", bone = "v_weapon.sg550_Parent", rel = "", pos = Vector(0.6, -5, -3), angle = Angle(90, 0, 0), size = Vector(0.15, 0.09, 0.05), color = Color(80, 78, 85, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["svu++++"] = { type = "Model", model = "models/props_wasteland/laundry_washer001a.mdl", bone = "v_weapon.sg550_Parent", rel = "svu", pos = Vector(-14, 0, 0.5), angle = Angle(92.337, -90, -90), size = Vector(0.019, 0.019, 0.15), color = Color(74, 94, 138, 255), surpresslightning = false, material = "models/props_pipes/pipeset_metal", skin = 0, bodygroup = {} },
		["svu+++++++++++++"] = { type = "Model", model = "models/props_junk/ibeam01a.mdl", bone = "v_weapon.sg550_Parent", rel = "svu", pos = Vector(6.5, -1, 0.5), angle = Angle(0, 0, 90), size = Vector(0.009, 0.09, 0.15), color = Color(128, 113, 94, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
		["svu++++++"] = { type = "Model", model = "models/hunter/tubes/tube1x1x2.mdl", bone = "v_weapon.sg550_Parent", rel = "svu", pos = Vector(6, -2.6, 0.5), angle = Angle(90, 0, 0), size = Vector(0.029, 0.029, 0.09), color = Color(161, 163, 132, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
		["svu+++++++++"] = { type = "Model", model = "models/XQM/panel360.mdl", bone = "v_weapon.sg550_Parent", rel = "svu", pos = Vector(9.5, -2.6, 0.5), angle = Angle(0, 0, 0), size = Vector(0.029, 0.029, 0.029), color = Color(25, 33, 51, 255), surpresslightning = false, material = "models/props/cs_office/snowmana", skin = 0, bodygroup = {} },
		["svu++++++++"] = { type = "Model", model = "models/hunter/tubes/tube1x1x2.mdl", bone = "v_weapon.sg550_Parent", rel = "svu", pos = Vector(9.5, -2.6, 0.5), angle = Angle(90, 0, 0), size = Vector(0.037, 0.037, 0.009), color = Color(72, 67, 62, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
		["svu+"] = { type = "Model", model = "models/props_wasteland/gaspump001a.mdl", bone = "v_weapon.sg550_Parent", rel = "svu", pos = Vector(13, 0, 0.5), angle = Angle(-90, 0, 90), size = Vector(0.05, 0.119, 0.059), color = Color(49, 44, 49, 255), surpresslightning = false, material = "models/props_pipes/pipemetal001a", skin = 0, bodygroup = {} },
		["svu+++++"] = { type = "Model", model = "models/props_wasteland/prison_flourescentlight001a.mdl", bone = "v_weapon.sg550_Parent", rel = "svu", pos = Vector(4, -0.741, 0.5), angle = Angle(90, 0, 90), size = Vector(0.119, 0.119, 0.039), color = Color(176, 170, 153, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} }
	}

	-- SCK 世界模型元素：第三人称下的"黑曜石"拼装外观（与视图模型组件对应）
	SWEP.WElements = {
		["svu++"] = { type = "Model", model = "models/props_wasteland/gaspump001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "svu", pos = Vector(2, 0, 0.5), angle = Angle(-90, 0, 73.636), size = Vector(0.029, 0.059, 0.1), color = Color(49, 54, 52, 255), surpresslightning = false, material = "models/props_pipes/pipemetal001a", skin = 0, bodygroup = {} },
		["svu+++++++"] = { type = "Model", model = "models/hunter/tubes/tube1x1x2.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "svu", pos = Vector(9, -2.6, 0.5), angle = Angle(90, 0, 0), size = Vector(0.034, 0.034, 0.034), color = Color(90, 85, 75, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
		["svu+++"] = { type = "Model", model = "models/props_wasteland/laundry_washer001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "svu", pos = Vector(-2, 0.6, 0.5), angle = Angle(92.337, -90, -90), size = Vector(0.019, 0.039, 0.15), color = Color(69, 94, 138, 255), surpresslightning = false, material = "models/props_pipes/pipeset_metal", skin = 0, bodygroup = {} },
		["svu+++++"] = { type = "Model", model = "models/props_wasteland/prison_flourescentlight001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "svu", pos = Vector(4, -0.741, 0.5), angle = Angle(90, 0, 90), size = Vector(0.119, 0.119, 0.039), color = Color(176, 170, 153, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
		["svu+"] = { type = "Model", model = "models/props_wasteland/gaspump001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "svu", pos = Vector(13, 0, 0.5), angle = Angle(-90, 0, 90), size = Vector(0.05, 0.119, 0.059), color = Color(49, 44, 49, 255), surpresslightning = false, material = "models/props_pipes/pipemetal001a", skin = 0, bodygroup = {} },
		["svu++++++++++"] = { type = "Model", model = "models/hunter/blocks/cube1x1x1.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "svu", pos = Vector(-1, 2, 0.25), angle = Angle(90, 0, 11), size = Vector(0.013, 0.109, 0.068), color = Color(27, 31, 34, 255), surpresslightning = false, material = "phoenix_storms/concrete2", skin = 0, bodygroup = {} },
		["svu"] = { type = "Model", model = "models/props_phx/torpedo.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(6.5, 0, -4), angle = Angle(171.817, 0, 90), size = Vector(0.15, 0.09, 0.05), color = Color(80, 78, 85, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["svu++++"] = { type = "Model", model = "models/props_wasteland/laundry_washer001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "svu", pos = Vector(-14, 0, 0.5), angle = Angle(92.337, -90, -90), size = Vector(0.019, 0.019, 0.159), color = Color(74, 94, 138, 255), surpresslightning = false, material = "models/props_pipes/pipeset_metal", skin = 0, bodygroup = {} },
		["svu+++++++++++++"] = { type = "Model", model = "models/props_junk/ibeam01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "svu", pos = Vector(6.5, -1, 0.5), angle = Angle(0, 0, 90), size = Vector(0.009, 0.09, 0.15), color = Color(128, 113, 94, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
		["svu++++++"] = { type = "Model", model = "models/hunter/tubes/tube1x1x2.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "svu", pos = Vector(6, -2.6, 0.5), angle = Angle(90, 0, 0), size = Vector(0.029, 0.029, 0.09), color = Color(161, 163, 132, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
		["svu+++++++++"] = { type = "Model", model = "models/XQM/panel360.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "svu", pos = Vector(9.5, -2.6, 0.5), angle = Angle(0, 0, 0), size = Vector(0.029, 0.029, 0.029), color = Color(25, 33, 51, 255), surpresslightning = false, material = "models/props/cs_office/snowmana", skin = 0, bodygroup = {} },
		["svu++++++++"] = { type = "Model", model = "models/hunter/tubes/tube1x1x2.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "svu", pos = Vector(9.5, -2.6, 0.5), angle = Angle(90, 0, 0), size = Vector(0.037, 0.037, 0.009), color = Color(72, 67, 62, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
		["svu++++++++++++"] = { type = "Model", model = "models/props_junk/ibeam01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "svu", pos = Vector(2.5, -1, 0.5), angle = Angle(0, 0, 90), size = Vector(0.009, 0.09, 0.15), color = Color(128, 113, 94, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
		["svu+++++++++++"] = { type = "Model", model = "models/props_wasteland/laundry_washer001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "svu", pos = Vector(11, 0.6, 0.5), angle = Angle(92.337, -90, -90), size = Vector(0.017, 0.035, 0.14), color = Color(85, 113, 160, 255), surpresslightning = false, material = "models/props_pipes/pipeset_metal", skin = 0, bodygroup = {} }
	}
end

-- 隐藏原始视图/世界模型（外观完全由 SCK 元素拼装）
SWEP.ShowViewModel = false
SWEP.ShowWorldModel = false

-- 继承基础武器基类（武器母本）
SWEP.Base = "weapon_zs_base"

-- 持枪姿势（AR2 步枪姿势）
SWEP.HoldType = "ar2"

-- 使用 SG550 的视图/世界模型作为骨架
SWEP.ViewModel = "models/weapons/cstrike/c_snip_sg550.mdl"
SWEP.WorldModel = "models/weapons/w_snip_sg550.mdl"
SWEP.UseHands = true

-- 主攻击：SG550 枪声、单发伤害 86.5、1 秒射击间隔
SWEP.Primary.Sound = Sound("weapons/sg550/sg550-1.wav")
SWEP.Primary.Damage = 86.5
SWEP.Primary.NumShots = 1
SWEP.Primary.Delay = 1

-- 弹匣 6 发、全自动、使用 357 弹药；默认弹量由 SetupDefaultClip 按规则补满
SWEP.Primary.ClipSize = 6
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "357"
GAMEMODE:SetupDefaultClip(SWEP.Primary)

-- 射击/换弹的全身手势（弩射击手势 + 霰弹枪换弹手势）
SWEP.Primary.Gesture = ACT_HL2MP_GESTURE_RANGE_ATTACK_CROSSBOW
SWEP.ReloadGesture = ACT_HL2MP_GESTURE_RELOAD_SHOTGUN

-- 扩散：最大 6.5，站立机瞄可缩至 0（狙击精度）
SWEP.ConeMax = 6.5
SWEP.ConeMin = 0

-- 机瞄（瞄准镜）位置
SWEP.IronSightsPos = Vector(11, -9, -2.2)
SWEP.IronSightsAng = Vector(0, 0, 0)

-- 持枪移动速度（慢速）
SWEP.WalkSpeed = SPEED_SLOWER

-- 武器等级 3、狙击小口径曳光弹、开火动画速度
SWEP.Tier = 3
SWEP.TracerName = "tracer_sniper_small"
SWEP.FireAnimSpeed = 0.6

-- 武器强化修饰器：开火延迟 -0.1 秒（第一级）
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_FIRE_DELAY, -0.1, 1)

-- ==== EmitFireSound - 播放开火音效（主枪声 + 高音协奏） ====
function SWEP:EmitFireSound()
	self:EmitSound(self.Primary.Sound, 77, 75, 1)
	self:EmitSound("weapons/sg552/sg552-1.wav", 70, 185, 0.95, CHAN_AUTO)
end

-- ==== IsScoped - 机瞄保持 0.25 秒后进入狙击镜状态 ====
function SWEP:IsScoped()
	return self:GetIronsights() and self.fIronTime and self.fIronTime + 0.25 <= CurTime()
end
-- 标记为狙击步枪（走通用狙击镜 UI）
SWEP.SniperRifle = true
-- 客户端：狙击镜画面参数与镜内视图模型处理
if CLIENT then
	-- 机瞄时视场角倍率（放大效果）
	SWEP.IronsightsMultiplier = 0.25

	-- ==== GetViewModelPosition - 狙击状态下隐藏视图模型（避免遮挡镜头） ====
	function SWEP:GetViewModelPosition(pos, ang)
		-- 服务器禁用狙击镜时不干预
		if GAMEMODE.DisableScopes then return end

		-- 狙击中：不返回位置即隐藏视图模型
		if self:IsScoped() then return end

		-- 其余情况走基类默认位置
		return BaseClass.GetViewModelPosition(self, pos, ang)
	end

	-- ==== DrawHUDBackground - 机瞄狙击时绘制狙击镜画面 ====
	function SWEP:DrawHUDBackground()
		if GAMEMODE.DisableScopes then return end

		if self:IsScoped() then
			self:DrawRegularScope()
		end
	end
end
