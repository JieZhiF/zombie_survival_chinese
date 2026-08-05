-- ============================================================================
-- projectile_flakbomb/init.lua - 高射炮弹（母弹）投射物（服务器）
-- 负责：3 秒后或碰撞时爆炸：对亡灵造成范围伤害，并向四周散射出 7 颗
--       高射子弹头（projectile_flak）；爆炸后播放音效并自毁
-- ============================================================================
INC_SERVER()

-- 飞行寿命（秒），到期自动爆炸
ENT.LifeTime = 3
-- 爆炸后散射的子投射物类型：高射子弹头
ENT.SubProjectile = "projectile_flak"
-- 子投射物生成回调（默认为空，可在生成母弹前覆写以定制子弹）
ENT.SubCallback = function(ent) end

-- ==== Initialize - 初始化：设定炸弹模型、小型球形物理与寿命 ====
function ENT:Initialize()
	-- 使用直升机炸弹模型，染成土黄色并缩小到 33%
	self:SetModel("models/combine_helicopter/helicopter_bomb01.mdl")
	self:SetColor(Color(205, 135, 110))
	self:PhysicsInitSphere(4)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetModelScale(0.33, 0)
	self:DrawShadow(false)
	-- 按通用投射物参数初始化（无重力抛射）
	self:SetupGenericProjectile(true)

	-- 记录爆炸时刻：生成时间 + 寿命
	self.ExplodeTime = CurTime() + self.LifeTime
end

-- ==== Think - 每帧检查：到达寿命或缓存到碰撞数据时执行爆炸 ====
function ENT:Think()
	-- 寿命耗尽：原地爆炸（向上喷发子弹）
	if self.ExplodeTime <= CurTime() then
		self:Explode(self:GetPos())
	end
	-- 物理碰撞后：按碰撞点法线与命中实体爆炸
	if self.PhysicsData then
		self:Explode(self:GetPos(), self.PhysicsData.HitNormal, self.PhysicsData.HitEntity)
	end

	self:NextThink(CurTime())
	return true
end

-- ==== Explode - 爆炸结算：范围伤害 + 散射 7 颗高射子弹头 ====
function ENT:Explode(hitpos, hitnormal, hitent)
	-- 只爆炸一次
	if self.Exploded then return end
	self.Exploded = true

	local owner = self:GetOwner()
	-- 未提供法线时默认朝上（空中/地面爆炸）
	hitnormal = hitnormal or Vector(0, 0, 1)
	-- 垂直喷发系数：命中实体时为 1；命中表面时按法线朝上程度计算
	-- （地面水平命中则全力向上喷，撞墙则喷发弱化）
	local upmulti = hitent and 1 or math.Clamp(-hitnormal.z, 0, 1)

	-- 施放者为存活人类时：对爆炸半径 81 内亡灵造成主伤害（基础 27 * 4）
	if owner:IsValidLivingHuman() then
		local source = self:ProjectileDamageSource()
		util.BlastDamagePlayer(source, owner, hitpos, 81, (self.ProjDamage or 27) * 4, DMG_ALWAYSGIB, 0.95)
	end

	-- 散射 7 颗高射子弹头：沿爆炸点略微后撤（防嵌入表面），继承母弹属性
	for i = 0, 6 do
		local ent = ents.Create(self.SubProjectile)
		if ent:IsValid() then
			ent:SetPos(self:GetPos() - hitnormal * 12 * upmulti)
			ent:SetAngles(self:GetAngles())
			ent:SetOwner(owner)
			ent.ProjDamage = self.ProjDamage * (owner.ProjectileDamageMul or 1)
			ent.ProjSource = self.ProjSource
			ent.Team = self.Team

			-- 调用自定义回调（可为子弹附加额外属性）
			self.SubCallback(ent)

			ent:Spawn()

			-- 子弹初速：随机水平方向 175 + 垂直上抛 200（按喷发系数），再反向推开表面
			local phys = ent:GetPhysicsObject()
			if phys:IsValid() then
				phys:Wake()

				local angle = Angle(0, 0, 0)
				angle:RotateAroundAxis(angle:Up(), math.random(360))
				phys:SetVelocityInstantaneous(angle:Forward() * 175 + Vector(0, 0, 200) * upmulti - hitnormal * 90)
			end
		end
	end

	-- 播放爆炸音效并自毁
	self:EmitSound(")weapons/explode5.wav", 80, 110)
	self:Remove()
end

-- ==== PhysicsCollide - 物理碰撞：缓冲碰撞数据，交由 Think 结算爆炸 ====
function ENT:PhysicsCollide(data, physobj)
	self.PhysicsData = data
	self:NextThink(CurTime())
end
