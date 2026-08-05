-- ============================================================================
-- projectile_nova/cl_init.lua - 新星投射物（客户端）
-- 负责：飞行时以白色模型叠加颜色调制（普通弹暗红/替代弹亮红）
--       渲染能量球，并绘制发光点与弥散粒子；
--       移除（爆炸）时播放音效与三层爆炸粒子特效
-- ============================================================================

-- 客户端加载入口（INC_CLIENT 系列约定写法）
INC_CLIENT()

-- 弥散粒子材质
local matGlow = Material("effects/splashwake1")
-- 发光点材质
local matGlow2 = Material("sprites/glow04_noz")
-- 纯白材质（用于覆盖模型贴图后颜色调制）
local matWhite = Material("models/debug/debugwhite")
-- 缓存零向量
local vector_origin = vector_origin

-- ==== Draw - 绘制能量球与飞行特效 ====
function ENT:Draw()
	-- 读取替代射击标记（替代弹为亮红色调）
	local alt = self:GetDTBool(0)

	-- 用纯白材质覆盖模型并调制颜色（普通弹暗红、替代弹亮红），忽略引擎光照
	render.ModelMaterialOverride(matWhite)
	render.SetColorModulation(1, alt and 1 or 0.5, 0.2)
	render.SuppressEngineLighting(true)
	self:DrawModel()
	render.SuppressEngineLighting(false)
	render.SetColorModulation(1, 1, 1)
	render.ModelMaterialOverride(nil)

	local pos = self:GetPos()

	-- 飞行中（有速度）时绘制内外两层发光点并持续发射弥散粒子
	if self:GetVelocity() ~= vector_origin then
		-- 外层大光晕（半透明）
		render.SetMaterial(matGlow2)
		render.DrawSprite(pos, alt and 25 or 50, alt and 25 or 50, Color(255, alt and 180 or 100, 100, 10))
		-- 内层亮核
		render.SetMaterial(matGlow)
		render.DrawSprite(pos, alt and 6 or 12, alt and 6 or 12, Color(255, alt and 180 or 10, 10))

		-- 每帧发射两个向外缓慢飘散的弥散粒子
		local emitter = ParticleEmitter(pos)
		emitter:SetNearClip(24, 32)
		local particle
		for i=0, 1 do
			particle = emitter:Add(matGlow2, pos)
			particle:SetVelocity(VectorRand() * 5)
			particle:SetDieTime(0.1)
			particle:SetStartAlpha(alt and 65 or 125)
			particle:SetEndAlpha(0)
			particle:SetStartSize(5)
			particle:SetEndSize(0)
			particle:SetRollDelta(math.Rand(-10, 10))
			particle:SetColor(255, alt and 180 or 100, 100)
		end
		-- 结束发射并触发垃圾回收，避免粒子对象堆积
		emitter:Finish() emitter = nil collectgarbage("step", 64)
	end
end

-- ==== OnRemove - 移除时播放爆炸特效 ====
-- 播放能量爆裂音效，并分三层粒子模拟爆炸：高速火花、
-- 慢速大光球、溅射火花
function ENT:OnRemove()
	local pos = self:GetPos()
	local alt = self:GetDTBool(0)

	sound.Play("weapons/physcannon/energy_bounce1.wav", pos, 75, math.random(124, 135))

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(24, 32)
	local particle
	-- 第一层：20 个向四周高速飞散的小火花
	for i=0, 19 do
		particle = emitter:Add(matGlow, pos)
		particle:SetVelocity(VectorRand() * 75)
		particle:SetDieTime(0.5)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		particle:SetStartSize(math.Rand(2, 3))
		particle:SetEndSize(0)
		particle:SetRoll(math.Rand(-0.8, 0.8))
		particle:SetRollDelta(math.Rand(-3, 3))
		particle:SetColor(245, alt and 155 or 33, 20)
	end
	-- 第二层：6 个缓慢膨胀的大光球（爆炸核心）
	for i=0,5 do
		particle = emitter:Add(matGlow, pos)
		particle:SetVelocity(VectorRand() * 5)
		particle:SetDieTime(0.3)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		particle:SetStartSize(math.Rand(24, 25))
		particle:SetEndSize(0)
		particle:SetRoll(math.Rand(-0.8, 0.8))
		particle:SetRollDelta(math.Rand(-3, 3))
		particle:SetColor(245, 35, 20)
	end
	-- 第三层：45 个细长溅射火花（冲击波效果）
	for i=1, 45 do
		particle = emitter:Add("effects/splash2", pos)
		particle:SetDieTime(0.6)
		particle:SetColor(255, alt and 150 or 35, 20)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		particle:SetStartSize(5)
		particle:SetEndSize(0)
		particle:SetStartLength(1)
		particle:SetEndLength(5)
		particle:SetVelocity(VectorRand():GetNormal() * 100)
	end
	-- 结束发射并触发垃圾回收
	emitter:Finish() emitter = nil collectgarbage("step", 64)
end

-- ==== Initialize - 客户端初始化（无额外处理） ====
function ENT:Initialize()
end

-- ==== Think - 每帧逻辑（无额外处理） ====
function ENT:Think()
end
