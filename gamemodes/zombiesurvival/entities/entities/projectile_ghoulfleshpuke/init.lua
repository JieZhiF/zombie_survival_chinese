-- ============================================================================
-- projectile_ghoulfleshpuke/init.lua - 食尸鬼血肉呕吐物投射物（服务器）
-- 负责：命中时给活着的玩家施加"疾病"状态（10 秒），并播放血肉命中特效；
--       爆炸只结算一次
-- ============================================================================
INC_SERVER()

-- ==== Hit - 命中结算：施加疾病状态并播放命中特效 ====
function ENT:Hit(vHitPos, vHitNormal, eHitEntity)
	-- 已结算过则不再重复处理
	if self.Exploded then return end
	self.Exploded = true
	self.DeathTime = 0

	local owner = self:GetOwner()
	-- 拥有者失效时以投射物自身作为伤害来源
	if not owner:IsValid() then owner = self end

	-- 补全缺失的命中位置与法线（用于特效）
	vHitPos = vHitPos or self:GetPos()
	vHitNormal = vHitNormal or Vector(0, 0, 1)

	-- 命中活着的玩家且允许受伤害时，施加 10 秒疾病状态
	if eHitEntity:IsValidLivingPlayer() and gamemode.Call("PlayerShouldTakeDamage", eHitEntity, owner) then
		eHitEntity:GiveStatus("sickness", 10)
	end

	-- 播放血肉命中特效
	local effectdata = EffectData()
		effectdata:SetOrigin(vHitPos)
		effectdata:SetNormal(vHitNormal)
	util.Effect("hit_flesh", effectdata)
end
