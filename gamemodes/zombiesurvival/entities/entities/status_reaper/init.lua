-- ============================================================================
-- status_reaper/init.lua - 死神状态结算（服务器）
-- 负责：管理状态死亡时间；伤害钩子按层数为拥有者增伤（每层 +8%）；
--       击杀僵尸时刷新状态时长并更新层数音效
-- ============================================================================
INC_SERVER()

-- ==== SetDie - 设置状态死亡时间：0/空=立即结束，-1=无限期，其余=定时结束 ====
function ENT:SetDie(fTime)
	if fTime == 0 or not fTime then
		self.DieTime = 0
	elseif fTime == -1 then
		self.DieTime = 999999999
	else
		self.DieTime = CurTime() + fTime
		self:SetDuration(fTime)
	end
end

-- ==== EntityTakeDamage - 死神增伤钩子：按层数提升拥有者造成的伤害 ====
function ENT:EntityTakeDamage(ent, dmginfo)
	local attacker = dmginfo:GetAttacker()
	-- 仅处理拥有者自己造成的伤害
	if attacker ~= self:GetOwner() then return end
	-- 拥有者为存活的人类时，伤害乘以 1 + 8% × 层数
	if attacker:IsValid() and attacker:IsPlayer() and attacker:Team() == TEAM_HUMAN then
		dmginfo:SetDamage(dmginfo:GetDamage() * (1 + 0.08 * self:GetDTInt(1)))
	end
end

-- ==== HumanKilledZombie - 击杀僵尸时刷新死神状态并更新层数音效 ====
function ENT:HumanKilledZombie(pl, attacker, inflictor, dmginfo, headshot, suicide)
	-- 仅处理拥有者自己的击杀
	if attacker ~= self:GetOwner() then return end

	if attacker:IsValid() and attacker:IsPlayer() and attacker:Team() == TEAM_HUMAN then
		-- 刷新状态时长：原有剩余时间 +7 秒，上限 14 秒
		local reaperstatus = attacker:GiveStatus("reaper", math.min(14, self.DieTime - CurTime() + 7))
		if reaperstatus and reaperstatus:IsValid() then
			-- 播放升级音效，音高随层数升高（层数越高音调越尖）
			attacker:EmitSound("hl1/ambience/particle_suck1.wav", 55, 150 + reaperstatus:GetDTInt(1) * 30, 0.45)
		end
	end
end
