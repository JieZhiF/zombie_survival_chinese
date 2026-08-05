-- ============================================================================
-- projectile_ghoulfleshfr/init.lua - 食尸鬼之肉（火）投射物（服务器）
-- 负责：命中时对符合条件的存活玩家施加冰冻 5 秒、致盲 3 秒状态并造成
--       18 点手臂伤害，随后播放冰冻命中特效并销毁弹体
-- ============================================================================
INC_SERVER()

-- ==== Hit - 命中结算：施加冰冻/致盲状态与手臂伤害并播放特效 ====
function ENT:Hit(vHitPos, vHitNormal, eHitEntity)
	-- 已爆炸过则忽略后续碰撞
	if self.Exploded then return end
	self.Exploded = true
	self.DeathTime = 0

	-- 拥有者失效时以自身为伤害来源
	local owner = self:GetOwner()
	if not owner:IsValid() then owner = self end

	-- 默认命中位置与法线
	vHitPos = vHitPos or self:GetPos()
	vHitNormal = vHitNormal or Vector(0, 0, 1)

	-- 命中存活的玩家且允许对其造成伤害时施加效果
	if eHitEntity:IsValidLivingPlayer() and gamemode.Call("PlayerShouldTakeDamage", eHitEntity, owner) then
		-- 冰冻 5 秒（减速控制）
		eHitEntity:GiveStatus("frost", 5)
		-- 致盲（视野受限）3 秒
		eHitEntity:GiveStatus("dimvision", 3)
		-- 18 点手臂伤害（影响持枪精度）
		eHitEntity:AddArmDamage(18)
	end

	-- 在命中位置播放冰冻打击特效
	local effectdata = EffectData()
		effectdata:SetOrigin(vHitPos)
		effectdata:SetNormal(vHitNormal)
	util.Effect("hit_frost", effectdata)
end
