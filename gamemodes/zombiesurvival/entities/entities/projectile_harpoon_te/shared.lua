-- ============================================================================
-- projectile_harpoon_te/shared.lua - 鱼叉枪投射物实体（共享端）
-- 负责：声明碰撞过滤规则、拉拽者网络引用，并预缓存模型与音效
-- ============================================================================

ENT.Type = "anim"

-- 被鱼叉击杀的玩家不触发复活机制
ENT.NoReviveFromKills = true

-- ==== ShouldNotCollide - 碰撞过滤 ====
-- 不碰撞人类玩家与其他投射物（只碰撞僵尸与场景）
function ENT:ShouldNotCollide(ent)
	return ent:IsPlayer() and ent:Team() == TEAM_HUMAN or ent:IsProjectile()
end

-- ==== SetPuller - 设置拉拽者 ====
-- 记录用鱼叉枪拉拽鱼叉的玩家（网络同步）
function ENT:SetPuller(puller)
	self:SetDTEntity(0, puller)
end

-- ==== GetPuller - 读取拉拽者 ====
function ENT:GetPuller()
	return self:GetDTEntity(0)
end

-- 预缓存鱼叉模型与相关音效，避免飞行途中首次加载卡顿
util.PrecacheModel("models/props_junk/harpoon002a.mdl")
util.PrecacheSound("weapons/iceaxe/iceaxe_swing1.wav")
util.PrecacheSound("physics/metal/metal_sheet_impact_bullet1.wav")
util.PrecacheSound("physics/metal/metal_sheet_impact_bullet2.wav")
util.PrecacheSound("npc/strider/strider_skewer1.wav")
