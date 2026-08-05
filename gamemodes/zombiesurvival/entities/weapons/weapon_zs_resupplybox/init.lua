-- ============================================================================
-- weapon_zs_resupplybox/init.lua - 补给箱部署武器（服务器端）
-- 负责：部署时生成放置预览（Ghost），左键在预览位置生成 prop_resupplybox 实体，
--       弹药耗尽后自动移除武器
-- ============================================================================
INC_SERVER()

-- ==== Deploy - 武器部署 ====
function SWEP:Deploy()
	-- 通知游戏模式武器已部署
	gamemode.Call("WeaponDeployed", self:GetOwner(), self)

	-- 生成放置预览状态
	self:SpawnGhost()

	return true
end

-- ==== OnRemove - 武器被移除 ====
function SWEP:OnRemove()
	-- 清除放置预览状态
	self:RemoveGhost()
end

-- ==== Holster - 收枪 ====
function SWEP:Holster()
	-- 收枪时清除放置预览状态
	self:RemoveGhost()
	return true
end

-- ==== SpawnGhost - 生成放置预览 ====
function SWEP:SpawnGhost()
	local owner = self:GetOwner()
	if owner and owner:IsValid() then
		-- 为持有者添加补给箱放置预览状态
		owner:GiveStatus("ghost_resupplybox")
	end
end

-- ==== RemoveGhost - 移除放置预览 ====
function SWEP:RemoveGhost()
	local owner = self:GetOwner()
	if owner and owner:IsValid() then
		-- 移除补给箱放置预览状态
		owner:RemoveStatus("ghost_resupplybox", false, true)
	end
end

-- ==== PrimaryAttack - 左键部署补给箱 ====
function SWEP:PrimaryAttack()
	-- 冷却/弹药检查
	if not self:CanPrimaryAttack() then return end

	local owner = self:GetOwner()

	-- 获取放置预览状态并确认放置位置有效
	local status = owner.status_ghost_resupplybox
	if not (status and status:IsValid()) then return end

	local pos, ang = status:RecalculateValidity()
	if not status:GetValidPlacement() or not pos or not ang then return end

	-- 设置下一次攻击的冷却时间
	self:SetNextPrimaryAttack(CurTime() + self.Primary.Delay)

	-- 在预览位置创建补给箱实体
	local ent = ents.Create("prop_resupplybox")
	if ent:IsValid() then
		ent:SetPos(pos)
		ent:SetAngles(ang)
		ent:Spawn()

		-- 设置归属者
		ent:SetObjectOwner(owner)
		-- 初始化部署物技能生命值
		ent:SetupDeployableSkillHealth()

		-- 播放部署音效
		ent:EmitSound("npc/dog/dog_servo12.wav")

		-- 将附近玩家设为穿透状态（避免卡在部署物内）
		ent:GhostAllPlayersInMe(5)

		-- 消耗一发弹药
		self:TakePrimaryAmmo(1)

		-- 若背包中存有打包的补给箱，恢复其生命值
		local stored = owner:PopPackedItem(ent:GetClass())
		if stored then
			ent:SetObjectHealth(stored[1])
		end

		-- 弹药耗尽后自动移除本武器
		if self:GetPrimaryAmmoCount() <= 0 then
			owner:StripWeapon(self:GetClass())
		end
	end
end

-- ==== Think - 每帧同步弹药数量并更新移动速度 ====
function SWEP:Think()
	local count = self:GetPrimaryAmmoCount()
	-- 弹药数量变化时同步到客户端并重置持有者速度
	if count ~= self:GetReplicatedAmmo() then
		self:SetReplicatedAmmo(count)
		self:GetOwner():ResetSpeed()
	end
end
