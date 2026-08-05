-- ============================================================================
-- weapon_zs_gigashadowchild/shared.lua - 暗影巨婴（巨型僵尸专用武器）
-- 负责：定义拳击攻击、扑倒人类、投掷暗影婴儿、以及嚎叫震击等技能逻辑
--       继承 weapon_zs_gigagorechild（血肉巨婴）基类
-- ============================================================================

-- 继承的基础武器类
SWEP.Base = "weapon_zs_gigagorechild"

-- 武器显示名称（本地化）
SWEP.PrintName = ""..translate.Get("weapon_zs_gigashadowchild")

-- 近战伤害
SWEP.MeleeDamage = 24
-- 近战击飞力度倍率
SWEP.MeleeForceScale = 1

-- ==== PrimaryAttack - 左键拳击 ====
function SWEP:PrimaryAttack()
	-- 正在投掷暗影婴儿时禁止拳击
	if self:IsThrowing() then return end

	self.BaseClass.BaseClass.PrimaryAttack(self)
end

-- ==== Deploy - 切出武器（播放双拳出拳动画） ====
function SWEP:Deploy()
	-- 播放拳头模型出拳动画
	local vm = self:GetOwner():GetViewModel()
	vm:SendViewModelMatchingSequence(vm:LookupSequence("fists_draw"))

	return self.BaseClass.BaseClass.Deploy(self)
end

-- 拳击动画列表（随机挑选）
local anims = {"fists_uppercut", "fists_right", "fists_left"}
-- ==== StartSwinging - 开始挥拳（慢速重拳） ====
function SWEP:StartSwinging()
	self.BaseClass.BaseClass.StartSwinging(self)

	-- 随机播放一种拳击动画，并把播放速度调慢（重拳慢动作）
	local vm = self:GetOwner():GetViewModel()
	vm:SendViewModelMatchingSequence(vm:LookupSequence(anims[math.random(#anims)]))
	vm:SetPlaybackRate(0.32)
end

-- ==== ApplyMeleeDamage - 近战伤害结算（扑倒人类并击飞） ====
function SWEP:ApplyMeleeDamage(ent, trace, damage)
	-- 命中活人：沿水平远离方向击飞并扑倒
	if ent:IsValidPlayer() then
		local vel = ent:GetPos() - self:GetOwner():GetPos()
		vel.z = 0
		vel:Normalize()
		vel = vel * 300
		vel.z = 150

		-- 目标 4 秒内未被扑倒过才触发扑倒
		if CurTime() >= (ent.NextKnockdown or 0) then
			ent:KnockDown()
			ent.NextKnockdown = CurTime() + 4
		end
		ent:SetGroundEntity(NULL)
		ent:SetVelocity(vel)

		if SERVER then
			-- 服务器端给予暗视（失明）状态 10 秒
			ent:GiveStatus("dimvision", 10)
		end
	end

	self.BaseClass.BaseClass.ApplyMeleeDamage(self, ent, trace, damage)
end

-- ==== CheckThrow - 检查并执行暗影婴儿投掷 ====
function SWEP:CheckThrow()
	-- 投掷计时到期时生成暗影婴儿实体
	if self:GetThrowing() and CurTime() >= self:GetThrowTime() then
		self:SetThrowTime(0)

		local owner = self:GetOwner()

		-- 记录最近远程攻击时间并播放投掷音效
		owner.LastRangedAttack = CurTime()
		owner:EmitSound("weapons/slam/throw.wav", 70, math.random(78, 82))

		if SERVER then
			-- 在玩家视角位置生成翻滚的暗影婴儿，沿准星方向抛出
			local ent = ents.Create("prop_thrownshadowbaby")
			if ent:IsValid() then
				ent:SetPos(owner:GetShootPos())
				ent:SetAngles(AngleRand())
				ent:SetOwner(owner)
				ent:Spawn()

				local phys = ent:GetPhysicsObject()
				if phys:IsValid() then
					phys:Wake()
					phys:SetVelocityInstantaneous(owner:GetAimVector() * 650)
					phys:AddAngleVelocity(VectorRand() * math.Rand(200, 300))

					ent:SetPhysicsAttacker(owner)
				end
			end
		end
	end
end

-- ==== CheckCry - 检查并执行嚎叫震击 ====
function SWEP:CheckCry()
	-- 嚎叫计时到期时对周围人类造成震击
	if self:IsCrying() and CurTime() >= self:GetCryTime() then
		self:SetCryTime(0)

		local owner = self:GetOwner()
		local worldspace = owner:WorldSpaceCenter()

		-- 屏幕震动 + 低沉破裂音效
		util.ScreenShake(worldspace, 5, 5, 2, 400)
		owner:EmitSound("physics/concrete/concrete_break2.wav", 77, 50)

		-- 半径 150 内、视线可见的活人：扑倒 + 暗视状态
		for k, ent in pairs(ents.FindInSphere(worldspace, 150)) do
			if ent:IsValid() and ent:IsValidLivingHuman() and WorldVisible(ent:GetPos(), worldspace) then
				if CurTime() >= (ent.NextKnockdown or 0) then
					ent:KnockDown()
					ent.NextKnockdown = CurTime() + 4
					if SERVER then
						ent:GiveStatus("dimvision", 10)
					end
				end
			end
		end
	end
end
