ENT.Type = "anim"

ENT.m_NoNailUnfreeze = true
ENT.NoNails = true

ENT.CanPackUp = true
ENT.PackUpTime = 3
ENT.IgnorePackTimeMul = true

ENT.IsBarricadeObject = true
ENT.UseCoolDown = 1
ENT.NextUseTime = 0
ENT.CollisionWithHuamn = false 
function ENT:GetObjectHealth()
	return self:GetDTFloat(0)
end

function ENT:SetMaxObjectHealth(health)
	self:SetDTFloat(1, health)
end

function ENT:GetMaxObjectHealth()
	return self:GetDTFloat(1)
end

function ENT:SetObjectOwner(ent)
	self:SetDTEntity(0, ent)
end

function ENT:GetObjectOwner()
	return self:GetDTEntity(0)
end

function ENT:ClearObjectOwner()
	self:SetObjectOwner(NULL)
end

function ENT:HitByWrench(wep, owner, tr)
	return true
end
--[[
-- 修复后的 Use 函数
function ENT:Use(activator, caller)
	if self.NextUseTime > CurTime() then return end

	-- 切换布尔值的状态
	self.CollisionWithHuamn = not self.CollisionWithHuamn

	-- !! 关键步骤：获取物理对象并唤醒它 !!
	-- 这会强制物理引擎重新评估 ShouldNotCollide
	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:Wake()
	end
	
	-- 更新冷却时间
	self.NextUseTime = CurTime() + self.UseCoolDown
end
]]
function ENT:ShouldNotCollide(ent)
	if self.CollisionWithHuamn then
		return false
	end
	-- 如果 CollisionWithHuamn 值为 false 或 nil (0)，则只与 TEAM_UNDEAD 碰撞。
	-- 这意味着需要阻止和 TEAM_HUMAN 的碰撞。
	-- 当对方是人类玩家时，返回 true 来“跳过碰撞”。
	if ent:IsPlayer() and ent:Team() == TEAM_HUMAN then
		return true
	end

-- 对于其他所有情况（例如 TEAM_UNDEAD 或非玩家实体），允许碰撞。
	return false
end