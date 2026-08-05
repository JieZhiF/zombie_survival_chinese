-- ============================================================================
-- status_vbloatedambience/cl_init.lua - 呕吐僵尸环境特效状态（客户端）
-- 负责：周期性从拥有者身体中心向上喷射绿色体液粒子，
--       模拟呕吐僵尸持续滴落酸液/体液的视觉效果
-- ============================================================================
INC_CLIENT()

-- 渲染组：半透明，用于粒子特效表现
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
-- 下次发射粒子的时间戳（发射节流用）
ENT.NextEmit = 0

-- ==== Initialize - 初始化：关闭阴影（纯粒子实体） ====
function ENT:Initialize()
	self:DrawShadow(false)
end

-- ==== Draw - 条件满足时周期性发射绿色体液粒子 ====
function ENT:Draw()
	local owner = self:GetOwner()
	-- 拥有者无效、本地玩家第一人称视角、或拥有者处于出生保护期时均不渲染
	if not owner:IsValid() or owner == MySelf and not owner:ShouldDrawLocalPlayer() then return end
	if owner.SpawnProtection then return end
	local pos = owner:WorldSpaceCenter()

	-- 发射节流：每 0.25 秒最多发射一批粒子
	if CurTime() < self.NextEmit then return end
	self.NextEmit = CurTime() + 0.25

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(16, 24)

	-- 发射方向：随机水平偏移叠加垂直向上的整体趋势
	local dir = (VectorRand() * 20 + Vector(0, 0, 40)):GetNormal()

	-- 配置单颗粒子：绿色血珠外观、初始速度、透明度渐隐、重力下落与碰撞反弹
	local particle = emitter:Add("!sprite_bloodspray"..math.random(8), pos)
	particle:SetVelocity(dir * 100)
	particle:SetDieTime(math.Rand(1.1, 1.4))
	particle:SetStartAlpha(240)
	particle:SetEndAlpha(0)
	particle:SetStartSize(math.Rand(6, 7))
	particle:SetEndSize(12)
	particle:SetRoll(math.Rand(0, 360))
	particle:SetRollDelta(math.Rand(-5, 5))
	particle:SetGravity(Vector(0, 0, -165))
	particle:SetCollide(true)
	particle:SetBounce(0.45)
	particle:SetAirResistance(12)
	particle:SetColor(60, 170, 40)

	-- 释放发射器并主动触发一步 GC，避免每帧残留临时对象
	emitter:Finish() emitter = nil collectgarbage("step", 64)
end
