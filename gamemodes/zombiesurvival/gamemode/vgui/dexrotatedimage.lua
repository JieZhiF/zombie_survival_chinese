-- ============================================================================
-- DEXRotatedImage - 可旋转的图片组件
-- 继承自 DImage，增加旋转角度支持，用于显示带角度的图片
-- ============================================================================
-- 区域地图（VGUI 四字段）
-- [区域] 旋转绘制
-- [位置] PaintAt()
-- [作用] 在指定位置按角度绘制图片，支持保持宽高比缩放
-- [常改] 绘制材质、颜色、旋转角度、缩放逻辑
--
-- [区域] 角度存取
-- [位置] SetRotation() / GetRotation()
-- [作用] 读写面板旋转角度
-- [常改] 角度存取方式、默认角度
-- ============================================================================

local PANEL = {}

-- ============================================================================
-- PaintAt - 在指定位置绘制旋转后的图片
-- ============================================================================
function PANEL:PaintAt( x, y, dw, dh )

	self:LoadMaterial()

	if ( !self.m_Material ) then return true end

	surface.SetMaterial( self.m_Material )
	surface.SetDrawColor( self.m_Color.r, self.m_Color.g, self.m_Color.b, self.m_Color.a )
	
	if ( self:GetKeepAspect() ) then
	
		local w = self.ActualWidth
		local h = self.ActualHeight
		
		-- Image is bigger than panel, shrink to suitable size
		if ( w > dw && h > dh ) then
		
			if ( w > dw ) then
			
				local diff = dw / w
				w = w * diff
				h = h * diff
			
			end
			
			if ( h > dh ) then
			
				local diff = dh / h
				w = w * diff
				h = h * diff
			
			end

		end
		
		if ( w < dw ) then
		
			local diff = dw / w
			w = w * diff
			h = h * diff
		
		end
		
		if ( h < dh ) then
		
			local diff = dh / h
			w = w * diff
			h = h * diff
		
		end
		
		local OffX = (dw - w) * 0.5
		local OffY = (dh - h) * 0.5
			
		surface.DrawTexturedRect( OffX+x, OffY+y, w, h )
	
		return true
	
	end
	
	
	surface.DrawTexturedRectRotated( x + dw / 2, y + dh / 2, dw, dh, self:GetRotation() )
	return true

end

-- ============================================================================
-- SetRotation - 设置旋转角度
-- ============================================================================
function PANEL:SetRotation(m)
	self.m_Rotation = m
end

-- ============================================================================
-- GetRotation - 获取当前旋转角度
-- ============================================================================
function PANEL:GetRotation()
	return self.m_Rotation or 0
end

vgui.Register("DEXRotatedImage", PANEL, "DImage")
