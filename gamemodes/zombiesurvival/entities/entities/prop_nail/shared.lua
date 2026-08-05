-- ============================================================================
-- prop_nail - 路障钉子实体（共享端）
-- 负责：定义钉子的属性访问接口：将路障血量/修理次数等数据转发给被钉住的基座实体
-- ============================================================================

-- 实体类型：动画实体
ENT.Type = "anim"

-- ==== GetDeployer - 返回钉子的放置者（拥有者玩家） ====
function ENT:GetDeployer()
	return self:GetOwner()
end

-- ==== GetMaxNailHealth - 转发获取基座实体的最大路障血量 ====
function ENT:GetMaxNailHealth()
	local ent = self:GetBaseEntity()
	if ent:IsValid() then
		return ent:GetMaxBarricadeHealth()
	end

	return 0
end

-- ==== GetNailHealth - 转发获取基座实体的当前路障血量 ====
function ENT:GetNailHealth()
	local ent = self:GetBaseEntity()
	if ent:IsValid() then
		return ent:GetBarricadeHealth()
	end

	return 0
end

-- ==== GetRepairs - 转发获取基座实体的当前修理次数 ====
function ENT:GetRepairs()
	local ent = self:GetBaseEntity()
	if ent:IsValid() then
		return ent:GetBarricadeRepairs()
	end

	return 0
end

-- ==== GetMaxRepairs - 转发获取基座实体的最大修理次数 ====
function ENT:GetMaxRepairs()
	local ent = self:GetBaseEntity()
	if ent:IsValid() then
		return ent:GetMaxBarricadeRepairs()
	end

	return 0
end

-- ==== SetMaxRepairs - 空实现：最大修理次数由基座实体管理，钉子侧无需设置 ====
function ENT:SetMaxRepairs(m)
end

-- ==== SetBaseEntity - 通过网络实体槽记录被钉住的基座实体 ====
function ENT:SetBaseEntity(ent)
	self:SetDTEntity(0, ent)
end

-- ==== GetBaseEntity - 从网络实体槽读取被钉住的基座实体 ====
function ENT:GetBaseEntity()
	return self:GetDTEntity(0)
end

-- ==== GetAttachEntity - 获取被钉住的附着目标实体 ====
function ENT:GetAttachEntity()
	return self.m_AttachEntity or NULL
end

-- ==== GetActualPos - 返回钉子的实际世界坐标（由父实体本地偏移换算） ====
function ENT:GetActualPos()
	local offset = self:GetActualOffset()
	if offset then
		local parent = self:GetParent()
		if parent:IsValid() then
			return parent:LocalToWorld(offset)
		end
	end

	return self:GetPos()
end

-- ==== GetActualOffset - 获取钉子相对父实体的本地偏移 ====
function ENT:GetActualOffset()
	return self.m_ActualOffset
end

-- ==== SetActualOffset - 将世界坐标转换为相对目标实体的本地偏移并记录 ====
function ENT:SetActualOffset(pos, ent)
	self.m_ActualOffset = ent:WorldToLocal(pos)
end
