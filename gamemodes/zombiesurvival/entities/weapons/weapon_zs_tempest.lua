-- ============================================================================
-- weapon_zs_tempest.lua - 暴风雨（五七式三连发能量手枪）
-- 负责：三连发点射机制、连发状态同步、两个强化分支（连发取消 / 电击强化）
-- ============================================================================
-- 注册为共享文件（客户端与服务端都加载）
AddCSLuaFile()
-- 定义基类（供 BaseClass 调用）
DEFINE_BASECLASS("weapon_zs_base")

-- 武器名称 / 描述（本地化）
SWEP.PrintName = ""..translate.Get("weapon_zs_tempest")
SWEP.Description = ""..translate.Get("weapon_zs_tempest_description")

-- 武器栏中的位置
SWEP.SlotPos = 0

if CLIENT then
-- 客户端专属：武器槽位（手枪槽）
SWEP.Slot = GAMEMODE:GetWeaponSlot("WeaponSelectSlotPistols")
-- 武器类型（单行多语句，保持原样）
SWEP.WeaponType = "pistol"
	-- 槽位分组：手枪
	SWEP.SlotGroup = WEPSELECT_PISTOL
	-- 第一人称视野 / 模型翻转
	SWEP.ViewModelFOV = 60
	SWEP.ViewModelFlip = false

	-- 武器栏 3D 预览：骨骼 / 位置 / 角度
	SWEP.HUD3DBone = "v_weapon.FIVESEVEN_PARENT"
	SWEP.HUD3DPos = Vector(-1, -2.5, -1)
	SWEP.HUD3DAng = Angle(0, 0, 0)

	-- 第一人称附加模型：科幻改造部件（炮塔/能量核心等）
	SWEP.VElements = {
		["top2"] = { type = "Model", model = "models/combine_turrets/ground_turret.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "top+", pos = Vector(0.1, 0, 1.5), angle = Angle(-90, 0, 0), size = Vector(0.2, 0.079, 0.1), color = Color(208, 229, 255, 255), surpresslightning = false, material = "models/weapons/v_models/pist_fiveseven/pist_fiveseven", skin = 0, bodygroup = {} },
		["bottom"] = { type = "Model", model = "models/props_combine/combinethumper001a.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "top+", pos = Vector(0.699, 0, -2), angle = Angle(0, 90, 0), size = Vector(0.009, 0.014, 0.019), color = Color(171, 191, 204, 255), surpresslightning = false, material = "models/weapons/v_models/pist_fiveseven/pist_fiveseven", skin = 0, bodygroup = {} },
		["top"] = { type = "Model", model = "models/props_lab/hev_case.mdl", bone = "v_weapon.FIVESEVEN_SLIDE", rel = "", pos = Vector(0, 7.989, -0.28), angle = Angle(-90, 90, 0), size = Vector(0.029, 0.028, 0.104), color = Color(49, 55, 62, 255), surpresslightning = false, material = "phoenix_storms/concrete2", skin = 0, bodygroup = {} },
		["top+"] = { type = "Model", model = "models/props_lab/hev_case.mdl", bone = "v_weapon.FIVESEVEN_PARENT", rel = "", pos = Vector(0, -2, -9.429), angle = Angle(0, -90, 0), size = Vector(0.025, 0.035, 0.108), color = Color(49, 52, 55, 255), surpresslightning = false, material = "phoenix_storms/concrete2", skin = 0, bodygroup = {} }
	}

	-- 第三人称附加模型：科幻改造部件
	SWEP.WElements = {
		["top2"] = { type = "Model", model = "models/combine_turrets/ground_turret.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "top+", pos = Vector(0.1, 0, 1.5), angle = Angle(-90, 0, 0), size = Vector(0.2, 0.079, 0.1), color = Color(208, 229, 255, 255), surpresslightning = false, material = "models/weapons/v_models/pist_fiveseven/pist_fiveseven", skin = 0, bodygroup = {} },
		["bottom"] = { type = "Model", model = "models/props_combine/combinethumper001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "top+", pos = Vector(0.699, 0, -2), angle = Angle(0, 90, 0), size = Vector(0.009, 0.014, 0.019), color = Color(171, 191, 204, 255), surpresslightning = false, material = "models/weapons/v_models/pist_fiveseven/pist_fiveseven", skin = 0, bodygroup = {} },
		["top+"] = { type = "Model", model = "models/props_lab/hev_case.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(10.5, 2.2, -2.5), angle = Angle(90, 174, 180), size = Vector(0.025, 0.035, 0.108), color = Color(49, 52, 55, 255), surpresslightning = false, material = "phoenix_storms/concrete2", skin = 0, bodygroup = {} },
		["top"] = { type = "Model", model = "models/props_lab/hev_case.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "top+", pos = Vector(-2, 0, -0.101), angle = Angle(180, 0, 180), size = Vector(0.029, 0.028, 0.104), color = Color(49, 55, 62, 255), surpresslightning = false, material = "phoenix_storms/concrete2", skin = 0, bodygroup = {} }
	}
end

-- 继承基础武器
SWEP.Base = "weapon_zs_base"

-- 持枪姿势（手枪姿势）
SWEP.HoldType = "pistol"

-- 第一人称 / 第三人称模型
SWEP.ViewModel = "models/weapons/cstrike/c_pist_fiveseven.mdl"
SWEP.WorldModel = "models/weapons/w_pist_fiveseven.mdl"
-- 使用玩家自己的手臂模型
SWEP.UseHands = true

-- 开火音效 / 单发伤害 / 单次射击弹数 / 射击间隔
SWEP.Primary.Sound = Sound("weapons/ar2/npc_ar2_altfire.wav")
SWEP.Primary.Damage = 37
SWEP.Primary.NumShots = 1
SWEP.Primary.Delay = 0.41
-- 每次攻击的连发次数（三连发）
SWEP.Primary.BurstShots = 3

-- 弹匣容量 / 全自动 / 弹药类型
SWEP.Primary.ClipSize = 21
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "pistol"
-- 按游戏模式规则设置初始弹匣
GAMEMODE:SetupDefaultClip(SWEP.Primary)

-- 扩散：最大 3.6 / 最小 1.8
SWEP.ConeMax = 3.6
SWEP.ConeMin = 1.8

-- 武器等级（Tier 3）/ 开火动画速度
SWEP.Tier = 3
SWEP.FireAnimSpeed = 1.5

-- 换弹速度倍率
SWEP.ReloadSpeed = 1.05

-- 机瞄位置
SWEP.IronSightsPos = Vector(-5.95, 0, 2.5)

-- 强化词条：最大扩散 -0.37 / 最小扩散 -0.25 / 射击间隔 -0.03 秒
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_MAX_SPREAD, -0.37, 1)
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_MIN_SPREAD, -0.25, 1)
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_FIRE_DELAY, -0.03, 1)
-- 强化分支 1（快速单发）：伤害 ×0.9、间隔 ×0.375，改为直接调用基础单发射击（取消三连发）
GAMEMODE:AddNewRemantleBranch(SWEP, 1, ""..translate.Get("weapon_zs_tempest_r1"), ""..translate.Get("weapon_zs_tempest_r1_description"), function(wept)
	wept.Primary.Damage = wept.Primary.Damage * 0.9
	wept.Primary.Delay = wept.Primary.Delay * 0.375
	wept.PrimaryAttack = function(self, ent) BaseClass.PrimaryAttack(self) end
end)
-- 强化分支 2（电击强化）：伤害 ×0.55、间隔 ×1.5、精准提升，改为脉冲弹药并更换音效与模型
local branch = GAMEMODE:AddNewRemantleBranch(SWEP, 2, ""..translate.Get("weapon_zs_tempest_r2"), ""..translate.Get("weapon_zs_tempest_r2_description"), function(wept)
	wept.Primary.Damage = wept.Primary.Damage * 0.55
	wept.Primary.Delay = wept.Primary.Delay * 1.5
	wept.ConeMin = wept.ConeMin * 0.75

	-- 增加最大射程与特殊曳光弹效果
	wept.MaxDistance = 512
	wept.TracerName = "tracer_cosmos"
	-- 改用脉冲弹药
	wept.Primary.Ammo = "pulse"

	-- 分支专属开火音效（电击声）
	wept.EmitFireSound = function(self)
		self:EmitSound("weapons/stunstick/alyx_stunner2.wav", 70, 155, 0.65, CHAN_AUTO)
		self:EmitSound("weapons/stunstick/alyx_stunner2.wav", 70, 157, 0.65, CHAN_WEAPON + 20)
	end

	-- 分支专属换弹完成音效
	wept.EmitReloadFinishSound = function(self)
		if IsFirstTimePredicted() then
			self:EmitSound("items/battery_pickup.wav", 70, 156, 0.85, CHAN_AUTO)
		end
	end

	-- 分支专属第一人称附加模型（能量电池组件）
	wept.VElements = {
		["lucasarts+"] = { type = "Model", model = "models/items/combine_rifle_cartridge01.mdl", bone = "v_weapon.FIVESEVEN_PARENT", rel = "", pos = Vector(0, -2, -5), angle = Angle(0, 90, 0), size = Vector(0.449, 0.899, 1.08), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["lucasarts++"] = { type = "Model", model = "models/props_lab/reciever01a.mdl", bone = "v_weapon.FIVESEVEN_PARENT", rel = "lucasarts+", pos = Vector(0.5, 0, 1.899), angle = Angle(0, 0, 90), size = Vector(0.079, 0.37, 0.2), color = Color(112, 125, 133, 255), surpresslightning = false, material = "models/props_lab/ravendoor_sheet", skin = 0, bodygroup = {} },
		["lucasarts+++"] = { type = "Model", model = "models/items/car_battery01.mdl", bone = "v_weapon.FIVESEVEN_PARENT", rel = "lucasarts+", pos = Vector(1, 0, 2), angle = Angle(0, 90, 90), size = Vector(0.109, 0.5, 0.119), color = Color(204, 255, 255, 255), surpresslightning = false, material = "models/props_building_details/courtyard_template001c_bars_dark", skin = 0, bodygroup = {} },
		["lucasarts++++"] = { type = "Model", model = "models/items/grenadeammo.mdl", bone = "v_weapon.FIVESEVEN_PARENT", rel = "lucasarts+", pos = Vector(1, 0, -7), angle = Angle(0, 90, 0), size = Vector(0.4, 0.4, 1.2), color = Color(92, 110, 135, 255), surpresslightning = false, material = "models/props_lab/ravendoor_sheet", skin = 0, bodygroup = {} },
		["lucasarts"] = { type = "Model", model = "models/props_pipes/valve001.mdl", bone = "v_weapon.FIVESEVEN_PARENT", rel = "lucasarts+", pos = Vector(-2, 0, -2), angle = Angle(0, 90, 0), size = Vector(0.1, 0.2, 0.05), color = Color(90, 102, 123, 255), surpresslightning = false, material = "models/props_interiors/radiator01c", skin = 0, bodygroup = {} }
	}

	-- 分支专属第三人称附加模型（能量电池组件）
	wept.WElements = {
		["lucasarts+"] = { type = "Model", model = "models/items/combine_rifle_cartridge01.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(4, 1.5, -3), angle = Angle(-90, -5, 180), size = Vector(0.449, 0.899, 1.08), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["lucasarts++"] = { type = "Model", model = "models/props_lab/reciever01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "lucasarts+", pos = Vector(0.5, 0, 1.899), angle = Angle(0, 0, 90), size = Vector(0.079, 0.37, 0.2), color = Color(112, 125, 133, 255), surpresslightning = false, material = "models/props_lab/ravendoor_sheet", skin = 0, bodygroup = {} },
		["lucasarts+++"] = { type = "Model", model = "models/items/car_battery01.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "lucasarts+", pos = Vector(1, 0, 2), angle = Angle(0, 90, 90), size = Vector(0.109, 0.5, 0.119), color = Color(204, 255, 255, 255), surpresslightning = false, material = "models/props_building_details/courtyard_template001c_bars_dark", skin = 0, bodygroup = {} },
		["lucasarts++++"] = { type = "Model", model = "models/items/grenadeammo.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "lucasarts+", pos = Vector(1, 0, -7), angle = Angle(0, 90, 0), size = Vector(0.4, 0.4, 1.2), color = Color(92, 110, 135, 255), surpresslightning = false, material = "models/props_lab/ravendoor_sheet", skin = 0, bodygroup = {} },
		["lucasarts"] = { type = "Model", model = "models/props_pipes/valve001.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "lucasarts+", pos = Vector(-2, 0, -2), angle = Angle(0, 90, 0), size = Vector(0.1, 0.2, 0.05), color = Color(90, 102, 123, 255), surpresslightning = false, material = "models/props_interiors/radiator01c", skin = 0, bodygroup = {} }
	}
end)
-- 分支外观：武器栏配色 / 等级名称 / 击杀图标（宇宙主题）
branch.Colors = {Color(100, 130, 180), Color(90, 120, 170), Color(70, 100, 160)}
branch.NewNames = {""..translate.Get("weapon_zs_tempest_r2_l1"), ""..translate.Get("weapon_zs_tempest_r2_l2"), ""..translate.Get("weapon_zs_tempest_r2_l3")}
branch.Killicon = "weapon_zs_cosmos"

-- ==== PrimaryAttack - 左键开火：启动一次三连发 ====
function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end

	-- 设置冷却并播放开火音效
	self:SetNextPrimaryFire(CurTime() + self:GetFireDelay())
	self:EmitFireSound()

	-- 初始化连发状态：立即发射第一发，剩余由 Think 依次打出
	self:SetNextShot(CurTime())
	self:SetShotsLeft(self.Primary.BurstShots)

	self.IdleAnimation = CurTime() + self:SequenceDuration()
end

-- ==== Think - 每帧执行连发的后续子弹 ====
function SWEP:Think()
	BaseClass.Think(self)

	-- 连发未打完且到下一次射击时间时，打出下一发
	local shotsleft = self:GetShotsLeft()
	if shotsleft > 0 and CurTime() >= self:GetNextShot() then
		self:SetShotsLeft(shotsleft - 1)
		self:SetNextShot(CurTime() + self:GetFireDelay()/6)

		-- 有弹药且不在换弹时射击；否则终止连发
		if self:Clip1() > 0 and self:GetReloadFinish() == 0 then
			self:EmitFireSound()
			self:TakeAmmo()
			self:ShootBullets(self.Primary.Damage, self.Primary.NumShots, self:GetCone())

			self.IdleAnimation = CurTime() + self:SequenceDuration()
		else
			self:SetShotsLeft(0)
		end
	end
end

-- ==== SetNextShot - 网络同步下一次射击时间 ====
function SWEP:SetNextShot(nextshot)
	self:SetDTFloat(5, nextshot)
end

-- ==== GetNextShot - 读取下一次射击时间 ====
function SWEP:GetNextShot()
	return self:GetDTFloat(5)
end

-- ==== SetShotsLeft - 网络同步剩余连发子弹数 ====
function SWEP:SetShotsLeft(shotsleft)
	self:SetDTInt(1, shotsleft)
end

-- ==== GetShotsLeft - 读取剩余连发子弹数 ====
function SWEP:GetShotsLeft()
	return self:GetDTInt(1)
end
