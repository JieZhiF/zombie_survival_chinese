-- ============================================================================
-- shared.lua - 感应地雷投射物（共享）：触发范围与扫描过滤
-- 负责：定义感应地雷的激活条件、感应半径与激光扫描过滤列表
-- ============================================================================
-- 动画实体类型（物理投射物）
ENT.Type = "anim"

-- 感应扫描半径
ENT.Range = 384

-- 子弹可穿过地雷（不阻挡任何子弹）
ENT.IgnoreBullets = true

-- 命中时间（用于判定激活延迟）
AccessorFuncDT(ENT, "HitTime", "Float", 0)

-- ==== IsActive - 是否已激活（命中 2 秒后进入感应状态） ====
function ENT:IsActive()
	local hittime = self:GetHitTime()
	return hittime > 0 and CurTime() >= hittime + 2
end

-- ==== GetStartPos - 感应激光的扫描起点（本体前方偏移） ====
function ENT:GetStartPos()
	return self:GetPos() + self:GetForward() * 9.25
end

-- ==== GetScanFilter - 构建扫描过滤列表（不阻挡人类/自身/相关投射物） ====
function ENT:GetScanFilter()
	local filter = team.GetPlayers(TEAM_HUMAN)
	filter[#filter + 1] = self
	filter = table.Add(filter, ents.FindByClass("prop_ffemitterfield"))
	filter = table.Add(filter, ents.FindByClass("projectile_*"))

	return filter
end

-- 扫描过滤缓存节流时间
local NextCache = 0
-- ==== GetCachedScanFilter - 带缓存地获取扫描过滤列表（避免高频重建） ====
function ENT:GetCachedScanFilter()
	if CurTime() < NextCache and self.CachedFilter then return self.CachedFilter end

	self.CachedFilter = self:GetScanFilter()
	NextCache = CurTime() + 1

	return self.CachedFilter
end
