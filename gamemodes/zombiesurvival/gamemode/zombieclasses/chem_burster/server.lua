-- ============================================================================
-- chem_burster/server.lua - 化学爆破者 (Chem Burster) 服务端逻辑
-- 负责：充能时禁止自杀、死亡时按充能强度引爆化学爆炸并触发赎回判定
-- ============================================================================

AddCSLuaFile("shared.lua")
include("shared.lua")

-- ==== CanPlayerSuicide - 充能期间禁止自杀 ====
function CLASS:CanPlayerSuicide(pl)
	local wep = pl:GetActiveWeapon()
	if wep:IsValid() and wep.GetCharge and wep:GetCharge() > 0 then return false end
end

-- ==== DoExplode - 执行化学爆炸：播放特效、造成范围毒伤并触发赎回判定 ====
local function DoExplode(pl, pos, magnitude, dmginfo)
	-- 爆炸伤害源取当前武器，无效时退回玩家本体
	local inflictor = pl:GetActiveWeapon()
	if not inflictor:IsValid() then inflictor = pl end

	-- 播放化学爆炸特效
	local effectdata = EffectData()
		effectdata:SetOrigin(pos)
		effectdata:SetMagnitude(magnitude)
	util.Effect("explosion_chem", effectdata, true)

	-- 造成范围毒伤（半径与伤害随充能强度放大）
	util.PoisonBlastDamage(inflictor, pl, pos, 38 + magnitude * 46, magnitude * 39, true, true)

	-- 触发死亡赎回判定
	pl:CheckRedeem()
end

-- ==== OnKilled - 死亡时按当前充能强度引爆（自杀且未充能则不炸） ====
function CLASS:OnKilled(pl, attacker, inflictor, suicide, headshot, dmginfo, assister)
	local magnitude = 1
	local wep = pl:GetActiveWeapon()
	if wep:IsValid() and wep.GetCharge then magnitude = wep:GetCharge() end

	-- 自杀且未充能时取消爆炸
	if suicide and magnitude < 1 then return end
	-- 充能强度映射到 0.25 ~ 1.0 的爆炸威力
	magnitude = 0.25 + magnitude * 0.75

	local pos = pl:WorldSpaceCenter()

	-- 延迟到下一帧执行爆炸，保证尸体状态先处理完毕
	timer.Simple(0, function() DoExplode(pl, pos, magnitude, dmginfo) end)

	return true
end

-- ==== OnSpawned - 生成时创建环境音效 ====
function CLASS:OnSpawned(pl)
	pl:CreateAmbience("bursterambience")
end
