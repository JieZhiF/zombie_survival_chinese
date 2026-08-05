-- ============================================================================
-- projectile_poisonspit/shared.lua - 毒液吐射物（共享）
-- 负责：声明实体类型，碰撞过滤（亡灵阵营玩家不阻挡毒液），预缓存模型与音效
-- ============================================================================
ENT.Type = "anim"

-- ==== ShouldNotCollide - 碰撞过滤：亡灵阵营玩家不阻挡毒液 ====
function ENT:ShouldNotCollide(ent)
	return ent:IsPlayer() and ent:Team() == TEAM_UNDEAD
end

-- 预缓存吐射物模型与命中音效，避免首次出现时卡顿
util.PrecacheModel("models/props/cs_italy/orange.mdl")
util.PrecacheSound("npc/antlion_grub/squashed.wav")
