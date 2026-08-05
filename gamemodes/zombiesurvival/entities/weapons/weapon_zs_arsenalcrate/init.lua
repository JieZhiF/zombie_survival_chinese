-- ============================================================================
-- weapon_zs_arsenalcrate/init.lua - 军械箱部署武器（服务器端）
-- 负责：展开时给予放置预览"幽灵"状态、左键放置军械箱实体、
--       以及每帧同步军械箱数量到客户端
-- ============================================================================
INC_SERVER() -- 服务器专用文件标记

-- ==== Deploy - 武器展开时 ====
-- 通知游戏模式部署事件，并生成放置位置的幽灵预览
function SWEP:Deploy()
	gamemode.Call("WeaponDeployed", self:GetOwner(), self)

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
-- 给予玩家"军械箱幽灵"状态，用于预览箱子的放置位置
function SWEP:SpawnGhost()
	local owner = self:GetOwner()
	if owner and owner:IsValid() then
		owner:GiveStatus("ghost_arsenalcrate")
	end
end

-- ==== RemoveGhost - 移除放置预览幽灵 ====
function SWEP:RemoveGhost()
	local owner = self:GetOwner()
	if owner and owner:IsValid() then
		owner:RemoveStatus("ghost_arsenalcrate", false, true)
	end
end

-- ==== PrimaryAttack - 左键：放置军械箱 ====
function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end

	local owner = self:GetOwner()

	-- 通过幽灵状态检查当前位置是否允许放置
	local status = owner.status_ghost_arsenalcrate
	if not (status and status:IsValid()) then return end
	status:RecalculateValidity()
	if not status:GetValidPlacement() then return end

	-- 获取计算好的放置位置与朝向
	local pos, ang = status:RecalculateValidity()
	if not pos or not ang then return end

	self:SetNextPrimaryAttack(CurTime() + self.Primary.Delay) -- 攻击冷却

	-- 生成军械箱实体并设置位置与朝向
	local ent = ents.Create("prop_arsenalcrate")
	if ent:IsValid() then
		ent:SetPos(pos)
		ent:SetAngles(ang)
		ent:Spawn()

		ent:SetObjectOwner(owner) -- 设置物件所有者
		ent:SetupDeployableSkillHealth() -- 按部署技能计算生命值

		ent:EmitSound("npc/dog/dog_servo12.wav") -- 放置音效

		ent:GhostAllPlayersInMe(5) -- 让箱内玩家进入幽灵状态（防卡住）

		self:TakePrimaryAmmo(1) -- 消耗 1 个军械箱

		-- 若之前收起过军械箱，恢复其保存的生命值
		local stored = owner:PopPackedItem(ent:GetClass())
		if stored then
			ent:SetObjectHealth(stored[1])
		end

		-- 军械箱数量用完后移除该武器
		if self:GetPrimaryAmmoCount() <= 0 then
			owner:StripWeapon(self:GetClass())
		end
	end
end

-- ==== Think - 思考帧：同步军械箱数量 ====
-- 数量变化时同步给客户端并重置玩家移动速度（重量感）
function SWEP:Think()
	local count = self:GetPrimaryAmmoCount()
	if count ~= self:GetReplicatedAmmo() then
		self:SetReplicatedAmmo(count) -- 同步数量到客户端
		self:GetOwner():ResetSpeed() -- 重新计算移动速度
	end
end
