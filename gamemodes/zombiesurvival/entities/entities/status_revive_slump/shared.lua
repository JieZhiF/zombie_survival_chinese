-- ============================================================================
-- shared.lua - 倒地待复活状态（共享）：声明实体类型与复活动画数据
-- 负责：提供复活计时、起身动画时间与复活治疗量的 DT 读写接口
-- ============================================================================
-- 动画实体类型
ENT.Type = "anim"
-- 基类为状态实体基类
ENT.Base = "status__base"

-- 复活起身动画的持续时间（秒）
ENT.AnimTime = 1.9

-- ==== GetRagdollEyes - 获取玩家布偶"眼睛"附着点的位置与角度 ====
function ENT:GetRagdollEyes(pl)
	local attachid = pl:LookupAttachment("eyes")
	if attachid then
		local attach = pl:GetAttachment(attachid)
		if attach then
			return attach.Pos, attach.Ang
		end
	end
end

-- ==== IsRising - 是否已进入起身动画阶段（复活完成前 AnimTime 秒内） ====
function ENT:IsRising()
	return self:GetReviveTime() - self.AnimTime <= CurTime()
end

-- ==== SetReviveTime - 设置复活完成时间点 ====
function ENT:SetReviveTime(tim)
	self:SetDTFloat(0, tim)
end

-- ==== GetReviveTime - 读取复活完成时间点 ====
function ENT:GetReviveTime()
	return self:GetDTFloat(0)
end

-- ==== SetReviveAnim - 设置起身动画起始时间点 ====
function ENT:SetReviveAnim(t)
	self:SetDTFloat(1, t)
end

-- ==== GetReviveAnim - 读取起身动画起始时间点 ====
function ENT:GetReviveAnim()
	return self:GetDTFloat(1)
end

-- ==== SetReviveHeal - 设置复活瞬间的治疗量 ====
function ENT:SetReviveHeal(h)
	self:SetDTFloat(2, h)
end

-- ==== GetReviveHeal - 读取复活瞬间的治疗量 ====
function ENT:GetReviveHeal()
	return self:GetDTFloat(2)
end
