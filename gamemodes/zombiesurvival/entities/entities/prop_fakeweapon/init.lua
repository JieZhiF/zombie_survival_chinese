-- ============================================================================
-- prop_fakeweapon/init.lua - 假武器掉落物（服务器）
-- 负责：模拟玩家武器掉落的物理实体：按武器表初始化碰撞与运动属性，
--       3 秒后自动销毁，避免掉落物残留
-- ============================================================================
INC_SERVER()
AddCSLuaFile("cl_animations.lua")

-- ==== Initialize - 初始化假武器的物理属性与生命周期 ====
function ENT:Initialize()
	-- 获取所模拟武器的 SWEP 数据表；武器未自定义盒体碰撞时使用标准 VPhysics 初始化
	local weptab = weapons.Get(self:GetWeaponType())
	if weptab and not weptab.BoxPhysicsMax then
		self:PhysicsInit(SOLID_VPHYSICS)
	end
	self:SetSolid(SOLID_VPHYSICS)
	-- 使用碎片触发碰撞组，避免与玩家或环境产生物理干扰
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)

	-- 物理对象：设置材质、按 Restrained 决定是否启用运动、固定质量并唤醒
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:SetMaterial("material")
		phys:EnableMotion(not self.Restrained)
		phys:SetMass(25)
		phys:Wake()
	end

	-- 3 秒后自动移除
	self:Fire("kill", "", 3)
end

-- ==== SetupPhysics - 使用武器表定义的盒体碰撞范围重建物理 ====
function ENT:SetupPhysics(weptab)
	-- 仅当武器表定义了自定义盒体范围时才重建盒体物理并套用相同碰撞参数
	if weptab.BoxPhysicsMax then
		self:PhysicsInitBox(weptab.BoxPhysicsMin, weptab.BoxPhysicsMax)
		self:SetCollisionBounds(weptab.BoxPhysicsMin, weptab.BoxPhysicsMax)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
	end
end
