-- ============================================================================
-- fakedeath - 假死道具实体（客户端）
-- 负责：驱动死亡倒地动画播放，并随移除时间临近让模型逐渐透明淡出
-- ============================================================================
INC_CLIENT()

-- 渲染分组：半透明（支持淡出效果）
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

-- ==== Initialize - 执行双端通用初始化 ====
function ENT:Initialize()
	self:SharedInitialize()
end

-- ==== DrawTranslucent - 推进死亡动画进度，并在移除前让模型逐步淡出 ====
function ENT:DrawTranslucent()
	-- 按生成时间推进动画进度（0.8 速率的 cycle），并叠加上起始偏移
	local cycle = math.Clamp((CurTime() - self.Created) * 0.8, 0, 1) * self:GetDeathSequenceLength() + self:GetDeathSequenceStart()
	local sequence = self:GetDeathSequence()

	-- 动画播放完毕后切换到死亡静止待机动画
	if cycle == 1 then
		local idleseq = self:LookupSequence("zombie_slump_idle_01")
		if idleseq and idleseq > 0 then
			sequence = idleseq
		end
	end

	self:SetSequence(sequence)
	self:SetCycle(cycle)
	self:SetAngles(self:GetDeathAngles())

	-- 在第三人称视角下绘制模型，透明度随剩余存在时间从 1 线性降到 0
	cam.Start3D(EyePos() + Vector(0, 0, 4), EyeAngles())
		render.SetBlend(math.Clamp(self:GetRemoveTime() - CurTime(), 0, 1))
		self:DrawModel()
		render.SetBlend(1)
	cam.End3D()
end
