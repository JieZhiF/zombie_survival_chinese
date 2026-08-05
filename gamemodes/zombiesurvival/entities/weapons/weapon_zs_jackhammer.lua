-- ============================================================================
-- weapon_zs_jackhammer.lua - 杰克锤（全自动霰弹枪）
-- 负责：12 号全自动霰弹枪属性、自定义拼装模型、改装分支（三倍弹丸）
-- ============================================================================
AddCSLuaFile()

SWEP.PrintName = ""..translate.Get("weapon_zs_jackhammer") -- 武器显示名称
SWEP.Description = ""..translate.Get("weapon_zs_jackhammer_description") -- 武器描述

if CLIENT then
	SWEP.Slot = GAMEMODE:GetWeaponSlot("WeaponSelectSlotShotguns") -- 霰弹枪武器栏
	SWEP.SlotGroup = WEPSELECT_SHOTGUN -- 武器选择组（霰弹枪）
	SWEP.SlotPos = 0 -- 武器栏中的槽位

	SWEP.ViewModelFlip = false -- 不翻转第一人称模型
	SWEP.ViewModelFOV = 59 -- 第一人称镜头大小

	SWEP.HUD3DBone = "v_weapon.galil" -- 3D HUD 挂点骨骼
	SWEP.HUD3DPos = Vector(1.3, -0.3, 2) -- 3D HUD 位置偏移
	SWEP.HUD3DScale = 0.018 -- 3D HUD 缩放

	-- 第一人称自定义拼装模型部件（管道/零件拼成霰弹枪外观）
	SWEP.VElements = {
		["t4_shot_part+++++++"] = { type = "Model", model = Model("models/props_pipes/concrete_pipe001a.mdl"), bone = "ValveBiped.Bip01_R_Hand", rel = "t4_shot_part+", pos = Vector(0, 11, 1.5), angle = Angle(90, 0, 0), size = Vector(0.032, 0.009, 0.009), color = Color(30, 30, 30, 255), surpresslightning = false, material = "models/props_pipes/pipemetal001a", skin = 0, bodygroup = {} },
		["t4_shot_part++++++"] = { type = "Model", model = Model("models/props_pipes/pipe02_straight01_long.mdl"), bone = "ValveBiped.Bip01_R_Hand", rel = "t4_shot_part+", pos = Vector(0, 13, -0.801), angle = Angle(0, 0, 0), size = Vector(0.17, 0.55, 0.17), color = Color(40, 40, 40, 255), surpresslightning = false, material = "models/props_pipes/pipemetal001a", skin = 0, bodygroup = {} },
		["t4_shot_part++++"] = { type = "Model", model = Model("models/props_wasteland/controlroom_filecabinet002a.mdl"), bone = "ValveBiped.Bip01_R_Hand", rel = "t4_shot_part+", pos = Vector(0, -13, 0.618), angle = Angle(0, 0, 100), size = Vector(0.039, 0.15, 0.009), color = Color(60, 60, 60, 255), surpresslightning = false, material = "phoenix_storms/metalfloor_2-3", skin = 0, bodygroup = {} },
		["t4_shot_part+++"] = { type = "Model", model = Model("models/props_junk/ibeam01a_cluster01.mdl"), bone = "ValveBiped.Bip01_R_Hand", rel = "t4_shot_part+", pos = Vector(0, -7.301, 0.66), angle = Angle(180, -90, 0), size = Vector(0.059, 0.029, 0.039), color = Color(47, 22, 1, 255), surpresslightning = false, material = "models/props_pipes/pipemetal004a", skin = 0, bodygroup = {} },
		["t4_shot_part++"] = { type = "Model", model = Model("models/props_combine/combine_interface003.mdl"), bone = "ValveBiped.Bip01_R_Hand", rel = "t4_shot_part+", pos = Vector(0, -6.301, 2.799), angle = Angle(180, -90, 0), size = Vector(0.059, 0.022, 0.059), color = Color(79, 100, 135, 255), surpresslightning = false, material = "models/props_pipes/pipeset_metal", skin = 0, bodygroup = {} },
		["t4_shot_part+++++"] = { type = "Model", model = Model("models/props_wasteland/laundry_washer001a.mdl"), bone = "v_weapon.magazine", rel = "", pos = Vector(0, -0.801, 3), angle = Angle(0, 0, 0), size = Vector(0.054, 0.054, 0.07), color = Color(50, 50, 50, 255), surpresslightning = false, material = "models/props_canal/canal_bridge_railing_01c", skin = 0, bodygroup = {} },
		["t4_shot_part+"] = { type = "Model", model = Model("models/props_combine/combine_train02a.mdl"), bone = "ValveBiped.Bip01_R_Hand", rel = "t4_shot_part", pos = Vector(24.5, 4.38, -4.1), angle = Angle(180, 90, 0), size = Vector(0.013, 0.024, 0.009), color = Color(60, 60, 60, 255), surpresslightning = false, material = "models/props_pipes/pipemetal001a", skin = 0, bodygroup = {} },
		["t4_shot_part"] = { type = "Model", model = Model("models/weapons/c_pistol.mdl"), bone = "v_weapon.galil", rel = "", pos = Vector(4.4, -5, -19.8), angle = Angle(90, 0, -90), size = Vector(0.8, 0.8, 1.21), color = Color(60, 60, 60, 255), surpresslightning = false, material = "models/props_pipes/pipemetal001a", skin = 0, bodygroup = {} }
	}

	-- 第三人称自定义拼装模型部件（挂在右手骨骼上）
	SWEP.WElements = {
		["t4_shot_part++++++"] = { type = "Model", model = Model("models/props_pipes/pipe02_straight01_long.mdl"), bone = "ValveBiped.Bip01_R_Hand", rel = "t4_shot_part+", pos = Vector(0, 13, -0.801), angle = Angle(0, 0, 0), size = Vector(0.17, 0.3, 0.17), color = Color(30, 30, 30, 255), surpresslightning = false, material = "models/props_pipes/pipemetal001a", skin = 0, bodygroup = {} },
		["t4_shot_part+++++++"] = { type = "Model", model = Model("models/props_pipes/concrete_pipe001a.mdl"), bone = "ValveBiped.Bip01_R_Hand", rel = "t4_shot_part+", pos = Vector(0, 11, 1.5), angle = Angle(90, 0, 0), size = Vector(0.032, 0.009, 0.009), color = Color(30, 30, 30, 255), surpresslightning = false, material = "models/props_pipes/pipemetal001a", skin = 0, bodygroup = {} },
		["t4_shot_part++++"] = { type = "Model", model = Model("models/props_wasteland/controlroom_filecabinet002a.mdl"), bone = "ValveBiped.Bip01_R_Hand", rel = "t4_shot_part+", pos = Vector(0, -13, 0.618), angle = Angle(0, 0, 100), size = Vector(0.039, 0.15, 0.009), color = Color(60, 60, 60, 255), surpresslightning = false, material = "phoenix_storms/metalfloor_2-3", skin = 0, bodygroup = {} },
		["t4_shot_part+++"] = { type = "Model", model = Model("models/props_junk/ibeam01a_cluster01.mdl"), bone = "ValveBiped.Bip01_R_Hand", rel = "t4_shot_part+", pos = Vector(0, -7.301, 0.66), angle = Angle(180, -90, 0), size = Vector(0.059, 0.029, 0.039), color = Color(47, 22, 1, 255), surpresslightning = false, material = "models/props_pipes/pipemetal004a", skin = 0, bodygroup = {} },
		["t4_shot_part++"] = { type = "Model", model = Model("models/props_combine/combine_interface003.mdl"), bone = "ValveBiped.Bip01_R_Hand", rel = "t4_shot_part+", pos = Vector(0, -6.301, 2.799), angle = Angle(180, -90, 0), size = Vector(0.059, 0.029, 0.059), color = Color(79, 100, 135, 255), surpresslightning = false, material = "models/props_pipes/pipeset_metal", skin = 0, bodygroup = {} },
		["t4_shot_part+++++"] = { type = "Model", model = Model("models/props_wasteland/laundry_washer001a.mdl"), bone = "ValveBiped.Bip01_R_Hand", rel = "t4_shot_part+", pos = Vector(0, 5, 2), angle = Angle(0, 0, 90), size = Vector(0.054, 0.054, 0.07), color = Color(50, 50, 50, 255), surpresslightning = false, material = "models/props_canal/canal_bridge_railing_01c", skin = 0, bodygroup = {} },
		["t4_shot_part+"] = { type = "Model", model = Model("models/props_combine/combine_train02a.mdl"), bone = "ValveBiped.Bip01_R_Hand", rel = "t4_shot_part", pos = Vector(-3.636, 0, 0.699), angle = Angle(0, 90, 180), size = Vector(0.013, 0.024, 0.009), color = Color(50, 50, 50, 255), surpresslightning = false, material = "models/props_pipes/pipemetal001a", skin = 0, bodygroup = {} },
		["t4_shot_part"] = { type = "Model", model = Model("models/weapons/w_pistol.mdl"), bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(3, 1, -4.5), angle = Angle(0, 180, 180), size = Vector(0.8, 0.8, 1.21), color = Color(50, 50, 50, 255), surpresslightning = false, material = "models/props_pipes/pipemetal001a", skin = 0, bodygroup = {} }
	}

	-- 调整左手握枪角度
	SWEP.ViewModelBoneMods = {
		["ValveBiped.Bip01_L_Hand"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(0, 0, 21) }
	}
end

SWEP.Base = "weapon_zs_base" -- 继承武器基础类

SWEP.HoldType = "shotgun" -- 持枪姿势（霰弹枪）

SWEP.ShowViewModel = false -- 不显示默认第一人称模型（使用自定义部件拼装）
SWEP.ShowWorldModel = false -- 不显示默认第三人称模型
SWEP.ViewModel = "models/weapons/cstrike/c_rif_galil.mdl" -- 第一人称动画模型
SWEP.WorldModel = "models/weapons/w_rif_galil.mdl" -- 第三人称动画模型
SWEP.UseHands = true -- 使用玩家手部模型

SWEP.Primary.Sound = Sound("weapons/xm1014/xm1014-1.wav") -- 开火音效（XM1014）
SWEP.ReloadSound = Sound("Weapon_Deagle.Clipout") -- 换弹音效
SWEP.Primary.Damage = 10.5 -- 单发弹丸伤害
SWEP.Primary.NumShots = 8 -- 每次射击的弹丸数
SWEP.Primary.Delay = 0.31 -- 射击间隔（秒）

SWEP.Primary.ClipSize = 12 -- 弹匣容量
SWEP.Primary.Automatic = true -- 全自动
SWEP.Primary.Ammo = "buckshot" -- 消耗的弹药类型（霰弹）
GAMEMODE:SetupDefaultClip(SWEP.Primary) -- 按游戏模式规则设置默认弹药

SWEP.ConeMax = 9 -- 最大扩散
SWEP.ConeMin = 6.5 -- 最小扩散

SWEP.ReloadSpeed = 0.65 -- 换弹速度倍率

SWEP.WalkSpeed = SPEED_SLOWEST -- 持枪移动速度（最慢）

SWEP.Tier = 4 -- 武器等级（4 级）
SWEP.MaxStock = 3 -- 商店最大库存


-- 附加武器修饰符：降低最大/最小扩散
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_MAX_SPREAD, -1.125)
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_MIN_SPREAD, -0.81)
-- 添加改装分支：弹丸数×3、射速降低、每发消耗 3 弹药并加大后坐力与扩散
GAMEMODE:AddNewRemantleBranch(SWEP, 1, ""..translate.Get("weapon_zs_jackhammer_r1"), ""..translate.Get("weapon_zs_jackhammer_r1_description"), function(wept)
	wept.Primary.NumShots = wept.Primary.NumShots * 3
	wept.Primary.Delay = wept.Primary.Delay * 3.3
	wept.Primary.Damage = wept.Primary.Damage * 1.1
	wept.RequiredClip = 3
	wept.Recoil = 10

	wept.ConeMin = wept.ConeMin * 1.4
	wept.ConeMax = wept.ConeMax * 1.2

	-- 改装分支自定义开火音效（低沉）
	wept.EmitFireSound = function(self)
		self:EmitSound(self.Primary.Sound, 75, math.random(87, 89), 0.75)
		self:EmitSound("weapons/shotgun/shotgun_fire6.wav", 75, math.random(102, 108), 0.65, CHAN_WEAPON + 20)
	end
end)

-- ==== EmitFireSound - 播放开火音效（高亢双音效） ====
function SWEP:EmitFireSound()
	self:EmitSound(self.Primary.Sound, 75, math.random(147, 153), 0.7)
	self:EmitSound("weapons/shotgun/shotgun_fire6.wav", 75, math.random(132, 138), 0.6, CHAN_WEAPON + 20)
end

-- ==== SecondaryAttack - 禁用右键 ====
function SWEP:SecondaryAttack()
end
