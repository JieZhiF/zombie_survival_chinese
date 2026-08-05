-- ============================================================================
-- projectile_emi_sub - 电磁脉冲子投射物实体（客户端）
-- 负责：抑制引擎光照绘制自发光模型，叠加光斑精灵与飘散粒子呈现能量球外观，移除时播放爆裂特效
-- ============================================================================
INC_CLIENT()

-- 预留的粒子发射限频时间戳
ENT.NextEmit = 0

-- 渲染组：透明实体，确保与场景半透明物体按正确顺序混合
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

-- 叠加混合的光斑精灵材质（用于发光点效果）
local matGlow = Material("sprites/light_glow02_add")

-- ==== Initialize - 关闭实体阴影 ====
function ENT:Initialize()
	self:DrawShadow(false)
end

-- 纯白材质：覆盖模型材质，配合抑制引擎光照实现不受场景光照影响的自发光渲染
local matWhite = Material("models/debug/debugwhite")
-- ==== Draw - 以纯白材质并抑制引擎光照绘制模型，再叠加光斑精灵与飘散粒子，营造能量球效果 ====
function ENT:Draw()
	render.ModelMaterialOverride(matWhite)
	render.SuppressEngineLighting(true)
	self:DrawModel()
	render.SuppressEngineLighting(false)
	render.ModelMaterialOverride(nil)

	local pos = self:GetPos()

	render.SetMaterial(matGlow)
	render.DrawSprite(pos, 32, 32)

	-- 创建粒子发射器并设置近裁剪范围
	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(24, 32)
	local particle

	-- 每帧生成 2 个缓慢飘散的灰色粒子作为能量外壳
	for i=0, 1 do
		particle = emitter:Add(matGlow, pos)
		particle:SetVelocity(VectorRand() * 5)
		particle:SetDieTime(0.2)
		particle:SetStartAlpha(175)
		particle:SetEndAlpha(0)
		particle:SetStartSize(5)
		particle:SetEndSize(0)
		particle:SetRollDelta(math.Rand(-10, 10))
		particle:SetColor(110, 110, 110)
	end

	-- 释放粒子发射器并主动回收一次垃圾内存
	emitter:Finish() emitter = nil collectgarbage("step", 64)
end

-- ==== Think - 空实现（外观动画全部在 Draw 中完成） ====
function ENT:Think()
end
-- ==== OnRemove - 移除时播放能量爆裂音效并喷发白色粒子模拟爆炸 ====
function ENT:OnRemove()
	local pos = self:GetPos()

	sound.Play("weapons/physcannon/energy_sing_explosion2.wav", pos, 65, math.Rand(245, 250))

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(24, 32)
	local particle

	-- 喷发 5 个快速消散的白色粒子模拟能量爆裂
	for i=0,4 do
		particle = emitter:Add(matGlow, pos)
		particle:SetVelocity(VectorRand() * 5)
		particle:SetDieTime(0.4)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		particle:SetStartSize(math.Rand(34, 36))
		particle:SetEndSize(0)
		particle:SetRoll(math.Rand(-0.8, 0.8))
		particle:SetRollDelta(math.Rand(-3, 3))
		particle:SetColor(255, 255, 255)
	end

	-- 释放粒子发射器并主动回收一次垃圾内存
	emitter:Finish() emitter = nil collectgarbage("step", 64)
end
