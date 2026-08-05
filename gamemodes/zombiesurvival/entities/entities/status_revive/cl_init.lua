-- ============================================================================
-- cl_init.lua - 复活状态（客户端）：驱动布偶起身动画
-- 负责：把布偶逐步吸附回玩家骨骼位置，模拟复活起身全过程
-- ============================================================================
INC_CLIENT()

-- ==== Initialize - 初始化：记录玩家复活状态引用 ====
function ENT:Initialize()
	self:DrawShadow(false)
	self:SetRenderBounds(Vector(-40, -40, -18), Vector(40, 40, 80))

	local owner = self:GetOwner()
	if owner:IsPlayer() then
		owner.Revive = self
	end
end

-- ==== OnRemove - 移除时清理玩家引用 ====
function ENT:OnRemove()
	local owner = self:GetOwner()
	if owner:IsValid() then
		owner.Revive = nil
	end
end

-- ==== Think - 每帧驱动布偶骨骼归位（起身动画） ====
function ENT:Think()
	local endtime = self:GetReviveTime()
	if endtime <= 0 then return end

	local ct = CurTime()
	local owner = self:GetOwner()
	if owner:IsValid() then
		local rag = owner:GetRagdollEntity()
		if rag and rag:IsValid() then
			-- 距复活完成 1 秒内：逐骨骼对齐玩家姿态（起身阶段）
			if endtime - 1 <= ct then
				local delta = math.max(0.01, endtime - ct)
				for i = 0, rag:GetPhysicsObjectCount() do
					local translate = owner:TranslatePhysBoneToBone(i)
					if translate and 0 < translate then
						local pos, ang = owner:GetBonePosition(translate)
						if pos and ang then
							local phys = rag:GetPhysicsObjectNum(i)
							if phys and phys:IsValid() then
								phys:Wake()
								phys:ComputeShadowControl({secondstoarrive = delta, pos = pos, angle = ang, maxangular = 1000, maxangulardamp = 10000, maxspeed = 5000, maxspeeddamp = 1000, dampfactor = 0.85, teleportdistance = 100, deltatime = FrameTime()})
							end
						end
					end
				end
			else
				-- 等待阶段：布偶主体吸附在玩家位置上方，保持平躺
				local phys = rag:GetPhysicsObject()
				if phys:IsValid() then
					phys:Wake()
					phys:ComputeShadowControl({secondstoarrive = 0.05, pos = owner:GetPos() + Vector(0,0,16), angle = phys:GetAngles(), maxangular = 2000, maxangulardamp = 10000, maxspeed = 5000, maxspeeddamp = 1000, dampfactor = 0.85, teleportdistance = 200, deltatime = FrameTime()})
				end
			end
		end
	end

	self:NextThink(ct)
	return true
end

-- ==== Draw - 自身不可见（外观由玩家布偶表现） ====
function ENT:Draw()
end
