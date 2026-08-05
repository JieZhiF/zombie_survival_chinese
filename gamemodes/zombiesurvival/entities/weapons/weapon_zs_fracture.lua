-- ============================================================================
-- weapon_zs_fracture.lua - 碎裂者（Fracture）霰弹枪
-- 负责：M3 猎枪改造的高射速霰弹枪；左键为垂直扇形散布、右键为水平扇形
--       散布（自定义弹丸排布），并叠加双音轨开火音效
-- ============================================================================
AddCSLuaFile()

-- 继承霰弹枪基底
SWEP.Base = "weapon_zs_baseshotgun"
-- 记录基底类供 BaseClass 调用
DEFINE_BASECLASS("weapon_zs_baseshotgun")

-- 武器显示名称与描述（本地化）
SWEP.PrintName = ""..translate.Get("weapon_zs_fracture")
SWEP.Description = ""..translate.Get("weapon_zs_fracture_description")

if CLIENT then
	-- 视模型不翻转
	SWEP.ViewModelFlip = false

	-- 枪身 3D2D HUD 挂点（M3 猎枪骨骼）
	SWEP.HUD3DBone = "v_weapon.M3_PARENT"
	SWEP.HUD3DPos = Vector(-1, -4, -3)
	SWEP.HUD3DAng = Angle(0, 0, 0)
	SWEP.HUD3DScale = 0.015

	-- 第一人称附加模型：以洗衣机为枪身主体，拼出深蓝灰色金属霰弹枪外形
	SWEP.VElements = {
		["fracture++++++"] = { type = "Model", model = "models/props_c17/trappropeller_lever.mdl", bone = "v_weapon.M3_PARENT", rel = "fracture", pos = Vector(10.5, 0, -2), angle = Angle(0, -90, -33.896), size = Vector(1, 0.6, 1.5), color = Color(87, 99, 118, 255), surpresslightning = false, material = "models/props_pipes/guttermetal01a", skin = 0, bodygroup = {} },
		["fracture++++"] = { type = "Model", model = "models/props_c17/utilityconnecter003.mdl", bone = "v_weapon.M3_PARENT", rel = "fracture", pos = Vector(4.675, 0, -0.201), angle = Angle(0, -90, 0), size = Vector(0.625, 0.625, 0.625), color = Color(60, 67, 90, 255), surpresslightning = false, material = "models/props_pipes/valve001_skin2", skin = 0, bodygroup = {} },
		["fracture+++++"] = { type = "Model", model = "models/props_c17/utilityconnecter002.mdl", bone = "v_weapon.M3_PARENT", rel = "fracture", pos = Vector(8, 0, -2.597), angle = Angle(0, -90, 180), size = Vector(0.2, 0.2, 0.2), color = Color(60, 67, 90, 255), surpresslightning = false, material = "models/props_pipes/valve001_skin2", skin = 0, bodygroup = {} },
		["fracture++"] = { type = "Model", model = "models/props_c17/factorymachine01.mdl", bone = "v_weapon.M3_PARENT", rel = "fracture", pos = Vector(-5.715, 0, -1.4), angle = Angle(180, -90, 0), size = Vector(0.025, 0.025, 0.025), color = Color(49, 54, 79, 255), surpresslightning = false, material = "models/props_pipes/guttermetal01a", skin = 0, bodygroup = {} },
		["fracture+"] = { type = "Model", model = "models/props_c17/factorymachine01.mdl", bone = "v_weapon.M3_PARENT", rel = "fracture", pos = Vector(-5.715, 0, 0), angle = Angle(0, -90, 0), size = Vector(0.025, 0.025, 0.025), color = Color(49, 54, 79, 255), surpresslightning = false, material = "models/props_pipes/guttermetal01a", skin = 0, bodygroup = {} },
		-- 枪身主体
		["fracture"] = { type = "Model", model = "models/props_wasteland/laundry_washer003.mdl", bone = "v_weapon.M3_PARENT", rel = "", pos = Vector(0, -4.5, -10.91), angle = Angle(90, -90, 0), size = Vector(0.15, 0.035, 0.035), color = Color(59, 70, 103, 255), surpresslightning = false, material = "models/props_pipes/guttermetal01a", skin = 0, bodygroup = {} },
		["fracture+++"] = { type = "Model", model = "models/props_wasteland/laundry_washer001a.mdl", bone = "v_weapon.M3_PARENT", rel = "fracture", pos = Vector(-1.5, 0, -1), angle = Angle(0, -90, -90), size = Vector(0.035, 0.029, 0.25), color = Color(49, 57, 74, 255), surpresslightning = false, material = "models/props_pipes/valve001_skin2", skin = 0, bodygroup = {} }
	}

	-- 第三人称附加模型：挂在右手骨上的同款外形
	SWEP.WElements = {
		["fracture+++"] = { type = "Model", model = "models/props_wasteland/laundry_washer001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "fracture", pos = Vector(-1.5, 0, -1), angle = Angle(0, -90, -90), size = Vector(0.035, 0.029, 0.25), color = Color(49, 57, 74, 255), surpresslightning = false, material = "models/props_pipes/valve001_skin2", skin = 0, bodygroup = {} },
		["fracture++++"] = { type = "Model", model = "models/props_c17/utilityconnecter003.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "fracture", pos = Vector(4.675, 0, -0.201), angle = Angle(0, -90, 0), size = Vector(0.625, 0.625, 0.625), color = Color(60, 67, 90, 255), surpresslightning = false, material = "models/props_pipes/valve001_skin2", skin = 0, bodygroup = {} },
		["fracture"] = { type = "Model", model = "models/props_wasteland/laundry_washer003.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(16, 1, -5.715), angle = Angle(176.494, 0, 0), size = Vector(0.15, 0.035, 0.035), color = Color(59, 70, 103, 255), surpresslightning = false, material = "models/props_pipes/guttermetal01a", skin = 0, bodygroup = {} },
		["fracture+++++"] = { type = "Model", model = "models/props_c17/utilityconnecter002.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "fracture", pos = Vector(8, 0, -2.597), angle = Angle(0, -90, 180), size = Vector(0.2, 0.2, 0.2), color = Color(60, 67, 90, 255), surpresslightning = false, material = "models/props_pipes/valve001_skin2", skin = 0, bodygroup = {} },
		["fracture+"] = { type = "Model", model = "models/props_c17/factorymachine01.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "fracture", pos = Vector(-5.715, 0, 0), angle = Angle(0, -90, 0), size = Vector(0.025, 0.025, 0.025), color = Color(49, 54, 79, 255), surpresslightning = false, material = "models/props_pipes/guttermetal01a", skin = 0, bodygroup = {} },
		["fracture++++++"] = { type = "Model", model = "models/props_c17/trappropeller_lever.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "fracture", pos = Vector(10.5, 0, -2), angle = Angle(0, -90, -33.896), size = Vector(1, 0.6, 1.5), color = Color(87, 99, 118, 255), surpresslightning = false, material = "models/props_pipes/guttermetal01a", skin = 0, bodygroup = {} },
		["fracture++"] = { type = "Model", model = "models/props_c17/factorymachine01.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "fracture", pos = Vector(-5.715, 0, -1.4), angle = Angle(180, -90, 0), size = Vector(0.025, 0.025, 0.025), color = Color(49, 54, 79, 255), surpresslightning = false, material = "models/props_pipes/guttermetal01a", skin = 0, bodygroup = {} }
	}
end

-- 继承霰弹枪基底（客户端块外再次声明，保证全端生效）
SWEP.Base = "weapon_zs_baseshotgun"

-- 持枪姿势：霰弹枪
SWEP.HoldType = "shotgun"

-- 视/世界模型（M3 猎枪），使用玩家手臂
SWEP.ViewModel = "models/weapons/cstrike/c_shot_m3super90.mdl"
SWEP.WorldModel = "models/weapons/w_shot_m3super90.mdl"
SWEP.UseHands = true

-- 隐藏视/世界模型（外观由附加模型拼装）
SWEP.ShowViewModel = false
SWEP.ShowWorldModel = false

-- 换弹间隔（秒）
SWEP.ReloadDelay = 0.45

-- 主攻击：7 弹丸 × 13 伤害，射击间隔 0.9 秒
SWEP.Primary.Sound = Sound("Weapon_M3.Single")
SWEP.Primary.Damage = 13
SWEP.Primary.NumShots = 7
SWEP.Primary.Delay = 0.9

-- 弹匣 6 发，半自动，消耗霰弹弹药，默认弹量由基底规则设置
SWEP.Primary.ClipSize = 6
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "buckshot"
GAMEMODE:SetupDefaultClip(SWEP.Primary)

-- 扩散范围（霰弹枪大散布）
SWEP.ConeMax = 7.55
SWEP.ConeMin = 5.25

-- 开火动画速度与持枪移动速度
SWEP.FireAnimSpeed = 1
SWEP.WalkSpeed = SPEED_SLOWER

-- 武器等级
SWEP.Tier = 2

-- 附加武器修改器：弹丸数 +1、换弹速度 +10%
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_SHOT_COUNT, 1)
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_RELOAD_SPEED, 0.1, 1)

-- ==== PrimaryAttack - 左键开火：标记为垂直散布后走基底开火 ====
function SWEP:PrimaryAttack()
	-- AttackContext = true 表示垂直扇形（见 ShootBullets）
	self.AttackContext = true
	BaseClass.PrimaryAttack(self)
end

-- ==== SecondaryAttack - 右键开火：标记为水平散布后走基底开火 ====
function SWEP:SecondaryAttack()
	-- AttackContext = nil 表示水平扇形
	self.AttackContext = nil
	BaseClass.PrimaryAttack(self)
end

-- ==== EmitFireSound - 开火音效：主音轨 + 高音副轨叠加 ====
function SWEP:EmitFireSound()
	self:EmitSound("weapons/m3/m3-1.wav", 75, math.random(134, 136), 0.7)
	self:EmitSound("weapons/xm1014/xm1014-1.wav", 75, math.random(172, 180), 0.5, CHAN_WEAPON + 20)
end

-- ==== ShootBullets - 自定义弹丸发射：按攻击上下文沿垂直/水平轴排布扇形 ====
function SWEP:ShootBullets(dmg, numbul, cone)
	local owner = self:GetOwner()
	-- 弹丸间角距：垂直散布更密（2），水平散布更散（2.75）
	local sprd = (self.AttackContext and 2 or 2.75)*cone/6
	-- 扩散除数：垂直散布后坐力更大（/2），水平散布更稳（/1.25）
	local recp = self.AttackContext and 2 or 1.25

	-- 播放射击动画并触发攻击事件
	self:SendWeaponAnimation()
	owner:DoAttackEvent()

	-- 开启延迟补偿（服务器端精确命中验证）
	owner:LagCompensation(true)
	for i = 1, numbul do
		local angle = owner:GetAimVector():Angle()
		-- 以中心弹丸为基准，向两侧按序号偏移角度：垂直模式绕 Up 轴、水平模式绕 Right 轴
		angle:RotateAroundAxis(self.AttackContext and angle:Up() or angle:Right(), (i - math.ceil(self.Primary.NumShots/2)) * sprd)

		owner:FireBulletsLua(owner:GetShootPos(), angle:Forward(), cone/recp, 1, dmg, nil, self.Primary.KnockbackScale, self.TracerName, self.BulletCallback, self.Primary.HullSize, nil, self.Primary.MaxDistance, nil, self)
	end
	owner:LagCompensation(false)
end
