-- ============================================================================
-- weapon_zs_medicfield/init.lua - 医疗站部署器（服务器端）
-- 负责：出枪时生成放置预览（幽灵状态）；左键在有效位置部署医疗脉冲站实体，
--       并把携带的电池弹药（上限 150）转入站点；同步弹药显示
-- ============================================================================
INC_SERVER()

-- ==== Deploy - 出枪：触发部署事件并生成放置预览幽灵 ====
function SWEP:Deploy()
	-- 通知游戏模式武器已部署
	gamemode.Call("WeaponDeployed", self:GetOwner(), self)

	-- 生成放置预览（幽灵）
	self:SpawnGhost()

	return true
end

-- ==== OnRemove - 武器移除时清除放置预览 ====
function SWEP:OnRemove()
	self:RemoveGhost()
end

-- ==== Holster - 收枪时清除放置预览 ====
function SWEP:Holster()
	self:RemoveGhost()
	return true
end

-- ==== SpawnGhost - 给予所有者放置预览状态 ====
function SWEP:SpawnGhost()
	local owner = self:GetOwner()
	if owner and owner:IsValid() then
		owner:GiveStatus(self.GhostStatus)
	end
end

-- ==== RemoveGhost - 移除所有者的放置预览状态 ====
function SWEP:RemoveGhost()
	local owner = self:GetOwner()
	if owner and owner:IsValid() then
		owner:RemoveStatus(self.GhostStatus, false, true)
	end
end

-- ==== PrimaryAttack - 左键：在幽灵的有效位置部署医疗站 ====
function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end

	local owner = self:GetOwner()

	-- 必须有放置预览状态且当前位置有效
	local status = owner:GetStatus(self.GhostStatus)
	if not (status and status:IsValid()) then return end
	status:RecalculateValidity()
	if not status:GetValidPlacement() then return end

	-- 取得最终放置位置与朝向
	local pos, ang = status:RecalculateValidity()
	if not pos or not ang then return end

	-- 进入攻击冷却
	self:SetNextPrimaryAttack(CurTime() + self.Primary.Delay)

	-- 创建医疗站实体并放置在目标位置
	local ent = ents.Create(self.DeployClass)
	if ent:IsValid() then
		ent:SetPos(pos)
		ent:SetAngles(ang)
		ent:Spawn()

		-- 绑定所有者并初始化部署物的技能血量
		ent:SetObjectOwner(owner)
		ent:SetupDeployableSkillHealth()

		-- 部署完成音效
		ent:EmitSound("npc/dog/dog_servo12.wav")

		-- 1 秒后开始第一次医疗脉冲
		ent:SetNextMedicPulse(CurTime() + 1)

		-- 消耗 1 发"电池"充能
		self:TakePrimaryAmmo(1)

		-- 若有回收存储的物品（同类实体），继承其血量
		local stored = owner:PopPackedItem(ent:GetClass())
		if stored then
			ent:SetObjectHealth(stored[1])
		end

		-- 把携带的电池弹药转入站点（上限 150 发）
		local ammo = math.min(owner:GetAmmoCount("Battery"), 150)
		ent:SetAmmo(ammo)
		owner:RemoveAmmo(ammo, "Battery")

		-- 配置站点的治疗参数与来源武器
		ent.DeployableAmmo = self.Primary.Ammo
		ent.HealValue = self.MedicHeal
		ent.MaxDistance = self.MaxDistance
		ent.SWEP = self:GetClass()

		-- 充能耗尽后自动移除本武器
		if self:GetPrimaryAmmoCount() <= 0 then
			owner:StripWeapon(self:GetClass())
		end
	end
end

-- ==== Think - 每帧：弹药变化时同步给客户端并刷新移动速度 ====
function SWEP:Think()
	local count = self:GetPrimaryAmmoCount()
	if count ~= self:GetReplicatedAmmo() then
		self:SetReplicatedAmmo(count)
		-- 重量变化影响移动速度，通知系统重算
		self:GetOwner():ResetSpeed()
	end
end
