local PANEL = {}
//这个玩意应该是用来旋转图片的
//注释状态：已完成，
function PANEL:PaintAt( x, y, dw, dh )

	self:LoadMaterial()//加载材质

	if ( !self.m_Material ) then return true end//如果没有材质就返回

	surface.SetMaterial( self.m_Material )//设置材质
	surface.SetDrawColor( self.m_Color.r, self.m_Color.g, self.m_Color.b, self.m_Color.a )//设置颜色,RGB值和透明度
	
	if ( self:GetKeepAspect() ) then //如果保持比例
	
		local w = self.ActualWidth//获取宽度
		local h = self.ActualHeight//获取高度
		
		-- Image is bigger than panel, shrink to suitable size
		//图像比面板大，请缩小到合适的尺寸
		if ( w > dw && h > dh ) then//如果宽度大于dw并且高度大于dh
		
			if ( w > dw ) then//如果宽度大于dw
			
				local diff = dw / w//计算差值
				w = w * diff//计算宽度
				h = h * diff//计算高度
			
			end
			
			if ( h > dh ) then//如果高度大于dh
			
				local diff = dh / h//计算差值
				w = w * diff//计算宽度
				h = h * diff//计算高度
			
			end

		end
		
		if ( w < dw ) then//如果宽度小于dw
		
			local diff = dw / w//计算差值
			w = w * diff
			h = h * diff
		
		end
		
		if ( h < dh ) then//如果高度小于dh
		
			local diff = dh / h
			w = w * diff
			h = h * diff
		
		end
		
		local OffX = (dw - w) * 0.5//计算偏移量
		local OffY = (dh - h) * 0.5//计算偏移量
			
		surface.DrawTexturedRect( OffX+x, OffY+y, w, h )//绘制图像
	
		return true
	
	end
	
	
	surface.DrawTexturedRectRotated( x + dw / 2, y + dh / 2, dw, dh, self:GetRotation() )//绘制图像
	return true

end

function PANEL:SetRotation(m)
	self.m_Rotation = m
end

function PANEL:GetRotation()
	return self.m_Rotation or 0
end

vgui.Register("DEXRotatedImage", PANEL, "DImage")
