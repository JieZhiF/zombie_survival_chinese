-- ============================================================================
-- weapon_zs_repairfield/init.lua - 修理场部署器（服务器端定义）
-- 负责：放置幽灵预览的生命周期管理与实际部署修理场实体的逻辑
-- ============================================================================
-- 服务器端专用（GMod 武器文件的标准服务器入口标记）
INC_SERVER()

-- ==== Deploy - 切换出武器时生成放置预览 ====
function SWEP:Deploy()
	-- 通知游戏模式武器已切换出
	gamemode.Call("WeaponDeployed", self:GetOwner(), self)

	-- 生成幽灵预览（显示可放置位置）
	self:SpawnGhost()

	return true
end

-- ==== OnRemove - 武器移除时清理幽灵预览 ====
function SWEP:OnRemove()
	self:RemoveGhost()
end

-- ==== Holster - 收起武器时清理幽灵预览 ====
function SWEP:Holster()
	self:RemoveGhost()
	return true
end

-- ==== SpawnGhost - 为主人附加放置预览状态 ====
function SWEP:SpawnGhost()
	local owner = self:GetOwner()
	if owner and owner:IsValid() then
		owner:GiveStatus(self.GhostStatus)
	end
end

-- ==== RemoveGhost - 移除主人的放置预览状态 ====
function SWEP:RemoveGhost()
	local owner = self:GetOwner()
	if owner and owner:IsValid() then
		owner:RemoveStatus(self.GhostStatus, false, true)
	end
end

-- ==== PrimaryAttack - 左键部署修理场（核心逻辑） ====
function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end

	local owner = self:GetOwner()

	-- 获取放置预览状态并检查放置点是否有效
	local status = owner:GetStatus(self.GhostStatus)
	if not (status and status:IsValid()) then return end
	status:RecalculateValidity()
	if not status:GetValidPlacement() then return end

	-- 重新计算得出最终放置位置与角度
	local pos, ang = status:RecalculateValidity()
	if not pos or not ang then return end

	-- 设置攻击冷却
	self:SetNextPrimaryAttack(CurTime() + self.Primary.Delay)

	-- 生成修理场实体
	local ent = ents.Create(self.DeployClass)
	if ent:IsValid() then
		ent:SetPos(pos)
		ent:SetAngles(ang)
		ent:Spawn()

		-- 设置归属与可部署技能的耐久
		ent:SetObjectOwner(owner)
		ent:SetupDeployableSkillHealth()

		-- 播放部署音效，并设置首次脉冲延迟
		ent:EmitSound("npc/dog/dog_servo12.wav")

		ent:SetNextRepairPulse(CurTime() + 4)

		-- 消耗一个部署器弹药
		self:TakePrimaryAmmo(1)

		-- 若背包中有回收的同类型修理场，恢复其耐久
		local stored = owner:PopPackedItem(ent:GetClass())
		if stored then
			ent:SetObjectHealth(stored[1])
		end

		-- 把携带的脉冲弹药充入修理场（上限 150）
		local ammo = math.min(owner:GetAmmoCount("pulse"), 150)
		ent:SetAmmo(ammo)
		owner:RemoveAmmo(ammo, "pulse")

		-- 传递武器相关属性给修理场实体
		ent.DeployableAmmo = self.Primary.Ammo
		ent.HealValue = self.Repair
		ent.MaxDistance = self.MaxDistance
		ent.SWEP = self:GetClass()

		-- 弹药耗尽后自动移除该武器
		if self:GetPrimaryAmmoCount() <= 0 then
			owner:StripWeapon(self:GetClass())
		end
	end
end

-- ==== Think - 每帧同步弹药量并刷新移动速度 ====
function SWEP:Think()
	local count = self:GetPrimaryAmmoCount()
	if count ~= self:GetReplicatedAmmo() then
		-- 弹药变化时同步给客户端，并让主人重新计算速度
		self:SetReplicatedAmmo(count)
		self:GetOwner():ResetSpeed()
	end
end
