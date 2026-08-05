-- ============================================================================
-- init.lua - 损坏道具特效实体（服务端）
-- 负责：复制被破坏道具的外观并延迟 10 秒，之后真正摧毁原道具并播爆炸特效
-- ============================================================================
INC_SERVER()

-- 延迟爆破时间（未初始化前为 0）
ENT.DieTime = 0

-- ==== Initialize - 初始化特效实体 ====
-- 无碰撞无物理，仅作为视觉替身；设置 10 秒后触发爆破
function ENT:Initialize()
	self:DrawShadow(false)
	self:SetSolid(SOLID_NONE)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetModelScale(1.03, 0)

	self.DieTime = CurTime() + 10
end

-- ==== AttachTo - 绑定到被破坏的道具 ====
-- 复制原道具的模型/皮肤/位置/角度/透明度并挂为其子实体；无效模型则延迟自杀
function ENT:AttachTo(ent)
	if IsValid(ent) and ent:GetModel() ~= "models/error.mdl" then
		self:SetModel(ent:GetModel())
		self:SetSkin(ent:GetSkin() or 0)
		self:SetPos(ent:GetPos())
		self:SetAngles(ent:GetAngles())
		self:SetAlpha(ent:GetAlpha())
		self:SetOwner(ent)
		self:SetParent(ent)
		-- 在原道具上记录破碎替身引用，供其他系统读取
		ent._BARRICADEBROKEN = self
	else
		self:Fire("kill", "", 1)
	end
end

-- ==== Think - 到点后爆破原道具 ====
-- 延迟期结束后触发原道具 break 与 kill（模拟倒塌），并播放爆炸特效后移除自己
function ENT:Think()
	if CurTime() >= self.DieTime and not self.Broken then
		self.Broken = true

		local ent = self:GetParent()
		if ent:IsValid() then
			ent:Fire("break", "", 0)
			ent:Fire("kill", "", 0.01)

			-- 在道具中心播发爆炸特效
			local effectdata = EffectData()
				effectdata:SetOrigin(ent:WorldSpaceCenter())
			util.Effect("Explosion", effectdata)
		end

		self:Remove()
	end
end
