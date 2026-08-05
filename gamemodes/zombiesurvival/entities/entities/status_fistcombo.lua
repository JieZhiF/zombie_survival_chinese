-- ============================================================================
-- status_fistcombo.lua - 拳头连击计数状态（共享/服务端）
-- 负责：统计僵尸拳头连续命中次数，累计 4 次时对目标造成肢体伤害并移除自身
-- ============================================================================
-- 客户端与服务端均加载本文件（后续有 CLIENT 提前返回分支）
AddCSLuaFile()

-- 动画实体类型
ENT.Type = "anim"
-- 继承通用状态基类（提供状态叠加/计时框架）
ENT.Base = "status__base"

-- ==== AddCounter - 增加连击计数：满 4 次结算肢体伤害 ====
function ENT:AddCounter(counter)
	local owner = self:GetOwner()
	-- 目标最近 3 秒内被眩晕过则连击中断（不累计）
	if owner.LastStunned and owner.LastStunned + 3 > CurTime() then return end

	-- 达到 4 连击：对目标双腿/双臂各造成 18 点伤害，播放钝击音效并结束状态
	if self:GetCounter() + counter >= 4 then
		owner:AddLegDamage(18)
		owner:AddArmDamage(18)
		owner:EmitSound("weapons/crowbar/crowbar_impact1.wav", 75, math.random(60, 65))
		self:Remove()
	else
		-- 未满 4 连击则累加计数
		self:SetCounter(self:GetCounter() + counter)
	end
end

-- ==== SetCounter - 写入连击计数（不低于 0，经 DT 同步） ====
function ENT:SetCounter(counter)
	self:SetDTFloat(0, math.max(0, counter))
end

-- ==== GetCounter - 读取当前连击计数 ====
function ENT:GetCounter()
	return self:GetDTFloat(0)
end

-- 以下逻辑仅服务端执行
if CLIENT then return end

-- ==== Think - 服务端每帧：目标死亡或转为人类时移除连击状态 ====
function ENT:Think()
	self.BaseClass.Think(self)

	local owner = self:GetOwner()

	if not owner:Alive() or owner:Team() == TEAM_HUMAN then
		self:Remove()
	end
end
