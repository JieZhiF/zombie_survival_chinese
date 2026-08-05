-- ============================================================================
-- prop_harpoon/init.lua - 鱼叉投射物实体（服务器端）
-- 负责：鱼叉钉在僵尸身上持续放血；目标死亡或非僵尸时掉落为可拾取武器
-- ============================================================================

INC_SERVER()

-- 下一次流血伤害的冷却时间戳
ENT.NextDamage = 0
-- 剩余流血次数（总共 10 次流血后鱼叉自然结束）
ENT.TicksLeft = 10

-- ==== Initialize - 初始化 ====
-- 设置鱼叉模型并关闭物理模拟（随目标移动）
function ENT:Initialize()
	self:SetModel("models/props_junk/harpoon002a.mdl")
	self:SetSolid(SOLID_NONE)
	self:SetMoveType(MOVETYPE_NONE)
	self:AddEFlags(EFL_SETTING_UP_BONES)
end

-- ==== Think - 每帧逻辑 ====
-- 目标为存活的僵尸且未被击中时持续流血；否则转为掉落的武器实体
function ENT:Think()
	local parent = self:GetParent()
	if parent:IsValid() and parent:IsPlayer() then
		-- 目标存活且为僵尸、未触发保护、还有流血次数时造成流血伤害
		if parent:Alive() and parent:Team() == TEAM_UNDEAD and self.TicksLeft >= 1 and not parent.SpawnProtection then
			-- 按 0.35 秒间隔扣除一次流血次数并造成伤害
			if CurTime() >= self.NextDamage then
				self.NextDamage = CurTime() + 0.35
				self.TicksLeft = self.TicksLeft - 1

				-- 在目标身体中间生成血迹效果
				util.Blood((parent:NearestPoint(self:GetPos()) + parent:WorldSpaceCenter()) / 2, math.random(4, 9), Vector(0, 0, 1), 100)
				parent:TakeSpecialDamage(self.BleedPerTick, DMG_SLASH, self:GetOwner(), self)
			end
		else
			-- 目标不再是可流血对象：把鱼叉还原为可拾取的地面武器
			local ang = self:GetAngles()
			ang:RotateAroundAxis(ang:Up(), 180)

			local ent = ents.Create("prop_weapon")
			if ent:IsValid() then
				-- 还原为原始武器类型，并落在地面鱼叉位置
				ent:SetWeaponType(self.BaseWeapon)
				ent:SetPos(self:GetPos())
				ent:SetAngles(ang)
				ent:Spawn()

				-- 原持有者为人类时，15 秒内只有本人能拾取
				local owner = self:GetOwner()
				if owner:IsValidHuman() then
					ent.NoPickupsTime = CurTime() + 15
					ent.NoPickupsOwner = self:GetOwner()
				end

				-- 给掉落的武器一个随机翻滚和上抛的物理效果
				local phys = ent:GetPhysicsObject()
				if phys:IsValid() then
					phys:Wake()
					phys:AddAngleVelocity(VectorRand() * 120)
					phys:SetVelocityInstantaneous(Vector(0, 0, 200))
				end
			end

			-- 鱼叉任务结束，移除自身
			self:Remove()
		end
	else
		-- 目标已失效（消失/死亡），直接移除
		self:Remove()
	end
end
