-- ============================================================================
-- DModelKillIcon - 击杀图标模型渲染组件
-- 使用 DModelPanelEx 在 3D 环境中渲染纯白色模型的击杀图标
-- 覆盖引擎光照并使用白色材质，实现统一的图标风格
-- ============================================================================
-- 区域地图（VGUI 四字段）
-- [区域] 模型设置
-- [位置] SetModel()
-- [作用] 加载模型并自动取景
-- [常改] 相机参数、模型序列
--
-- [区域] 击杀图标绘制
-- [位置] Paint()
-- [作用] 以白色材质覆盖引擎光照绘制纯色模型图标
-- [常改] 颜色调制、材质覆盖、相机参数
-- ============================================================================

local PANEL = {}

-- ============================================================================
-- SetModel - 设置要渲染的模型
-- ============================================================================
function PANEL:SetModel(strModelName)
	self.BaseClass.SetModel(self, strModelName)

	self:AutoCam()
end

-- 白色覆盖材质
local matWhite = Material("models/debug/debugwhite")

-- ============================================================================
-- Paint - 绘制 3D 击杀图标模型
-- 使用白色材质覆盖模型颜色，引擎光照被抑制
-- ============================================================================
function PANEL:Paint(w, h)
	if not IsValid( self.Entity ) then return end
	
	self:LayoutEntity( self.Entity )
	
	local ang = self.aLookAngle
	local x, y = self:LocalToScreen( 0, 0 )
	local col = self.colColor

	if not ang then
		ang = (self.vLookatPos - self.vCamPos):Angle()
	end
	
	cam.Start3D(self.vCamPos, ang, self.fFOV, x, y, w, h, 5, self.FarZ)
	cam.IgnoreZ(true)
	
	render.SuppressEngineLighting(true)
	render.SetColorModulation(col.r / 255, col.g / 255, col.b / 255)
	render.SetBlend(col.a / 255)
	render.ModelMaterialOverride(matWhite)

	self:DrawModel()

	render.ModelMaterialOverride()
	render.SetBlend(1)
	render.SetColorModulation(1, 1, 1)
	render.SuppressEngineLighting(false)

	cam.IgnoreZ(false)
	cam.End3D()
	
	self.LastPaint = RealTime()
end

vgui.Register("DModelKillIcon", PANEL, "DModelPanelEx")
