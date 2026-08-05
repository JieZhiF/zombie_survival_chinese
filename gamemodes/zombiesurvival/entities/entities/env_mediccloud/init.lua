-- ============================================================================
-- init.lua - 医疗云环境实体（服务器）：周期性范围治疗
-- 负责：按固定间隔对半径内可见的人类进行治疗，次数受拥有者加成
-- ============================================================================
INC_SERVER()

-- 治疗间隔（秒）
ENT.TickTime = 1
-- 总治疗次数
ENT.Ticks = 10
-- 每次治疗量
ENT.HealPower = 2.5

-- ==== Initialize - 初始化：按拥有者加成计算治疗次数并调度 ====
function ENT:Initialize()
	local owner = self:GetOwner()

	self:DrawShadow(false)
	-- 拥有者的 CloudTime 加成可延长治疗次数
	self.Ticks = math.floor(self.Ticks * (owner:IsValidLivingHuman() and owner.CloudTime or 1))

	-- 首次治疗与整体销毁按时间调度
	self:Fire("heal", "", self.TickTime)
	self:Fire("kill", "", self.TickTime * self.Ticks + 0.01)
end

-- ==== AcceptInput - 治疗周期：治疗半径内可见的活人 ====
function ENT:AcceptInput(name, activator, caller, arg)
	if name ~= "heal" then return end

	self.Ticks = self.Ticks - 1

	-- 治疗归属：拥有者存活则算作拥有者的治疗
	local healer = self:GetOwner()
	if not healer:IsValidLivingHuman() then healer = self end

	local vPos = self:GetPos()
	-- 对半径内所有可见的活人玩家进行治疗
	for _, ent in pairs(ents.FindInSphere(vPos, self.Radius * (healer.CloudRadius or 1))) do
		if ent and ent:IsValidLivingHuman() and WorldVisible(vPos, ent:NearestPoint(vPos)) then
			healer:HealPlayer(ent, self.HealPower, 0.5, true)
		end
	end

	-- 还有剩余次数则安排下一次治疗
	if self.Ticks > 0 then
		self:Fire("heal", "", self.TickTime)
	end

	return true
end
