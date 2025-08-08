local PANEL = {}
//描述：可能是用来显示模型的，不清楚哪里有用到
//注释状态：已完成，
function PANEL:SetModel(strModelName)//设置模型
	self.BaseClass.SetModel(self, strModelName)//调用父类的SetModel方法

	self:AutoCam()//自动摄像机
end

local matWhite = Material("models/debug/debugwhite")//白色材质
function PANEL:Paint(w, h)
	if !IsValid( self.Entity ) then return end
	
	self:LayoutEntity( self.Entity )//布局实体
	
	local ang = self.aLookAngle//获取角度
	local x, y = self:LocalToScreen( 0, 0 )//获取屏幕坐标
	local col = self.colColor//获取颜色

	if not ang then//如果没有角度
		ang = (self.vLookatPos - self.vCamPos):Angle()//获取角度
	end
	
	cam.Start3D(self.vCamPos, ang, self.fFOV, x, y, w, h, 5, self.FarZ)//开始3D绘制
	cam.IgnoreZ(true)//忽略Z轴
	
	render.SuppressEngineLighting(true)//抑制引擎光照
	render.SetColorModulation(col.r / 255, col.g / 255, col.b / 255)//设置颜色
	render.SetBlend(col.a / 255)//设置混合
	render.ModelMaterialOverride(matWhite)//设置模型材质

	self:DrawModel()//绘制模型

	render.ModelMaterialOverride()	//覆盖模型材质
	render.SetBlend(1)//设置混合
	render.SetColorModulation(1, 1, 1)//设置颜色
	render.SuppressEngineLighting(false)//取消抑制引擎光照

	cam.IgnoreZ(false)//	取消忽略Z轴
	cam.End3D()//结束3D绘制
	
	self.LastPaint = RealTime()//设置最后绘制时间
end

vgui.Register("DModelKillIcon", PANEL, "DModelPanelEx")
