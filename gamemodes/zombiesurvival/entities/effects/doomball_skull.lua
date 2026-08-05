-- ============================================================================
-- doomball_skull.lua - 末日骷髅头特效（客户端）
-- 负责：生成一个缓慢漂浮的骷髅头模型（无重力、高阻尼），持续缓慢
--       上升，随寿命渐隐，双眼位置绘制红色光点，营造末日法术氛围
-- ============================================================================

-- 渲染用基准寿命（秒）：由于 Init 会覆盖，实际寿命取 3~5 秒随机值
EFFECT.LifeTime = 1

-- ==== Init - 特效初始化：设置骷髅头模型并赋予漂浮物理 ====
function EFFECT:Init(data)
	-- 随机水平朝向，让每个骷髅头朝向不同
	self:SetAngles(Angle(0, math.Rand(0, 360), 0))
	-- 使用人类头骨模型并放大 2 倍
	self:SetModel("models/gibs/HGIBS.mdl")
	self:SetModelScale(2, 0)
	self:PhysicsInitSphere(4)

	-- 实际寿命随机 3~5 秒，决定漂浮与渐隐时长
	self.LifeTime = math.Rand(3, 5)
	self.DieTime = CurTime() + self.LifeTime

	-- 物理设置：无重力漂浮，超高阻尼防止滚动，沿随机方向缓慢漂移
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableMotion(true)
		phys:EnableGravity(false)
		phys:EnableDrag(true)
		phys:Wake()
		phys:SetDragCoefficient(200)
		phys:SetAngleDragCoefficient(9999999)
		phys:SetVelocityInstantaneous((data:GetNormal() + VectorRand()):GetNormalized() * math.Rand(10, 40))
	end
end

-- ==== Think - 每帧给骷髅头微小的上升速度，到消亡时刻结束 ====
function EFFECT:Think()
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		-- 唤醒物理并持续施加缓慢上升速度，模拟漂浮
		phys:Wake()
		phys:AddVelocity(Vector(0, 0, 15 * FrameTime()))
	end

	return CurTime() < self.DieTime
end

-- 眼睛光晕颜色/材质与双眼在模型空间中的位置
local colGlow = Color(255, 0, 0)
local matGlow = Material("sprites/glow04_noz")
local vecEyeLeft = Vector(5, -3.5, 1)
local vecEyeRight = Vector(5, 3.5, 1)

-- ==== Render - 逐帧渲染：骷髅头随寿命渐隐，双眼发光 ====
function EFFECT:Render()
	-- 剩余寿命比例（1 → 0）开平方，控制模型透明度与双眼亮度
	local dt = math.Clamp((self.DieTime - CurTime()) / self.LifeTime, 0, 1) ^ 0.5

	-- 整体调暗并随寿命渐隐地绘制骷髅头模型
	render.SetBlend(dt)
	render.SetColorModulation(0.5, 0.5, 0.5)

	self:DrawModel()

	-- 恢复默认渲染状态
	render.SetColorModulation(1, 1, 1)
	render.SetBlend(1)

	-- 在双眼位置绘制红色光点，随寿命变暗
	colGlow.a = dt * 255
	render.SetMaterial(matGlow)
	render.DrawSprite(self:LocalToWorld(vecEyeLeft), 8, 8, colGlow)
	render.DrawSprite(self:LocalToWorld(vecEyeRight), 8, 8, colGlow)
end
