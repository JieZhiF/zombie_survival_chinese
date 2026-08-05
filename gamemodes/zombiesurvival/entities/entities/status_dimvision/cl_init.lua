-- ============================================================================
-- status_dimvision/cl_init.lua - 暗视状态渲染（客户端）
-- 负责：计算暗度系数（状态开始/结束时平滑淡入淡出），通过屏幕空间
--       色彩修改（降低亮度）实现视野变暗效果
-- ============================================================================
INC_CLIENT()

-- ==== GetDim - 计算当前暗度系数：0（无效果）~1（全暗） ====
function ENT:GetDim()
	local creation_time = self:GetStartTime()
	local time = CurTime()
	local life_time = self:GetDuration()
	local end_time = creation_time + life_time

	-- 状态即将结束时：最后 0.5 秒内按剩余时间线性淡出
	if time > end_time - 0.5 then
		return math.Clamp((end_time - time) * 2, 0, 1)
	end

	-- 状态刚附加时：前 0.5 秒内按经过时间线性淡入
	if time < creation_time + 0.5 then
		return math.max(0, (time - creation_time) * 2)
	end

	-- 中间阶段保持全量暗度
	return 1
end

-- ==== Draw - 不绘制模型（纯屏幕特效状态） ====
function ENT:Draw()
end

-- 色彩修改参数表：仅调整亮度，其他参数保持原样
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
-- ==== RenderScreenspaceEffects - 屏幕特效：按暗度系数压低画面亮度 ====
function ENT:RenderScreenspaceEffects()
	-- 仅对状态拥有者本人生效
	if MySelf ~= self:GetOwner() then return end

	-- 亮度偏移 = 暗度系数 × -0.15（最大变暗幅度）
	colModDimVision["$pp_colour_brightness"] = self:GetDim() * -0.15
	DrawColorModify(colModDimVision)
end
