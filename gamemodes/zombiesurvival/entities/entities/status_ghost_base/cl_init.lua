-- ============================================================================
-- status_ghost_base/cl_init.lua - 幽灵放置预览状态（客户端）
-- 负责：以半透明幽灵形式绘制放置预览：有效位置显示绿色、无效位置显示
--       红色，并可叠加方向箭头指示器；逐帧刷新有效性
-- ============================================================================
INC_CLIENT()

-- 以透明渲染组绘制，保证半透明混合效果
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

-- ==== Think - 每帧刷新放置有效性 ====
function ENT:Think()
	self:RecalculateValidity()

	self:NextThink(CurTime())
	return true
end

-- 有效/无效放置的颜色（低透明度绿/红）
local colValid = Color(50, 255, 50, 50)
local colInvalid = Color(255, 50, 50, 50)
-- ==== DrawTranslucent - 绘制幽灵预览模型与方向箭头 ====
function ENT:DrawTranslucent()
	-- 读取当前放置有效性标记
	local validp = self:GetValidPlacement()

	-- 关闭引擎光照以使用纯色调制，保证预览颜色稳定
	cam.Start3D(EyePos(), EyeAngles())
		render.SuppressEngineLighting(true)
		-- 按有效性设置透明度与颜色：有效=半透明绿，无效=更透明红
		if validp then
			render.SetBlend(0.75)
			render.SetColorModulation(0, 1, 0)
		else
			render.SetBlend(0.5)
			render.SetColorModulation(1, 0, 0)
		end

		-- 可选箭头指示器：绕右轴旋转绘制方向标记
		if self.GhostArrow then
			local angs = self:GetAngles()
			angs:RotateAroundAxis(self:GetRight(), self.GhostArrowUp and 270 or 0)

			-- 在世界空间中绘制 2D 箭头条，颜色随有效性变化
			cam.Start3D2D(self:WorldSpaceCenter(), angs, 0.2)
				surface.SetDrawColor(validp and colValid or colInvalid)
				surface.DrawRect( 0, -1, 128, 2 )
			cam.End3D2D()
		end

		-- 绘制幽灵模型本体
		self:DrawModel()

		-- 还原渲染状态，避免影响其他实体
		render.SetBlend(1)
		render.SetColorModulation(1, 1, 1)
		render.SuppressEngineLighting(false)
	cam.End3D()
end

-- 客户端控制台变量：幽灵旋转（0/1 开关，存档）
CreateClientConVar("_zs_ghostrotation", 0, false, true)
