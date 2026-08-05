-- ============================================================================
-- cl_init.lua - 冻结状态（客户端）：蓝冰染色与屏幕冻结特效
-- 负责：将受冻玩家模型染成脉动冰蓝色，并给本地玩家屏幕叠加冷色调滤镜
-- ============================================================================
INC_CLIENT()

-- ==== PrePlayerDraw - 玩家绘制前：将受冻玩家模型染成脉动冰蓝色 ====
function ENT:PrePlayerDraw(pl)
	if pl ~= self:GetOwner() then return end

	-- 蓝色分量随时间正弦脉动（±0.2），红/绿压到 0.1 形成冰蓝调
	local b = 1 - math.abs(math.sin((CurTime() + self:EntIndex()) * 3)) * 0.2
	render.SetColorModulation(0.1, 0.1, b)
end

-- ==== PostPlayerDraw - 玩家绘制后：恢复默认调色 ====
function ENT:PostPlayerDraw(pl)
	if pl ~= self:GetOwner() then return end

	render.SetColorModulation(1, 1, 1)
end

-- ==== GetPower - 计算冻结剩余强度：从 1（刚冻结）衰减到 0（即将解除） ====
function ENT:GetPower()
	return math.Clamp(self:GetStartTime() + self:GetDuration() - CurTime(), 0, 1)
end

-- 屏幕色彩滤镜参数表（基值：仅开启颜色调节，不改变亮度/对比度）
local colModDimVision = {
	["$pp_colour_colour"] = 1,
	["$pp_colour_brightness"] = 0,
	["$pp_colour_contrast"] = 1,
	["$pp_colour_mulr"]	= 0,
	["$pp_colour_mulg"] = 0,
	["$pp_colour_mulb"] = 0,
	["$pp_colour_addr"] = 0,
	["$pp_colour_addg"] = 0,
	["$pp_colour_addb"] = 0
}

-- ==== RenderScreenspaceEffects - 屏幕特效：叠加随冻结强度变化的冷色滤镜 ====
function ENT:RenderScreenspaceEffects()
	-- 仅对本地玩家自身生效
	if MySelf ~= self:GetOwner() then return end

	-- 强度越高蓝色叠加越多、红绿轻微削减，模拟被冻住的冷色调视野
	colModDimVision["$pp_colour_addb"] = self:GetPower() * 0.2
	colModDimVision["$pp_colour_addg"] = self:GetPower() * -0.05
	colModDimVision["$pp_colour_addr"] = self:GetPower() * -0.13
	DrawColorModify(colModDimVision)
end
