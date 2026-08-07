INC_CLIENT()

-- ==== DrawTranslucent - 半透明渲染尖刺 ====
function ENT:DrawTranslucent()
	local freeze = self:GetFreezeMode()

	local delta = math.max(0, self.DieTime - CurTime())
	local size = math.min(1, (0.75 - delta) * 3)
	local normal = -self:GetUp()

	local icea
	if freeze then
		-- 冻结模式：刺出动画完成后保持可见静止（旋转/裁剪会让附着尖刺穿帮）
		if size < 1 then
			icea = 0.8
		else
			icea = 0.9
		end
		self:SetAngles(Angle(180, 0, 0))
	else
		-- 机关模式：原逻辑（旋转 + 地面裁剪 + 按剩余时间淡出）
		if size == 1 then
			icea = delta * 2.2
		else
			icea = 0.8
			self.Rotation = self.Rotation + FrameTime() * 520
		end
		self:SetAngles(Angle(180, self.Rotation, 0))

		if render.SupportsVertexShaders_2_0() then
			render.EnableClipping(true)
			render.PushCustomClipPlane(normal, normal:Dot(self:GetPos()))
		end
	end

	-- 冻结模式缩放为基础 0.7 的 65%（0.455），机关模式保持原大小
	self:SetModelScale(size * 0.7 * (freeze and 0.65 or 1), 0)

	render.SetBlend(icea)
	self:DrawModel()
	render.SetBlend(1)

	if not freeze and render.SupportsVertexShaders_2_0() then
		render.PopCustomClipPlane()
		render.EnableClipping(false)
	end
end

-- ==== Initialize - 初始化：音效、粒子、生命周期 ====
function ENT:Initialize()
	self:DrawShadow(false)
	self.Rotation = math.Rand(0, 360)
	self:SetColor(Color(30, 150, 255, 255))
	self:SetMaterial("models/shadertest/shader2")

	if self:GetFreezeMode() then
		-- 冻结模式：0.5 秒内刺出，之后持续显示（由状态实体负责移除）
		self.DieTime = CurTime() + 0.5
	else
		-- 机关模式：0.75 秒后由服务端销毁
		self.DieTime = CurTime() + 0.75
	end

	self:EmitSound("physics/glass/glass_largesheet_break"..math.random(1, 3)..".wav", 70, math.random(160, 180))
	self:EmitSound("physics/glass/glass_largesheet_break"..math.random(1, 3)..".wav", 70, math.random(160, 180))

	local emitter = ParticleEmitter(self:GetPos())
	emitter:SetNearClip(40, 48)

	local ang = Angle(0,0,0)
	local up = Vector(0,0,1)
	local pos = self:GetPos()
	for i=1, 120 do
		ang:RotateAroundAxis(up, 3)
		local fwd = ang:Forward()
		local particle = emitter:Add("particle/snow", pos + Vector(0, 0, 16) + fwd * 8)
		particle:SetVelocity(fwd * 64)
		particle:SetAirResistance(-64)
		particle:SetDieTime(1.7)
		particle:SetLifeTime(1)
		particle:SetStartAlpha(60)
		particle:SetEndAlpha(0)
		particle:SetStartSize(10)
		particle:SetEndSize(10)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-2, 2))

		particle = emitter:Add("particle/snow", pos)
		particle:SetVelocity(fwd * 72 + Vector(0,0,32))
		particle:SetAirResistance(-128)
		particle:SetDieTime(1.7)
		particle:SetLifeTime(1)
		particle:SetStartAlpha(60)
		particle:SetEndAlpha(0)
		particle:SetStartSize(12)
		particle:SetEndSize(12)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-2, 2))
	end
	emitter:Finish() emitter = nil collectgarbage("step", 64)
end
