-- ============================================================================
-- status_devourer/init.lua - 吞噬状态（服务器）
-- 负责：每 0.12 秒将拥有者朝拉拽者方向高速拖拽（脱离地面、弧线飞行），
--       直至伤害量耗尽、拥有者变为僵尸、拉拽者失效或拉拽者贴近时结束
-- ============================================================================
INC_SERVER()

-- ==== Think - 拉拽结算：条件不符立即移除，否则拖拽拥有者并衰减伤害值 ====
function ENT:Think()
	local owner = self:GetOwner()

	-- 伤害耗尽或拥有者已变为僵尸：状态失效
	if self:GetDamage() <= 0 or owner:Team() == TEAM_UNDEAD then
		self:Remove()
		return
	end

	-- 拉拽者失效：停止拉拽但保留状态
	if not self:GetPuller():IsValid() then
		return
	end

	-- 拉拽者已贴近拥有者：拉拽完成，移除状态
	local puller = self:GetPuller()
	if puller:GetPos():DistToSqr(owner:GetPos()) < 14000 then
		self:Remove()
		return
	end

	-- 计算朝向拉拽者的方向，并叠加向上抬升量形成弧线轨迹
	local dir = (puller:GetPos() - owner:GetPos())
	dir.z = math.Clamp(dir.z + 35, 0, 65)
	dir = dir:GetNormalized()

	-- 脱离地面并按方向高速拖拽
	owner:SetGroundEntity(NULL)
	owner:SetVelocity(dir * 380)
	-- 每次拉拽消耗 1 点伤害量
	self:SetDamage(self:GetDamage() - 1)

	-- 每 0.12 秒结算一次拉拽
	self:NextThink(CurTime() + 0.12)
	return true
end
