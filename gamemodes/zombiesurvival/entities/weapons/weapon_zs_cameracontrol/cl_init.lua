-- ============================================================================
-- weapon_zs_cameracontrol/cl_init.lua - 监控摄像头遥控器（客户端定义）
-- 负责：手持小电视模型、摄像头画面渲染到屏幕纹理的完整流程
-- ============================================================================
-- 客户端专用（GMod 武器文件的标准客户端入口标记）
INC_CLIENT()
-- 武器槽位（可部署物品槽）/ 槽位分组
SWEP.Slot = GAMEMODE:GetWeaponSlot("WeaponSelectSlotDeployables")
SWEP.SlotGroup = WEPSELECT_DEPLOYABLE

-- 第一人称视野 / 模型翻转
SWEP.ViewModelFOV = 45
SWEP.ViewModelFlip = false

-- 行走/摆动幅度（持摄像机时画面更稳）
SWEP.BobScale = 0.15
SWEP.SwayScale = 0.15

-- 隐藏原始模型（用附加模型替代显示）
SWEP.ShowViewModel = false
SWEP.ShowWorldModel = false

-- 第一人称附加模型：手持小电视（绑定右手）
SWEP.VElements = {
	["base"] = { type = "Model", model = "models/props_c17/tv_monitor01.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(7.791, 3.635, -1.558), angle = Angle(0, -118.053, 180), size = Vector(0.1, 0.5, 0.5), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}

-- 第三人称附加模型：小电视 + 屏幕（带噪点材质）
SWEP.WElements = {
	["base"] = { type = "Model", model = "models/props_c17/tv_monitor01.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(4.675, 4.5, -1.558), angle = Angle(0, 180, 180), size = Vector(0.1, 0.4, 0.4), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["base+"] = { type = "Model", model = "models/props_c17/tv_monitor01_screen.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(0, 0, 0), angle = Angle(0, 0, 0), size = Vector(0.1, 0.4, 0.4), color = Color(255, 255, 255, 255), surpresslightning = false, material = "effects/tvscreen_noise003a", skin = 0, bodygroup = {} }
}

-- 第一人称手臂骨骼偏移（举起电视的姿势）
SWEP.ViewModelBoneMods = {
	["ValveBiped.Bip01_R_UpperArm"] = { scale = Vector(1, 1, 1), pos = Vector(0, 4, 3), angle = Angle(0, 0, 0) }
}

-- ==== Initialize - 武器初始化（自己持有时挂载渲染 hook） ====
function SWEP:Initialize()
	self.BaseClass.Initialize(self)

	if self:GetOwner() == MySelf then
		hook.Add("RenderScene", self, self.RenderScene)
	end
end

-- ==== DrawWeaponSelection - 使用基础武器选择绘制 ====
function SWEP:DrawWeaponSelection(x, y, w, h, alpha)
	self:BaseDrawWeaponSelection(x, y, w, h, alpha)
end

-- 摄像头画面渲染目标与屏幕贴图参数
local w, h = 320, 256
local x, y = -w / 2, -h / 2
local CamPos = Vector(8, -4, -2)
local CamAng = Angle(180, -28, 90)
local CamScale = 0.025
local CamData = {x = 0, y = 0, w = h * 2, h = h * 2, drawhud = false, drawmonitors = false, drawviewmodel = false, aspectratio = w / h}
local rt = GetRenderTarget("prop_camera", w * 2, h * 2)
local matRT = Material("prop_camera")
local matStatic = Material("zombiesurvival/filmgrain/filmgrain")
local matNoSignal = Material("effects/tvscreen_noise003a")
-- ==== PostDrawViewModel - 在手持电视屏幕上绘制摄像头画面 ====
function SWEP:PostDrawViewModel(vm)
	self.BaseClass.PostDrawViewModel(self, vm)

	if not vm or not vm:IsValid() then return end

	-- 定位右手骨骼作为屏幕绘制位置
	local boneid = vm:LookupBone("ValveBiped.Bip01_R_Hand")
	if not boneid or boneid == 0 then return end

	local bpos, bang = vm:GetBonePositionMatrixed(boneid)

	-- 转换到电视屏幕表面的局部坐标
	bpos, bang = LocalToWorld(CamPos, CamAng, bpos, bang)

	cam.Start3D2D(bpos, bang, CamScale)

	surface.SetDrawColor(255, 255, 255, 255)

	-- 摄像头有效时显示实时画面，否则显示"无信号"噪点
	local camera = self:GetCamera()
	if camera:IsValid() then
		matRT:SetTexture("$basetexture", rt)
		surface.SetMaterial(matRT)
		surface.DrawTexturedRect(x, y, w, h)

		-- 叠加胶片颗粒效果（模仿老式监控画面）
		surface.SetDrawColor(30, 30, 30, 200)
		surface.SetMaterial(matStatic)
		surface.DrawTexturedRectUV(x, y, w, h, 2, 2, 0, 0)
	else
		surface.SetMaterial(matNoSignal)
		surface.DrawTexturedRect(x, y, w, h)
	end

	cam.End3D2D()
end

-- ==== RenderScene - 把摄像头视角渲染到渲染目标 ====
function SWEP:RenderScene(origin, angles, fov)
	-- 防止从摄像头视角内再渲染摄像头（无限递归）
	if FROM_CAMERA then return end

	local camera = self:GetCamera()
	if not camera:IsValid() then return end

	FROM_CAMERA = camera

	-- 以摄像头位置（略微向上偏移）为观察点
	CamData.origin = camera:GetPos() + camera:GetUp() * -16
	CamData.angles = angles

	-- 离屏渲染摄像头视角到纹理
	local originalRT = render.GetRenderTarget()
	render.SetRenderTarget(rt)
	render.RenderView(CamData)
	render.SetRenderTarget(originalRT)

	FROM_CAMERA = nil
end

-- ==== Draw3DHUD - 3D HUD 留空 ====
function SWEP:Draw3DHUD(vm, pos, ang)
end

-- ==== Draw2DHUD - 2D HUD 留空 ====
function SWEP:Draw2DHUD()
end
