-- ============================================================================
-- weapon_zs_detpack/init.lua - 炸药包部署武器（服务器端）
-- 负责：部署时生成放置预览（Ghost），左键在预览位置生成 prop_detpack 实体，
--       可吸附到实体表面；部署后自动切换到遥控引爆武器
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
		-- 为持有者添加炸药包放置预览状态
		owner:GiveStatus("ghost_detpack")
	end
end

-- ==== RemoveGhost - 移除放置预览 ====
function SWEP:RemoveGhost()
	local owner = self:GetOwner()
	if owner and owner:IsValid() then
		-- 移除炸药包放置预览状态
		owner:RemoveStatus("ghost_detpack", false, true)
	end
end

-- ==== PrimaryAttack - 左键部署炸药包 ====
function SWEP:PrimaryAttack()
	-- 冷却/弹药检查
	if not self:CanPrimaryAttack() then return end

	local owner = self:GetOwner()

	-- 获取放置预览状态并确认放置位置有效
	local status = owner.status_ghost_detpack
	if not (status and status:IsValid()) then return end
	status:RecalculateValidity()
	if not status:GetValidPlacement() then return end

	-- 取得放置位置、角度和吸附的实体
	local pos, ang, entity = status:RecalculateValidity()
	if not pos or not ang then return end

	-- 设置1秒部署冷却
	self:SetNextPrimaryAttack(CurTime() + 1)

	-- 在预览位置创建炸药包实体
	local ent = ents.Create("prop_detpack")
	if ent:IsValid() then
		ent:SetPos(pos)
		ent:SetAngles(ang)
		ent:Spawn()
		-- 如果吸附到某个实体上，将炸药包设为其子级（跟随实体移动）
		if entity and entity:IsValid() then
			ent:SetParent(entity)
		end

		-- 播放 C4 放置音效
		ent:EmitSound("weapons/c4/c4_plant.wav")

		-- 消耗一发弹药
		self:TakePrimaryAmmo(1)

		-- 设置炸药包所有者
		ent:SetOwner(self:GetOwner())

		-- 弹药耗尽后自动移除本武器
		if self:GetPrimaryAmmoCount() <= 0 then
			owner:StripWeapon(self:GetClass())
		end

		-- 确保玩家持有遥控引爆武器并切换过去
		if not owner:HasWeapon("weapon_zs_detpackremote") then
			owner:Give("weapon_zs_detpackremote")
		end
		owner:SelectWeapon("weapon_zs_detpackremote")
	end
end

-- ==== SecondaryAttack - 副攻击（空实现） ====
function SWEP:SecondaryAttack()
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
