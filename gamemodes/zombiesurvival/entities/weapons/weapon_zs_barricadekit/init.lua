-- ============================================================================
-- init.lua - 搭建包（服务器端）
-- 负责：幽灵预览、木板放置（prop_aegisboard）与耐久继承逻辑
-- ============================================================================
INC_SERVER()

-- ==== Deploy - 部署时广播事件、开始闲置动画并生成幽灵预览 ====
function SWEP:Deploy()
	gamemode.Call("WeaponDeployed", self:GetOwner(), self)

	self.IdleAnimation = CurTime() + self:SequenceDuration()

	self:SpawnGhost()

	return true
end

-- ==== OnRemove - 武器移除时清除幽灵预览 ====
function SWEP:OnRemove()
	self:RemoveGhost()
end

-- ==== Holster - 收起武器时清除幽灵预览 ====
function SWEP:Holster()
	self:RemoveGhost()
	return true
end
 
-- ==== SpawnGhost - 给持有者附加搭建预览状态 ====
function SWEP:SpawnGhost()
	local owner = self:GetOwner()
	if owner and owner:IsValid() then
		owner:GiveStatus("ghost_barricadekit")
	end
end

-- ==== RemoveGhost - 移除持有者的搭建预览状态 ====
function SWEP:RemoveGhost()
	local owner = self:GetOwner()
	if owner and owner:IsValid() then
		owner:RemoveStatus("ghost_barricadekit", false, true)
	end
end

-- ==== Think - 闲置动画计时结束则播放闲置姿势 ====
function SWEP:Think()
	if self.IdleAnimation and self.IdleAnimation <= CurTime() then
		self.IdleAnimation = nil
		self:SendWeaponAnim(ACT_VM_IDLE)
	end
end

-- ==== PrimaryAttack - 左键在预览位置放置木板 ====
function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end

	local owner = self:GetOwner()
	if not gamemode.Call("CanPlaceNail", owner) then return false end

	-- 校验幽灵预览状态与放置合法性
	local status = owner.status_ghost_barricadekit
	if not (status and status:IsValid()) then return end
	status:RecalculateValidity()
	if not status:GetValidPlacement() then return end

	local pos, ang = status:RecalculateValidity()
	if not pos or not ang then return end

	-- 按放置间隔冷却，创建木板实体
	self:SetNextPrimaryAttack(CurTime() + self.Primary.Delay)

	local ent = ents.Create("prop_aegisboard")
	if ent:IsValid() then
		ent:SetPos(pos)
		ent:SetAngles(ang)
		ent:Spawn()

		ent:EmitSound("npc/dog/dog_servo12.wav")

		ent:GhostAllPlayersInMe(5)

		ent:SetObjectOwner(owner)

		-- 取出打包存储的同款木板以继承耐久
		local stored = owner:PopPackedItem(ent:GetClass())
		if stored then
			ent:SetObjectHealth(stored[1])
		end

		self:TakePrimaryAmmo(1)
	end
end
