-- ============================================================================
-- shared.lua - 武器箱道具（共享）：声明实体属性与耐久/归属 DT 存取
-- 负责：定义武器箱作为路障物/可打包道具的属性，及耐久与持有者的同步
-- ============================================================================
-- 动画实体类型
ENT.Type = "anim"

-- 不可被钉子冻结/钉住（作为建筑类道具的例外）
ENT.m_NoNailUnfreeze = true
ENT.NoNails = true

-- 可以打包带走
ENT.CanPackUp = true

-- 属于路障类道具
ENT.IsBarricadeObject = true
-- 放置阶段始终显示幽灵预览
ENT.AlwaysGhostable = true

-- ==== SetObjectHealth - 写入耐久：归零时标记销毁并播放碎裂效果 ====
function ENT:SetObjectHealth(health)
	self:SetDTFloat(0, health)
	if health <= 0 and not self.Destroyed then
		self.Destroyed = true
		self:FakePopBreak()
	end
end

-- ==== GetObjectHealth - 读取当前耐久 ====
function ENT:GetObjectHealth()
	return self:GetDTFloat(0)
end

-- ==== SetMaxObjectHealth - 写入最大耐久 ====
function ENT:SetMaxObjectHealth(health)
	self:SetDTFloat(1, health)
end

-- ==== GetMaxObjectHealth - 读取最大耐久 ====
function ENT:GetMaxObjectHealth()
	return self:GetDTFloat(1)
end

-- ==== SetObjectOwner - 写入持有者（DT 同步到客户端） ====
function ENT:SetObjectOwner(ent)
	self:SetDTEntity(0, ent)
end

-- ==== GetObjectOwner - 读取持有者 ====
function ENT:GetObjectOwner()
	return self:GetDTEntity(0)
end

-- ==== ClearObjectOwner - 清空持有者 ====
function ENT:ClearObjectOwner()
	self:SetObjectOwner(NULL)
end
