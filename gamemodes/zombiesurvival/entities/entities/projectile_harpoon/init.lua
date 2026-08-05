-- ============================================================================
-- projectile_harpoon/init.lua - 鱼叉投射物（服务器）
-- 负责：飞行中保持鱼叉指向速度方向；命中玩家造成腿部伤害+穿刺流血
--       并生成钉刺道具；命中环境则落地为可拾取武器；30 秒后自动消失
-- ============================================================================
INC_SERVER()

-- ==== Initialize - 初始化：设定鱼叉模型、物理与飞行音效 ====
function ENT:Initialize()
	-- 已处理命中标记与命中时初始朝向（用于生成道具时还原）
	self.Touched = {}
	self.OriginalAngles = self:GetAngles()

	-- 使用鱼叉模型与纯物理碰撞体，按通用投射物参数初始化
	self:SetModel("models/props_junk/harpoon002a.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetupGenericProjectile(true)

	-- 30 秒后强制自毁（落空兜底）
	self:Fire("kill", "", 30)
	-- 投掷挥击音效（低频）
	self:EmitSound("weapons/iceaxe/iceaxe_swing1.wav", 75, math.random(35, 45))
	self.LastPhysicsUpdate = UnPredictedCurTime()
end

-- ==== PhysicsUpdate - 物理更新：鱼叉朝向始终对准速度方向 ====
function ENT:PhysicsUpdate(phys)
	self.LastPhysicsUpdate = UnPredictedCurTime()
	local vel = phys:GetVelocity()
	-- 将鱼叉模型旋转为沿速度方向，再恢复原速度（避免旋转改变速度）
	phys:SetAngles(phys:GetVelocity():Angle())
	phys:SetVelocityInstantaneous(vel)
end

-- ==== Think - 每帧处理物理碰撞缓冲，延后到下一帧执行命中结算 ====
function ENT:Think()
	if self.PhysicsData then
		self:Hit(self.PhysicsData.HitPos, self.PhysicsData.HitNormal, self.PhysicsData.OurOldVelocity, self.PhysicsData.HitEntity)
	end

	self:NextThink(CurTime())
	return true
end

-- ==== Hit - 命中结算：玩家被钉刺流血，环境则掉落可拾取鱼叉武器 ====
function ENT:Hit(vHitPos, vHitNormal, vel, hitent)
	-- 只结算一次
	if self.Done then return end
	self.Done = true

	local owner = self:GetOwner()

	-- 命中玩家：腿部伤害 + 生成钉刺道具 + 直接伤害
	if hitent and hitent:IsValid() and hitent:IsPlayer() then
		-- 造成 30 点腿部伤害（影响移动）
		hitent:AddLegDamage(30)

		-- 生成钉在玩家身上的鱼叉道具，持续造成流血（每跳 2 点）
		local ent = ents.Create("prop_harpoon")
		if ent:IsValid() then
			ent:SetPos(vHitPos)
			ent.BaseWeapon = self.BaseWeapon
			ent.BleedPerTick = 2
			ent:Spawn()
			ent:SetOwner(self:GetOwner())
			ent:SetParent(hitent)
			ent:SetAngles(self:GetAngles())
		end

		-- 造成主伤害（默认 45），播放穿刺音效
		hitent:TakeSpecialDamage(self.ProjDamage or 45, DMG_GENERIC, owner, self, self:GetPos())
		hitent:EmitSound("npc/strider/strider_skewer1.wav", 70, 112)
	else
		-- 命中环境：掉转为可拾取的鱼叉武器道具（朝向翻转 180 度贴地）
		local ang = self:GetAngles()
		ang:RotateAroundAxis(ang:Up(), 180)

		local ent = ents.Create("prop_weapon")
		if ent:IsValid() then
			ent:SetWeaponType(self.BaseWeapon)
			ent:SetPos(self:GetPos())
			ent:SetAngles(ang)
			ent:Spawn()

			-- 施放者为存活人类时：15 秒内仅原拥有者可拾取
			if owner:IsValidHuman() then
				ent.NoPickupsTime = CurTime() + 15
				ent.NoPickupsOwner = self:GetOwner()
			end

			-- 继承鱼叉落地时的剩余速度，保持飞行惯性
			local physob = ent:GetPhysicsObject()
			if physob:IsValid() then
				physob:Wake()
				physob:SetVelocityInstantaneous(vel)
			end
		end

		-- 播放金属板命中音效（两种随机）
		self:EmitSound("physics/metal/metal_sheet_impact_bullet"..math.random(2)..".wav", 70, math.random(90, 95))
	end

	self:Remove()
end

-- ==== PhysicsCollide - 物理碰撞：缓冲碰撞数据，交由 Think 下一帧结算 ====
function ENT:PhysicsCollide(data, phys)
	self.PhysicsData = data
	self:NextThink(CurTime())
end
