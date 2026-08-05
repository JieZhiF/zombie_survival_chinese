-- ============================================================================
-- status_burn/cl_init.lua - 燃烧状态（客户端）
-- 负责：燃烧视觉特效——每帧从拥有者身体随机位置冒出小火苗粒子，
--       表现持续燃烧的火焰
-- ============================================================================
INC_CLIENT()

-- 随机取玩家身体某根骨骼的世界坐标，用作粒子出生位置
local function GetRandomBonePos(pl)
	-- 非本地玩家，或本地玩家可见自身模型时：从随机骨骼取点
	if pl ~= MySelf or pl:ShouldDrawLocalPlayer() then
		local bone = pl:GetBoneMatrix(math.random(0,25))
		if bone then
			return bone:GetTranslation()
		end
	end

	-- 本地第一人称视角下退回枪口位置
	return pl:GetShootPos()
end

-- ==== Draw - 火焰粒子特效：每帧从身体随机位置冒出小火苗 ====
function ENT:Draw()
	local ent = self:GetOwner()
	if not ent:IsValid() then return end
	
	-- 本地玩家第一人称（看不到自己模型）时从模型包围盒内随机取点，
	-- 否则取随机骨骼位置
	local pos
	if ent == MySelf and not ent:ShouldDrawLocalPlayer() then
		local aa, bb = ent:WorldSpaceAABB()
		pos = Vector(math.Rand(aa.x, bb.x), math.Rand(aa.y, bb.y), math.Rand(aa.z, bb.z))
	else
		pos = GetRandomBonePos(ent)
	end

	local emitter = ParticleEmitter(self:GetPos())
	emitter:SetNearClip(24, 32)
	
	-- 每帧喷出 2 缕随机火苗粒子，短促燃烧后消散
	for i = 1, 2 do
		local particle = emitter:Add("sprites/flamelet"..math.random(4), pos + VectorRand():GetNormalized() * 2)
		particle:SetDieTime(math.Rand(0.2, 0.5))
		particle:SetStartSize(5)
		particle:SetEndSize(10)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		particle:SetVelocity(ent:GetVelocity())
		particle:SetAirResistance(32)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-1.5, 1.5))
	end
	
	emitter:Finish()
end
