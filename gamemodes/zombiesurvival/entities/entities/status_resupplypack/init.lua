-- ============================================================================
-- status_resupplypack/init.lua - 补给包状态实体（服务器端）
-- 负责：生成跟随玩家的补给包模型，供其他人类按 E 补给自己弹药/血量
-- ============================================================================

INC_SERVER()

-- ==== Initialize - 初始化 ====
-- 设置小型弹药箱模型，关闭阴影并允许玩家交互（Use）
function ENT:Initialize()
	self:DrawShadow(false)
	self:SetModelScale(0.35, 0)

	self:SetModel("models/Items/ammocrate_ar2.mdl")
	self:SetMoveType(MOVETYPE_NONE)
	-- 球形碰撞（方便从各个方向按 E 交互）
	self:PhysicsInitSphere(3)
	self:SetCollisionGroup(COLLISION_GROUP_WORLD)
	self:SetUseType(SIMPLE_USE)
end

-- ==== Think - 每帧逻辑 ====
-- 持有者失效或不再持有补给包饰品时移除自身
function ENT:Think()
	local owner = self:GetOwner()
	if not (owner:IsValid() and owner:Alive() and owner:HasTrinket("resupplypack")) then self:Remove() end
end

-- ==== Use - 使用交互 ====
-- 人类玩家在波次中按 E 使用：向持有者请求补给
function ENT:Use(activator, caller)
	-- 仅存活的人类且处于波次中才允许使用
	if activator:Team() ~= TEAM_HUMAN or not activator:Alive() or GAMEMODE:GetWave() <= 0 then return end

	-- 以持有者为补给来源，为使用者执行补给
	local owner = self:GetOwner()
	activator:Resupply(owner, self)
end
