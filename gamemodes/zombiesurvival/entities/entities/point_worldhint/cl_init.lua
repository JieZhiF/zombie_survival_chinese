-- ============================================================================
-- point_worldhint - 世界提示点实体（客户端）
-- 负责：在 3D 世界中绘制提示文字，并依据观看者队伍与玩家距离决定是否显示
-- ============================================================================
INC_CLIENT()

-- ==== Initialize - 初始化客户端实体：关闭阴影、无移动、无碰撞体 ====
function ENT:Initialize()
	self:DrawShadow(false)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_NONE)
	self:SetCollisionGroup(COLLISION_GROUP_WORLD)
end

-- ==== Draw - 本实体不绘制任何模型 ====
function ENT:Draw()
end

-- ==== DrawHint - 满足观看队伍条件且玩家在范围内时绘制世界提示文字 ====
function ENT:DrawHint()
	-- 观看条件：设置为 0（全部可见）或与本地玩家同队
	if self:GetViewable() == 0 or self:GetViewable() == MySelf:Team() then
		local pos = self:GetPos()
		local eyepos = EyePos()
		local range = self:GetRange()

		-- 范围为 0 时不限制距离，否则仅当玩家处于范围内才绘制
		if range <= 0 then
			DrawWorldHint(self:GetHint(), pos)
		else
			local dist = pos:DistToSqr(eyepos)
			if dist <= range * range then
				DrawWorldHint(self:GetHint(), pos)
			end
		end
	end
end
