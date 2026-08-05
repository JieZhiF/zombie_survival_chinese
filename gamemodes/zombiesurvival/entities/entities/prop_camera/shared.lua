-- ============================================================================
-- shared.lua - 监控摄像头道具（共享）
-- 负责：定义摄像头放置物的属性与血量/所有者数据访问接口
-- ============================================================================
-- 基于 anim 实体类型，不透明渲染
ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_OPAQUE

-- 收起后返还的武器 SWEP（监控摄像头武器）
ENT.SWEP = "weapon_zs_camera"
-- 最大血量
ENT.MaxHealth = 75

-- 不可被钉子解冻、不可被钉子加固
ENT.m_NoNailUnfreeze = true
ENT.NoNails = true
-- 子弹无法直接命中（通过子命中箱 prop_hitbox_camera 结算）
ENT.IgnoreBullets = true

-- 允许右键收起
ENT.CanPackUp = true
-- 收起所需时间（秒）
ENT.PackUpTime = 1

-- 始终允许幽灵重建（人类在幽灵状态也能预览放置）
ENT.AlwaysGhostable = true

-- ==== GetObjectHealth - 读取当前血量（DT 浮点槽 3）====
function ENT:GetObjectHealth()
	return self:GetDTFloat(3)
end

-- ==== GetMaxObjectHealth - 读取最大血量（DT 整数槽 1）====
function ENT:GetMaxObjectHealth()
	return self:GetDTInt(1)
end

-- ==== GetObjectOwner - 读取放置者（DT 实体槽 1）====
function ENT:GetObjectOwner()
	return self:GetDTEntity(1)
end
