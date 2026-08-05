-- ============================================================================
-- init.lua - 符石传送状态（服务端）
-- 负责：计时结束后将主人传送到目标符石，并在受击时延长传送准备时间
-- ============================================================================
INC_SERVER()

-- ==== PlayerSet - 状态附加到玩家时初始化 ====
-- 播放按钮提示音、初始化开始时间，并挂接受击延迟传送的伤害钩子
function ENT:PlayerSet(pPlayer, bExists)
	pPlayer:SendLua("MySelf:EmitSound(\"buttons/button1.wav\", 50, 35, 0.5)")

	-- 首次附加时记录开始时间
	if self:GetStartTime() == 0 then
		self:SetStartTime(CurTime())
	end

	hook.Add("EntityTakeDamage", self, self.EntityTakeDamage)
end

-- ==== Think - 每帧驱动传送流程 ====
-- 到点后执行传送并移除状态；来源符石被破坏或距离过远时中断传送
function ENT:Think()
	local owner = self:GetOwner()
	local froms = self:GetFromSigil()

	-- 传送计时结束：若目标符石有效则执行符石传送，随后移除状态
	if CurTime() >= self:GetEndTime() then
		if self:GetTargetSigil():IsValid() then
			owner:DoSigilTeleport(self:GetTargetSigil(), froms, self:GetClass() == "status_corruptedteleport")
		end

		self:Remove()
	end

	-- 来源符石已腐化，或主人距来源符石超过 128 单位（16384 = 128^2）时取消传送
	if froms and froms:IsValid() and not froms:IsWeapon() and (froms:GetSigilCorrupted() or owner:GetPos():DistToSqr(froms:GetPos()) > 16384) then
		self:Remove()
	end

	self:NextThink(CurTime())
	return true
end

-- ==== EntityTakeDamage - 传送期间受击则延后传送 ====
-- 主人每次受击（非状态伤害）都会重置计时，按主人的时间倍率延长 2 秒
function ENT:EntityTakeDamage(ent, dmginfo)
	if ent == self:GetOwner() and not dmginfo:GetInflictor().IsStatus then
		self:SetStartTime(CurTime())
		self:SetEndTime(CurTime() + 2 * (ent.SigilTeleportTimeMul or 1))
	end
end
