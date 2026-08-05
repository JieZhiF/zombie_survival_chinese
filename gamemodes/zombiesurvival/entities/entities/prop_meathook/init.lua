-- ============================================================================
-- prop_meathook/init.lua - 肉钩（服务器）
-- 负责：挂在僵尸身上周期性造成切割流血伤害；条件不满足时掉落为可拾取武器
-- ============================================================================
INC_SERVER()

-- 下一次造成伤害的时间戳
ENT.NextDamage = 0
-- 剩余流血次数（共 10 次）
ENT.TicksLeft = 10

-- ==== Initialize - 初始化：创建无碰撞、静止的肉钩模型 ====
function ENT:Initialize()
	self:SetModel("models/props_junk/meathook001a.mdl")
	-- 纯伤害载体：无碰撞、不移动
	self:SetSolid(SOLID_NONE)
	self:SetMoveType(MOVETYPE_NONE)
	-- 设置骨骼更新标记，保证模型正常渲染
	self:AddEFlags(EFL_SETTING_UP_BONES)
end

-- ==== Drop - 从僵尸身上掉落：转化为可拾取的地面武器 ====
function ENT:Drop()
	-- 生成对应武器的 prop_weapon 掉落物
	local ent = ents.Create("prop_weapon")
	if ent:IsValid() then
		ent:SetWeaponType(self.BaseWeapon)
		ent:SetPos(self:GetPos())
		ent:SetAngles(self:GetAngles())
		ent:Spawn()

		-- 掉落 15 秒内仅限原拥有者拾取
		local owner = self:GetOwner()
		if owner:IsValidHuman() then
			ent.NoPickupsTime = CurTime() + 15
			ent.NoPickupsOwner = owner
		end

		-- 赋予掉落物随机翻滚与上抛速度，模拟真实掉落
		local phys = ent:GetPhysicsObject()
		if phys:IsValid() then
			phys:Wake()
			phys:AddAngleVelocity(VectorRand() * 200)
			phys:SetVelocityInstantaneous(Vector(0, 0, 200))
		end
	end

	self:Remove()
end

-- ==== Think - 流血结算：周期性伤害僵尸，目标不满足条件则掉落或移除 ====
function ENT:Think()
	local parent = self:GetParent()
	-- 挂在玩家身上时持续造成伤害
	if parent:IsValid() and parent:IsPlayer() then
		-- 目标为存活、亡灵阵营、非重生保护且仍有剩余次数时结算一次流血
		if parent:Alive() and parent:Team() == TEAM_UNDEAD and self.TicksLeft >= 1 and not parent.SpawnProtection then
			if CurTime() >= self.NextDamage then
				local owner = self:GetOwner()

				-- 每 0.35 秒结算一次，扣减剩余次数
				self.NextDamage = CurTime() + 0.35
				self.TicksLeft = self.TicksLeft - 1

				-- 肉钩带削弱效果时，同时附加短暂的力量削弱状态（0.45 秒）
				if self.Weaken then
					local status = parent:GiveStatus("zombiestrdebuff")
					status.DieTime = CurTime() + 0.45
					status.Applier = owner
				end

				-- 播放血液喷溅效果并造成切割伤害
				util.Blood((parent:NearestPoint(self:GetPos()) + parent:WorldSpaceCenter()) / 2, math.random(4, 9), Vector(0, 0, 1), 100)
				parent:TakeSpecialDamage(self.BleedPerTick, DMG_SLASH, owner, self)
			end
		else
			-- 目标死亡/非亡灵/受保护/次数耗尽：掉落为武器
			self:Drop()
		end
	else
		-- 父实体不是玩家（如已被移除）：直接销毁
		self:Remove()
	end
end
