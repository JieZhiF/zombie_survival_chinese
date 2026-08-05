-- ============================================================================
-- status_spawnslow/cl_init.lua - 出生减速状态实体（客户端）
-- 负责：脚下绿色烟雾粒子、剩余效果强度计算与绿色屏幕视觉滤镜
-- ============================================================================

INC_CLIENT()

-- 粒子发射节流时间戳
ENT.NextEmit = 0

-- 双脚骨骼名称（在脚下生成烟雾）
local Bones = {"ValveBiped.Bip01_R_Foot", "ValveBiped.Bip01_L_Foot"}

-- ==== Draw - 绘制 ====
-- 每 0.05 秒从持有者双脚生成绿色烟雾粒子
function ENT:Draw()
	if CurTime() < self.NextEmit then return end
	self.NextEmit = CurTime() + 0.05

	local owner = self:GetOwner()
	-- 持有者无效或本地玩家不可见时跳过绘制
	if not owner:IsValid() or owner == MySelf and not owner:ShouldDrawLocalPlayer() then return end

	local boneid, particle, pos

	local emitter = ParticleEmitter(owner:GetPos())
	emitter:SetNearClip(12, 16)

	-- 遍历左右脚骨骼，在脚部上方生成绿色毒雾粒子
	for _, bonename in pairs(Bones) do
		boneid = owner:LookupBone(bonename)
		if boneid and boneid > 0 then
			pos = owner:GetBonePositionMatrixed(boneid)
			if pos then
				pos.z = pos.z + 8

				particle = emitter:Add("particle/smokesprites_0001", pos)
				particle:SetDieTime(math.Rand(1, 1.3))
				particle:SetVelocity(Vector(math.Rand(-12, 12), math.Rand(-12, 12), 0))
				particle:SetGravity(Vector(0, 0, -20))
				particle:SetColor(0, 80, 0)
				particle:SetAirResistance(8)
				particle:SetStartAlpha(100)
				particle:SetEndAlpha(0)
				particle:SetStartSize(1)
				particle:SetEndSize(14)
				particle:SetRoll(math.Rand(0, 360))
				particle:SetRollDelta(math.Rand(-10, 10))
			end
		end
	end

	-- 结束发射器并手动触发垃圾回收释放资源
	emitter:Finish() emitter = nil collectgarbage("step", 64)
end

-- ==== GetPower - 计算剩余效果强度 ====
-- 根据开始时间与持续时间计算剩余强度（0~1，随时间衰减）
function ENT:GetPower()
	return math.Clamp(self:GetStartTime() + self:GetDuration() - CurTime(), 0, 1)
end

-- 绿色色调的颜色修正参数表
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

-- 屏幕遮罩材质（视觉滤镜用）
local overlay = Material("effects/tp_eyefx/tpeye")

-- ==== RenderScreenspaceEffects - 屏幕特效 ====
-- 对本地持有者叠加绿色色调与遮罩，强度随时间衰减
function ENT:RenderScreenspaceEffects()
	-- 仅当自己是状态持有者时生效
	if MySelf ~= self:GetOwner() then return end

	-- 叠加半透明遮罩（透明度随剩余强度变化）
	overlay:SetFloat("$alpha", 0.05 * self:GetPower())
	DrawMaterialOverlay("effects/tp_eyefx/tpeye", -0.05)

	-- 绿色通道加成（随时间衰减的绿色视觉污染）
	colModDimVision["$pp_colour_addg"] = self:GetPower() * 0.15
	DrawColorModify(colModDimVision)
end
