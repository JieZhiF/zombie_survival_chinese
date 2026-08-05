-- ============================================================================
-- weapon_zs_colossus.lua - 巨像（重型单发穿透步枪）
-- 负责：高伤害穿透射击（最多穿透 3 个目标）、慢速装填循环与重型音效
-- ============================================================================
-- 注册为共享文件（客户端与服务端都加载）
AddCSLuaFile()

-- 武器名称 / 描述（本地化）
SWEP.PrintName = ""..translate.Get("weapon_zs_colossus")
SWEP.Description = ""..translate.Get("weapon_zs_colossus_description")

if CLIENT then
	-- 客户端专属：武器槽位（步枪槽）
	SWEP.Slot = GAMEMODE:GetWeaponSlot("WeaponSelectSlotRifles")
	-- 武器类型与槽位分组（单行多语句，保持原样）
SWEP.WeaponType = "rifle"	SWEP.SlotGroup = WEPSELECT_RIFLE
	-- 槽内位置
	SWEP.SlotPos = 0

	-- 第一人称模型不翻转 / 视野 55
	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 55

	-- 武器栏 3D 预览：骨骼 / 位置 / 角度 / 缩放
	SWEP.HUD3DBone = "v_weapon.xm1014_Bolt"
	SWEP.HUD3DPos = Vector(-3.75, -1, -10)
	SWEP.HUD3DAng = Angle(0, 0, 0)
	SWEP.HUD3DScale = 0.022

	-- 第一人称附加模型：重型枪身组件（多个部件拼合）
	SWEP.VElements = {
		["frontbit_inner"] = { type = "Model", model = "models/hunter/tubes/tube2x2x1.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "frontbit__behind_underbit", pos = Vector(0, 0, 0), angle = Angle(0, 141.695, 0), size = Vector(0.07, 0.07, 0.215), color = Color(255, 15, 15, 255), surpresslightning = false, material = "models/props_combine/masterinterface_disp", skin = 0, bodygroup = {} },
		["frontbit_behind"] = { type = "Model", model = "models/XQM/panel360.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "side", pos = Vector(6.011, 0.037, -3.062), angle = Angle(0, 0, 0), size = Vector(1.881, 0.136, 0.136), color = Color(170, 155, 149, 255), surpresslightning = false, material = "models/props_wasteland/tugboat02", skin = 0, bodygroup = {} },
		["top"] = { type = "Model", model = "models/props_wasteland/laundry_washer001a.mdl", bone = "v_weapon.xm1014_Parent", rel = "", pos = Vector(-0.262, -3.875, -25.164), angle = Angle(0, 100.58, 0), size = Vector(0.085, 0.085, 0.143), color = Color(170, 155, 149, 255), surpresslightning = false, material = "models/props_wasteland/tugboat02", skin = 0, bodygroup = {} },
		["frontbit_behind_2+"] = { type = "Model", model = "models/hunter/triangles/trapezium3x3x1a.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "frontbit_behind+", pos = Vector(-0.461, 2, 0), angle = Angle(90, 90, 0), size = Vector(0.032, 0.092, 0.089), color = Color(165, 165, 165, 255), surpresslightning = false, material = "phoenix_storms/metalset_1-2", skin = 0, bodygroup = {} },
		["frontbit_behind_bottom"] = { type = "Model", model = "models/props_docks/dock03_pole01a.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "frontbit_behind_2+", pos = Vector(0, 1.937, 3.118), angle = Angle(0, 0, 10), size = Vector(0.092, 0.092, 0.012), color = Color(165, 165, 165, 255), surpresslightning = false, material = "phoenix_storms/metalset_1-2", skin = 0, bodygroup = {} },
		["frontbit_behind+"] = { type = "Model", model = "models/XQM/panel360.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "frontbit_behind", pos = Vector(10.821, 0, 0), angle = Angle(0, 0, 0), size = Vector(1, 0.136, 0.136), color = Color(170, 155, 149, 255), surpresslightning = false, material = "models/props_wasteland/tugboat02", skin = 0, bodygroup = {} },
		["frontbit_behind_mp5"] = { type = "Model", model = "models/weapons/w_smg_mp5.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "frontbit_behind_2", pos = Vector(0, -2.057, -4.428), angle = Angle(0, 90, 0), size = Vector(0.977, 1.077, 0.354), color = Color(165, 165, 165, 255), surpresslightning = false, material = "phoenix_storms/metalset_1-2", skin = 0, bodygroup = {} },
		["frontbit_behind_2"] = { type = "Model", model = "models/hunter/triangles/trapezium3x3x1a.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "frontbit_behind+", pos = Vector(0, -1.275, 0), angle = Angle(-90, 90, 0), size = Vector(0.032, 0.085, 0.048), color = Color(165, 165, 165, 255), surpresslightning = false, material = "phoenix_storms/metalset_1-2", skin = 0, bodygroup = {} },
		["frontbit_pipe"] = { type = "Model", model = "models/props_debris/rebar_smallnorm01c.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "side", pos = Vector(0, 0.239, 0.003), angle = Angle(21.548, 0, 0), size = Vector(0.649, 0.666, 0.319), color = Color(255, 255, 255, 255), surpresslightning = false, material = "phoenix_storms/metal_plate", skin = 0, bodygroup = {} },
		["side"] = { type = "Model", model = "models/props_wasteland/horizontalcoolingtank04.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "top", pos = Vector(-0.736, -2.576, 0.358), angle = Angle(90, -78, 0), size = Vector(0.028, 0.041, 0.048), color = Color(170, 155, 149, 255), surpresslightning = false, material = "models/props_wasteland/tugboat02", skin = 0, bodygroup = {} },
		["frontbit__behind_underbit"] = { type = "Model", model = "models/hunter/tubes/tube2x2x1b.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "frontbit_behind", pos = Vector(5.613, 0.043, 0), angle = Angle(-45, 90, 90), size = Vector(0.074, 0.074, 0.231), color = Color(170, 155, 149, 255), surpresslightning = false, material = "models/props_wasteland/tugboat02", skin = 0, bodygroup = {} }
	}

	-- 第三人称附加模型：重型枪身组件
	SWEP.WElements = {
		["frontbit_behind++"] = { type = "Model", model = "models/XQM/panel360.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "side", pos = Vector(-4.196, -0.069, -3.062), angle = Angle(0, 0, 0), size = Vector(1.205, 0.119, 0.119), color = Color(0, 0, 0, 255), surpresslightning = false, material = "models/debug/debugwhite", skin = 0, bodygroup = {} },
		["frontbit_inner"] = { type = "Model", model = "models/hunter/tubes/tube2x2x1.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "frontbit__behind_underbit", pos = Vector(0, 0, 0), angle = Angle(0, 141.695, 0), size = Vector(0.07, 0.07, 0.215), color = Color(255, 15, 15, 255), surpresslightning = false, material = "models/props_combine/masterinterface_disp", skin = 0, bodygroup = {} },
		["frontbit_behind"] = { type = "Model", model = "models/XQM/panel360.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "side", pos = Vector(6.011, 0.037, -3.062), angle = Angle(0, 0, 0), size = Vector(1.881, 0.136, 0.136), color = Color(170, 155, 149, 255), surpresslightning = false, material = "models/props_wasteland/tugboat02", skin = 0, bodygroup = {} },
		["top"] = { type = "Model", model = "models/props_wasteland/laundry_washer001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(20.954, 2.823, -8.398), angle = Angle(-78.195, 180, 0), size = Vector(0.085, 0.085, 0.143), color = Color(170, 155, 149, 255), surpresslightning = false, material = "models/props_wasteland/tugboat02", skin = 0, bodygroup = {} },
		["frontbit_pipe"] = { type = "Model", model = "models/props_debris/rebar_smallnorm01c.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "side", pos = Vector(0, 0.239, 0.003), angle = Angle(21.548, 0, 0), size = Vector(0.649, 0.666, 0.319), color = Color(255, 255, 255, 255), surpresslightning = false, material = "phoenix_storms/metal_plate", skin = 0, bodygroup = {} },
		["side"] = { type = "Model", model = "models/props_wasteland/horizontalcoolingtank04.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "top", pos = Vector(-0.736, -2.576, 0.358), angle = Angle(90, -78, 0), size = Vector(0.028, 0.041, 0.048), color = Color(170, 155, 149, 255), surpresslightning = false, material = "models/props_wasteland/tugboat02", skin = 0, bodygroup = {} },
		["frontbit_behind+"] = { type = "Model", model = "models/XQM/panel360.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "frontbit_behind", pos = Vector(10.821, 0, 0), angle = Angle(0, 0, 0), size = Vector(1, 0.136, 0.136), color = Color(170, 155, 149, 255), surpresslightning = false, material = "models/props_wasteland/tugboat02", skin = 0, bodygroup = {} },
		["frontbit__behind_underbit"] = { type = "Model", model = "models/hunter/tubes/tube2x2x1b.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "frontbit_behind", pos = Vector(5.613, 0.043, 0), angle = Angle(-45, 90, 90), size = Vector(0.074, 0.074, 0.231), color = Color(170, 155, 149, 255), surpresslightning = false, material = "models/props_wasteland/tugboat02", skin = 0, bodygroup = {} },
		["frontbit_behind_2"] = { type = "Model", model = "models/hunter/triangles/trapezium3x3x1a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "frontbit_behind+", pos = Vector(0, -1.275, 0), angle = Angle(-90, 90, 0), size = Vector(0.032, 0.085, 0.048), color = Color(165, 165, 165, 255), surpresslightning = false, material = "phoenix_storms/metalset_1-2", skin = 0, bodygroup = {} },
		["frontbit_behind_2+"] = { type = "Model", model = "models/hunter/triangles/trapezium3x3x1a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "frontbit_behind+", pos = Vector(-0.461, 2, 0), angle = Angle(90, 90, 0), size = Vector(0.032, 0.092, 0.089), color = Color(165, 165, 165, 255), surpresslightning = false, material = "phoenix_storms/metalset_1-2", skin = 0, bodygroup = {} },
		["frontbit_behind_bottom"] = { type = "Model", model = "models/props_docks/dock03_pole01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "frontbit_behind_2+", pos = Vector(0, 1.937, 3.118), angle = Angle(0, 0, 10), size = Vector(0.092, 0.092, 0.012), color = Color(165, 165, 165, 255), surpresslightning = false, material = "phoenix_storms/metalset_1-2", skin = 0, bodygroup = {} },
		["frontbit_behind_mp5"] = { type = "Model", model = "models/weapons/w_smg_mp5.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "frontbit_behind_2", pos = Vector(0, -2.057, -4.428), angle = Angle(0, 90, 0), size = Vector(0.977, 1.077, 0.354), color = Color(165, 165, 165, 255), surpresslightning = false, material = "phoenix_storms/metalset_1-2", skin = 0, bodygroup = {} }
	}

	-- 第一人称骨骼偏移（调整枪身位置）
	SWEP.ViewModelBoneMods = {
		["v_weapon.xm1014_Parent"] = { scale = Vector(1, 1, 1), pos = Vector(-5, -2, -3), angle = Angle(0, 0, 0) }
	}
end

-- 隐藏所有模型（完全用附加模型显示）
SWEP.ShowWorldModel = false
SWEP.ShowViewModel = false

-- 继承基础武器
SWEP.Base = "weapon_zs_base"

-- 持枪姿势（物理枪姿势，表现重型武器手感）
SWEP.HoldType = "physgun"

-- 第一人称 / 第三人称模型
SWEP.ViewModel = "models/weapons/cstrike/c_shot_xm1014.mdl"
SWEP.WorldModel = "models/weapons/w_shot_xm1014.mdl"
-- 不使用玩家手臂模型（重型外骨骼武器）
SWEP.UseHands = false

-- 单发伤害 / 单次射击弹数 / 射击间隔 / 爆头倍率 / 装填音效
SWEP.Primary.Damage = 135
SWEP.Primary.NumShots = 1
SWEP.Primary.Delay = 1
SWEP.HeadshotMulti = 1.75
SWEP.ReloadSound = Sound("ambient/machines/thumper_startup1.wav")

-- 弹匣容量（单发装填）/ 全自动 / 弹药类型 / 初始弹药
SWEP.Primary.ClipSize = 1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "357"
SWEP.Primary.DefaultClip = 9

-- 扩散：固定 0.25（射击精准）
SWEP.ConeMax = 0.25
SWEP.ConeMin = 0.25

-- 后坐力
SWEP.Recoil = 5

-- 机瞄位置与角度
SWEP.IronSightsPos = Vector(5.015, -8, 2.52)
SWEP.IronSightsAng = Vector(0, 0, 0)

-- 持枪移动速度（较慢）
SWEP.WalkSpeed = SPEED_SLOWER

-- 开火动画速度（慢速重击）
SWEP.FireAnimSpeed = 0.4

-- 特殊曳光弹效果
SWEP.TracerName = "tracer_colossus"

-- 换弹速度倍率 / 武器等级（Tier 5）
SWEP.ReloadSpeed = 1
SWEP.Tier = 5

-- 携带上限 / 子弹穿透目标数（最多 3 个）
SWEP.MaxStock = 2
SWEP.Pierces = 3

-- 强化词条：换弹速度 +0.032
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_RELOAD_SPEED, 0.032)

-- ==== ShootBullets - 发射穿透子弹（核心机制） ====
function SWEP:ShootBullets(dmg, numbul, cone)
	local owner = self:GetOwner()
	-- 播放开火动画与攻击动作
	self:SendWeaponAnimation()
	owner:DoAttackEvent()

	local dir = owner:GetAimVector()
	local dirang = dir:Angle()
	local start = owner:GetShootPos()

	-- 随机旋转弹道（表现重型弹药的散布手感）
	dirang:RotateAroundAxis(dirang:Forward(), util.SharedRandom("bulletrotate1", 0, 360))
	dirang:RotateAroundAxis(dirang:Up(), util.SharedRandom("bulletangle1", -cone, cone))

	dir = dirang:Forward()
	-- 穿透射线检测：一次性取得整条弹道上的所有命中目标
	local tr = owner:CompensatedPenetratingMeleeTrace(4092, 0.01, start, dir)
	local ent

	-- 穿透伤害递减：每穿透一个目标伤害降低 10%
	local dmgf = function(i) return dmg * (1 - 0.1 * i) end

	owner:LagCompensation(true)
	for i, trace in ipairs(tr) do
		if not trace.Hit then continue end
		-- 达到穿透上限后停止
		if i > self.Pierces - 1 then break end

		ent = trace.Entity

		-- 对每个被穿透的目标单独结算递减伤害
		if ent and ent:IsValid() then
			owner:FireBulletsLua(trace.HitPos, dir, 0, numbul, dmgf(i-1), nil, self.Primary.KnockbackScale, "", self.BulletCallback, self.Primary.HullSize, nil, self.Primary.MaxDistance, nil, self)
		end
	end
	-- 最终弹道（穿透后剩余部分）也结算一次伤害
	owner:FireBulletsLua(start, dir, cone, numbul, 0, nil, self.Primary.KnockbackScale, self.TracerName, self.BulletCallback, self.Primary.HullSize, nil, self.Primary.MaxDistance, nil, self)
	owner:LagCompensation(false)
end

-- ==== SendWeaponAnimation - 播放攻击动画并开始慢速装填 ====
function SWEP:SendWeaponAnimation()
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)

	local owner = self:GetOwner()
	local vm = owner:GetViewModel()
	local speed = self.ReloadSpeed * self:GetReloadSpeedMultiplier()

	-- 放慢开火动画播放速度（重型武器的沉重感）
	if vm:IsValid() then
		vm:SetPlaybackRate(0.25 * speed)
	end

	-- 设置装填完成时间（2.1 秒基础装填）
	self:SetReloadFinish(CurTime() + 2.1 / speed)

	if IsFirstTimePredicted() then
		-- 播放重型启动音效
		self:EmitSound("ambient/machines/thumper_startup1.wav", 70, 147, 1, CHAN_WEAPON + 21)
	end
end

-- ==== MockReload - 模拟装填（只计时，不消耗弹药） ====
function SWEP:MockReload()
	local speed = self.ReloadSpeed * self:GetReloadSpeedMultiplier()
	self:SetReloadFinish(CurTime() + 2.1 / speed)
end

-- ==== Reload - 换弹入口（手动触发模拟装填） ====
function SWEP:Reload()
	local owner = self:GetOwner()
	-- 搬运物品时禁止换弹
	if owner:IsHolding() then return end

	-- 换弹时退出机瞄
	if self:GetIronsights() then
		self:SetIronsights(false)
	end

	if self:CanReload() then
		self:MockReload()
	end
end

-- ==== Deploy - 切换出武器 ====
function SWEP:Deploy()
	self.BaseClass.Deploy(self)

	-- 空弹匣时立即开始装填
	if self:Clip1() <= 0 then
		self:MockReload()
	end

	return true
end

-- ==== Think - 每帧检查弹药状态 ====
function SWEP:Think()
	self.BaseClass.Think(self)

	-- 弹匣与备弹都为空时持续播放装填动作
	if self:Clip1() <= 0 and self:GetPrimaryAmmoCount() <= 0 then
		self:MockReload()
	end
end

-- ==== BulletCallback - 子弹命中回调：生成猎头者命中特效 ====
function SWEP.BulletCallback(attacker, tr, dmginfo)
	local effectdata = EffectData()
		effectdata:SetOrigin(tr.HitPos)
		effectdata:SetNormal(tr.HitNormal)
	util.Effect("hit_hunter", effectdata)
end

-- ==== EmitReloadSound - 换弹音效留空（使用启动音效代替） ====
function SWEP:EmitReloadSound()

end

-- ==== EmitReloadFinishSound - 装填完成音效留空 ====
function SWEP:EmitReloadFinishSound()
end

-- ==== EmitFireSound - 播放开火音效（闷响 + 电磁声双层） ====
function SWEP:EmitFireSound()
	self:EmitSound("weapons/m4a1/m4a1_unsil-1.wav", 76, 45, 0.35)
	self:EmitSound("weapons/zs_rail/rail.wav", 76, 100, 0.95, CHAN_WEAPON + 20)
end
