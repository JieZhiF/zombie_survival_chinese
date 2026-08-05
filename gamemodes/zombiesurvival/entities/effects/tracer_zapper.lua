-- ============================================================================
-- tracer_zapper.lua - 电击器曳光特效（客户端）
-- 负责：喷射蓝色闪光粒子，并绘制从起点到终点的白色电弧光束（末端带
--       随机抖动）与两端蓝白光晕，表现电流沿弹道传导的视觉冲击
-- ============================================================================

-- ==== Init - 特效初始化：喷射蓝色闪光粒子并记录弹道两端点 ====
function EFFECT:Init( data )
	local pos = data:GetStart()

	self.StartPos = pos
	self.EndPos = data:GetOrigin()

	-- 透明度与寿命计数器初始值
	self.Alpha = 255
	self.Life = 0

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(24, 32)

	-- 9 颗蓝色耀斑粒子在起点向四周缓慢扩散
	for i=1, 9 do
		local particle = emitter:Add("effects/blueflare1", pos)
		particle:SetDieTime(0.8)
		particle:SetColor(150,190,255)
		particle:SetStartAlpha(200)
		particle:SetEndAlpha(0)
		particle:SetStartSize(4)
		particle:SetEndSize(0)
		particle:SetVelocity(VectorRand():GetNormal() * 60)
	end

	-- 释放粒子发射器并回收内存
	emitter:Finish() emitter = nil collectgarbage("step", 64)

	-- 扩大渲染包围盒以覆盖整条弹道，防止光束被视锥裁剪
	self:SetRenderBoundsWS( self.StartPos, self.EndPos )
end

-- ==== Think - 特效思考：寿命快速推进并驱动透明度线性衰减 ====
function EFFECT:Think( )
	-- 寿命以 6 倍速推进（约 0.17 秒内消散），透明度同步线性衰减
	self.Life = self.Life + FrameTime() * 6
	self.Alpha = 255 * ( 1 - self.Life )
	return ( self.Life < 1 )
end

-- 渲染用的电弧光束材质与光晕材质
local beam1mat = Material("trails/electric")
local glowmat = Material("sprites/light_glow02_add")

-- ==== Render - 特效渲染：绘制抖动电弧与两端光晕 ====
function EFFECT:Render()
	-- 完全透明后提前返回，避免无效绘制
	if ( self.Alpha < 1 ) then return end

	-- 随机纹理坐标起点，让电弧纹理相位随机
	local texcoord = math.Rand( 0, 1 )
	-- 弹道两端距离 × 剩余寿命，决定电弧纹理滚动区间
	local norm = (self.StartPos - self.EndPos) * self.Life
	self.Length = norm:Length()

	render.SetMaterial( beam1mat )
	-- 三层白色电弧叠加，终点叠加随机抖动制造电击闪烁感
	for i = 1, 3 do
		render.DrawBeam(self.StartPos, self.EndPos + (VectorRand() * 6), 12, texcoord, texcoord + self.Length / 128, Color( 255, 255, 255, self.Alpha ))
	end

	-- 起点绘制大光晕、终点绘制小光晕，表现电流两端放电
	render.SetMaterial(glowmat)
	render.DrawSprite(self.StartPos, 130, 130, Color(150, 215, 255, self.Alpha))
	render.DrawSprite(self.EndPos, 50, 50, Color(170, 215, 255, self.Alpha))
end
