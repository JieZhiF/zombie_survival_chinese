-- ============================================================================
-- weapon_zs_novacolt.lua - 新星手枪（沙漠之鹰造型高伤害手枪）
-- 负责：定义手枪属性、自定义音效、命中击退，以及由零件拼装的手持模型外观
-- ============================================================================

-- 客户端共享加载声明（本文件双端加载）
AddCSLuaFile()

-- 武器显示名称（本地化）
SWEP.PrintName = ""..translate.Get("weapon_zs_novacolt")
-- 武器商店中的描述文本（本地化）
SWEP.Description = ""..translate.Get("weapon_zs_novacolt_description")

-- 武器在栏位内的排序位置
SWEP.SlotPos = 0

-- 客户端专用属性：栏位分组与拼装模型外观
if CLIENT then
SWEP.Slot = GAMEMODE:GetWeaponSlot("WeaponSelectSlotPistols")
SWEP.WeaponType = "pistol"
	SWEP.SlotGroup = WEPSELECT_PISTOL
	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 56

	-- HUD 3D 预览图标：挂在沙漠之鹰模型父骨骼上
	SWEP.HUD3DBone = "v_weapon.Deagle_Parent"
	SWEP.HUD3DPos = Vector(0.1, -5.5, 1.22)
	SWEP.HUD3DAng = Angle(0, 0, 0)
	SWEP.HUD3DScale = 0.016

	-- 第一人称附加模型：用多个零件拼装出科幻手枪外观
	SWEP.VElements = {
		["novacolt++++++"] = { type = "Model", model = "models/props_combine/breenlight.mdl", bone = "v_weapon.Deagle_Parent", rel = "novacolt", pos = Vector(0, 4.524, 4.07), angle = Angle(113.376, -90, 0), size = Vector(0.451, 0.298, 0.365), color = Color(148, 152, 183, 255), surpresslightning = false, material = "models/props_c17/clockwood01", skin = 0, bodygroup = {} },
		["novacolt++"] = { type = "Model", model = "models/props_combine/combinethumper002.mdl", bone = "v_weapon.Deagle_Parent", rel = "novacolt", pos = Vector(-0.612, 3.635, 1.74), angle = Angle(0, 0, 180), size = Vector(0.05, 0.059, 0.059), color = Color(170, 181, 185, 255), surpresslightning = false, material = "models/weapons/v_stunstick/v_stunstick_diffuse", skin = 0, bodygroup = {} },
		["novacolt"] = { type = "Model", model = "models/props_wasteland/laundry_washer001a.mdl", bone = "v_weapon.Deagle_Parent", rel = "", pos = Vector(0, -5.56, -2.725), angle = Angle(0, 0, 0), size = Vector(0.045, 0.045, 0.059), color = Color(80, 87, 99, 255), surpresslightning = false, material = "models/weapons/v_shotgun/vshotgun_albedo", skin = 0, bodygroup = {} },
		["novacolt+++++"] = { type = "Model", model = "models/props_wasteland/laundry_dryer001.mdl", bone = "v_weapon.Deagle_Parent", rel = "novacolt", pos = Vector(0, 0.6, 3), angle = Angle(110, -90, 0), size = Vector(0.019, 0.041, 0.034), color = Color(75, 82, 95, 255), surpresslightning = false, material = "models/props_c17/column02a", skin = 0, bodygroup = {} },
		["novacolt+"] = { type = "Model", model = "models/props_wasteland/laundry_washer001a.mdl", bone = "v_weapon.Deagle_Parent", rel = "novacolt", pos = Vector(0, 3, -0.35), angle = Angle(90, 0, 0), size = Vector(0.029, 0.029, 0.05), color = Color(92, 108, 118, 255), surpresslightning = false, material = "models/weapons/v_smg1/texture4", skin = 0, bodygroup = {} },
		["novacolt+++++++"] = { type = "Model", model = "models/props_lab/eyescanner.mdl", bone = "v_weapon.Deagle_Parent", rel = "novacolt", pos = Vector(0, -1.601, 2.2), angle = Angle(66.62, 90, 0), size = Vector(0.129, 0.15, 0.159), color = Color(47, 52, 56, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["novacolt++++"] = { type = "Model", model = "models/props_combine/combine_train02a.mdl", bone = "v_weapon.Deagle_Parent", rel = "novacolt", pos = Vector(0, 0.47, -5.652), angle = Angle(-180, 180, 90), size = Vector(0.019, 0.028, 0.019), color = Color(75, 87, 79, 255), surpresslightning = false, material = "models/weapons/w_irifle/w_irifle", skin = 0, bodygroup = {} }
	}

	-- 第三人称附加模型：同样的拼装外观，供他人视角显示
	SWEP.WElements = {
		["novacolt"] = { type = "Model", model = "models/props_wasteland/laundry_washer001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(6.314, 1.432, -5.409), angle = Angle(0, 90, -86.532), size = Vector(0.045, 0.045, 0.059), color = Color(80, 87, 99, 255), surpresslightning = false, material = "models/weapons/v_shotgun/vshotgun_albedo", skin = 0, bodygroup = {} },
		["novacolt++++"] = { type = "Model", model = "models/props_combine/combine_train02a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "novacolt", pos = Vector(0, 0.47, -5.652), angle = Angle(-180, 180, 90), size = Vector(0.019, 0.028, 0.019), color = Color(75, 87, 79, 255), surpresslightning = false, material = "models/weapons/w_irifle/w_irifle", skin = 0, bodygroup = {} },
		["novacolt+++++"] = { type = "Model", model = "models/props_wasteland/laundry_dryer001.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "novacolt", pos = Vector(0, 0.6, 3), angle = Angle(110, -90, 0), size = Vector(0.019, 0.041, 0.034), color = Color(75, 82, 95, 255), surpresslightning = false, material = "models/props_c17/column02a", skin = 0, bodygroup = {} },
		["novacolt+"] = { type = "Model", model = "models/props_wasteland/laundry_washer001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "novacolt", pos = Vector(0, 3, -0.35), angle = Angle(90, 0, 0), size = Vector(0.029, 0.029, 0.05), color = Color(92, 108, 118, 255), surpresslightning = false, material = "models/weapons/v_smg1/texture4", skin = 0, bodygroup = {} },
		["novacolt++"] = { type = "Model", model = "models/props_combine/combinethumper002.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "novacolt", pos = Vector(-0.612, 3.635, 1.74), angle = Angle(0, 0, 180), size = Vector(0.05, 0.059, 0.059), color = Color(170, 181, 185, 255), surpresslightning = false, material = "models/weapons/v_stunstick/v_stunstick_diffuse", skin = 0, bodygroup = {} },
		["novacolt+++++++"] = { type = "Model", model = "models/props_lab/eyescanner.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "novacolt", pos = Vector(0, -1.601, 2.2), angle = Angle(66.62, 90, 0), size = Vector(0.129, 0.15, 0.159), color = Color(47, 52, 56, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["novacolt++++++"] = { type = "Model", model = "models/props_combine/breenlight.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "novacolt", pos = Vector(0, 4.524, 4.07), angle = Angle(113.376, -90, 0), size = Vector(0.451, 0.298, 0.365), color = Color(148, 152, 183, 255), surpresslightning = false, material = "models/props_c17/clockwood01", skin = 0, bodygroup = {} }
	}

	-- 机瞄时的准星偏移
	SWEP.IronSightsPos = Vector(-6.321, 0, -0.561)
end

-- 继承武器基础类
SWEP.Base = "weapon_zs_base"

-- 持枪姿势：左轮
SWEP.HoldType = "revolver"

-- 第一人称视角模型（CS 版沙漠之鹰，实际显示由附加模型完成）
SWEP.ViewModel = "models/weapons/cstrike/c_pist_deagle.mdl"
-- 第三人称世界模型
SWEP.WorldModel = "models/weapons/w_pist_deagle.mdl"

-- 隐藏原始模型，只显示拼装出的外观
SWEP.ShowViewModel = false
SWEP.ShowWorldModel = false
-- 使用玩家手臂模型握持
SWEP.UseHands = true

-- 单发伤害（高伤害大威力手枪）
SWEP.Primary.Damage = 85
-- 每次射击的子弹数量
SWEP.Primary.NumShots = 1
-- 射击间隔
SWEP.Primary.Delay = 0.31

-- 弹匣容量
SWEP.Primary.ClipSize = 8
-- 半自动射击
SWEP.Primary.Automatic = false
-- 使用的弹药类型
SWEP.Primary.Ammo = "pistol"
-- 按游戏规则填充默认备弹
GAMEMODE:SetupDefaultClip(SWEP.Primary)

-- 扩散范围：最大/最小准星
SWEP.ConeMax = 3.05
SWEP.ConeMin = 1.35

-- 开火动画与换弹动画速度倍率
SWEP.FireAnimSpeed = 1.35
SWEP.ReloadSpeed = 0.43

-- 武器等级
SWEP.Tier = 5
-- 可同时持有的最大库存数量
SWEP.MaxStock = 2


-- 附加改装：弹匣容量 +1
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_CLIP_SIZE, 1, 1)

-- ==== EmitFireSound - 播放开火音效（重击声 + 高频点缀） ====
function SWEP:EmitFireSound()
	-- 主射击声（沙漠之鹰）
	self:EmitSound("weapons/deagle/deagle-1.wav", 75, math.random(81, 85), 0.8)
	-- 附加高频层叠声
	self:EmitSound("weapons/galil/galil-1.wav", 75, math.random(142, 148), 0.7, CHAN_WEAPON + 20)
end

-- ==== EmitReloadSound - 播放换弹开始音效 ====
function SWEP:EmitReloadSound()
	-- 仅预测端播放，避免重复
	if IsFirstTimePredicted() then
		self:EmitSound("weapons/357/357_reload1.wav", 75, 75, 1, CHAN_WEAPON + 21)
	end
end

-- ==== EmitReloadFinishSound - 播放换弹完成音效 ====
function SWEP:EmitReloadFinishSound()
	-- 仅预测端播放，避免重复
	if IsFirstTimePredicted() then
		self:EmitSound("weapons/357/357_spin1.wav", 70, 90)
	end
end

-- ==== SendReloadAnimation - 发送换弹动画 ====
function SWEP:SendReloadAnimation()
	-- 直接播取出枪动画充当换弹动作
	self:SendWeaponAnim(ACT_VM_DRAW)
end

-- ==== BulletCallback - 子弹命中回调（对僵尸施加巨大击退力） ====
function SWEP.BulletCallback(attacker, tr, dmginfo)
	local ent = tr.Entity

	-- 服务器端：命中活体僵尸时，沿玩家上方与前方施加击退力
	if SERVER and ent and ent:IsValidLivingZombie() then
		dmginfo:SetDamageForce(attacker:GetUp() * 7000 + attacker:GetForward() * 25000)
	end
end

-- 视角模型倾斜插值（放置路障预览或换弹完成时向下倾斜）
local ghostlerp = 0
-- ==== CalcViewModelView - 计算视角模型位置姿态 ====
function SWEP:CalcViewModelView(vm, oldpos, oldang, pos, ang)
	-- 放置路障预览期间或换弹完成时，平滑倾斜视角模型
	if self:GetOwner():GetBarricadeGhosting() or self:GetReloadFinish() > 0 then
		ghostlerp = math.min(1, ghostlerp + FrameTime() * 0.1)
	elseif ghostlerp > 0 then
		ghostlerp = math.max(0, ghostlerp - FrameTime() * 0.9)
	end

	-- 按插值量绕右轴向下倾斜最多 65 度
	if ghostlerp > 0 then
		ang:RotateAroundAxis(ang:Right(), -65 * ghostlerp)
	end

	return pos, ang
end
