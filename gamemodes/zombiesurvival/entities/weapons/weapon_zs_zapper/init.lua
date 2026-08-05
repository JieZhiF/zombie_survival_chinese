-- ============================================================================
-- init.lua - 电击器（可部署陷阱武器）服务端逻辑
-- 负责：幽灵预览状态管理（SpawnGhost/RemoveGhost）、部署 prop_zapper 实体
--       （位置校验/弹药转移/属性注入）、弹药复制与移速联动
-- ============================================================================

-- 服务端 realm 守卫：仅服务端加载本文件（替代 if SERVER then 写法）
INC_SERVER()

-- ==== Deploy - 部署武器：广播部署事件并生成放置预览 ====
function SWEP:Deploy()
	gamemode.Call("WeaponDeployed", self:GetOwner(), self)

	self:SpawnGhost()

	return true
end

-- ==== OnRemove - 武器被移除时清除放置预览 ====
function SWEP:OnRemove()
	self:RemoveGhost()
end

-- ==== Holster - 收起武器时清除放置预览 ====
function SWEP:Holster()
	self:RemoveGhost()
	return true
end

-- ==== SpawnGhost - 给予持有者"幽灵电击器"状态（显示可放置预览） ====
function SWEP:SpawnGhost()
	local owner = self:GetOwner()
	if owner and owner:IsValid() then
		owner:GiveStatus(self.GhostStatus)
	end
end

-- ==== RemoveGhost - 移除持有者的幽灵状态（隐藏放置预览） ====
function SWEP:RemoveGhost()
	local owner = self:GetOwner()
	if owner and owner:IsValid() then
		owner:RemoveStatus(self.GhostStatus, false, true)
	end
end

-- ==== PrimaryAttack - 开火：在合法位置部署电击器实体 ====
function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end

	local owner = self:GetOwner()

	-- 读取幽灵状态并校验放置合法性
	local status = owner:GetStatus(self.GhostStatus)
	if not (status and status:IsValid()) then return end
	status:RecalculateValidity()
	if not status:GetValidPlacement() then return end

	-- 获取最终放置位置与角度
	local pos, ang = status:RecalculateValidity()
	if not pos or not ang then return end

	-- 设置部署冷却
	self:SetNextPrimaryAttack(CurTime() + self.Primary.Delay)

	-- 生成电击器实体并放置
	local ent = ents.Create(self.DeployClass)
	if ent:IsValid() then
		ent:SetPos(pos)
		ent:SetAngles(ang)
		ent:Spawn()

		-- 记录所有者并应用技能树生命值
		ent:SetObjectOwner(owner)
		ent:SetupDeployableSkillHealth()

		-- 部署音效；2 秒后开始电击
		ent:EmitSound("npc/dog/dog_servo12.wav")

		ent:SetNextZap(CurTime() + 2)

		-- 消耗一发部署弹药
		self:TakePrimaryAmmo(1)

		-- 若玩家曾打包保存过同类电击器，恢复其耐久
		local stored = owner:PopPackedItem(ent:GetClass())
		if stored then
			ent:SetObjectHealth(stored[1])
		end

		-- 转移最多 150 发脉冲弹药给电击器作为电量
		local ammo = math.min(owner:GetAmmoCount("pulse"), 150)
		ent:SetAmmo(ammo)
		owner:RemoveAmmo(ammo, "pulse")

		-- 注入战斗属性：弹药类型/伤害/腿部伤害/来源武器
		ent.DeployableAmmo = self.Primary.Ammo
		ent.Damage = self.Primary.Damage
		ent.LegDamage = self.LegDamage
		ent.SWEP = self:GetClass()

		-- 部署弹药耗尽后自动卸下武器
		if self:GetPrimaryAmmoCount() <= 0 then
			owner:StripWeapon(self:GetClass())
		end
	end
end

-- ==== Think - 每帧同步弹药数到客户端，弹药变化时重置移动速度 ====
function SWEP:Think()
	local count = self:GetPrimaryAmmoCount()
	if count ~= self:GetReplicatedAmmo() then
		self:SetReplicatedAmmo(count)
		self:GetOwner():ResetSpeed()
	end
end
