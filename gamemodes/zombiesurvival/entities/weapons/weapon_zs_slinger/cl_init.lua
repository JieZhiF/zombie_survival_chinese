-- ============================================================================
-- weapon_zs_slinger/cl_init.lua - 弹弓（客户端）
-- 负责：HUD 3D 展示、火车轨道+弩箭的弹弓造型（第一/三人称）、换弹时装填动画
-- ============================================================================

INC_CLIENT()

-- HUD 3D 模型挂点：滑套骨骼
SWEP.HUD3DBone = "v_weapon.p228_Slide"
-- HUD 3D 模型偏移位置
SWEP.HUD3DPos = Vector(-1.4, 0.15, 0)
-- HUD 3D 模型旋转角度
SWEP.HUD3DAng = Angle(0, 0, 0)
-- HUD 3D 模型缩放
SWEP.HUD3DScale = 0.017

-- 第一人称附加模型：火车轨道基座 + 弩箭的弹弓造型
SWEP.VElements = {
	["BACKING+"] = { type = "Model", model = "models/props_wasteland/light_spotlight02_base.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "train", pos = Vector(-0.101, -1.787, -0.027), angle = Angle(111.536, 90, 0), size = Vector(0.18, 0.504, 1.327), color = Color(75, 75, 75, 255), surpresslightning = false, material = "models/props_canal/metalwall005b", skin = 0, bodygroup = {} },
	["BOLT"] = { type = "Model", model = "models/crossbow_bolt.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "train", pos = Vector(-0.042, 11.982, 1.141), angle = Angle(0, 90, 0), size = Vector(0.65, 0.65, 0.65), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["train"] = { type = "Model", model = "models/props_combine/combine_train02a.mdl", bone = "v_weapon.p228_Parent", rel = "", pos = Vector(0, -3.579, -2.291), angle = Angle(180, 0, -90), size = Vector(0.023, 0.019, 0.009), color = Color(100, 100, 100, 255), surpresslightning = false, material = "models/props_canal/metalwall005b", skin = 0, bodygroup = {} },
	["backa"] = { type = "Model", model = "models/props_wasteland/tram_bracket01.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "train", pos = Vector(-0.065, 4.964, 0.18), angle = Angle(0, -90, 0), size = Vector(0.043, 0.043, 0.043), color = Color(100, 100, 100, 255), surpresslightning = false, material = "models/props_canal/metalwall005b", skin = 0, bodygroup = {} },
	["BACKING"] = { type = "Model", model = "models/props_wasteland/light_spotlight02_base.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "train", pos = Vector(-0.062, -3.317, 1.368), angle = Angle(93.779, 90, 0), size = Vector(0.18, 0.504, 1.327), color = Color(75, 75, 75, 255), surpresslightning = false, material = "models/props_canal/metalwall005b", skin = 0, bodygroup = {} }
}

-- 世界模型附加模型：第三人称对应的弹弓造型
SWEP.WElements = {
	["BACKING+"] = { type = "Model", model = "models/props_wasteland/light_spotlight02_base.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "train", pos = Vector(-0.101, -1.787, -0.027), angle = Angle(111.536, 90, 0), size = Vector(0.18, 0.504, 1.327), color = Color(100, 100, 100, 255), surpresslightning = false, material = "models/props_canal/metalwall005b", skin = 0, bodygroup = {} },
	["BOLT"] = { type = "Model", model = "models/crossbow_bolt.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "train", pos = Vector(-0.042, 11, 1.141), angle = Angle(0, 90, 0), size = Vector(0.65, 0.65, 0.65), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["train"] = { type = "Model", model = "models/props_combine/combine_train02a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(7.178, 1.909, -3.55), angle = Angle(180, 85.359, -2.799), size = Vector(0.023, 0.019, 0.009), color = Color(100, 100, 100, 255), surpresslightning = false, material = "models/props_canal/metalwall005b", skin = 0, bodygroup = {} },
	["BACKING"] = { type = "Model", model = "models/props_wasteland/light_spotlight02_base.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "train", pos = Vector(-0.062, -3.317, 1.368), angle = Angle(93.779, 90, 0), size = Vector(0.18, 0.504, 1.327), color = Color(75, 75, 75, 255), surpresslightning = false, material = "models/props_canal/metalwall005b", skin = 0, bodygroup = {} },
	["backa"] = { type = "Model", model = "models/props_wasteland/tram_bracket01.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "train", pos = Vector(-0.065, 4.964, 0.18), angle = Angle(0, -90, 0), size = Vector(0.043, 0.043, 0.043), color = Color(100, 100, 100, 255), surpresslightning = false, material = "models/props_canal/metalwall005b", skin = 0, bodygroup = {} }
}

-- 第一人称镜头视野
SWEP.ViewModelFOV = 65
-- 不翻转第一人称模型
SWEP.ViewModelFlip = false

-- 武器槽位：弩箭类
SWEP.Slot = GAMEMODE:GetWeaponSlot("WeaponSelectSlotBolt")
-- 武器选择分组：弩箭
SWEP.SlotGroup = WEPSELECT_BOLT
-- 槽内位置 0
SWEP.SlotPos = 0

-- ==== ShootBullets - 发射投射物（客户端预测表现） ====
function SWEP:ShootBullets(damage, numshots, cone)
	local owner = self:GetOwner()
	-- 播放开火动画与攻击事件
	self:SendWeaponAnimation()
	owner:DoAttackEvent()

	-- 有后坐力时施加随机视角抖动（后坐力方向随机左右偏）
	if self.Recoil > 0 then
		local r = math.Rand(0.8, 1)
		owner:ViewPunch(Angle(r * -self.Recoil, 0, (1 - r) * (math.random(2) == 1 and -1 or 1) * self.Recoil))
	end

	-- 记录发射时间
	self.ProjShootTime = CurTime()
end


-- ==== PostDrawViewModel - 第一人称模型绘制后处理（换弹装填动画） ====
function SWEP:PostDrawViewModel(vm, pl, wep)
	-- 绘制 HUD 3D 武器图标（若游戏模式允许）
	if self.HUD3DPos and GAMEMODE:ShouldDraw3DWeaponHUD() then
		local pos, ang = self:GetHUD3DPos(vm)
		if pos then
			self:Draw3DHUD(vm, pos, ang)
		end
	end

	local veles = self.VElements

	-- 弩箭模型与背板模型引用
	local boltpos = veles["BOLT"].pos
	local backang = veles["BACKING"].angle

	local time = CurTime()
	-- 换弹完成/开始时间戳
	local reloadfinish = self:GetReloadFinish()
	local reloadstart = self:GetReloadStart()

	-- 弩箭颜色：换弹中不可见（透明），装填完成后高亮发光（黄色）
	local col1, col2 = Color(0, 0, 0, 0), Color(255, 255, 140, 255)
	if (reloadfinish == 0 and self:Clip1() < 1) or (reloadfinish - time * 5) > (time - reloadstart) then
		veles["BOLT"].color = col1
	else
		veles["BOLT"].color = col2
	end

	-- 换弹过程中：弩箭沿导轨前移（装填推进动画），背板随之倾斜
	if time < reloadfinish then
		-- 取换弹进度两端较小值并归一化（0-1 进度）
		local lowertime = math.min(reloadfinish - time, time - reloadstart)
		local delta = math.Clamp(lowertime * 4 / (reloadfinish - reloadstart), 0, 1)

		-- 弩箭位置从装填起点插值到就位位置
		boltpos.y = Lerp(delta, 11, 5)
		backang.pitch = Lerp(delta, 105, 120)
	else
		-- 换弹完成：弩箭就位，背板复位
		boltpos.y = 11
		backang.pitch = 95
	end
end
