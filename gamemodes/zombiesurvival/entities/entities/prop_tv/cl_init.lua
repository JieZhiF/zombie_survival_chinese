-- ============================================================================
-- prop_tv/cl_init.lua - 电视机监控道具（客户端）
-- 负责：把监控相机的画面渲染进渲染目标贴图，再以 3D2D 绘制到电视屏幕；
--       无信号时显示噪点雪花屏；接收服务器切换相机的网络消息
-- ============================================================================
INC_CLIENT()

-- ==== SetObjectHealth - 同步网络耐久值（DT 浮点 3 号位）====
function ENT:SetObjectHealth(health)
	self:SetDTFloat(3, health)
end

-- ==== SetObjectOwner - 同步网络拥有者（DT 实体 1 号位）====
function ENT:SetObjectOwner(ent)
	self:SetDTEntity(1, ent)
end

-- 屏幕尺寸与绘制偏移：320x256 的 3D2D 画面，以中心对齐
local w, h = 320, 256
local x, y = -w / 2, -h / 2
-- 渲染目标贴图与材质：监控画面先渲染到这里，再贴到电视屏幕
local rt = GetRenderTarget("prop_camera", w * 2, h * 2)
local matRT = Material("prop_camera")
-- 雪花/静态噪点材质（无信号时整屏显示）
local matStatic = Material("zombiesurvival/filmgrain/filmgrain")
-- 相机相对电视机的挂点位置与朝向
local CamPos = Vector(6, -2, 0)
-- 两个小指示灯的位置
local LightPos = Vector(7.4, 8, 3)
local LightPos2 = Vector(7.4, 8, 1)
local CamAng = Angle(0, 90, 90)
-- 3D2D 画面缩放比例
local CamScale = 0.05
-- 当前监控的相机实体（由网络消息设置）
MyCamera = NULL

-- 指示灯发光点材质
local matGlow = Material("sprites/glow04_noz")

-- ==== Draw - 绘制电视模型、屏幕画面与指示灯 ====
function ENT:Draw()
	self:DrawModel()

	-- 距离足够近时才绘制屏幕内容（近距离 LOD 优化）
	local dist = EyePos():DistToSqr(self:GetPos())
	if dist < 9000 then
		-- 计算屏幕挂点位置并开始 3D2D 绘制
		local bpos, bang = self:LocalToWorld(CamPos), self:LocalToWorldAngles(CamAng)

		cam.Start3D2D(bpos, bang, CamScale)

		surface.SetDrawColor(255, 255, 255, 255)

		local camera = MyCamera
		if camera:IsValid() then
			-- 有监控画面：贴上渲染目标贴图，再叠加轻微噪点
			matRT:SetTexture("$basetexture", rt)
			surface.SetMaterial(matRT)
			surface.DrawTexturedRect(x, y, w, h)

			surface.SetDrawColor(30, 30, 30, 200)
			surface.SetMaterial(matStatic)
			surface.DrawTexturedRectUV(x, y, w, h, 2, 2, 0, 0)
		else
			-- 无信号：显示纯噪点雪花屏
			surface.SetDrawColor(50, 60, 80, 255)
			surface.SetMaterial(matStatic)
			surface.DrawTexturedRect(x, y, w, h)
		end

		cam.End3D2D()
	end

	-- 绘制两个小指示灯（深蓝与红色发光点）
	render.SetMaterial(matGlow)
	render.DrawSprite(self:LocalToWorld(LightPos), 3, 3, COLOR_DARKBLUE)
	render.DrawSprite(self:LocalToWorld(LightPos2), 2, 2, COLOR_HURT)
end

-- 相机视图渲染参数：以屏幕尺寸为基准，关闭 HUD/监视器/第一人称模型
local CamData = {x = 0, y = 0, w = h * 2, h = h * 2, drawhud = false, drawmonitors = false, drawviewmodel = false, aspectratio = w / h}

-- ==== RenderScene - 把当前监控相机的画面渲染进渲染目标贴图 ====
function RenderScene(origin, angles, fov)
	-- 防止递归：渲染电视画面时不再触发本函数
	if FROM_CAMERA then return end

	local camera = MyCamera
	if not camera:IsValid() then return end

	FROM_CAMERA = camera

	-- 修正相机朝向为监控视角（旋转三个轴）
	local camangs = camera:GetAngles()
	camangs:RotateAroundAxis(camera:GetRight(), 90)
	camangs:RotateAroundAxis(camera:GetUp(), 180)
	camangs:RotateAroundAxis(camera:GetForward(), 180)

	-- 相机位置放在相机实体正下方 16 单位处
	CamData.origin = camera:GetPos() + camera:GetUp() * -16
	CamData.angles = camangs

	-- 切换到渲染目标贴图渲染相机视图，随后恢复原渲染目标
	local originalRT = render.GetRenderTarget()
	render.SetRenderTarget(rt)
	render.RenderView(CamData)
	render.SetRenderTarget(originalRT)

	FROM_CAMERA = nil
end

-- 接收服务器切换监控相机的消息，并注册 RenderScene 渲染钩子
net.Receive(NET_MSG.TVCAMERA, function(length)
	MyCamera = net.ReadEntity()

	hook.Add("RenderScene", "TVCamera", RenderScene)
end)
