-- ============================================================================
-- projectile_purger/init.lua - 净化弹投射物（服务器）
-- 负责：飞行 0.7 秒后自毁；接触玩家后治疗其中毒者并清除可抵抗负面状态，
--       最多净化 4 名目标；碰撞后播放音效并移除
-- ============================================================================
INC_SERVER()

-- ==== Initialize - 初始化：登记状态表、设定模型与球形物理 ====
function ENT:Initialize()
	-- 已接触目标表（键为目标实体，值为 true）
	self.Touched = {}
	-- 已净化目标表（防止重复治疗/清除状态）
	self.Damaged = {}

	-- 0.7 秒后无条件自毁（投射物短寿命兜底）
	self:Fire("kill", "", 0.7)

	-- 使用十字弓弩弹模型，10 单位半径球形物理体
	self:SetModel("models/Items/CrossbowRounds.mdl")
	self:PhysicsInitSphere(10)
	self:SetSolid(SOLID_VPHYSICS)
	-- 应用游戏模式统一的投射物初始参数（重力、速度、碰撞等）
	self:SetupGenericProjectile(false)
end

-- ==== Think - 净化结算：治疗中毒者并清除可抵抗状态，最多 4 名 ====
function ENT:Think()
	-- 每帧持续运行
	self:NextThink(CurTime())

	-- 获取施放者，失效时以自身代替（保证来源有效）
	local owner = self:GetOwner()
	if not owner:IsValid() then owner = self end

	-- 已净化满 4 名目标后停止处理，等待自毁
	if table.Count(self.Damaged) >= 4 then return true end

	-- 遍历所有接触过的实体，只处理尚未净化且存活的人类玩家
	for ent, _ in pairs(self.Touched) do
		if not self.Damaged[ent] and ent:IsValidLivingHuman() then
			-- 目标带有中毒伤害时：标记净化并治疗（治疗量取自 ENT.Heal）
			if ent:GetPoisonDamage() > 0 then
				self.Damaged[ent] = true
				owner:HealPlayer(ent, self.Heal, nil, nil, true)
			end

			-- 目标带有可抵抗负面状态（疾病/失明/虚弱等）时逐一清除
			for _,v in ipairs(GAMEMODE.ResistableStatuses) do
				if ent:GetStatus(v) then
					self.Damaged[ent] = true

					-- 直接移除状态（不触发死亡掉落），施放者获得 0.2 分奖励
					ent:RemoveStatus(v, false, true)
					owner:AddPoints(0.2)
				end
			end
		end
	end
	return true
end

-- ==== PhysicsCollide - 物理碰撞：播放蒸汽音效并延迟自毁 ====
function ENT:PhysicsCollide(data, phys)
	-- 只处理首次碰撞，防止重复触发
	if self.Done then return end
	self.Done = true

	-- 0.1 秒后移除实体，并播放高频蒸汽释放音效
	self:Fire("kill", "", 0.1)
	self:EmitSound("ambient/machines/steam_release_2.wav", 70, 175)
end

-- ==== StartTouch - 开始接触：记录施放者以外的玩家目标 ====
function ENT:StartTouch(ent)
	-- 忽略已记录目标与无效实体
	if self.Touched[ent] or not ent:IsValid() then return end

	-- 获取施放者，失效时以自身代替
	local owner = self:GetOwner()
	if not owner:IsValid() then owner = self end

	-- 忽略施放者本人及非玩家实体
	if ent == owner or not ent:IsPlayer() then return end

	-- 登记为净化候选目标
	self.Touched[ent] = true
end
