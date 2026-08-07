-- ============================================================================
-- weapon_zs_seditionist.lua - 反叛者高威力穿透手枪
-- 负责：沙漠之鹰改造：高伤害、强击退，子弹可穿透多个目标（伤害逐层递减），
--       并带激光指示器外观
-- ============================================================================
AddCSLuaFile()

-- 显示名称与描述
SWEP.PrintName = ""..translate.Get("weapon_zs_seditionist")
SWEP.Description = ""..translate.Get("weapon_zs_seditionist_description")

-- 武器栏内位置
SWEP.SlotPos = 0

if CLIENT then
-- 武器栏：手枪槽
SWEP.Slot = GAMEMODE:GetWeaponSlot("WeaponSelectSlotPistols")
-- 武器类型：手枪
SWEP.WeaponType = "pistol"
	SWEP.SlotGroup = WEPSELECT_PISTOL
	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 55

	-- HUD 3D 图标（大图标预览）参数
	SWEP.HUD3DBone = "v_weapon.Deagle_Slide"
	SWEP.HUD3DPos = Vector(-1.5, 0, 1)
	SWEP.HUD3DAng = Angle(0, 0, 0)
	SWEP.HUD3DScale = 0.015

	-- 机瞄位置
	SWEP.IronSightsPos = Vector(-6.36, 5, 1.6)

	-- 视图模型拼装件（含激光指示器光点）
	SWEP.VElements = {
		["laserbeam"] = { type = "Sprite", sprite = "sprites/glow01", bone = "ValveBiped.Bip01_Spine4", rel = "back", pos = Vector(-0.018, -3.799, -1.691), size = { x = 0.79, y = 0.79 }, color = Color(255, 0, 0, 255), nocull = true, additive = true, vertexalpha = true, vertexcolor = true, ignorez = false},
		["back++++"] = { type = "Model", model = "models/props_combine/combine_train02a.mdl", bone = "v_weapon.Deagle_Parent", rel = "back", pos = Vector(0, -0.387, -1.553), angle = Angle(0, 0, -180), size = Vector(0.018, 0.01, 0.01), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["back"] = { type = "Model", model = "models/props_combine/combine_train02a.mdl", bone = "v_weapon.Deagle_Parent", rel = "", pos = Vector(0.02, -3.869, -4.113), angle = Angle(0, 0, -90), size = Vector(0.018, 0.013, 0.01), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["scope"] = { type = "Model", model = "models/props_lab/teleportring.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "back+", pos = Vector(2.154, 0, 2.752), angle = Angle(90, 0, 0), size = Vector(0.028, 0.024, 0.098), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/props_combine/combine_train002", skin = 0, bodygroup = {} },
		["scopeinnard+"] = { type = "Model", model = "models/XQM/panel360.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "scope", pos = Vector(0.426, 0, 0.323), angle = Angle(90, 0, 0), size = Vector(0.025, 0.024, 0.019), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/weapons/v_smg1/texture5", skin = 0, bodygroup = {} },
		["back+"] = { type = "Model", model = "models/props_combine/combinetrain01a.mdl", bone = "v_weapon.Deagle_Slide", rel = "", pos = Vector(0, 1.519, 1.187), angle = Angle(90, -0.288, -90), size = Vector(0.01, 0.021, 0.01), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/props_combine/combine_train002", skin = 0, bodygroup = {} },
		["back+++++"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "v_weapon.Deagle_Parent", rel = "back", pos = Vector(0, -3.51, -0.551), angle = Angle(0, 0, -90), size = Vector(0.03, 0.03, 0.03), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/props_combine/combine_train002", skin = 0, bodygroup = {} },
		["dribble+"] = { type = "Model", model = "models/props_combine/combinethumper002.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "back", pos = Vector(-1.209, 3.344, 0.642), angle = Angle(-105, 0, -90), size = Vector(0.025, 0.016, 0.026), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["scopeinnard"] = { type = "Model", model = "models/XQM/panel360.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "scope", pos = Vector(0.423, 0, 0.323), angle = Angle(90, 180, 0), size = Vector(0.025, 0.024, 0.019), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/weapons/v_smg1/texture5", skin = 0, bodygroup = {} },
		["laser"] = { type = "Model", model = "models/props_phx/trains/wheel_medium.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "back", pos = Vector(0, -3.399, -1.675), angle = Angle(0, 0, -90), size = Vector(0.016, 0.016, 0.05), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/props_combine/combine_train002", skin = 0, bodygroup = {} },
		["dribble"] = { type = "Model", model = "models/props_combine/combinethumper002.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "back", pos = Vector(1.208, 3.344, 0.094), angle = Angle(105, 0, -90), size = Vector(0.025, 0.016, 0.026), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}

	-- 世界模型拼装件
	SWEP.WElements = {
		["scopeinnard+"] = { type = "Model", model = "models/XQM/panel360.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "back", pos = Vector(0.029, 8.166, 1.659), angle = Angle(180, 90, 0), size = Vector(0.025, 0.024, 0.025), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/weapons/v_smg1/texture5", skin = 0, bodygroup = {} },
		["laserbegins"] = { type = "Sprite", sprite = "sprites/glow01", bone = "ValveBiped.Bip01_R_Hand", rel = "back", pos = Vector(-0.018, -3.799, -1.691), size = { x = 0.79, y = 0.79 }, color = Color(255, 0, 0, 255), nocull = true, additive = true, vertexalpha = true, vertexcolor = true, ignorez = false},
		["scopeinnard++"] = { type = "Model", model = "models/XQM/panel360.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "back", pos = Vector(0.029, 8.166, 1.659), angle = Angle(0, 90, 0), size = Vector(0.025, 0.024, 0.014), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/weapons/v_smg1/texture5", skin = 0, bodygroup = {} },
		["scope"] = { type = "Model", model = "models/props_lab/teleportring.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "back", pos = Vector(0.029, 7.666, 1.121), angle = Angle(90, 90, 0), size = Vector(0.028, 0.024, 0.098), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/props_combine/combine_train002", skin = 0, bodygroup = {} },
		["back"] = { type = "Model", model = "models/props_combine/combine_train02a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(10.425, 2.095, -4.106), angle = Angle(180, -94.622, 2.526), size = Vector(0.018, 0.013, 0.01), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["back+"] = { type = "Model", model = "models/props_combine/combinetrain01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(4.125, 1.56, -2.293), angle = Angle(178.087, -4.79, 0), size = Vector(0.01, 0.021, 0.01), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/props_combine/combine_train002", skin = 0, bodygroup = {} },
		["back+++++"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "back", pos = Vector(0, -3.51, -0.551), angle = Angle(0, 0, -90), size = Vector(0.03, 0.03, 0.03), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/props_combine/combine_train002", skin = 0, bodygroup = {} },
		["back++++"] = { type = "Model", model = "models/props_combine/combine_train02a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "back", pos = Vector(0, -0.387, -1.553), angle = Angle(0, 0, -180), size = Vector(0.018, 0.01, 0.01), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["dribble+"] = { type = "Model", model = "models/props_combine/combinethumper002.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "back", pos = Vector(-1.209, 3.344, 0.642), angle = Angle(-105, 0, -90), size = Vector(0.025, 0.016, 0.026), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["laser"] = { type = "Model", model = "models/props_phx/trains/wheel_medium.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "back", pos = Vector(0, -3.399, -1.675), angle = Angle(0, 0, -90), size = Vector(0.016, 0.016, 0.05), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/props_combine/combine_train002", skin = 0, bodygroup = {} },
		["dribble"] = { type = "Model", model = "models/props_combine/combinethumper002.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "back", pos = Vector(1.208, 3.344, 0.094), angle = Angle(105, 0, -90), size = Vector(0.025, 0.016, 0.026), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}
end

SWEP.Base = "weapon_zs_base"

-- 持枪姿势
SWEP.HoldType = "revolver"

-- 模型与手臂
SWEP.ViewModel = "models/weapons/cstrike/c_pist_deagle.mdl"
SWEP.WorldModel = "models/weapons/w_pist_deagle.mdl"
SWEP.UseHands = true

-- 基础伤害与强击退
SWEP.Primary.Damage = 53
SWEP.Primary.NumShots = 1
SWEP.Primary.Delay = 0.32
SWEP.Primary.KnockbackScale = 2

-- 弹匣
SWEP.Primary.ClipSize = 7
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "pistol"
GAMEMODE:SetupDefaultClip(SWEP.Primary)

-- 扩散
SWEP.ConeMax = 3.75
SWEP.ConeMin = 1.5

-- 开火动画速度倍率
SWEP.FireAnimSpeed = 1.3

-- 武器等级
SWEP.Tier = 4

-- 穿透层数（主弹可再穿 4 个目标）
SWEP.Pierces = 4

-- 强化：穿透层数 +1
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_BULLET_PIERCES, 1)

-- ==== EmitFireSound - 开火音效 ====
-- 沙漠之鹰主音 + 高频回响叠加
function SWEP:EmitFireSound()
	self:EmitSound("weapons/deagle/deagle-1.wav", 75, math.random(122, 130), 0.6)
	self:EmitSound("weapons/elite/elite-1.wav", 75, math.random(82, 88), 0.4, CHAN_WEAPON + 20)
end

-- ==== ShootBullets - 带穿透的射击逻辑 ====
-- 先沿准星方向发射主弹，再对穿透命中的每个目标补一发子弹，伤害随穿透
-- 深度递减（第 i 层为 dmg/i）
function SWEP:ShootBullets(dmg, numbul, cone)
	local owner = self:GetOwner()
	self:SendWeaponAnimation()
	owner:DoAttackEvent()

	local dir = owner:GetAimVector()
	local dirang = dir:Angle()
	local start = owner:GetShootPos()

	-- 共享随机旋转，保证多客户端弹道一致
	dirang:RotateAroundAxis(dirang:Forward(), util.SharedRandom("bulletrotate1", 0, 360))
	dirang:RotateAroundAxis(dirang:Up(), util.SharedRandom("bulletangle1", -cone, cone))

	dir = dirang:Forward()
	-- 延迟补偿下的穿透扫描（最远 2048 单位），返回沿途命中列表
	local tr = owner:CompensatedPenetratingMeleeTrace(2048, 0.01, start, dir)
	local ent

	owner:LagCompensation(true)
	-- 发射主弹
	owner:FireBulletsLua(start, dir, cone, numbul, dmg, nil, self.Primary.KnockbackScale, self.TracerName, self.BulletCallback, self.Primary.HullSize, nil, self.Primary.MaxDistance, nil, self)
	-- 对穿透命中的每个目标补一发零散布子弹，伤害逐层递减
	for i, trace in ipairs(tr) do
		if i ~= 1 and trace.Hit then
			if i > self.Pierces then break end

			ent = trace.Entity

			if ent and ent:IsValid() then
				owner:FireBulletsLua(trace.HitPos, dir, 0, numbul, dmg/i, nil, self.Primary.KnockbackScale, "", self.BulletCallback, self.Primary.HullSize, nil, self.Primary.MaxDistance, nil, self)
			end
		end
	end
	owner:LagCompensation(false)

end
