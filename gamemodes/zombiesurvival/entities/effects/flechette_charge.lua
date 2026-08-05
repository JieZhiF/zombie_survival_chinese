-- ============================================================================
-- flechette_charge.lua - 纳米云充能特效（客户端）：命中点收缩光晕
-- 负责：技能触发瞬间在命中点绘制快速收缩的红色光晕与折射环，并在消亡前
--       发射两枚爆散光点，提示纳米云即将生成
-- ============================================================================

-- 特效总时长（秒），决定光晕收缩与粒子爆散的速度
EFFECT.LifeTime = 0.3
-- 光晕基准尺寸（像素）
EFFECT.Size = 42

-- ==== Init - 特效初始化：记录位置与消亡时刻，发射爆散光点 ====
function EFFECT:Init(data)
	-- 记录消亡时刻，Think 据此判断特效是否继续存活
	self.DieTime = CurTime() + self.LifeTime

	local normal = data:GetNormal()
	local pos = data:GetOrigin()
	local mag = data:GetMagnitude()

	-- 起点沿法线略微抬起，避免光晕嵌入表面内部
	pos = pos + normal * 2
	self.Pos = pos
	self.Normal = normal
	self.Magnitude = mag
	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(32, 48)
	-- 两枚紫白色光点向随机方向高速飞出后坠落
	for i=1, 2 do
		local particle = emitter:Add("sprites/glow04_noz", pos)
		particle:SetDieTime(1)
		particle:SetColor(255, 208, 255)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		particle:SetStartSize(4)
		particle:SetEndSize(0)
		particle:SetVelocity(VectorRand():GetNormal() * 350)
		particle:SetGravity(Vector(0,0,-600))
		particle:SetCollide(true)
		particle:SetBounce(0.5)
	end
end

-- ==== Think - 特效存活判定：未到消亡时刻则继续渲染 ====
function EFFECT:Think()
	return CurTime() < self.DieTime
end

-- 折射环材质：绘制扭曲光线效果的光环
local matRefraction	= Material("refract_ring")
-- 特斯拉辉光材质：绘制主光晕
local matGlow = Material("effects/tesla_glow_noz")
-- 光晕颜色（可复用颜色对象，Render 中逐帧修改通道）
local colGlow = Color(255, 35, 35)
-- ==== Render - 逐帧渲染：光晕收缩并渐隐，红色通道随剩余时间衰减 ====
function EFFECT:Render()
	-- 剩余时间比例（1 → 0），随特效推进逐渐减小
	local delta = math.Clamp((self.DieTime - CurTime()) / self.LifeTime, 0, 1)
	local rdelta = 1 - delta
	-- 折射环尺寸随时间平方根比例收缩
	local size = rdelta ^ 0.5 * self.Size
	-- 透明度随推进渐隐，红色渐暗至全黑
	colGlow.a = rdelta * 255
	colGlow.r = delta * 255
	colGlow.b = colGlow.r - 255

	-- 绘制主光晕（固定尺寸，仅变色渐隐）
	render.SetMaterial(matGlow)
	render.DrawSprite(self.Pos, self.Size, self.Size, colGlow)
	-- 折射环：折射强度随剩余时间减弱，尺寸同步收缩
	matRefraction:SetFloat("$refractamount", delta*0.5)
	render.SetMaterial(matRefraction)
	render.UpdateRefractTexture()
	render.DrawSprite(self.Pos, size, size, color_white)
end
