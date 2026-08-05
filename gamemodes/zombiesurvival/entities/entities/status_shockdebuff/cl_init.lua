-- ============================================================================
-- cl_init.lua - 电击减益状态（客户端）
-- 负责：在受击僵尸头顶周期性喷出绿色电弧粒子，标识其处于电击减速状态
-- ============================================================================
INC_CLIENT()

-- 粒子发射节流计时
ENT.NextEmit = 0

-- ==== Draw - 绘制电击粒子特效 ====
-- 每 0.15 秒在主人头顶发射 3 条绿色电弧粒子；隐身的僵尸或带目标辅助免疫的僵尸不绘制
function ENT:Draw()
	local owner = self:GetOwner()
	-- 主人无效，或主人是自己且不绘制本地玩家时跳过
	if not owner:IsValid() or owner == MySelf and not owner:ShouldDrawLocalPlayer() then return end
	-- 僵尸类型带目标辅助免疫时不绘制
	if owner:GetZombieClassTable().IgnoreTargetAssist then return end

	-- 出生保护期间不绘制
	if owner.SpawnProtection then return end

	-- 粒子节流：每 0.15 秒发射一轮
	if CurTime() < self.NextEmit then return end
	self.NextEmit = CurTime() + 0.15

	-- 以主人身体中心偏上 12 单位作为发射原点
	local pos = owner:WorldSpaceCenter()
	pos.z = pos.z + 12

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(16, 24)

	-- 从原点周围随机偏移发射 3 条短电弧（快速消失的拉长粒子）
	for i = 1, 3 do
		particle = emitter:Add("trails/electric", pos + VectorRand() * 8)
		particle:SetDieTime(0.1)
		particle:SetStartAlpha(230)
		particle:SetEndAlpha(0)
		particle:SetStartSize(2)
		particle:SetEndSize(0)
		particle:SetVelocity(VectorRand() * 5)
		particle:SetAirResistance(300)
		particle:SetStartLength(12)
		particle:SetEndLength(12)
		particle:SetColor(150, 255, 150)
	end

	emitter:Finish() emitter = nil collectgarbage("step", 64)
end
