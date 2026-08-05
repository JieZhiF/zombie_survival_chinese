-- ============================================================================
-- cl_init.lua - 人类搬运状态（客户端）：第一人称携带动画与收放处理
-- 负责：搬运时标记物体忽略攻击并播收枪动画，第一人称渲染搬运物
-- ============================================================================
INC_CLIENT()

-- 半透明渲染组（搬运物始终可见）
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

-- 搬运物落到面前位置的过渡动画时长（秒）
ENT.AnimTime = 0.25

-- ==== OnRemove - 移除时：解除物体攻击忽略并还原武器动画 ====
function ENT:OnRemove()
	-- 解除被搬运物体的近战/射线/子弹忽略标记
	local object = self:GetObject()
	if object:IsValid() then
		object.IgnoreMelee = nil
		object.IgnoreTraces = nil
		object.IgnoreBullets = nil
	end

	local owner = self:GetOwner()
	if owner == MySelf then
		-- 旋转搬运时移除自建 Move 钩子
		if self.Rotating then
			hook.Remove("CreateMove", "HoldingCreateMove")
		end

		-- 还原武器动画：不可收枪的武器保持现状，否则播拔出动画
		local wep = owner:GetActiveWeapon()
		if wep:IsValid() then
			if wep.NoHolsterOnCarry then
				self.NoHolster = true
			else
				wep:SendWeaponAnim(ACT_VM_DRAW)
			end
		end
	end

	self.BaseClass.OnRemove(self)
end

-- ==== Initialize - 初始化：注册移速钩子、标记搬运物并播收枪动画 ====
function ENT:Initialize()
	-- 注册移动钩子（基类实现：按物体重量降低移速）
	hook.Add("Move", self, self.Move)

	-- 标记被搬运物体：不响应近战/射线/子弹（防止误伤）
	local object = self:GetObject()
	if object:IsValid() then
		object.IgnoreMelee = true
		object.IgnoreTraces = true
		object.IgnoreBullets = true
	end

	self.Created = CurTime()

	-- 开始搬运时播放收枪动画
	if not self.NoHolster then
		local owner = self:GetOwner()
		if owner == MySelf then
			local wep = owner:GetActiveWeapon()
			if wep:IsValid() then
				wep:SendWeaponAnim(ACT_VM_HOLSTER)
			end
		end
	end

	self.BaseClass.Initialize(self)
end

-- ==== Think - 每帧更新：搬运期间保持"举起"姿势的微小晃动 ====
function ENT:Think()
	if self:GetOwner() ~= MySelf then return end

	if not self.NoHolster then
		-- 锁定举起序列并在基准循环上轻微摆动
		self:SetSequence(2)
		self:SetCycle(0.68 + math.sin(CurTime() * math.pi) * 0.01)
	end

	self.BaseClass.Think(self)
end

-- ==== Draw - 绘制：第一人称在眼前渲染搬运物（带落下过渡动画） ====
function ENT:Draw()
	if self:GetOwner() ~= MySelf or self.NoHolster or MySelf:ShouldDrawLocalPlayer() then return end

	local pos = EyePos()
	local ang = EyeAngles()

	-- 搬运开始时物体从上方落向眼前位置（0.25 秒内平滑过渡）
	pos = pos + -16 * (1 - math.Clamp((CurTime() - self.Created) / self.AnimTime, 0, 1) ^ 0.5) * ang:Up()

	self:SetPos(pos)
	self:SetAngles(ang)
	self:DrawModel()
end
