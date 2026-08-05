-- ============================================================================
-- shared.lua - 补给弹药箱（共享）：实体类型与物件血量/属主访问器
-- 负责：声明弹药箱为可被敲掉血量、可打包的障碍物，并定义血量与属主的网络同步
-- ============================================================================
-- 动画实体类型（具备物理模拟的物件）
ENT.Type = "anim"

-- 不允许用钉枪固定解冻（弹药箱为静态摆放）
ENT.m_NoNailUnfreeze = true
-- 不允许钉入钉子
ENT.NoNails = true

-- 允许右键打包收起（交还给玩家）
ENT.CanPackUp = true

-- 属于障碍物体系（受障碍物血量/伤害规则约束）
ENT.IsBarricadeObject = true
-- 放置预览时总是显示幽灵模型
ENT.AlwaysGhostable = true

-- ==== SetObjectHealth - 设置物件血量：归零时触发破损拆毁 ====
function ENT:SetObjectHealth(health)
	self:SetDTFloat(0, health)
	if health <= 0 and not self.Destroyed then
		self.Destroyed = true
		self:FakePropBreak()
	end
end

-- ==== GetObjectHealth - 读取当前物件血量 ====
function ENT:GetObjectHealth()
	return self:GetDTFloat(0)
end

-- ==== SetMaxObjectHealth - 设置物件最大血量 ====
function ENT:SetMaxObjectHealth(health)
	self:SetDTFloat(1, health)
end

-- ==== GetMaxObjectHealth - 读取物件最大血量 ====
function ENT:GetMaxObjectHealth()
	return self:GetDTFloat(1)
end

-- ==== SetObjectOwner - 设置物件属主玩家 ====
function ENT:SetObjectOwner(ent)
	self:SetDTEntity(0, ent)
end

-- ==== GetObjectOwner - 读取物件属主玩家 ====
function ENT:GetObjectOwner()
	return self:GetDTEntity(0)
end

-- ==== ClearObjectOwner - 清除物件属主（置为 NULL） ====
function ENT:ClearObjectOwner()
	self:SetObjectOwner(NULL)
end
