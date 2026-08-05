-- ============================================================================
-- sillytracer/init.lua - 简易曳光弹轨迹特效（客户端）
-- 负责：在射击起点与命中点之间绘制一条快速衰减的烟雾光束，
--       模拟子弹飞行留下的拖尾轨迹
-- ============================================================================

-- 轨迹使用烟雾材质，由 render.DrawBeam 采样绘制
EFFECT.Mat = Material( "trails/smoke" )

-- ==== Init - 特效初始化：解析射击起终点并设置渲染包围盒 ====
function EFFECT:Init( data )

	-- 随机纹理坐标偏移，使不同弹道轨迹的烟雾纹理错开
	self.texcoord = math.Rand( 0, 20 )/3
	-- 记录开火事件位置、武器实体与枪口附件名
	self.Position = data:GetStart()
	self.WeaponEnt = data:GetEntity()
	self.Attachment = data:GetAttachment()
	
	-- 由武器枪口附件换算真实射击起点，命中点为终点
	self.StartPos = self:GetTracerShootPos( self.Position, self.WeaponEnt, self.Attachment )
	self.EndPos = data:GetOrigin()

	-- 设置碰撞与渲染包围盒，保证整条轨迹不被引擎剔除
	self.Entity:SetCollisionBounds( self.StartPos -  self.EndPos, Vector( 110, 110, 110 ) )
	self.Entity:SetRenderBoundsWS( self.StartPos, self.EndPos, Vector()*8 )
	
	-- 再次换算起点（枪口位置可能延迟生成，需刷新一次）
	self.StartPos = self:GetTracerShootPos( self.Position, self.WeaponEnt, self.Attachment )
	
	-- 光束与枪口闪光部分的初始透明度
	self.Alpha = 195
	self.FlashA = 255
	
end

-- ==== Think - 逐帧衰减透明度，决定特效存活 ====
function EFFECT:Think( )

	-- 枪口闪光透明度快速衰减至零
	self.FlashA = self.FlashA - 650 * FrameTime()
	if (self.FlashA < 0) then self.FlashA = 0 end

	-- 光束透明度衰减，归零后销毁特效
	self.Alpha = self.Alpha - 1150 * FrameTime()
	if (self.Alpha < 0) then return false end
	
	return true

end

-- ==== Render - 绘制起点到终点的烟雾光束 ====
function EFFECT:Render( )
	
	-- 弹道总长度，用于决定烟雾纹理的平铺次数
	self.Length = (self.StartPos - self.EndPos):Length()
	
	local texcoord = self.texcoord
	
		render.SetMaterial( self.Mat )
		-- 以烟雾材质绘制 4 像素宽的光束，纹理随弹道长度平铺
		render.DrawBeam( self.StartPos,
					 self.EndPos,
					 4,
					 texcoord,													
					 texcoord + self.Length / 256,
					 Color( 255, 255, 255, math.Clamp(self.Alpha, 0,195)) )
					 
end
