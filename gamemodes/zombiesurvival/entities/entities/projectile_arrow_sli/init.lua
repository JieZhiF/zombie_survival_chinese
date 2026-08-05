-- ============================================================================
-- projectile_arrow_sli/init.lua - 滑膛箭投射物（服务器端）
-- 负责：箭矢的模型与物理初始化；命中目标时按飞行时间结算伤害（强化蓄力
--       箭有飞行时间加成）、触发溅血与音效，随后移除自身
-- ============================================================================
INC_SERVER()

-- ==== Initialize - 初始化箭矢模型、球形碰撞体与通用投射物参数 ====
function ENT:Initialize()
	-- 使用弩箭模型，缩小 45%，碰撞体为半径 1 的物理球
	self:SetModel("models/Items/CrossbowRounds.mdl")
	self:PhysicsInitSphere(1)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetModelScale(0.55, 0)
	-- 按通用投射物规则初始化（重力、碰撞过滤等）
	self:SetupGenericProjectile(true)

	-- 记录发射时刻，供命中时计算飞行时间伤害加成
	self.TimeCreated = CurTime()
end

-- ==== Think - 命中结算：按飞行时间计算伤害并施加命中效果 ====
function ENT:Think()
	-- 每帧持续思考（NextThink 设为当前时间即逐帧触发）
	self:NextThink(CurTime())

	local owner = self:GetOwner()
	-- 拥有者已失效时以自身作为伤害来源
	if not owner:IsValid() then owner = self end

	-- 已碰到目标且尚未结算过伤害：只结算一次
	if self.Touched and not self.Damaged then
		self.Damaged = true

		-- 飞行时间越久伤害越高：1 + 飞行秒数×1.2，封顶 1.6 倍
		local airtime = CurTime() - self.TimeCreated
		local dmgmul = math.Clamp(1 + airtime * 1.2, 1, 1.6)
		-- alt2 标记强化箭（蓄力射击），仅强化箭享受飞行时间加成
		local alt2 = self:GetDTBool(1)

		local tr = self.Touched

		-- 结算伤害：基础 66 点，强化箭按飞行时间加成
		self:DealProjectileTraceDamage((self.ProjDamage or 66) * (alt2 and dmgmul or 1), tr, owner)

		-- 命中处生成血液粒子
		util.Blood(tr.Entity:WorldSpaceCenter(), math.max(0, 15), -self:GetForward(), math.Rand(100, 300), true)

		-- 随机播放两段命中身体音效之一
		self:EmitSound("weapons/crossbow/hitbod"..math.random(2)..".wav", 75, 80)
		self:Remove()
	elseif self.HitData then
		-- 命中环境等无伤害结算路径：直接移除
		self:Remove()
	end
	return true
end
