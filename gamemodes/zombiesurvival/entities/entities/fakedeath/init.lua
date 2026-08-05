-- ============================================================================
-- fakedeath - 假死道具实体（服务端）
-- 负责：将假死实体吸附到地面（向下追踪 10240 单位），并在移除时间到达时自动清除
-- ============================================================================
INC_SERVER()

-- 地面追踪用的碰撞体半尺寸（小型探针）
local ViewHullMins = Vector(-4, -4, -4)
local ViewHullMaxs = Vector(4, 4, 4)
-- ==== Initialize - 初始化并沿竖直方向向下追踪，将实体摆放到地面上 ====
function ENT:Initialize()
	self:SharedInitialize()

	-- 向下发射 10240 单位长的实体追踪（仅碰撞固体），命中后贴在命中面上
	local tr = util.TraceHull({start = self:GetPos(), endpos = self:GetPos() + Vector(0, 0, -10240), mask = MASK_SOLID_BRUSHONLY, mins = ViewHullMins, maxs = ViewHullMaxs})
	self:SetPos(tr.HitPos + tr.HitNormal)
end

-- ==== Think - 到达移除时间后自动清除假死实体 ====
function ENT:Think()
	if self:GetRemoveTime() > 0 and CurTime() >= self:GetRemoveTime() then
		self:Remove()
	end
end
