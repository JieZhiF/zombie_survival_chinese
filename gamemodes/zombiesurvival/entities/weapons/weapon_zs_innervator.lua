-- ============================================================================
-- weapon_zs_innervator.lua - 灵能脉冲枪（XM1014 改造连射霰弹枪，绿色激光造型）
-- 负责：连射机制（BurstShots 分轮发射）、脉冲弹药属性、SCK 激光外观、
--       客户端幽灵/换弹时的视角倾斜
-- ============================================================================

-- 共享文件：客户端也需要下载本文件
AddCSLuaFile()
-- 声明基类，供 BaseClass 调用
DEFINE_BASECLASS("weapon_zs_base")

-- 武器显示名与描述（走翻译表）
SWEP.PrintName = ""..translate.Get("weapon_zs_innervator")
SWEP.Description = ""..translate.Get("weapon_zs_innervator_description")

-- 客户端专属属性（槽位、SCK 模型元素）
if CLIENT then
	-- 武器栏位（霰弹枪位）
	SWEP.Slot = GAMEMODE:GetWeaponSlot("WeaponSelectSlotShotguns")
	SWEP.SlotGroup = WEPSELECT_SHOTGUN
	SWEP.SlotPos = 0

	-- 不翻转视图模型；视场角 49
	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 49

	-- 3D 图标（HUD 商店展示）挂在枪机骨骼上
	SWEP.HUD3DBone = "v_weapon.xm1014_Bolt"
	SWEP.HUD3DPos = Vector(-1.2, -1.1, 2)
	SWEP.HUD3DAng = Angle(0, 0, 0)
	SWEP.HUD3DScale = 0.02

	-- 视图模型骨骼修改：弹壳骨缩小（隐藏），主体放大 1.2 倍
	SWEP.ViewModelBoneMods = {
		["v_weapon.xm1014_Shell"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
		["v_weapon.xm1014_Parent"] = { scale = Vector(1.2, 1.2, 1.2), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) }
	}

	-- SCK 视图模型元素：围绕枪机拼装的绿色激光能量组件（laser 系列）
	SWEP.VElements = {
		["laser+++++"] = { type = "Model", model = "models/props_wasteland/laundry_washer001a.mdl", bone = "v_weapon.xm1014_Bolt", rel = "laser", pos = Vector(0.1, 3, -0.601), angle = Angle(180, 0, -91), size = Vector(0.019, 0.021, 0.3), color = Color(89, 89, 97, 255), surpresslightning = false, material = "models/props/de_nuke/coolingtower", skin = 0, bodygroup = {} },
		["laser+++++++++"] = { type = "Model", model = "models/props_lab/rotato.mdl", bone = "v_weapon.xm1014_Bolt", rel = "laser", pos = Vector(0.1, 4.9, 0.699), angle = Angle(180, 0, -90), size = Vector(0.449, 1, 0.1), color = Color(108, 118, 133, 255), surpresslightning = false, material = "models/props/de_train/fence_sheet01", skin = 0, bodygroup = {} },
		["laser++++"] = { type = "Model", model = "models/props_combine/combine_lock01.mdl", bone = "v_weapon.xm1014_Bolt", rel = "laser", pos = Vector(-0.301, -7.5, 0.5), angle = Angle(0, 180, -120.39), size = Vector(0.129, 0.1, 0.189), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["laser++++++++"] = { type = "Model", model = "models/props_lab/rotato.mdl", bone = "v_weapon.xm1014_Bolt", rel = "laser", pos = Vector(0.1, 9.869, 0.699), angle = Angle(180, 0, -90), size = Vector(0.5, 1, 0.1), color = Color(108, 118, 133, 255), surpresslightning = false, material = "models/props/de_train/fence_sheet01", skin = 0, bodygroup = {} },
		["laser+++++++"] = { type = "Model", model = "models/props_lab/rotato.mdl", bone = "v_weapon.xm1014_Bolt", rel = "laser", pos = Vector(0.1, -4.901, 0.699), angle = Angle(180, 0, -90), size = Vector(0.349, 1, 0.4), color = Color(108, 118, 133, 255), surpresslightning = false, material = "models/props/de_train/fence_sheet01", skin = 0, bodygroup = {} },
		["laser++"] = { type = "Model", model = "models/props_combine/combine_generator01.mdl", bone = "v_weapon.xm1014_Bolt", rel = "laser", pos = Vector(-1, 15, 2), angle = Angle(0, 180, 90), size = Vector(0.079, 0.039, 0.119), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["laser"] = { type = "Model", model = "models/props_pipes/pipe02_straight01_long.mdl", bone = "v_weapon.xm1014_Bolt", rel = "", pos = Vector(0, -1.601, -2.401), angle = Angle(0, 0, 90), size = Vector(0.2, 0.2, 0.2), color = Color(0, 255, 186, 255), surpresslightning = false, material = "models/props_lab/eyescanner_disp", skin = 0, bodygroup = {} },
		["laser+++"] = { type = "Model", model = "models/props_combine/combine_generator01.mdl", bone = "v_weapon.xm1014_Bolt", rel = "laser", pos = Vector(-0.22, 16, -0.5), angle = Angle(180, 0, 90), size = Vector(0.029, 0.059, 0.15), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["laser+"] = { type = "Model", model = "models/props_pipes/pipe02_straight01_long.mdl", bone = "v_weapon.xm1014_Bolt", rel = "laser", pos = Vector(0, 16.104, 0), angle = Angle(0, 0, 0), size = Vector(0.25, 0.25, 0.2), color = Color(0, 255, 186, 255), surpresslightning = false, material = "models/props_lab/eyescanner_disp", skin = 0, bodygroup = {} },
		["laser++++++"] = { type = "Model", model = "models/props_wasteland/laundry_washer001a.mdl", bone = "v_weapon.xm1014_Bolt", rel = "laser", pos = Vector(0.1, 3, 2.5), angle = Angle(180, 0, -90), size = Vector(0.029, 0.029, 0.449), color = Color(89, 89, 97, 255), surpresslightning = false, material = "models/props/de_nuke/coolingtower", skin = 0, bodygroup = {} }
	}

	-- SCK 世界模型元素：第三人称下的绿色激光外观
	SWEP.WElements = {
		["laser+++++"] = { type = "Model", model = "models/props_wasteland/laundry_washer001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "laser", pos = Vector(0.1, 3, -0.601), angle = Angle(180, 0, -91), size = Vector(0.019, 0.021, 0.3), color = Color(89, 89, 97, 255), surpresslightning = false, material = "models/props/de_nuke/coolingtower", skin = 0, bodygroup = {} },
		["laser++++++++"] = { type = "Model", model = "models/props_lab/rotato.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "laser", pos = Vector(0.1, 9.869, 0.699), angle = Angle(180, 0, -90), size = Vector(0.5, 1, 0.1), color = Color(108, 118, 133, 255), surpresslightning = false, material = "models/props/de_train/fence_sheet01", skin = 0, bodygroup = {} },
		["laser+++++++++"] = { type = "Model", model = "models/props_lab/rotato.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "laser", pos = Vector(0.1, 4.9, 0.699), angle = Angle(180, 0, -90), size = Vector(0.449, 1, 0.1), color = Color(108, 118, 133, 255), surpresslightning = false, material = "models/props/de_train/fence_sheet01", skin = 0, bodygroup = {} },
		["laser++++"] = { type = "Model", model = "models/props_combine/combine_lock01.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "laser", pos = Vector(-0.301, -7.5, 0.5), angle = Angle(0, 180, -120.39), size = Vector(0.129, 0.1, 0.189), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["laser+++++++"] = { type = "Model", model = "models/props_lab/rotato.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "laser", pos = Vector(0.009, -4.901, 0.699), angle = Angle(180, 0, -90), size = Vector(0.349, 1, 0.4), color = Color(108, 118, 133, 255), surpresslightning = false, material = "models/props/de_train/fence_sheet01", skin = 0, bodygroup = {} },
		["laser+++"] = { type = "Model", model = "models/props_combine/combine_generator01.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "laser", pos = Vector(-0.22, 16, -0.5), angle = Angle(180, 0, 90), size = Vector(0.029, 0.059, 0.15), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["laser+"] = { type = "Model", model = "models/props_pipes/pipe02_straight01_long.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "laser", pos = Vector(0, 16.104, 0), angle = Angle(0, 0, 0), size = Vector(0.25, 0.25, 0.2), color = Color(0, 255, 186, 255), surpresslightning = false, material = "models/props_lab/eyescanner_disp", skin = 0, bodygroup = {} },
		["laser++"] = { type = "Model", model = "models/props_combine/combine_generator01.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "laser", pos = Vector(-1, 15, 2), angle = Angle(0, 180, 90), size = Vector(0.079, 0.039, 0.119), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["laser"] = { type = "Model", model = "models/props_pipes/pipe02_straight01_long.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(8, 1, -5), angle = Angle(0, 90, 10), size = Vector(0.2, 0.2, 0.2), color = Color(0, 255, 186, 255), surpresslightning = false, material = "models/props_lab/eyescanner_disp", skin = 0, bodygroup = {} },
		["laser++++++"] = { type = "Model", model = "models/props_wasteland/laundry_washer001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "laser", pos = Vector(0.1, 3, 2.5), angle = Angle(180, 0, -90), size = Vector(0.029, 0.029, 0.449), color = Color(89, 89, 97, 255), surpresslightning = false, material = "models/props/de_nuke/coolingtower", skin = 0, bodygroup = {} }
	}
end

-- 继承基础武器基类（武器母本）
SWEP.Base = "weapon_zs_base"

-- 持枪姿势（霰弹枪姿势）
SWEP.HoldType = "shotgun"

-- 使用 XM1014 的视图/世界模型作为骨架
SWEP.ViewModel = "models/weapons/cstrike/c_shot_xm1014.mdl"
SWEP.WorldModel = "models/weapons/w_shot_xm1014.mdl"
SWEP.UseHands = true

-- 主攻击：脉冲枪声、每轮 5 弹片 × 11 伤害、1.6 秒开火间隔
SWEP.Primary.Sound = Sound("weapons/zs_inner/innershot.ogg")
-- 换弹音效（引擎启动声）
SWEP.ReloadSound = Sound("ambient/machines/thumper_startup1.wav")
SWEP.Primary.Damage = 11
SWEP.Primary.NumShots = 5
SWEP.Primary.Delay = 1.6
-- 子弹最大射程 288 单位；每次开火连射 5 轮（由 Think 分轮发射）
SWEP.Primary.MaxDistance = 288
SWEP.Primary.BurstShots = 5

-- 弹匣 30 发、全自动、使用脉冲弹药；默认弹量由 SetupDefaultClip 按规则补满
SWEP.Primary.ClipSize = 30
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "pulse"
SWEP.WeaponType = "pulse"
GAMEMODE:SetupDefaultClip(SWEP.Primary)

-- 换弹速度
SWEP.ReloadSpeed = 0.33

-- 开火所需的最小弹匣存量
SWEP.RequiredClip = 6

-- 扩散：最大 6.5 / 最小 5
SWEP.ConeMax = 6.5
SWEP.ConeMin = 5

-- 持枪移动速度（慢速）；武器等级 4
SWEP.WalkSpeed = SPEED_SLOWER

SWEP.Tier = 4

-- 武器强化修饰器：最大扩散 -0.8125，最小扩散 -0.625
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_MAX_SPREAD, -0.8125)
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_MIN_SPREAD, -0.625)

-- 电压式曳光弹特效
SWEP.TracerName = "tracer_volt"

-- ==== EmitFireSound - 播放开火音效（低音铺垫 + 脉冲主声） ====
function SWEP:EmitFireSound()
	self:EmitSound("weapons/m4a1/m4a1_unsil-1.wav", 85, 130, 0.65)
	self:EmitSound("weapons/zs_inner/innershot.ogg", 85, 128, 0.85, CHAN_WEAPON + 20)
end

-- ==== SendReloadAnimation - 换弹时播放出枪动画 ====
function SWEP:SendReloadAnimation()
	self:SendWeaponAnim(ACT_VM_DRAW)
end

-- ==== SecondaryAttack - 副攻击无功能 ====
function SWEP:SecondaryAttack()
end

-- ==== EmitReloadSound - 换弹开始音效（扫描声 + 电池拾取声） ====
function SWEP:EmitReloadSound()
	-- 仅本机首次预测时播放（避免重复音）
	if IsFirstTimePredicted() then
		self:EmitSound("npc/scanner/combat_scan1.wav", 70, 15, 0.9, CHAN_WEAPON + 21)
		self:EmitSound("items/battery_pickup.wav", 70, 47, 0.85, CHAN_WEAPON + 22)
	end
end

-- ==== EmitReloadFinishSound - 换弹完成音效（扫描完成声） ====
function SWEP:EmitReloadFinishSound()
	if IsFirstTimePredicted() then
		self:EmitSound("npc/scanner/combat_scan2.wav", 70, 135)
	end
end

-- ==== PrimaryAttack - 开火：消耗弹药并启动一轮连射 ====
function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end

	-- 设置开火冷却并播放音效
	self:SetNextPrimaryFire(CurTime() + self:GetFireDelay())
	self:EmitFireSound()

	-- 消耗弹药，初始化连射计数与首发射击时间
	self:TakeAmmo()
	self:SetNextShot(CurTime())
	self:SetShotsLeft(self.Primary.BurstShots)

	self.IdleAnimation = CurTime() + self:SequenceDuration()
end

-- ==== Think - 连射循环：按间隔逐轮发射子弹，换弹时中断 ====
function SWEP:Think()
	BaseClass.Think(self)

	-- 还有剩余轮次且到达下一发射时间时继续发射
	local shotsleft = self:GetShotsLeft()
	if shotsleft > 0 and CurTime() >= self:GetNextShot() then
		-- 递减轮次，下一轮间隔为开火延迟的 1/12（快速连射）
		self:SetShotsLeft(shotsleft - 1)
		self:SetNextShot(CurTime() + self:GetFireDelay()/12)

		-- 换弹中则立即终止连射
		if self:GetReloadFinish() == 0 then
			self:EmitFireSound()
			self:ShootBullets(self.Primary.Damage, self.Primary.NumShots, self:GetCone())

			self.IdleAnimation = CurTime() + self:SequenceDuration()
		else
			self:SetShotsLeft(0)
		end
	end
end

-- ==== SetNextShot - 记录下一发射时间（DTFloat 5） ====
function SWEP:SetNextShot(nextshot)
	self:SetDTFloat(5, nextshot)
end

-- ==== GetNextShot - 读取下一发射时间 ====
function SWEP:GetNextShot()
	return self:GetDTFloat(5)
end

-- ==== SetShotsLeft - 记录剩余连射轮次（DTInt 1） ====
function SWEP:SetShotsLeft(shotsleft)
	self:SetDTInt(1, shotsleft)
end

-- ==== GetShotsLeft - 读取剩余连射轮次 ====
function SWEP:GetShotsLeft()
	return self:GetDTInt(1)
end

-- 以下代码仅客户端执行（服务端到此为止）
if not CLIENT then return end

-- 视角倾斜插值状态（0 = 正常，1 = 完全倾斜）
local ghostlerp = 0
-- ==== CalcViewModelView - 放置路障幽灵或换弹时让枪口向下倾斜 ====
function SWEP:CalcViewModelView(vm, oldpos, oldang, pos, ang)
	-- 处于幽灵放置或换弹状态时平滑增大倾斜系数
	if self:GetOwner():GetBarricadeGhosting() or self:GetReloadFinish() > 0 then
		ghostlerp = math.min(1, ghostlerp + FrameTime() * 2)
	elseif ghostlerp > 0 then
		-- 否则平滑回落
		ghostlerp = math.max(0, ghostlerp - FrameTime() * 2.5)
	end

	-- 按倾斜系数把视角绕右轴下压最多 35 度
	if ghostlerp > 0 then
		ang:RotateAroundAxis(ang:Right(), -35 * ghostlerp)
	end

	return pos, ang
end
