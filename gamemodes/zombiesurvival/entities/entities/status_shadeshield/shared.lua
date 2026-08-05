-- ============================================================================
-- status_shadeshield/shared.lua - 阴影护盾状态（共享）
-- 负责：护盾实体的类型声明与状态/血量存取接口；碰撞过滤（放行友方投射
--       物与玩家/路障）；锁定拥有者移动；护盾血量归零时触发破碎特效
-- ============================================================================

-- 动画实体类型（可挂接在拥有者身上跟随移动）
ENT.Type = "anim"
-- 继承通用状态实体基类，复用其生命周期管理
ENT.Base = "status__base"
-- 半透明渲染组，保证与透明物体正确排序绘制
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
-- 近战攻击不会命中护盾
ENT.IgnoreMelee = true

-- ==== ShouldNotCollide - 碰撞过滤：放行友军投射物与玩家/路障 ====
function ENT:ShouldNotCollide(ent)
	-- 僵尸阵营（友军）的投射物直接穿过护盾
	if ent:IsProjectile() then
		local owner = ent:GetOwner()
		if owner:IsValid() and owner:Team() == TEAM_UNDEAD then return true end
	end

	-- 路障、玩家、武器等实体同样不与护盾发生碰撞
	local colgroup = ent:GetCollisionGroup()
	if ent.IsBarricadeObject or colgroup == COLLISION_GROUP_PLAYER or colgroup == COLLISION_GROUP_WEAPON or colgroup == COLLISION_GROUP_NONE then
		return true
	end

	return false
end

-- ==== Move - 移动限制：护盾展开期间锁定拥有者，禁止移动 ====
function ENT:Move(pl, move)
	if pl ~= self:GetOwner() then return end

	-- 将拥有者的移动速度钳制为 0，实现护盾定身效果
	move:SetMaxSpeed(0)
	move:SetMaxClientSpeed(0)
end

-- ==== SetState - 设置护盾状态（0=展开中 1=完全展开） ====
function ENT:SetState(state)
	self:SetDTInt(0, state)
end

-- ==== GetState - 获取护盾当前状态 ====
function ENT:GetState()
	return self:GetDTInt(0)
end

-- ==== SetStateEndTime - 设置状态结束时间（驱动展开/收起动画） ====
function ENT:SetStateEndTime(time)
	self:SetDTFloat(0, time)
end

-- ==== GetStateEndTime - 获取状态结束时间 ====
function ENT:GetStateEndTime()
	return self:GetDTFloat(0)
end

-- ==== SetDirection - 设置护盾方向（整数索引，客户端据此旋转显示） ====
function ENT:SetDirection(m)
	self:SetDTInt(1, m)
end

-- ==== GetDirection - 获取护盾方向 ====
function ENT:GetDirection()
	return self:GetDTInt(1)
end

-- ==== SetObjectHealth - 设置护盾血量；首次归零时触发破碎特效与音效 ====
function ENT:SetObjectHealth(health)
	self:SetDTFloat(1, health)
	-- 血量首次降到 0 及以下时触发破碎表现（只触发一次）
	if health <= 0 and not self.Destroyed then
		self.Destroyed = true

		if SERVER then
			-- 播放爆炸特效、屏幕震动与爆炸音效
			local effectdata = EffectData()
				effectdata:SetOrigin(self:WorldSpaceCenter())
				effectdata:SetNormal(self:GetUp())
			util.Effect("explosion_shadeshield", effectdata, true, true)

			util.ScreenShake(self:GetPos(), 15, 5, 1.5, 800)
			self:EmitSound("ambient/levels/labs/electric_explosion2.wav", 85, 100)
		end
	end
end

-- ==== GetObjectHealth - 获取护盾当前血量 ====
function ENT:GetObjectHealth()
	return self:GetDTFloat(1)
end

-- ==== SetMaxObjectHealth - 设置护盾最大血量 ====
function ENT:SetMaxObjectHealth(health)
	self:SetDTFloat(2, health)
end

-- ==== GetMaxObjectHealth - 获取护盾最大血量 ====
function ENT:GetMaxObjectHealth()
	return self:GetDTFloat(2)
end
