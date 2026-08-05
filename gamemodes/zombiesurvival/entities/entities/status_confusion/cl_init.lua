-- ============================================================================
-- cl_init.lua - 混乱状态（客户端）：镜头摇晃与画面失真特效
-- 负责：按强度旋转视野、叠加锐化闪烁与动态模糊，模拟眩晕效果
-- ============================================================================
INC_CLIENT()

-- ==== Initialize - 初始化：登记混乱引用并初始化起止时间 ====
function ENT:Initialize()
	self:DrawShadow(false)

	local owner = self:GetOwner()
	if owner:IsValid() then
		owner.Confusion = self
	end

	-- 首次附加时记录开始时间
	if self:GetStartTime() == 0 then
		self:SetStartTime(CurTime())
	end

	-- 未指定结束时间时默认持续 10 秒
	if self:GetEndTime() == 0 then
		self:SetEndTime(CurTime() + 10)
	end
end

-- ==== Draw - 空实现：状态实体本身不绘制 ====
function ENT:Draw()
end

-- ==== CalcView - 视角修改：按强度正弦摆动镜头横滚角 ====
function ENT:CalcView(pl, pos, ang, fov, znear, zfar)
	ang.roll = ang.roll + math.sin(CurTime() * 0.5) * 50 * self:GetPower()
end

-- ==== RenderScreenSpaceEffects - 屏幕特效：锐化闪烁 + 动态模糊 ====
function ENT:RenderScreenSpaceEffects()
	local power = self:GetPower()

	local time = CurTime() * 1.5
	local sharpenpower = power * 0.4
	-- 两个相位相反的锐化偏移产生抖动闪烁
	DrawSharpen(sharpenpower, math.sin(time) * 128)
	DrawSharpen(sharpenpower, math.cos(time) * 128)
	-- 模糊强度随状态强度缩放
	DrawMotionBlur(0.1 * power, 4 * power, 0.05)
end

-- ==== OnRemove - 移除时：清除玩家混乱引用 ====
function ENT:OnRemove()
	local owner = self:GetOwner()
	if owner.Confusion == self then
		owner.Confusion = nil
	end
end
