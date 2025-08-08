ENT.Type = "anim"
ENT.Base = "status__base"

AccessorFuncDT(ENT, "Duration", "Float", 0)
AccessorFuncDT(ENT, "StartTime", "Float", 4)

function ENT:PlayerSet(pl)
	self:SetStartTime(CurTime())
end

function ENT:SetDie(fTime)
	if fTime == 0 or not fTime then
		self.DieTime = 0
	elseif fTime == -1 then
		self.DieTime = 999999999
	elseif self.DieTime < CurTime() + fTime then
		self.DieTime = CurTime() + fTime
		self:SetDuration(fTime)
	end
end