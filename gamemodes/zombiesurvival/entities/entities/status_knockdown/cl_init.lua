-- ============================================================================
-- status_knockdown/cl_init.lua - 击倒状态（客户端）
-- 负责：锁定被击倒玩家的视角与操作输入，隐藏玩家本体，并驱动布娃娃倒地动画
-- ============================================================================
INC_CLIENT()

-- ==== Initialize - 初始化：锁定输入与视角，隐藏玩家并记录初始朝向 ====
function ENT:Initialize()
	-- 注册 CreateMove 钩子，持续限制被击倒玩家的输入
	hook.Add("CreateMove", self, self.CreateMove)

	self:DrawShadow(false)
	-- 扩大渲染边界，保证布娃娃动画在范围内完整显示
	self:SetRenderBounds(Vector(-40, -40, -18), Vector(40, 40, 80))

	local owner = self:GetOwner()
	if owner:IsValid() then
		-- 在玩家身上登记本状态实体
		owner[self:GetClass()] = self

		-- 记录击倒瞬间的视角偏航，期间锁定为固定朝向
		self.CommandYaw = owner:GetAngles().yaw
	end
	if owner:IsPlayer() then
		-- 标记击倒状态并隐藏玩家本体（由布娃娃代替显示）
		owner.KnockedDown = self
		owner:SetNoDraw(true)
	end
end

-- ==== CreateMove - 输入锁定：固定视角偏航并清除移动/按键输入 ====
function ENT:CreateMove(cmd)
	-- 仅影响本地被击倒的玩家
	if MySelf ~= self:GetOwner() then return end

	-- 锁定视角偏航为击倒前的朝向，防止玩家转向
	local ang = cmd:GetViewAngles()
	ang.yaw = self.CommandYaw or ang.yaw
	cmd:SetViewAngles(ang)

	-- 禁止所有按键操作与移动输入
	cmd:ClearButtons(0)
	cmd:ClearMovement()
end

-- ==== OnRemove - 移除时恢复玩家显示并解除击倒标记 ====
function ENT:OnRemove()
	local owner = self:GetOwner()
	if owner:IsValid() then
		owner.KnockedDown = nil
		owner:SetNoDraw(false)
		-- 仅当登记仍指向本实体时清除，避免误删新赋予的状态
		if owner[self:GetClass()] == self then
			owner[self:GetClass()] = nil
		end
	end
end

-- ==== Think - 布娃娃控制：持续驱动物理骨骼模拟倒地向起身的过程 ====
function ENT:Think()
	local ct = CurTime()
	local owner = self:GetOwner()
	if owner:IsValid() and 0 < owner:Health() then
		local rag = owner:GetRagdollEntity()
		if rag and rag:IsValid() then
			local endtime = self:GetDTFloat(1)
			-- 临近结束（最后 0.65 秒）：逐骨骼将布娃娃吸附回玩家骨骼位置，准备起身
			if endtime - 0.65 <= ct then
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
				-- 击倒期间：将布娃娃整体保持在玩家位置上方 16 单位
				local phys = rag:GetPhysicsObject()
				if phys and phys:IsValid() then
					phys:Wake()
					phys:ComputeShadowControl({secondstoarrive = 0.05, pos = owner:GetPos() + Vector(0,0,16), angle = rag:GetPhysicsObject():GetAngles(), maxangular = 2000, maxangulardamp = 10000, maxspeed = 5000, maxspeeddamp = 1000, dampfactor = 0.85, teleportdistance = 200, deltatime = FrameTime()})
				end
			end
		end
	end

	-- 每帧持续结算
	self:NextThink(ct)
	return true
end

-- ==== Draw - 无自定义绘制（玩家本体已隐藏，由布娃娃自行渲染） ====
function ENT:Draw()
end
