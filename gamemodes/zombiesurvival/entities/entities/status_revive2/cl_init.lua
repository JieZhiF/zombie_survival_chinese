-- ============================================================================
-- status_revive2 - 复活状态实体（客户端）
-- 负责：驱动死亡玩家布娃娃逐物理部件吸附到玩家骨骼位置，呈现僵尸复活起身动画
-- ============================================================================
INC_CLIENT()

-- ==== Initialize - 关闭阴影并扩大渲染边界，同时在玩家身上登记复活状态引用 ====
function ENT:Initialize()
	self:DrawShadow(false)
	self:SetRenderBounds(Vector(-40, -40, -18), Vector(40, 40, 80))

	local owner = self:GetOwner()
	if owner:IsPlayer() then
		owner.Revive = self
	end
end

-- ==== OnRemove - 清除玩家身上的复活状态引用 ====
function ENT:OnRemove()
	local owner = self:GetOwner()
	if owner:IsValid() then
		owner.Revive = nil
	end
end

-- ==== Think - 每帧将布娃娃物理部件吸附到玩家骨骼位置：起身前贴合地面，起身阶段逐骨对位 ====
function ENT:Think()
	local endtime = self:GetReviveTime()
	-- 尚未设置复活时间时不做处理
	if endtime <= 0 then return end

	local ct = CurTime()
	local owner = self:GetOwner()
	if owner:IsValid() then
		local rag = owner:GetRagdollEntity()
		if rag and rag:IsValid() then
			-- 距复活完成不足 1 秒：进入起身阶段
			if endtime - 1 <= ct then
				-- 起身阶段将布娃娃模型替换为僵尸模型（复活的玩家化为僵尸）
				if not self.m_DidSetModel then
					self.m_DidSetModel = true
					rag:SetModel(GAMEMODE.ZombieClasses["Zombie"].Model)
				end
				local delta = math.max(0.01, endtime - ct)
				-- 逐物理部件计算玩家对应骨骼位置，将布娃娃部件吸附过去完成起身
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
				-- 起身前：将整个布娃娃贴合吸附到玩家当前位置（保持倒地状态）
				local phys = rag:GetPhysicsObject()
				if phys:IsValid() then
					phys:Wake()
					phys:ComputeShadowControl({secondstoarrive = 0.05, pos = owner:GetPos() + Vector(0,0,16), angle = phys:GetAngles(), maxangular = 2000, maxangulardamp = 10000, maxspeed = 5000, maxspeeddamp = 1000, dampfactor = 0.85, teleportdistance = 200, deltatime = FrameTime()})
				end
			end
		end
	end

	-- 将下一帧刷新时间设为本帧，保证逐帧执行吸附动画
	self:NextThink(ct)
	return true
end

-- ==== Draw - 空实现（布娃娃本体负责渲染） ====
function ENT:Draw()
end
