ENT.Type = "anim"

ENT.m_NoNailUnfreeze = true
ENT.NoNails = true

ENT.CanPackUp = true
ENT.PackUpTime = 3
ENT.IgnorePackTimeMul = true

ENT.IsBarricadeObject = true
ENT.UseCoolDown = 1
ENT.NextUseTime = 0
AccessorFuncDT(ENT, "LastDamaged", "Float", 0)
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

function ENT:ShouldNotCollide(ent)
	if ent:IsPlayer() and ent:Team() == TEAM_HUMAN then
		return true
	end

-- 对于其他所有情况（例如 TEAM_UNDEAD 或非玩家实体），允许碰撞。
	return false
end