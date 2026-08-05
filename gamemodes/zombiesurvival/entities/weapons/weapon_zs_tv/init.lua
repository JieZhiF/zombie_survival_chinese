-- ============================================================================
-- weapon_zs_tv/init.lua - 电视部署物武器（服务器端）
-- 负责：部署电视实体（带放置预览"幽灵"状态）；展开时给予幽灵状态、
--       收起/移除时移除，左键在有效位置放置电视并消耗数量
-- ============================================================================
INC_SERVER() -- 服务器专用文件标记

-- ==== Deploy - 武器展开时 ====
-- 通知游戏模式部署事件，并生成放置位置的幽灵预览
function SWEP:Deploy()
	gamemode.Call("WeaponDeployed", self:GetOwner(), self)

	self.IdleAnimation = CurTime() + self:SequenceDuration() -- 延迟待机动画

	self:SpawnGhost() -- 生成放置预览幽灵

	return true
end

-- ==== OnRemove - 武器被移除时 ====
-- 清理放置预览幽灵
function SWEP:OnRemove()
	self:RemoveGhost()
end

-- ==== Holster - 武器收起时 ====
-- 清理放置预览幽灵后收起
function SWEP:Holster()
	self:RemoveGhost()
	return true
end

-- ==== SpawnGhost - 生成放置预览幽灵 ====
-- 给予玩家"幽灵"状态，用于预览电视的放置位置
function SWEP:SpawnGhost()
	local owner = self:GetOwner()
	if owner and owner:IsValid() then
		owner:GiveStatus(self.GhostStatus)
	end
end

-- ==== RemoveGhost - 移除放置预览幽灵 ====
function SWEP:RemoveGhost()
	local owner = self:GetOwner()
	if owner and owner:IsValid() then
		owner:RemoveStatus(self.GhostStatus, false, true)
	end
end

-- ==== PrimaryAttack - 左键：放置电视 ====
function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end

	local owner = self:GetOwner()

	-- 通过幽灵状态检查当前位置是否允许放置
	local status = owner:GetStatus(self.GhostStatus)
	if not (status and status:IsValid()) then return end
	status:RecalculateValidity()
	if not status:GetValidPlacement() then return end

	-- 获取计算好的放置位置与朝向
	local pos, ang = status:RecalculateValidity()
	if not pos or not ang then return end

	self:SetNextPrimaryAttack(CurTime() + self.Primary.Delay) -- 攻击冷却

	-- 生成电视实体并设置位置与朝向
	local ent = ents.Create(self.DeployClass)
	if ent:IsValid() then
		ent:SetPos(pos)
		ent:SetAngles(ang)
		ent.PreOwn = owner -- 预记录所有者
		ent:Spawn()

		ent:SetObjectOwner(owner) -- 设置物件所有者

		ent:EmitSound("npc/dog/dog_servo12.wav") -- 放置音效

		self:TakePrimaryAmmo(1) -- 消耗 1 个电视

		-- 若之前收起过电视，恢复其保存的生命值
		local stored = owner:PopPackedItem(ent:GetClass())
		if stored then
			ent:SetObjectHealth(stored[1])
		end

		-- 电视数量用完后移除该武器
		if self:GetPrimaryAmmoCount() <= 0 then
			owner:StripWeapon(self:GetClass())
		end
	end
end
