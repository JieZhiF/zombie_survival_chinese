-- ============================================================================
-- cl_init.lua - 冰冻 buff 状态（客户端）：屏幕冻结特效
-- 负责：给本地玩家叠加冷色滤镜；模型蓝冰染色由 GM:_PrePlayerDraw 统一处理
--       （hook.Add 钩子先于 GM 方法执行，状态钩子染色会被职业 PrePlayerDraw 覆盖）
--       冻结尖刺由服务端生成 env_protrusionspike 实体（自动同步渲染）
-- ============================================================================
INC_CLIENT()

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