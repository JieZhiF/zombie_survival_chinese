-- ============================================================================
-- cl_init.lua - 冷冻瓦斯手雷（客户端）：瓦斯音效与蓝灰烟雾渲染
-- 负责：喷射期间播放嘶嘶声，并按频率生成上升扩散的蓝灰色瓦斯烟雾粒子
-- ============================================================================
INC_CLIENT()

-- ==== Think - 每帧更新：喷射期间播放持续瓦斯音效 ====
function ENT:Think()
	if not self:GetGasEmit() then return end

	-- 音高随秒数波动（200~201），模拟气流不稳的嘶嘶声
	self.AmbientSound:PlayEx(0.80, 200 + CurTime() % 1)
end

-- ==== Draw - 绘制：给手雷模型染色并生成瓦斯烟雾粒子 ====
function ENT:Draw()
	-- 将手雷模型调成蓝灰色调（冷冻主题）
	render.SetColorModulation(0.25, 0.46, 0.51)
	self:DrawModel()
	render.SetColorModulation(1, 1, 1)

	if not self:GetGasEmit() then return end

	local time = CurTime()

	-- 每 0.07 秒生成一批粒子
	if time < self.NextEmit then return end
	self.NextEmit = time + 0.07

	local particle
	local pos = self:GetPos()
	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(12, 16)

	-- 主上升速度：垂直 170 单位/秒，水平方向随机散布在瓦斯半径内
	local vel = Vector(0, 0, 170)
	for i=1, 7 do
		local angler = AngleRand()
		local dist = math.Rand(0, self.Radius)
		particle = emitter:Add(math.random(2) == 1 and "particle/smokesprites_0003" or "particle/smokestack", pos)
		particle:SetColor(70, 120, 150)
		particle:SetVelocity(vel * math.Rand(0.5, 1) + Vector(math.cos(angler.y) * dist, math.sin(angler.y) * dist, 0)/1.21)
		particle:SetGravity(vel * -0.95)
		particle:SetDieTime(math.Rand(1.85, 2.4))
		particle:SetStartAlpha(math.random(150, 200))
		particle:SetEndAlpha(0)
		particle:SetStartSize(0)
		particle:SetEndSize(math.Rand(11, 19))
		particle:SetRoll(math.Rand(0, 360))
		particle:SetCollide(true)
	end

	emitter:Finish() emitter = nil collectgarbage("step", 64)
end
