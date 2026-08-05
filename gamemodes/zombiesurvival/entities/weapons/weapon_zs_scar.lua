-- ============================================================================
-- weapon_zs_scar.lua - SCAR 突击步枪
-- 负责：全自动突击步枪，具有命中叠加系统（连续命中僵尸时准星越来越精准），
--       换弹时重置叠加；使用 SCK 自定义混凝土风格外观
-- ============================================================================
AddCSLuaFile()
-- 定义基类引用
DEFINE_BASECLASS("weapon_zs_base")

-- 武器显示名称与描述（本地化键）
SWEP.PrintName = ""..translate.Get("weapon_zs_scar")
SWEP.Description = ""..translate.Get("weapon_zs_scar_description")


-- 栏位内排序位置
SWEP.SlotPos = 0

if CLIENT then
	
    -- 武器栏位（突击步枪栏）
    SWEP.Slot = GAMEMODE:GetWeaponSlot("WeaponSelectSlotAssaultRifles")
-- 武器类型：步枪
SWEP.WeaponType = "rifle"
    -- 武器栏位分组（突击步枪）
    SWEP.SlotGroup = WEPSELECT_ASSAULT_RIFLE
	-- 第一人称视角设置
	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 60

	-- 重复设置（保持原样）
	SWEP.ViewModelFlip = false
	-- 隐藏原始模型，使用 SCK 元素自定义外观
	SWEP.ShowViewModel = false
	SWEP.ShowWorldModel = false

	-- 3D HUD 绘制参数（在 SG550 骨上绘制弹药信息）
	SWEP.HUD3DBone = "v_weapon.sg550_Parent"
	SWEP.HUD3DPos = Vector(-1.3, -5.56, -2)
	SWEP.HUD3DAng = Angle(0, 0, 0)
	SWEP.HUD3DScale = 0.02

	-- 第一人称视角模型元素（由大量混凝土风格道具拼装的自定义枪身外观）
	SWEP.VElements = {
		["base+++++"] = { type = "Model", model = "models/props_trainstation/trainstation_column001.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "base", pos = Vector(-0.399, -10.077, 0.458), angle = Angle(0, 0, -90), size = Vector(0.09, 0.09, 0.041), color = Color(200, 200, 200, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["base++++++++++++"] = { type = "Model", model = "models/props_phx/trains/tracks/track_2x.mdl", bone = "v_weapon.sg550_Parent", rel = "base", pos = Vector(-1.147, -5.325, 0.579), angle = Angle(0, 90, 90), size = Vector(0.019, 0.008, 0.029), color = Color(80, 80, 80, 255), surpresslightning = false, material = "phoenix_storms/concrete2", skin = 0, bodygroup = {} },
		["base++++++++++++++"] = { type = "Model", model = "models/hunter/blocks/cube025x2x025.mdl", bone = "v_weapon.sg550_Parent", rel = "base", pos = Vector(0.133, -6.993, -0.058), angle = Angle(0, 0, 0), size = Vector(0.093, 0.067, 0.109), color = Color(80, 80, 80, 255), surpresslightning = false, material = "phoenix_storms/concrete2", skin = 0, bodygroup = {} },
		["base++++"] = { type = "Model", model = "models/props_phx/trains/tracks/track_2x.mdl", bone = "v_weapon.sg550_Parent", rel = "base", pos = Vector(-0.431, -3.07, -1.063), angle = Angle(0, 90, 0), size = Vector(0.029, 0.004, 0.029), color = Color(80, 80, 80, 255), surpresslightning = false, material = "phoenix_storms/concrete2", skin = 0, bodygroup = {} },
		["mag"] = { type = "Model", model = "models/hunter/blocks/cube1x1x1.mdl", bone = "v_weapon.sg550_Clip", rel = "", pos = Vector(-0.03, 2.838, -0.187), angle = Angle(0, 0, 11.232), size = Vector(0.017, 0.14, 0.068), color = Color(80, 80, 80, 255), surpresslightning = false, material = "phoenix_storms/concrete2", skin = 0, bodygroup = {} },
		["base+++++++++++"] = { type = "Model", model = "models/hunter/blocks/cube1x1x025.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "base", pos = Vector(-0.401, 18.51, -1.601), angle = Angle(92.424, -90, 0), size = Vector(0.129, 0.028, 0.054), color = Color(80, 80, 80, 255), surpresslightning = false, material = "phoenix_storms/concrete1", skin = 0, bodygroup = {} },
		["base+++"] = { type = "Model", model = "models/hunter/blocks/cube025x2x025.mdl", bone = "v_weapon.sg550_Parent", rel = "base", pos = Vector(0, -5.474, -0.886), angle = Angle(0, 0, 0), size = Vector(0.074, 0.097, 0.078), color = Color(80, 80, 80, 255), surpresslightning = false, material = "phoenix_storms/concrete2", skin = 0, bodygroup = {} },
		["base++++++++++++++++"] = { type = "Model", model = "models/props_pipes/concrete_pipe001a.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "base", pos = Vector(-0.429, -10.79, 3.95), angle = Angle(-180, 90, 0), size = Vector(0.004, 0.009, 0.009), color = Color(80, 80, 80, 255), surpresslightning = false, material = "phoenix_storms/concrete2", skin = 0, bodygroup = {} },
		["base++"] = { type = "Model", model = "models/props_phx/trains/tracks/track_8x.mdl", bone = "v_weapon.sg550_Parent", rel = "base", pos = Vector(-0.431, -3.901, 2.5), angle = Angle(180, 90, 0), size = Vector(0.017, 0.004, 0.029), color = Color(80, 80, 80, 255), surpresslightning = false, material = "phoenix_storms/concrete1", skin = 0, bodygroup = {} },
		["base+++++++"] = { type = "Model", model = "models/weapons/w_pist_glock18.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "base", pos = Vector(-0.452, 7.76, -6.605), angle = Angle(0.172, 90, 0), size = Vector(1.18, 0.879, 1.059), color = Color(80, 80, 80, 255), surpresslightning = false, material = "phoenix_storms/concrete0", skin = 0, bodygroup = {} },
		["base+"] = { type = "Model", model = "models/hunter/blocks/cube025x2x025.mdl", bone = "v_weapon.sg550_Parent", rel = "base", pos = Vector(-0.11, 0, 1.697), angle = Angle(0, 0, 0), size = Vector(0.054, 0.214, 0.056), color = Color(80, 80, 80, 255), surpresslightning = false, material = "phoenix_storms/concrete2", skin = 0, bodygroup = {} },
		["base+++++++++++++++"] = { type = "Model", model = "models/props_combine/combinethumper002.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "base", pos = Vector(-0.581, 9.357, 2.319), angle = Angle(0, 0, 0), size = Vector(0.014, 0.012, 0.006), color = Color(80, 80, 80, 255), surpresslightning = false, material = "phoenix_storms/concrete2", skin = 0, bodygroup = {} },
		["base+++++++++++++++++"] = { type = "Model", model = "models/props_pipes/concrete_pipe001a.mdl", bone = "v_weapon.sg550_Chamber", rel = "", pos = Vector(-0.633, -0.877, -4.751), angle = Angle(-180, 0, 0), size = Vector(0.008, 0.004, 0.004), color = Color(80, 80, 80, 255), surpresslightning = false, material = "phoenix_storms/concrete2", skin = 0, bodygroup = {} },
		["base++++++"] = { type = "Model", model = "models/props_combine/combine_binocular01.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "base", pos = Vector(-0.429, -10.709, 2.403), angle = Angle(-180, 90, 0), size = Vector(0.104, 0.076, 0.054), color = Color(80, 80, 80, 255), surpresslightning = false, material = "phoenix_storms/concrete2", skin = 0, bodygroup = {} },
		["base"] = { type = "Model", model = "models/hunter/blocks/cube025x2x025.mdl", bone = "v_weapon.sg550_Parent", rel = "", pos = Vector(0.398, -4.837, -6.283), angle = Angle(0, 0, -90), size = Vector(0.074, 0.214, 0.142), color = Color(80, 80, 80, 255), surpresslightning = false, material = "phoenix_storms/concrete1", skin = 0, bodygroup = {} },
		["base+++++++++"] = { type = "Model", model = "models/Gibs/helicopter_brokenpiece_03.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "base", pos = Vector(-0.464, 12.635, -0.173), angle = Angle(13.321, 85.75, -18.448), size = Vector(0.123, 0.065, 0.14), color = Color(80, 80, 80, 255), surpresslightning = false, material = "phoenix_storms/concrete2", skin = 0, bodygroup = {} },
		["base++++++++"] = { type = "Model", model = "models/hunter/blocks/cube025x1x025.mdl", bone = "v_weapon.sg550_Parent", rel = "base", pos = Vector(0.05, 1.534, -2.869), angle = Angle(0, 0, 9.149), size = Vector(0.079, 0.082, 0.207), color = Color(80, 80, 80, 255), surpresslightning = false, material = "phoenix_storms/concrete0", skin = 0, bodygroup = {} },
		["base++++++++++"] = { type = "Model", model = "models/hunter/triangles/trapezium3x3x1c.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "base", pos = Vector(-0.401, 16.805, -1.68), angle = Angle(92.424, -90, 0), size = Vector(0.063, 0.027, 0.059), color = Color(80, 80, 80, 255), surpresslightning = false, material = "phoenix_storms/concrete1", skin = 0, bodygroup = {} },
		["base++++++++++++++++++"] = { type = "Model", model = "models/hunter/blocks/cube025x2x025.mdl", bone = "v_weapon.sg550_Parent", rel = "base", pos = Vector(-0.565, 1.32, 1.84), angle = Angle(0, 0, 0), size = Vector(0.02, 0.052, 0.029), color = Color(80, 80, 80, 255), surpresslightning = false, material = "phoenix_storms/concrete2", skin = 0, bodygroup = {} }
	}

	-- 世界模型元素（第三人称显示的混凝土风格枪身外观）
	SWEP.WElements = {
		["base+++++"] = { type = "Model", model = "models/props_trainstation/trainstation_column001.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(-0.399, -10.077, 0.458), angle = Angle(0, 0, -90), size = Vector(0.09, 0.09, 0.041), color = Color(200, 200, 200, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["base+++++++++++++"] = { type = "Model", model = "models/props_phx/trains/tracks/track_2x.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(0.282, -5.325, 0.579), angle = Angle(0, 90, -90), size = Vector(0.019, 0.008, 0.029), color = Color(80, 80, 80, 255), surpresslightning = false, material = "phoenix_storms/concrete2", skin = 0, bodygroup = {} },
		["base++++++++++++"] = { type = "Model", model = "models/props_phx/trains/tracks/track_2x.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(-1.147, -5.325, 0.579), angle = Angle(0, 90, 90), size = Vector(0.019, 0.008, 0.029), color = Color(80, 80, 80, 255), surpresslightning = false, material = "phoenix_storms/concrete2", skin = 0, bodygroup = {} },
		["base++++++++++++++"] = { type = "Model", model = "models/hunter/blocks/cube025x2x025.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(0.133, -6.993, -0.058), angle = Angle(0, 0, 0), size = Vector(0.093, 0.067, 0.109), color = Color(80, 80, 80, 255), surpresslightning = false, material = "phoenix_storms/concrete2", skin = 0, bodygroup = {} },
		["base++++"] = { type = "Model", model = "models/props_phx/trains/tracks/track_2x.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(-0.431, -3.07, -1.063), angle = Angle(0, 90, 0), size = Vector(0.029, 0.004, 0.029), color = Color(80, 80, 80, 255), surpresslightning = false, material = "phoenix_storms/concrete2", skin = 0, bodygroup = {} },
		["base+++++++++++"] = { type = "Model", model = "models/hunter/blocks/cube1x1x025.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(-0.401, 18.51, -1.601), angle = Angle(92.424, -90, 0), size = Vector(0.129, 0.028, 0.054), color = Color(80, 80, 80, 255), surpresslightning = false, material = "phoenix_storms/concrete1", skin = 0, bodygroup = {} },
		["base+++"] = { type = "Model", model = "models/hunter/blocks/cube025x2x025.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(0, -5.474, -0.886), angle = Angle(0, 0, 0), size = Vector(0.074, 0.097, 0.078), color = Color(80, 80, 80, 255), surpresslightning = false, material = "phoenix_storms/concrete2", skin = 0, bodygroup = {} },
		["base++++++++++++++++"] = { type = "Model", model = "models/props_pipes/concrete_pipe001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(-0.429, -10.79, 3.95), angle = Angle(-180, 90, 0), size = Vector(0.004, 0.009, 0.009), color = Color(80, 80, 80, 255), surpresslightning = false, material = "phoenix_storms/concrete2", skin = 0, bodygroup = {} },
		["base++"] = { type = "Model", model = "models/props_phx/trains/tracks/track_8x.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(-0.431, -3.901, 2.5), angle = Angle(180, 90, 0), size = Vector(0.017, 0.004, 0.029), color = Color(80, 80, 80, 255), surpresslightning = false, material = "phoenix_storms/concrete1", skin = 0, bodygroup = {} },
		["base+++++++"] = { type = "Model", model = "models/weapons/w_pist_glock18.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(-0.452, 7.76, -6.605), angle = Angle(0.172, 90, 0), size = Vector(1.18, 0.879, 1.059), color = Color(80, 80, 80, 255), surpresslightning = false, material = "phoenix_storms/concrete0", skin = 0, bodygroup = {} },
		["base+"] = { type = "Model", model = "models/hunter/blocks/cube025x2x025.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(-0.11, 0, 1.697), angle = Angle(0, 0, 0), size = Vector(0.054, 0.214, 0.056), color = Color(80, 80, 80, 255), surpresslightning = false, material = "phoenix_storms/concrete2", skin = 0, bodygroup = {} },
		["base+++++++++++++++"] = { type = "Model", model = "models/props_combine/combinethumper002.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(-0.581, 9.357, 2.319), angle = Angle(0, 0, 0), size = Vector(0.014, 0.012, 0.006), color = Color(80, 80, 80, 255), surpresslightning = false, material = "phoenix_storms/concrete2", skin = 0, bodygroup = {} },
		["base"] = { type = "Model", model = "models/hunter/blocks/cube025x2x025.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(11.472, 0.644, -4.957), angle = Angle(-180, -84.611, 9.975), size = Vector(0.074, 0.214, 0.142), color = Color(80, 80, 80, 255), surpresslightning = false, material = "phoenix_storms/concrete1", skin = 0, bodygroup = {} },
		["base++++++"] = { type = "Model", model = "models/props_combine/combine_binocular01.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(-0.429, -10.709, 2.403), angle = Angle(-180, 90, 0), size = Vector(0.104, 0.076, 0.054), color = Color(80, 80, 80, 255), surpresslightning = false, material = "phoenix_storms/concrete2", skin = 0, bodygroup = {} },
		["mag"] = { type = "Model", model = "models/hunter/blocks/cube1x1x1.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(-0.408, 1.106, -5.235), angle = Angle(0, 0, 102.095), size = Vector(0.017, 0.14, 0.068), color = Color(80, 80, 80, 255), surpresslightning = false, material = "phoenix_storms/concrete2", skin = 0, bodygroup = {} },
		["base+++++++++"] = { type = "Model", model = "models/Gibs/helicopter_brokenpiece_03.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(-0.464, 12.635, -0.173), angle = Angle(13.321, 85.75, -18.448), size = Vector(0.123, 0.065, 0.14), color = Color(80, 80, 80, 255), surpresslightning = false, material = "phoenix_storms/concrete2", skin = 0, bodygroup = {} },
		["base++++++++"] = { type = "Model", model = "models/hunter/blocks/cube025x1x025.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(0.05, 1.534, -2.869), angle = Angle(0, 0, 9.149), size = Vector(0.079, 0.082, 0.207), color = Color(80, 80, 80, 255), surpresslightning = false, material = "phoenix_storms/concrete0", skin = 0, bodygroup = {} },
		["base++++++++++"] = { type = "Model", model = "models/hunter/triangles/trapezium3x3x1c.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(-0.401, 16.805, -1.68), angle = Angle(92.424, -90, 0), size = Vector(0.063, 0.027, 0.059), color = Color(80, 80, 80, 255), surpresslightning = false, material = "phoenix_storms/concrete1", skin = 0, bodygroup = {} },
		["base++++++++++++++++++"] = { type = "Model", model = "models/hunter/blocks/cube025x2x025.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(-0.565, 1.32, 1.84), angle = Angle(0, 0, 0), size = Vector(0.02, 0.052, 0.029), color = Color(80, 80, 80, 255), surpresslightning = false, material = "phoenix_storms/concrete2", skin = 0, bodygroup = {} }
	}
end

-- 注册自定义开火音效（SCAR 射击音）
sound.Add(
{
	name = "Weapon_Scar.Single",
	channel = CHAN_WEAPON,
	volume = 1,
	level = 85,
	pitch = {85,90},
	sound = {"weapons/zs_scar/scar_fire1.ogg"}
})

-- 继承基础武器类
SWEP.Base = "weapon_zs_base"

-- 持握姿势：AR2（步枪）
SWEP.HoldType = "ar2"

-- 第一人称/世界模型（SG550 狙击步枪模型作为载体）
SWEP.ViewModel = "models/weapons/cstrike/c_snip_sg550.mdl"
SWEP.WorldModel = "models/weapons/w_snip_sg550.mdl"
-- 使用 C 模型手部
SWEP.UseHands = true

-- 主攻击设置：开火音效、伤害、子弹数、延迟
SWEP.Primary.Sound = Sound("Weapon_Scar.Single")
SWEP.Primary.Damage = 27.5
SWEP.Primary.NumShots = 1
SWEP.Primary.Delay = 0.1

-- 弹匣容量30发、全自动、AR2弹药
SWEP.Primary.ClipSize = 30
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "ar2"
-- 设置默认弹药（根据弹匣容量自动计算）
GAMEMODE:SetupDefaultClip(SWEP.Primary)

-- 开火与换弹手势动画
SWEP.Primary.Gesture = ACT_HL2MP_GESTURE_RANGE_ATTACK_AR2
SWEP.ReloadGesture = ACT_HL2MP_GESTURE_RELOAD_AR2

-- 准星扩散
SWEP.ConeMax = 3.5
SWEP.ConeMin = 1.4

-- 持有时的移动速度（慢）
SWEP.WalkSpeed = SPEED_SLOW

-- 武器等级与最大库存
SWEP.Tier = 5
SWEP.MaxStock = 2

-- 开火动画播放速度
SWEP.FireAnimSpeed = 0.65

-- 机瞄位置
SWEP.IronSightsPos = Vector(-7.361, 0, 0.62)

-- 武器修饰符：弹匣容量+3
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_CLIP_SIZE, 3)

-- ==== SetHitStacks - 设置命中叠加数（网络同步） ====
function SWEP:SetHitStacks(stacks)
	self:SetDTInt(9, stacks)
end

-- ==== GetHitStacks - 获取命中叠加数 ====
function SWEP:GetHitStacks()
	return self:GetDTInt(9)
end

-- ==== FinishReload - 换弹完成回调（重置命中叠加） ====
function SWEP:FinishReload()
	-- 换弹后重置命中叠加数
	self:SetHitStacks(0)
	-- 调用基类换弹完成逻辑
	BaseClass.FinishReload(self)
end

-- ==== GetCone - 获取当前准星扩散（命中叠加降低扩散） ====
function SWEP:GetCone()
	-- 基础扩散乘以(1 - 叠加数/35)，叠加越高扩散越小
	return BaseClass.GetCone(self) * (1 - self:GetHitStacks()/35)
end

-- ==== BulletCallback - 子弹命中回调（命中僵尸时增加叠加数） ====
function SWEP.BulletCallback(attacker, tr, dmginfo)
	local ent = tr.Entity
	if SERVER then
		local wep = attacker:GetActiveWeapon()
		-- 命中有效僵尸时增加命中叠加数
		if ent:IsValidZombie() then
			wep:SetHitStacks(wep:GetHitStacks() + 1)
		end
	end
end
