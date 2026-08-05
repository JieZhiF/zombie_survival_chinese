-- ============================================================================
-- tracer_volt.lua - 伏特狙击枪曳光特效（客户端）
-- 负责：在枪口与命中点之间绘制两条绿色电弧光束与两端光晕精灵，
--       光束随生命周期快速收缩并渐隐，表现高压电击弹道
-- ============================================================================

-- ==== Init - 特效初始化：解析弹道起点/终点并设置渲染包围盒 ====
function EFFECT:Init( data )
	-- 记录开火起点数据：位置、武器实体与枪口附件
	self.Position = data:GetStart()
	self.WeaponEnt = data:GetEntity()
	self.Attachment = data:GetAttachment()

	-- 由武器枪口位置推导弹道起点，命中位置作为弹道终点
	self.StartPos = self:GetTracerShootPos( self.Position, self.WeaponEnt, self.Attachment )
	self.EndPos = data:GetOrigin()

	-- 生命周期状态：Alpha 从 255 衰减，Life 0 → 1 控制光束收缩
	self.Alpha = 255
	self.Life = 0

	-- 扩大渲染包围盒到整条弹道，避免光束被引擎裁剪
	self:SetRenderBoundsWS( self.StartPos, self.EndPos )
end

-- ==== Think - 推进生命周期：透明度衰减，Life 达到 1 时特效消亡 ====
function EFFECT:Think( )
	-- 生命周期以每秒 6 倍速推进，透明度同步线性下降
	self.Life = self.Life + FrameTime() * 6
	self.Alpha = 255 * ( 1 - self.Life )
	return ( self.Life < 1 )
end

-- 电弧光束材质与两端光晕材质
local beam1mat = Material("trails/electric")
local glowmat = Material("sprites/light_glow02_add")

-- ==== Render - 逐帧渲染：两条电弧光束 + 起止点光晕 ====
function EFFECT:Render()
	-- 透明度归零后不再绘制，避免残影
	if ( self.Alpha < 1 ) then return end

	-- 计算光束收缩量：随生命周期从全长收缩到零
	local texcoord = math.Rand( 0, 1 )
	local norm = (self.StartPos - self.EndPos) * self.Life
	self.Length = norm:Length()

	-- 绘制两条起点终点带随机抖动的电弧光束，模拟电流跳动
	render.SetMaterial( beam1mat )
	for i = 1, 2 do
		render.DrawBeam(self.StartPos + (VectorRand() * 2), self.EndPos + (VectorRand() * 3), 4, texcoord, texcoord + self.Length / 128, Color( 50, 255, 135, self.Alpha ))
	end

	-- 在弹道起点与终点绘制青色光晕，标记命中位置
	render.SetMaterial(glowmat)
	render.DrawSprite(self.StartPos, 20, 20, Color(50, 245, 235, self.Alpha))
	render.DrawSprite(self.EndPos, 15, 15, Color(50, 245, 235, self.Alpha))
end
