-- ============================================================================
-- weapon_zs_amigo.lua - 阿米戈突击步枪（可强化改装）
-- 负责：SG552 风格步枪的基础属性，以及两个强化分支：分支1 改装为侧翼榴弹
--       射手，分支2 改装为三连发精确射手步枪（带瞄准镜）
-- ============================================================================
AddCSLuaFile()
-- 声明基类引用（供分支代码调用 BaseClass 方法）
DEFINE_BASECLASS("weapon_zs_base")

-- 显示名称与描述
SWEP.PrintName = ""..translate.Get("weapon_zs_amigo")
SWEP.Description = ""..translate.Get("weapon_zs_amigo_description")


-- 武器栏内位置
SWEP.SlotPos = 0

if CLIENT then
    -- 武器栏：突击步枪槽
    SWEP.Slot = GAMEMODE:GetWeaponSlot("WeaponSelectSlotAssaultRifles")
	-- 武器类型：步枪
	SWEP.WeaponType = "rifle"
    SWEP.SlotGroup = WEPSELECT_ASSAULT_RIFLE
	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 55

	-- HUD 3D 图标（大图标预览）参数
	SWEP.HUD3DBone = "v_weapon.sg552_Parent"
	SWEP.HUD3DPos = Vector(-2.12, -6.25, -2)
	SWEP.HUD3DAng = Angle(0, -6, 0)
	SWEP.HUD3DScale = 0.015
end

SWEP.Base = "weapon_zs_base"

-- 持枪姿势
SWEP.HoldType = "ar2"

-- 模型与手臂
SWEP.ViewModel = "models/weapons/cstrike/c_rif_sg552.mdl"
SWEP.WorldModel = "models/weapons/w_rif_sg552.mdl"
SWEP.UseHands = true

-- 换弹/开火音效与基础伤害
SWEP.ReloadSound = Sound("Weapon_SG552.Clipout")
SWEP.Primary.Sound = Sound("Weapon_SG552.Single")
SWEP.Primary.Damage = 18.5
SWEP.Primary.NumShots = 1
SWEP.Primary.Delay = 0.15

-- 弹匣与自动射击
SWEP.Primary.ClipSize = 25
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "ar2"
GAMEMODE:SetupDefaultClip(SWEP.Primary)

-- 扩散与爆头倍率
SWEP.ConeMax = 2
SWEP.ConeMin = 0.8
SWEP.HeadshotMulti = 2.1

-- 换弹速度倍率
SWEP.ReloadSpeed = 0.9

-- 移动速度
SWEP.WalkSpeed = SPEED_SLOW

-- 武器等级
SWEP.Tier = 2

-- 机瞄位置
SWEP.IronSightsPos = Vector(-5, 1, 3)
SWEP.IronSightsAng = Vector(0, 0, 0)

-- 强化：射速提升 + 爆头倍率提升
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_FIRE_DELAY, -0.01, 1)
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_HEADSHOT_MULTI, 0.07)
-- ==== 强化分支 1：榴弹射手 ====
-- 加大扩散、伤害降至 0.8 倍、弹匣扩到 35 发；每跨过 10 发子弹的边界时，
-- 从侧向额外发射一发强化榴弹（伤害 = 武器伤害 × 1.75）
GAMEMODE:AddNewRemantleBranch(SWEP, 1, ""..translate.Get("weapon_zs_amigo_r1"), ""..translate.Get("weapon_zs_amigo_r1_description"), function(wept)
	wept.ConeMax = wept.ConeMax * 1.5
	wept.ConeMin = wept.ConeMin * 1.5
	wept.Primary.Damage = wept.Primary.Damage * 0.8
	wept.Primary.ClipSize = 35

	-- ==== ShootBullets - 覆盖射击逻辑 ====
	-- 播放射击动画；子弹数每跨过 10 的边界时额外侧向发射一发强化榴弹
	wept.ShootBullets = function(self, dmg, numbul, cone)
		local owner = self:GetOwner()

		self:SendWeaponAnimation()
		owner:DoAttackEvent()

		if SERVER and self:Clip1() % 10 == 1 then
			local ent = ents.Create("projectile_juggernaut")
			if ent:IsValid() then
				ent:SetPos(owner:GetShootPos())

				-- 先绕上轴旋转 90° 定位弹体朝向
				local angle = owner:GetAimVector():Angle()
				angle:RotateAroundAxis(angle:Up(), 90)
				ent:SetAngles(angle)

				ent:SetOwner(owner)
				ent.ProjDamage = self.Primary.Damage * 1.75 * (owner.ProjectileDamageMul or 1)
				ent.ProjSource = self
				ent.Team = owner:Team()

				ent:Spawn()

				-- 发射：随机环绕角 + 锥形散布，出膛速度 700
				local phys = ent:GetPhysicsObject()
				if phys:IsValid() then
					phys:Wake()

					angle = owner:GetAimVector():Angle()
					angle:RotateAroundAxis(angle:Forward(), math.Rand(0, 360))
					angle:RotateAroundAxis(angle:Up(), math.Rand(-cone/1.5, cone/1.5))
					phys:SetVelocityInstantaneous(angle:Forward() * 700 * (owner.ProjectileSpeedMul or 1))
				end
			end
		end

		-- 延迟补偿后按常规逻辑发射子弹
		owner:LagCompensation(true)
		owner:FireBulletsLua(owner:GetShootPos(), owner:GetAimVector(), cone, numbul, dmg, nil, self.Primary.KnockbackScale, self.TracerName, self.BulletCallback, self.Primary.HullSize, nil, self.Primary.MaxDistance, nil, self)
		owner:LagCompensation(false)
	end
end)

-- ==== 强化分支 2：三连发精确射手步枪 ====
-- 伤害 ×1.12、射速放慢 6 倍但改为 3 发点射、扩散大减；外观换成 FAMAS，
-- 并附带狙击镜与开镜画面
local branch = GAMEMODE:AddNewRemantleBranch(SWEP, 2, ""..translate.Get("weapon_zs_amigo_r2"), ""..translate.Get("weapon_zs_amigo_r2_description"), function(wept)
	wept.Primary.Damage = wept.Primary.Damage * 1.12
	wept.Primary.Delay = wept.Primary.Delay * 6
	wept.Primary.BurstShots = 3
	wept.ConeMin = wept.ConeMin * 0.6
	wept.ConeMax = wept.ConeMax * 0.85

	-- ==== PrimaryAttack - 覆盖左键：启动一轮点射 ====
	wept.PrimaryAttack = function(self)
		if not self:CanPrimaryAttack() then return end

		self:SetNextPrimaryFire(CurTime() + self:GetFireDelay())
		self:EmitFireSound()

		self:SetNextShot(CurTime())
		self:SetShotsLeft(self.Primary.BurstShots)

		self.IdleAnimation = CurTime() + self:SequenceDuration()
	end

	-- ==== Think - 覆盖每帧：按极短间隔打出点射剩余子弹 ====
	wept.Think = function(self)
		BaseClass.Think(self)

		local shotsleft = self:GetShotsLeft()
		if shotsleft > 0 and CurTime() >= self:GetNextShot() then
			self:SetShotsLeft(shotsleft - 1)
			self:SetNextShot(CurTime() + self:GetFireDelay()/12)

			-- 有子弹且不在换弹中才继续发射，否则中断点射
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

	wept.ViewModel = "models/weapons/cstrike/c_rif_famas.mdl"
	wept.WorldModel = "models/weapons/w_rif_famas.mdl"

	-- ==== EmitFireSound - 点射开火音效（FAMAS 声） ====
	wept.EmitFireSound = function(self)
		self:EmitSound("weapons/famas/famas-1.wav", 75, math.random(80, 85), 0.8)
		self:EmitSound("npc/sniper/echo1.wav", 75, math.random(81, 85), 1, CHAN_WEAPON+20)
	end

	if CLIENT then
		-- 分支2 的瞄准镜视图模型拼装件
		wept.VElements = {
			["underside"] = { type = "Model", model = "models/props_combine/combine_train02a.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "scope", pos = Vector(0, 5.438, 8.074), angle = Angle(0, 0, 88), size = Vector(0.024, 0.021, 0.013), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
			["scopeback+"] = { type = "Model", model = "models/props_wasteland/laundry_basket001.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "scope", pos = Vector(0, 0, 4.012), angle = Angle(0, 0, 0), size = Vector(0.025, 0.025, 0.017), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
			["mid"] = { type = "Model", model = "models/props_phx/trains/double_wheels.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "scope", pos = Vector(0.726, 0.008, 1.82), angle = Angle(90, 90, -90), size = Vector(0.02, 0.02, 0.016), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
			["top"] = { type = "Model", model = "models/props_borealis/mooring_cleat01.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "scope", pos = Vector(0, 0, 1.815), angle = Angle(0, 0, -90), size = Vector(0.048, 0.039, 0.034), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
			["scopeback"] = { type = "Model", model = "models/props_wasteland/laundry_basket001.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "scope", pos = Vector(0, 0, -0.29), angle = Angle(180, 0, 0), size = Vector(0.025, 0.025, 0.017), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
			["glass"] = { type = "Model", model = "models/XQM/panel360.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "scope", pos = Vector(0, 0, -0.285), angle = Angle(90, 0, 0), size = Vector(0.123, 0.023, 0.023), color = Color(0, 0, 115, 255), surpresslightning = false, material = "models/props/cs_office/snowmana", skin = 0, bodygroup = {} },
			["scope"] = { type = "Model", model = "models/hunter/tubes/tube1x1x2.mdl", bone = "v_weapon.famas", rel = "", pos = Vector(0.082, -5.666, 9.55), angle = Angle(0, 0, 1.254), size = Vector(0.025, 0.025, 0.039), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
			["back"] = { type = "Model", model = "models/items/combine_rifle_cartridge01.mdl", bone = "v_weapon.famas", rel = "", pos = Vector(0.104, -1.573, 10.755), angle = Angle(90, 90.005, 0), size = Vector(0.361, 0.476, 0.597), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
			["hold"] = { type = "Model", model = "models/props_c17/playgroundTick-tack-toe_post01.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "scope", pos = Vector(0, 0.694, 1.85), angle = Angle(0, 0, -90), size = Vector(0.152, 0.041, 0.009), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
			["midsection"] = { type = "Model", model = "models/props_combine/eli_pod_inner.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "scope", pos = Vector(0, 3.048, 13.31), angle = Angle(0.15, 90, 180), size = Vector(0.15, 0.107, 0.194), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} }
		}
		-- 分支2 的第三人称拼装件
		wept.WElements = {
			["underside"] = { type = "Model", model = "models/props_combine/combine_train02a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "scope", pos = Vector(0, 6.301, 10.373), angle = Angle(0, 0, 88), size = Vector(0.025, 0.027, 0.01), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
			["scopeback+"] = { type = "Model", model = "models/props_wasteland/laundry_basket001.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "scope", pos = Vector(0, 0, 4.012), angle = Angle(0, 0, 0), size = Vector(0.025, 0.025, 0.017), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
			["mid"] = { type = "Model", model = "models/props_phx/trains/double_wheels.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "scope", pos = Vector(0.811, -0.03, 1.82), angle = Angle(90, 90, -90), size = Vector(0.02, 0.02, 0.017), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
			["top"] = { type = "Model", model = "models/props_borealis/mooring_cleat01.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "scope", pos = Vector(0, 0, 1.815), angle = Angle(0, 0, -90), size = Vector(0.048, 0.039, 0.034), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
			["scopeback"] = { type = "Model", model = "models/props_wasteland/laundry_basket001.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "scope", pos = Vector(0, 0, -0.29), angle = Angle(180, 0, 0), size = Vector(0.025, 0.025, 0.017), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
			["glass"] = { type = "Model", model = "models/XQM/panel360.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "scope", pos = Vector(0, 0, -0.424), angle = Angle(90, 0, 0), size = Vector(0.123, 0.023, 0.023), color = Color(0, 0, 115, 255), surpresslightning = false, material = "models/props/cs_office/snowmana", skin = 0, bodygroup = {} },
			["scope"] = { type = "Model", model = "models/hunter/tubes/tube1x1x2.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(-0.99, 0.794, -8.33), angle = Angle(0, -90, -99.326), size = Vector(0.025, 0.025, 0.039), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
			["back"] = { type = "Model", model = "models/items/combine_rifle_cartridge01.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "scope", pos = Vector(0, 4.708, 1.435), angle = Angle(90, 90.005, 0), size = Vector(0.361, 0.583, 0.708), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
			["hold"] = { type = "Model", model = "models/props_c17/playgroundTick-tack-toe_post01.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "scope", pos = Vector(0, 0.694, 1.85), angle = Angle(0, 0, -90), size = Vector(0.152, 0.041, 0.009), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
			["midsection"] = { type = "Model", model = "models/props_combine/eli_pod_inner.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "scope", pos = Vector(0, 3.368, 17.281), angle = Angle(0.15, 90, 180), size = Vector(0.185, 0.151, 0.245), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
			["glass+"] = { type = "Model", model = "models/XQM/panel360.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "scope", pos = Vector(0, 0, 4.243), angle = Angle(90, 0, 0), size = Vector(0.123, 0.023, 0.023), color = Color(0, 0, 115, 255), surpresslightning = false, material = "models/props/cs_office/snowmana", skin = 0, bodygroup = {} }
		}

		-- 分支2 的 HUD 3D 图标参数与狙击镜属性
		wept.HUD3DBone = "v_weapon.famas"
		wept.HUD3DPos = Vector(-0.2, -4, 8.6)
		wept.HUD3DAng = BaseClass.HUD3DAng
		wept.SniperRifle = true
		wept.IronsightsMultiplier = 0.25

		-- ==== GetViewModelPosition - 开镜时锁定视角位置 ====
		-- 禁用瞄准镜时或已开镜时不做视角偏移，保持瞄准画面稳定
		wept.GetViewModelPosition = function(self, pos, ang)
			if GAMEMODE.DisableScopes then return end

			if self:IsScoped() then return end

			return BaseClass.GetViewModelPosition(self, pos, ang)
		end

		-- ==== DrawHUDBackground - 绘制狙击镜画面 ====
		wept.DrawHUDBackground = function(self)
			if GAMEMODE.DisableScopes then return end

			if self:IsScoped() then
				self:DrawRegularScope()
			end
		end
	end
end)
-- 分支2 的分级配色、等级名称与击杀图标
branch.Colors = {Color(110, 160, 170), Color(90, 140, 150), Color(70, 120, 130)}
branch.NewNames = {""..translate.Get("weapon_zs_amigo_r2_l1"), ""..translate.Get("weapon_zs_amigo_r2_l2"), ""..translate.Get("weapon_zs_amigo_r2_l3")}
branch.Killicon = "weapon_zs_battlerifle"

-- ==== IsScoped - 是否处于开镜状态 ====
-- 机瞄开启且持续超过 0.25 秒才视为开镜
function SWEP:IsScoped()
	return self:GetIronsights() and self.fIronTime and self.fIronTime + 0.25 <= CurTime()
end

-- ==== SetNextShot - 设置下一次点射子弹的时间 ====
-- 通过网络变量同步（DT 槽 5）
function SWEP:SetNextShot(nextshot)
	self:SetDTFloat(5, nextshot)
end

-- ==== GetNextShot - 获取下一次点射子弹的时间 ====
function SWEP:GetNextShot()
	return self:GetDTFloat(5)
end

-- ==== SetShotsLeft - 设置剩余点射子弹数 ====
-- 通过网络变量同步（DT 槽 1）
function SWEP:SetShotsLeft(shotsleft)
	self:SetDTInt(1, shotsleft)
end

-- ==== GetShotsLeft - 获取剩余点射子弹数 ====
function SWEP:GetShotsLeft()
	return self:GetDTInt(1)
end
