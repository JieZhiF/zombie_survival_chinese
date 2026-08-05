-- ============================================================================
-- projectile_ghoulfleshno/init.lua - 食尸鬼血肉投射物命中结算（服务器）
-- 负责：命中判定；对玩家施加减速、疾病状态与腿部伤害，并播放命中特效；
--       与冰冻版不同的是不施加冰冻状态
-- ============================================================================
INC_SERVER()

-- ==== Hit - 命中结算：施加状态与伤害并触发命中特效 ====
function ENT:Hit(vHitPos, vHitNormal, eHitEntity)
	-- 防止重复结算（爆炸标记）
	if self.Exploded then return end
	self.Exploded = true
	self.DeathTime = 0

	-- 命中归属：投射物无有效发射者时以自身为来源
	local owner = self:GetOwner()
	if not owner:IsValid() then owner = self end

	-- 兜底填充未传入的命中位置/法线
	vHitPos = vHitPos or self:GetPos()
	vHitNormal = vHitNormal or Vector(0, 0, 1)

	-- 命中存活的敌对玩家且允许造成伤害时：施加 5 秒减速、5 秒疾病并造成腿部伤害
	if eHitEntity:IsValidLivingPlayer() and gamemode.Call("PlayerShouldTakeDamage", eHitEntity, owner) then
		eHitEntity:GiveStatus("slow", 5)
		eHitEntity:GiveStatus("sickness", 5)
		eHitEntity:AddLegDamage(6)
	end

	-- 在命中点播放血肉飞溅特效
	local effectdata = EffectData()
		effectdata:SetOrigin(vHitPos)
		effectdata:SetNormal(vHitNormal)
	util.Effect("hit_flesh", effectdata)
end
