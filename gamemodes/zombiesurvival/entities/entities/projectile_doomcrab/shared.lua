-- ============================================================================
-- projectile_doomcrab - 末日螃蟹（DoomCrab）投掷的投射物实体（共享端）
-- 负责：声明实体类型、定义与亡灵队伍玩家的碰撞豁免规则，并预缓存模型与音效
-- ============================================================================

-- 实体类型：动画实体
ENT.Type = "anim"

-- ==== ShouldNotCollide - 判断目标是否应跳过碰撞：亡灵队伍玩家与其互不碰撞 ====
function ENT:ShouldNotCollide(ent)
	return ent:IsPlayer() and ent:Team() == TEAM_UNDEAD
end

-- 预缓存投射物使用的模型（橙色圆球）
util.PrecacheModel("models/props/cs_italy/orange.mdl")
-- 预缓存命中压扁时播放的音效
util.PrecacheSound("npc/antlion_grub/squashed.wav")
