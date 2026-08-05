-- ============================================================================
-- prop_tv - 电视机道具实体（共享端）
-- 负责：声明实体属性与网络变量，提供血量、最大血量与拥有者的查询接口
-- ============================================================================

-- 实体类型：动画实体
ENT.Type = "anim"
-- 渲染组：不透明实体
ENT.RenderGroup = RENDERGROUP_OPAQUE

-- 对应的部署武器：电视机武器
ENT.SWEP = "weapon_zs_tv"
-- 最大血量：75
ENT.MaxHealth = 75

-- 不可被钉子解冻；不可钉上钉子
ENT.m_NoNailUnfreeze = true
ENT.NoNails = true
-- 免疫子弹伤害
ENT.IgnoreBullets = true

-- 可打包收起；打包所需时间（秒）
ENT.CanPackUp = true
ENT.PackUpTime = 1

-- 始终允许显示放置幽灵预览
ENT.AlwaysGhostable = true

-- ==== GetObjectHealth - 读取网络同步的当前血量 ====
function ENT:GetObjectHealth()
	return self:GetDTFloat(3)
end

-- ==== GetMaxObjectHealth - 读取网络同步的最大血量 ====
function ENT:GetMaxObjectHealth()
	return self:GetDTInt(1)
end

-- ==== GetObjectOwner - 读取网络同步的拥有者实体 ====
function ENT:GetObjectOwner()
	return self:GetDTEntity(1)
end
