-- ============================================================================
-- prop_thrownbaby/shared.lua - 被投掷的婴儿实体（共享端）
-- 负责：定义碰撞过滤规则、被投掷状态与落地标记的网络同步
-- ============================================================================

ENT.Type = "anim"

-- 禁止被钉子固定/拆除
ENT.NoNails = true
-- 可生成随从（落地后产生小僵尸随从）
ENT.MinionSpawn = true

-- ==== ShouldNotCollide - 碰撞过滤 ====
-- 不碰撞僵尸玩家（避免投掷时被挡回）
function ENT:ShouldNotCollide(ent)
	return ent:IsPlayer() and ent:Team() == TEAM_UNDEAD
end

-- 网络变量：是否已落地（触发随从生成与后续行为）
AccessorFuncDT(ENT, "Settled", "Bool", 0)
