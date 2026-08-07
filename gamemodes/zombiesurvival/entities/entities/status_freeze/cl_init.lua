-- ============================================================================
-- cl_init.lua - 冰冻 buff 状态（客户端）：蓝冰染色与屏幕冻结特效
-- 负责：将受冻玩家模型染成冰蓝色（阶段越高越蓝），并给本地玩家叠加冷色滤镜
--       冻结尖刺由服务端生成 env_protrusionspike 实体（自动同步渲染）
-- ============================================================================
INC_CLIENT()

-- ==== PrePlayerDraw - 玩家绘制前：冰蓝染色，阶段越高蓝色越浓 ====
function ENT:PrePlayerDraw(pl)
	if pl ~= self:GetOwner() then return end

	local stage = self:GetStage()
	if stage <= 0 then return end

	-- 蓝色分量随正弦脉动，阶段越高红/绿压得越低
	local b = 1 - math.abs(math.sin((CurTime() + self:EntIndex()) * 3)) * 0.2
	local rg = 0.45 - stage * 0.12
	render.SetColorModulation(rg, rg, b)
end

-- ==== PostPlayerDraw - 玩家绘制后：恢复默认调色 ====
function ENT:PostPlayerDraw(pl)
	if pl ~= self:GetOwner() then return end

	render.SetColorModulation(1, 1, 1)
end

-- 屏幕色彩滤镜参数表
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

-- ==== RenderScreenspaceEffects - 屏幕特效：叠加随冻结阶段变化的冷色滤镜 ====
function ENT:RenderScreenspaceEffects()
	if MySelf ~= self:GetOwner() then return end

	local power = self:GetRemaining() / FREEZE_FULL_DURATION
	power = math.Clamp(power, 0, 1)

	-- 强度越高蓝色叠加越多、红绿轻微削减，模拟被冻住的冷色调视野
	colModDimVision["$pp_colour_addb"] = power * 0.25
	colModDimVision["$pp_colour_addg"] = power * -0.06
	colModDimVision["$pp_colour_addr"] = power * -0.16
	DrawColorModify(colModDimVision)
end
