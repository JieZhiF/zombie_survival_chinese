-- ============================================================================
-- prop_messagebeacon/shared.lua - 信息信标（共享）
-- 负责：可打包/可钉装的信标道具，展示当前消息 ID 对应的消息内容，
--       记录放置者信息；消息内容来自 GAMEMODE.ValidBeaconMessages 配置表
-- ============================================================================
ENT.Type = "anim"

-- 允许被收拾打包，打包耗时 0.05 秒
ENT.CanPackUp = true
ENT.PackUpTime = 0.05

-- 不可被钉子解除冻结，也不可被钉装加固
ENT.m_NoNailUnfreeze = true
ENT.NoNails = true

-- 属于路障类物体，且始终允许虚影预览（放置时显示放置位置）
ENT.IsBarricadeObject = true
ENT.AlwaysGhostable = true

-- ==== GetMessageID - 读取当前展示的消息 ID ====
function ENT:GetMessageID()
	return self:GetDTInt(0)
end

-- ==== GetMessage - 获取消息内容，无效/缺省 ID 回退到第一条 ====
function ENT:GetMessage(id)
	return GAMEMODE.ValidBeaconMessages[id or self:GetMessageID()] or GAMEMODE.ValidBeaconMessages[1]
end

-- ==== SetObjectOwner - 记录放置者（DT 同步） ====
function ENT:SetObjectOwner(owner)
	self:SetDTEntity(0, owner)
end

-- ==== GetObjectOwner - 读取放置者 ====
function ENT:GetObjectOwner()
	return self:GetDTEntity(0)
end
