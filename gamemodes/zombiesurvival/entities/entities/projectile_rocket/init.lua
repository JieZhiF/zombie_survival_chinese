-- ============================================================================
-- init.lua - 火箭投射物（服务端）
-- 负责：火箭飞行 4 秒或碰撞后爆炸，对爆炸半径内敌人造成范围伤害
-- ============================================================================
INC_SERVER()

-- ==== Initialize - 初始化火箭 ====
-- 设置 4 秒自毁时限、导弹模型与球形物理；副武器模式（DTBool 0）缩小模型
function ENT:Initialize()
	self.DieTime = CurTime() + 4

	self:SetModel("models/weapons/w_missile_closed.mdl")
	self:PhysicsInitSphere(1)
	self:SetSolid(SOLID_VPHYSICS)

	-- 副武器模式（小型火箭）按 0.4 比例缩小模型
	if self:GetDTBool(0) then
		self:SetModelScale(0.4, 0)
	end

	self:SetupGenericProjectile(false)
end

-- ==== Think - 驱动爆炸流程 ====
-- 碰撞后立即爆炸；爆炸后播放对应特效并移除，超时则自行爆炸
function ENT:Think()
	-- 有碰撞数据则爆炸
	if self.PhysicsData then
		self:Explode()
	end

	-- 爆炸完成后：主武器播爆炸特效，副武器只播音效，然后移除自身
	if self.Exploded then
		local pos = self:GetPos()
		local alt = self:GetDTBool(0)

		if not alt then
			local effectdata = EffectData()
				effectdata:SetOrigin(pos)
			util.Effect("Explosion", effectdata)
			util.Effect("explosion_rocket", effectdata)
		else
			self:EmitSound(")weapons/explode5.wav", 80, 130)
		end

		self:Remove()
	elseif self.DieTime <= CurTime() then
		self:Explode()
	end
end

-- ==== Explode - 引爆火箭 ====
-- 主人有效时在自身位置对半径 85 单位内造成范围伤害（伤害随距离衰减）
function ENT:Explode()
	if self.Exploded then return end
	self.Exploded = true

	local owner = self:GetOwner()
	if owner:IsValidHuman() then
		local pos = self:GetPos()

		local source = self:ProjectileDamageSource()
		util.BlastDamagePlayer(source, owner, pos, 85, self.ProjDamage, DMG_ALWAYSGIB, self.ProjTaper)
	end
end

-- ==== PhysicsCollide - 物理碰撞回调 ====
-- 记录碰撞数据并安排下一帧引爆（忽略具体碰撞点，统一在自身位置爆炸）
function ENT:PhysicsCollide(data, phys)
	self.PhysicsData = data
	self:NextThink(CurTime())
end
