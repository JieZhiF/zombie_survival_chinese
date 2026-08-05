-- ============================================================================
-- shared.lua - 医疗飞镖投射物（共享）：声明实体类型与碰撞过滤
-- 负责：定义医疗飞镖的碰撞规则（不碰撞活人，追踪目标除外）与 DT 数据访问
-- ============================================================================
-- 动画实体类型（具备物理模拟的投射物）
ENT.Type = "anim"

-- ==== ShouldNotCollide - 碰撞过滤：除追踪目标外的活人皆不与其碰撞 ====
function ENT:ShouldNotCollide(ent)
	return ent:IsValidLivingHuman() and self:GetSeeked():IsValidLivingHuman() and self:GetSeeked() ~= ent
end

-- 命中时间（0 表示尚未命中，客户端据此变色提示治疗效果）
AccessorFuncDT(ENT, "HitTime", "Float", 0)
-- 追踪目标（需要治疗/被锁定的玩家）
AccessorFuncDT(ENT, "Seeked", "Entity", 0)
