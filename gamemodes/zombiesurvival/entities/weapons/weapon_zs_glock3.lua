-- ============================================================================
-- weapon_zs_glock3.lua - Glock18 三连发手枪
-- 负责：定义三连发手枪的基础属性、扩散参数与两个改造分支（短连发收割 / 单发重型）
-- ============================================================================

-- 注册为共享文件（客户端也需加载）
AddCSLuaFile()

-- 武器显示名称
SWEP.PrintName = ""..translate.Get("weapon_zs_glock3")
-- 武器描述
SWEP.Description = ""..translate.Get("weapon_zs_glock3_description")


-- 武器选择槽内位置 0
SWEP.SlotPos = 0

if CLIENT then
-- 武器槽位：手枪类
SWEP.Slot = GAMEMODE:GetWeaponSlot("WeaponSelectSlotPistols")
-- 武器类型：手枪
SWEP.WeaponType = "pistol"
	-- 武器选择分组：手枪
	SWEP.SlotGroup = WEPSELECT_PISTOL
	-- 第一人称镜头视野
	SWEP.ViewModelFOV = 50
	-- 不翻转第一人称模型
	SWEP.ViewModelFlip = false

	-- HUD 3D 模型挂点：滑套骨骼
	SWEP.HUD3DBone = "v_weapon.Glock_Slide"
	-- HUD 3D 模型偏移位置
	SWEP.HUD3DPos = Vector(5, 0.25, -0.8)
	-- HUD 3D 模型旋转角度
	SWEP.HUD3DAng = Angle(90, 0, 0)
end

-- 换弹时骨骼调整表（当前为空）
SWEP.ViewModelBoneMods_Reload={

}
-- 母本：基础武器
SWEP.Base = "weapon_zs_base"

-- 持枪姿势：手枪
SWEP.HoldType = "pistol"

-- 第一人称模型（CS 的 Glock18）
SWEP.ViewModel = "models/weapons/cstrike/c_pist_glock18.mdl"
-- 世界模型
SWEP.WorldModel = "models/weapons/w_pist_glock18.mdl"
-- 使用玩家手臂模型
SWEP.UseHands = true

-- 开火音效
SWEP.Primary.Sound = Sound("Weapon_Glock.Single")
-- 单发伤害
SWEP.Primary.Damage = 15.5
-- 每次开火射出 3 发（三连发）
SWEP.Primary.NumShots = 3
-- 射击间隔 0.3 秒
SWEP.Primary.Delay = 0.3

-- 弹匣容量 7 发
SWEP.Primary.ClipSize = 7
-- 半自动（需手动连点）
SWEP.Primary.Automatic = false
-- 消耗手枪弹药
SWEP.Primary.Ammo = "pistol"
-- 按游戏模式规则设置默认弹匣
GAMEMODE:SetupDefaultClip(SWEP.Primary)

-- 最大扩散（移动/跳跃时）
SWEP.ConeMax = 4.5
-- 最小扩散（静止瞄准时）
SWEP.ConeMin = 3

-- 武器等级 2
SWEP.Tier = 2

-- 机瞄位置偏移
SWEP.IronSightsPos = Vector(-5.75, 10, 2.7)
-- 第一人称模型骨骼调整表（保持默认姿态）
SWEP.ViewModelBoneMods={
    ["ValveBiped.Bip01_L_UpperArm"]={scale=Vector(1,1,1),pos=Vector(0,0,0),angle=Angle(0,0,0)},
    ["ValveBiped.Bip01_L_Forearm"]={scale=Vector(1,1,1),pos=Vector(0,0,0),angle=Angle(0,0,0)},
    ["ValveBiped.Bip01_R_UpperArm"]={scale=Vector(1,1,1),pos=Vector(0,0,0),angle=Angle(0,0,0)},
    ["ValveBiped.Bip01_R_Hand"] = { scale = Vector(1, 1, 1), pos = Vector(0,0,0), angle = Angle(0,0,0) },
	["v_weapon.Glock_Parent"] = { scale = Vector(1,1,1), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) }
}
	
-- 附加武器强化修改器：最大扩散 -0.9
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_MAX_SPREAD, -0.9, 1)
-- 附加武器强化修改器：最小扩散 -0.5
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_MIN_SPREAD, -0.5, 1)
-- 附加武器强化修改器：弹匣容量 +1
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_CLIP_SIZE, 1, 1)
-- 改造分支 1：短连发收割——2 连发、伤害提升，命中僵尸有几率叠加"收割者"状态
GAMEMODE:AddNewRemantleBranch(SWEP, 1, ""..translate.Get("weapon_zs_glock3_r1"), ""..translate.Get("weapon_zs_glock3_r1_description"), function(wept)
	-- 每轮射出 2 发
	wept.Primary.NumShots = 2
	-- 单发伤害提升 20%
	wept.Primary.Damage = wept.Primary.Damage * 1.2
	-- 扩散大幅降低（更精准）
	wept.ConeMin = wept.ConeMin * 0.65
	wept.ConeMax = wept.ConeMax * 0.65

	-- 子弹命中回调：5% 几率给僵尸叠加"收割者"状态（最多 3 层，音调随层数升高）
	wept.BulletCallback = function(attacker, tr, dmginfo)
		if SERVER and tr.Entity:IsValidLivingZombie() and math.random(20) == 1 then
			-- 给予 14 秒的收割者状态
			local status = attacker:GiveStatus("reaper", 14)
			if status and status:IsValid() then
				-- 叠加层数（上限 3）
				status:SetDTInt(1, math.min(status:GetDTInt(1) + 1, 3))
				-- 播放吸取音效，音调随层数升高
				attacker:EmitSound("hl1/ambience/particle_suck1.wav", 55, 150 + status:GetDTInt(1) * 30, 0.45)
			end
		end
	end
end)
-- 改造分支 2：单发重型——改为大威力单发狙击手枪，附带大量外观附件与光环效果
local branch = GAMEMODE:AddNewRemantleBranch(SWEP, 2, ""..translate.Get("weapon_zs_glock3_r2"), ""..translate.Get("weapon_zs_glock3_r2_description"), function(wept)
	-- 改为单发
	wept.Primary.NumShots = 1
	-- 单发伤害提升至 2.3 倍
	wept.Primary.Damage = wept.Primary.Damage * 2.3
	-- 射速加快（间隔 0.2 秒）
	wept.Primary.Delay = 0.2
	-- 散布大幅降低（精确射击）
	wept.ConeMin = wept.ConeMin * 0.3
	wept.ConeMax = wept.ConeMax * 0.4
	-- 更换为 USP 开火音效
	wept.Primary.Sound = Sound("weapons/usp/usp1.wav")

	-- 第一人称附加模型（炮管、尖刺、消音器等金属改装件）
	wept.VElements = {
		["detail"] = { type = "Model", model = "models/Mechanics/wheels/wheel_extruded_48.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "bottom2", pos = Vector(0, -1.64, 0), angle = Angle(0, 0, -90), size = Vector(0.014, 0.014, 0.014), color = Color(190, 190, 190, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
		["bottom2+"] = { type = "Model", model = "models/props_junk/gascan001a.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "bottom2", pos = Vector(0, 0.889, 0.976), angle = Angle(0, 0, 0), size = Vector(0.15, 0.268, 0.029), color = Color(190, 190, 190, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
		["barrel"] = { type = "Model", model = "models/props_borealis/bluebarrel001.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "bottom2", pos = Vector(0.039, -2.02, -1.951), angle = Angle(-90, -90, 0), size = Vector(0.041, 0.041, 0.013), color = Color(190, 190, 190, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
		["spikes"] = { type = "Model", model = "models/props_phx/gears/rack9.mdl", bone = "v_weapon.Glock_Slide", rel = "", pos = Vector(1.583, -0.04, -0.08), angle = Angle(102.149, -90, 0), size = Vector(0.072, 0.082, 0.063), color = Color(190, 190, 190, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
		["silencer2"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "bottom2", pos = Vector(0.039, -2.26, -1.951), angle = Angle(90, -90, 0), size = Vector(0.043, 0.043, 0.101), color = Color(190, 190, 190, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
		["spikes+"] = { type = "Model", model = "models/props_phx/gears/rack9.mdl", bone = "v_weapon.Glock_Slide", rel = "", pos = Vector(5.008, -0.035, -0.08), angle = Angle(102.149, -90, 0), size = Vector(0.072, 0.082, 0.063), color = Color(190, 190, 190, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
		["topmetal"] = { type = "Model", model = "models/props_junk/cardboard_box001a.mdl", bone = "v_weapon.Glock_Slide", rel = "", pos = Vector(3.078, 0.217, -0.029), angle = Angle(76.47, 90, 0), size = Vector(0.035, 0.219, 0.034), color = Color(190, 190, 190, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
		["bottom2"] = { type = "Model", model = "models/props_junk/gascan001a.mdl", bone = "v_weapon.Glock_Parent", rel = "", pos = Vector(-3.201, -2.156, 0.246), angle = Angle(102.806, 84.778, -11.667), size = Vector(0.133, 0.172, 0.068), color = Color(190, 190, 190, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} }
	}
	-- 世界模型附加模型（第三人称对应的改装件）
	wept.WElements = {
		["detail"] = { type = "Model", model = "models/Mechanics/wheels/wheel_extruded_48.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "bottom2", pos = Vector(0, -1.64, 0), angle = Angle(0, 0, -90), size = Vector(0.014, 0.014, 0.014), color = Color(190, 190, 190, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
		["bottom"] = { type = "Model", model = "models/mechanics/solid_steel/crossbeam_4.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(8.513, 1.929, -2.32), angle = Angle(40.83, -4.801, 90), size = Vector(0.009, 0.009, 0.009), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/props_combine/combine_citadel001", skin = 0, bodygroup = {} },
		["spikes"] = { type = "Model", model = "models/props_phx/gears/rack9.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "bottom2", pos = Vector(0.009, 0.732, -2.25), angle = Angle(180, 0, -1.56), size = Vector(0.072, 0.082, 0.063), color = Color(190, 190, 190, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
		["bottom2"] = { type = "Model", model = "models/props_junk/gascan001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "bottom", pos = Vector(0.241, -0.242, 0), angle = Angle(90, -135, 0), size = Vector(0.133, 0.172, 0.083), color = Color(190, 190, 190, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
		["barrel"] = { type = "Model", model = "models/props_borealis/bluebarrel001.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "bottom2", pos = Vector(0, -2.29, -1.851), angle = Angle(-92, -90, 0), size = Vector(0.041, 0.041, 0.013), color = Color(190, 190, 190, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
		["topmetal"] = { type = "Model", model = "models/props_junk/cardboard_box001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "bottom2", pos = Vector(-0.01, 2.589, -1.861), angle = Angle(0, -0.181, 1.6), size = Vector(0.037, 0.223, 0.034), color = Color(190, 190, 190, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
		["silencer2"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "bottom2", pos = Vector(0, -2.471, -1.841), angle = Angle(88, -90, 0), size = Vector(0.043, 0.043, 0.101), color = Color(190, 190, 190, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
		["bottom2+"] = { type = "Model", model = "models/props_junk/gascan001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "bottom2", pos = Vector(0, 0.889, 1.049), angle = Angle(0, 0, 0), size = Vector(0.15, 0.268, 0.029), color = Color(190, 190, 190, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
		["spikes+"] = { type = "Model", model = "models/props_phx/gears/rack9.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "bottom2", pos = Vector(0.009, 4.179, -2.35), angle = Angle(180, 0, -1.56), size = Vector(0.072, 0.082, 0.063), color = Color(190, 190, 190, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} }
	}

	-- 光环范围：512 单位（对周围友军/敌人生效的光环）
	wept.GetAuraRange = function()
		return 512
	end
end)
-- 分支 2 强化等级颜色（灰阶金属色）
branch.Colors = {Color(170, 170, 170), Color(120, 120, 120), Color(70, 70, 70)}
-- 分支 2 各强化等级显示名称
branch.NewNames = {""..translate.Get("weapon_zs_glock3_r2_l1"), ""..translate.Get("weapon_zs_glock3_r2_l2"), ""..translate.Get("weapon_zs_glock3_r2_l3")}
-- 分支 2 击杀图标
branch.Killicon = "weapon_zs_shroud"
