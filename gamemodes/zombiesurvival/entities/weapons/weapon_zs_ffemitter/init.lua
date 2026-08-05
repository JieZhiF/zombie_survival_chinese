-- ============================================================================
-- weapon_zs_ffemitter/init.lua - 火焰发射器建造装置（服务器端逻辑）
-- 负责：放置幽灵管理、生成火焰发射器实体与弹药消耗
-- ============================================================================
INC_SERVER()

-- ==== Deploy - 出枪：通知游戏模式并生成放置幽灵 ====
function SWEP:Deploy()
	gamemode.Call("WeaponDeployed", self:GetOwner(), self)

	self:SpawnGhost()

	return true
end

-- ==== OnRemove - 武器移除时：清除放置幽灵 ====
function SWEP:OnRemove()
	self:RemoveGhost()
end

-- ==== Holster - 收枪：清除放置幽灵 ====
function SWEP:Holster()
	self:RemoveGhost()
	return true
end

-- ==== SpawnGhost - 给持有者附加放置幽灵状态 ====
function SWEP:SpawnGhost()
	local owner = self:GetOwner()
	if owner and owner:IsValid() then
		owner:GiveStatus("ghost_ffemitter")
	end
end

-- ==== RemoveGhost - 移除持有者的放置幽灵状态 ====
function SWEP:RemoveGhost()
	local owner = self:GetOwner()
	if owner and owner:IsValid() then
		owner:RemoveStatus("ghost_ffemitter", false, true)
	end
end

-- ==== PrimaryAttack - 主攻击：在幽灵位置放置火焰发射器 ====
function SWEP:PrimaryAttack()
	-- 弹药/状态检查
	if not self:CanPrimaryAttack() then return end

	local owner = self:GetOwner()

	-- 读取放置幽灵并校验放置合法性
	local status = owner.status_ghost_ffemitter
	if not (status and status:IsValid()) then return end
	status:RecalculateValidity()
	if not status:GetValidPlacement() then return end

	-- 重新计算合法的放置位置与角度
	local pos, ang = status:RecalculateValidity()
	if not pos or not ang then return end

	-- 设置攻击冷却
	self:SetNextPrimaryAttack(CurTime() + self.Primary.Delay)

	-- 生成火焰发射器实体并设置位置/角度
	local ent = ents.Create("prop_ffemitter")
	if ent:IsValid() then
		ent:SetPos(pos)
		ent:SetAngles(ang)
		ent:Spawn()

		-- 归属玩家并设置技能加成生命值
		ent:SetObjectOwner(owner)
		ent:SetupDeployableSkillHealth()

		ent:EmitSound("npc/dog/dog_servo12.wav")

		-- 消耗一枚建造弹药
		self:TakePrimaryAmmo(1)

		-- 若有打包存储的旧实体，恢复其生命值
		local stored = owner:PopPackedItem(ent:GetClass())
		if stored then
			ent:SetObjectHealth(stored[1])
		end

		-- 将玩家携带的脉冲弹药转移给发射器（上限 150 发）
		local ammo = math.min(owner:GetAmmoCount("pulse"), 150)
		ent:SetAmmo(ammo)
		owner:RemoveAmmo(ammo, "pulse")

		-- 建造弹药耗尽后移除本武器
		if self:GetPrimaryAmmoCount() <= 0 then
			owner:StripWeapon(self:GetClass())
		end
	end
end

-- ==== Think - 每帧逻辑：弹药变化时同步并重置玩家移速 ====
function SWEP:Think()
	local count = self:GetPrimaryAmmoCount()
	if count ~= self:GetReplicatedAmmo() then
		self:SetReplicatedAmmo(count)
		self:GetOwner():ResetSpeed()
	end
end
