-- ============================================================================
-- hit_hunter.lua - 猎人命中特效（客户端）：收缩紫色光晕
-- 负责：命中瞬间在命中点播放金属撞击音效，并逐帧绘制快速收缩的
--       紫色光晕与折射环，提示猎人（猎枪）攻击的落点
-- ============================================================================

-- 特效总时长（秒），决定光晕收缩与渐隐速度
EFFECT.LifeTime = 0.375
-- 光晕基准尺寸（像素）
EFFECT.Size = 128

-- ==== Init - 特效初始化：记录位置与消亡时刻并播放命中音效 ====
function EFFECT:Init(data)
	-- 记录消亡时刻，Think 据此判断特效是否继续存活
	self.DieTime = CurTime() + self.LifeTime

	local normal = data:GetNormal()
	local pos = data:GetOrigin()

	-- 起点沿法线略微抬起，避免光晕嵌入表面内部
	pos = pos + normal * 2
	self.Pos = pos
	self.Normal = normal

	-- 播放金属板被子弹命中的音效（随机 2 种之一）
	sound.Play("physics/metal/metal_sheet_impact_bullet"..math.random(2)..".wav", pos, 80, math.Rand(85, 95))
end

-- ==== Think - 特效存活判定：未到消亡时刻则继续渲染 ====
function EFFECT:Think()
	return CurTime() < self.DieTime
end

-- 折射环材质（绘制扭曲光线光环）与紫色辉光材质
local matRefraction	= Material("refract_ring")
local matGlow = Material("effects/rollerglow")
local colGlow = Color(255, 30, 255)
-- ==== Render - 逐帧渲染：光晕收缩并渐隐，颜色随剩余时间变化 ====
function EFFECT:Render()
	-- 剩余时间比例（1 → 0），随特效推进逐渐减小
	local delta = math.Clamp((self.DieTime - CurTime()) / self.LifeTime, 0, 1)
	local rdelta = 1 - delta
	-- 光晕尺寸随剩余时间平方根比例收缩
	local size = rdelta ^ 0.5 * self.Size
	-- 透明度渐隐，红色通道渐暗至全黑（紫色向深蓝过渡）
	colGlow.a = delta * 220
	colGlow.r = delta * 255
	colGlow.b = colGlow.r - 255

	-- 沿法线正反两面各绘制一张紫色光晕平面，并叠加中心光晕精灵
	render.SetMaterial(matGlow)
	render.DrawQuadEasy(self.Pos, self.Normal, size, size, colGlow, 0)
	render.DrawQuadEasy(self.Pos, self.Normal * -1, size, size, colGlow, 0)
	render.DrawSprite(self.Pos, size, size, colGlow)
	-- 折射环：折射强度按正弦脉动一次，随后同步收缩
	matRefraction:SetFloat("$refractamount", math.sin(delta * 2 * math.pi) * 0.2)
	render.SetMaterial(matRefraction)
	render.UpdateRefractTexture()
	render.DrawQuadEasy(self.Pos, self.Normal, size, size, color_white, 0)
	render.DrawQuadEasy(self.Pos, self.Normal * -1, size, size, color_white, 0)
	render.DrawSprite(self.Pos, size, size, color_white)
end
