-- ============================================================================
-- weapon_zs_camera/init.lua - 相机部署武器（服务器端）
-- 负责：部署时生成相机放置预览（Ghost）状态，左键在预览位置放置相机实体，
--       随后自动切换到相机控制武器（weapon_zs_cameracontrol）
-- ============================================================================
INC_SERVER()

-- ==== Deploy - 武器部署 ====
function SWEP:Deploy()
	-- 通知游戏模式武器已部署
	gamemode.Call("WeaponDeployed", self:GetOwner(), self)

	-- 记录待机动画播放完成时间（防止部署动画被打断）
	self.IdleAnimation = CurTime() + self:SequenceDuration()

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
		-- 为持有者添加相机放置预览状态（GhostStatus 由状态系统提供虚拟放置物）
		owner:GiveStatus(self.GhostStatus)
	end
end

-- ==== RemoveGhost - 移除放置预览 ====
function SWEP:RemoveGhost()
	local owner = self:GetOwner()
	if owner and owner:IsValid() then
		-- 移除相机放置预览状态
		owner:RemoveStatus(self.GhostStatus, false, true)
	end
end

-- ==== PrimaryAttack - 左键放置相机 ====
function SWEP:PrimaryAttack()
	-- 冷却/弹药检查
	if not self:CanPrimaryAttack() then return end

	local owner = self:GetOwner()

	-- 获取放置预览状态并确认当前放置位置有效
	local status = owner:GetStatus(self.GhostStatus)
	if not (status and status:IsValid()) then return end
	status:RecalculateValidity()
	if not status:GetValidPlacement() then return end

	-- 取得最终放置位置与角度
	local pos, ang = status:RecalculateValidity()
	if not pos or not ang then return end

	-- 设置下一次攻击的冷却时间
	self:SetNextPrimaryAttack(CurTime() + self.Primary.Delay)

	-- 在预览位置创建相机实体
	local ent = ents.Create(self.DeployClass)
	if ent:IsValid() then
		ent:SetPos(pos)
		ent:SetAngles(ang)
		ent.PreOwn = owner
		ent:Spawn()

		-- 设置相机归属者
		ent:SetObjectOwner(owner)

		-- 播放放置音效
		ent:EmitSound("npc/dog/dog_servo12.wav")

		-- 消耗一发弹药
		self:TakePrimaryAmmo(1)

		-- 若背包中存有打包的相机，恢复其生命值
		local stored = owner:PopPackedItem(ent:GetClass())
		if stored then
			ent:SetObjectHealth(stored[1])
		end

		-- 确保玩家持有相机控制武器并立即切换过去
		if not owner:HasWeapon("weapon_zs_cameracontrol") then
			owner:Give("weapon_zs_cameracontrol")
		end
		owner:SelectWeapon("weapon_zs_cameracontrol")

		-- 弹药耗尽后自动移除本武器
		if self:GetPrimaryAmmoCount() <= 0 then
			owner:StripWeapon(self:GetClass())
		end
	end
end
