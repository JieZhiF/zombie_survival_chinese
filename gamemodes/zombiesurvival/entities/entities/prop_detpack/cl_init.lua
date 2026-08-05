-- ============================================================================
-- cl_init.lua - 遥控炸药包（客户端）
-- 负责：绘制 C4 模型与状态指示灯（无主蓝光/布防黄光/可引爆绿光/引爆中红光）
-- ============================================================================
INC_CLIENT()

-- 普通渲染与半透明渲染均参与
ENT.RenderGroup = RENDERGROUP_BOTH

-- ==== Initialize - 记录客户端放置时间 ====
function ENT:Initialize()
	self.CreateTime = CurTime()
end

-- ==== Draw - 绘制模型 ====
function ENT:Draw()
	self:DrawModel()
end

-- 指示灯发光材质与无主蓝光颜色
local matGlow = Material("sprites/glow04_noz")
local colBlue = Color(100, 100, 255)
-- ==== DrawTranslucent - 绘制状态指示灯 ====
-- 依据引爆状态与所有权绘制对应颜色的脉冲光点
function ENT:DrawTranslucent()
	-- 指示灯位置：C4 面板处的固定偏移点
	local lightpos = self:GetPos() + self:GetUp() * 9 - self:GetRight() * 2
	local armed = self.CreateTime + self.ArmTime < CurTime()

	if self:GetExplodeTime() == 0 then
		-- 未引爆：已认领且过布防期显示绿色常亮；已认领未布防显示黄色脉冲；无主显示蓝色
		if self:GetOwner():IsValid() and armed then
			render.SetMaterial(matGlow)
			render.DrawSprite(lightpos, 16, 16, COLOR_GREEN)
			render.DrawSprite(lightpos, 4, 4, COLOR_WHITE)
		elseif self:GetOwner():IsValid() then
			local size = (CurTime() * 2.5 % 1) * 8

			render.SetMaterial(matGlow)
			render.DrawSprite(lightpos, size, size, COLOR_YELLOW)
			render.DrawSprite(lightpos, size / 4, size / 4, COLOR_WHITE)
		else
			render.SetMaterial(matGlow)
			render.DrawSprite(lightpos, 16, 16, colBlue)
			render.DrawSprite(lightpos, 4, 4, COLOR_WHITE)
		end
	else
		-- 引爆倒计时中：红色快速脉冲闪烁警示
		local size = (CurTime() * 2.5 % 1) * 24
		render.SetMaterial(matGlow)
		render.DrawSprite(lightpos, size, size, COLOR_RED)
		render.DrawSprite(lightpos, size / 4, size / 4, COLOR_WHITE)
	end
end
