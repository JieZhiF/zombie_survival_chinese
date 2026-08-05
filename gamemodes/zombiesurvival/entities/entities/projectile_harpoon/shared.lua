-- ============================================================================
-- projectile_harpoon/shared.lua - 鱼叉投射物（共享定义）
-- 负责：声明投射物类型、碰撞豁免规则（不伤人类/不撞投射物）、击杀不复活
--       标记，并预缓存模型与命中音效
-- ============================================================================

-- 实体类型：动画物理投射物
ENT.Type = "anim"

-- 鱼叉击杀不触发人类复活（防刷分机制）
ENT.NoReviveFromKills = true

-- ==== ShouldNotCollide - 不与人类玩家及其他投射物碰撞 ====
function ENT:ShouldNotCollide(ent)
	return ent:IsPlayer() and ent:Team() == TEAM_HUMAN or ent:IsProjectile()
end

-- 预缓存鱼叉模型与各阶段音效（投掷/命中金属/穿刺）
util.PrecacheModel("models/props_junk/harpoon002a.mdl")
util.PrecacheSound("weapons/iceaxe/iceaxe_swing1.wav")
util.PrecacheSound("physics/metal/metal_sheet_impact_bullet1.wav")
util.PrecacheSound("physics/metal/metal_sheet_impact_bullet2.wav")
util.PrecacheSound("npc/strider/strider_skewer1.wav")
