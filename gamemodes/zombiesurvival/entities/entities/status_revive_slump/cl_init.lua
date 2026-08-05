-- ============================================================================
-- cl_init.lua - 倒地待复活状态（客户端）：接管输入并驱动布偶起身
-- 负责：锁定玩家视角与移动键位，将布偶吸附到玩家位置模拟起身动画
-- ============================================================================
INC_CLIENT()

-- ==== Initialize - 初始化：挂接输入钩子并记录初始视角 ====
function ENT:Initialize()
	-- 挂接 CreateMove 钩子以接管玩家输入
	hook.Add("CreateMove", self, self.CreateMove)

	self:DrawShadow(false)
	self:SetRenderBounds(Vector(-40, -40, -18), Vector(40, 40, 80))

	local owner = self:GetOwner()
	if owner:IsValid() then
		owner.Revive = self

		-- 记录复活开始时的朝向，起身期间保持该朝向
		self.CommandYaw = owner:GetAngles().yaw

		-- 通知武器/僵尸职业脚本：玩家已被击倒
		owner:CallWeaponFunction("KnockedDown", self, false)
		owner:CallZombieFunction("KnockedDown", self, false)
	end
end

-- ==== CreateMove - 输入接管：固定视角朝向并清除所有移动键位 ====
function ENT:CreateMove(cmd)
	-- 仅接管状态拥有者本人的输入
	if MySelf ~= self:GetOwner() then return end

	-- 固定视角偏航，防止玩家自行转头
	local ang = cmd:GetViewAngles()
	ang.yaw = self.CommandYaw or ang.yaw
	cmd:SetViewAngles(ang)

	-- 清除攻击/跳跃等按键与移动指令
	cmd:ClearButtons(0)
	cmd:ClearMovement()
end

-- ==== OnRemove - 移除时解除输入接管与引用 ====
function ENT:OnRemove()
	local owner = self:GetOwner()
	if owner:IsValid() then
		owner.Revive = nil
	end
end

-- ==== Think - 每帧将布偶主体吸附到玩家位置（起身动画） ====
function ENT:Think()
	local endtime = self:GetReviveTime()
	if endtime == 0 then return end

	local owner = self:GetOwner()
	if owner:IsValid() then
		local rag = owner:GetRagdollEntity()
		if rag and rag:IsValid() then
			local phys = rag:GetPhysicsObject()
			if phys:IsValid() then
				-- 通过影子物理控制把布偶拉回玩家位置（略高于地面）
				phys:Wake()
				phys:ComputeShadowControl({secondstoarrive = 0.05, pos = owner:GetPos() + Vector(0,0,16), angle = phys:GetAngles(), maxangular = 2000, maxangulardamp = 10000, maxspeed = 5000, maxspeeddamp = 1000, dampfactor = 0.85, teleportdistance = 200, deltatime = FrameTime()})
			end
		end
	end

	-- 每帧持续驱动，直到复活完成
	self:NextThink(CurTime())
	return true
end

-- ==== Draw - 自身不可见（外观由玩家布偶表现） ====
function ENT:Draw()
end
