-- ============================================================================
-- fakedeath - 假死道具实体（共享端）
-- 负责：声明网络同步的死亡动画属性，并提供双端通用的初始化逻辑（无碰撞、客户端动画、默认时长/移除时间）
-- ============================================================================

-- 实体类型：动画实体
ENT.Type = "anim"

-- 死亡动画序列索引（LookupSequence 结果）
AccessorFuncDT(ENT, "DeathSequence", "Int", 0)
-- 死亡倒地时的朝向角度
AccessorFuncDT(ENT, "DeathAngles", "Angle", 0)
-- 死亡动画的总播放时长（秒）
AccessorFuncDT(ENT, "DeathSequenceLength", "Float", 0)
-- 死亡动画的起始播放进度（cycle 偏移）
AccessorFuncDT(ENT, "DeathSequenceStart", "Float", 1)
-- 自动移除时间（超过该时刻后实体消失）
AccessorFuncDT(ENT, "RemoveTime", "Float", 2)

-- ==== SharedInitialize - 双端通用初始化：无碰撞无移动、启用客户端动画并设置默认时长 ====
function ENT:SharedInitialize()
	self:SetSolid(SOLID_NONE)
	self:SetMoveType(MOVETYPE_NONE)

	-- 动画播放由客户端驱动
	self:UseClientSideAnimation(true)

	self.Created = CurTime()

	-- 未指定动画时长时默认 1 秒
	if self:GetDeathSequenceLength() == 0 then
		self:SetDeathSequenceLength(1)
	end

	-- 未指定移除时间时默认 10 秒后消失
	if self:GetRemoveTime() == 0 then
		self:SetRemoveTime(CurTime() + 10)
	end
end
