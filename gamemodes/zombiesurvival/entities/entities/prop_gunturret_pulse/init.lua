-- ============================================================================
-- init.lua - 冰冻炮塔（服务器）：锁定冷冻光束
-- 负责：锁定目标持续照射，平滑累积冰冻时长（无伤害，类似 RA3 冰冻塔）、
--       弹药消耗与空仓处理
-- ============================================================================
INC_SERVER()

-- 记录伤害事件的间隔周期（供基类跟踪最近一次命中时间，单位：秒）
ENT.LastHitPeriod = 4

-- 调试日志节流（高频节拍下避免刷屏）
local NextFreezeDbg = 0
local function FreezeDbg(...)
	if CurTime() < NextFreezeDbg then return end
	NextFreezeDbg = CurTime() + 0.5
	Msg("[FREEZE-DBG] " .. ... .. "\n")
end

-- ==== 对目标施加冰冻 ====
-- 按抗性缩放：免疫（倍率 0）则无效，其余按 FreezeResistance/100 缩放时长
local function ApplyFreeze(ent, amount)
	local mult = ent:GetFreezeEffectMult()
	FreezeDbg(ent:Name() .. " 抗性倍率=" .. tostring(mult))
	if not mult or mult <= 0 then
		FreezeDbg(ent:Name() .. " 免疫冰冻")
		return
	end

	amount = amount * mult
	local cur = ent:GetStatus("freeze")
	if cur then
		cur:Extend(amount)
		FreezeDbg(ent:Name() .. " 累加 +" .. amount .. "s, 剩余 " .. cur:GetRemaining() .. "s")
	else
		local st = ent:GiveStatus("freeze", amount)
		FreezeDbg(ent:Name() .. " 新建状态 -> " .. (st and st:IsValid() and "OK" or "FAILED(nil)"))
	end
end

-- ==== FireTurret - 炮塔开火：高频节拍锁定目标持续照射冻结 ====
-- 类似 RA3 冰冻塔：锁定目标后持续冷冻，无直接伤害，冻结效果平滑累积
function ENT:FireTurret(src, dir)
	-- 冷却结束才允许开火
	if self:GetNextFire() <= CurTime() then
		local curammo = self:GetAmmo()
		local owner = self:GetObjectOwner()
		-- 手动操控且激活"双发齐射"天赋时，冷却略微延长
		local twinvolley = self:GetManualControl() and owner:IsSkillActive(SKILL_TWINVOLLEY)
		-- 弹药足够才进入照射流程
		if curammo > 0 then
			self:SetNextFire(CurTime() + self.FireDelay * (twinvolley and 1.5 or 1))

			-- 弹药小数累积消耗：每拍消耗 AmmoPerShot，累积满 1 发才扣除
			self.AmmoAccumulator = (self.AmmoAccumulator or 0) + self.AmmoPerShot
			if self.AmmoAccumulator >= 1 then
				local consume = math.floor(self.AmmoAccumulator)
				self.AmmoAccumulator = self.AmmoAccumulator - consume
				if curammo > consume then
					self:SetAmmo(curammo - consume)
				else
					self:SetAmmo(0)
				end
			end

			-- 弹药耗尽时向部署者发送弹药不足提示
			if self:GetAmmo() == 0 then
				owner:SendDeployableOutOfAmmoMessage(self)
			end

			self:PlayShootSound()

			-- 目标：自动索敌模式取锁定目标；手动操控模式沿炮口方向射线检测
			local target = self:GetTarget()
			if not target:IsValid() then
				local tr = util.TraceLine({
					start = src,
					endpos = src + dir * (self.BeamRange or 1024),
					filter = {self, owner},
					mask = MASK_SHOT
				})
				target = tr.Entity
			end

			if target:IsValid() and target:IsPlayer() and target:Team() == TEAM_UNDEAD then
				-- 更新最近命中时间，防止基类超时丢失目标
				self.LastHitSomething = CurTime()

				-- 按节拍平滑累积冰冻：每拍施加 FreezeRate × FireDelay 秒
				ApplyFreeze(target, (self.FreezeRate or 3) * self.FireDelay)
			end
		else
			-- 弹药不足：短暂冷却后播放空仓音效
			self:SetNextFire(CurTime() + 0.20)
			self:EmitSound("npc/turret_floor/die.wav")
		end
	end
end