-- ============================================================================
-- shared.lua - 闪电箭投射物（共享）
-- 负责：定义投射物基础类型与碰撞过滤规则（对人类队友与其它投射物不碰撞）
-- ============================================================================


-- 基于 anim 实体类型，继承基础实体
ENT.Type 			= "anim"
ENT.Base 			= "base_entity"

-- 不可通过沙盒菜单生成（仅由武器发射产生）
ENT.Spawnable			= false
ENT.AdminSpawnable		= false


-- ==== ShouldNotCollide - 碰撞过滤 ====
-- 不与人类阵营玩家及其它投射物碰撞（避免误伤队友/误触发）
function ENT:ShouldNotCollide(ent)
	return ent:IsPlayer() and ent:Team() == TEAM_HUMAN or ent:IsProjectile()
end
