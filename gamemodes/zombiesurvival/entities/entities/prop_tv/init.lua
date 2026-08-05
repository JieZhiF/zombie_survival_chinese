-- ============================================================================
-- prop_tv/init.lua - 电视机监控道具（服务器）
-- 负责：可部署的监控电视：人类玩家可认领并在多个 prop_camera 间循环
--       切换监控画面；有耐久，被摧毁时生成残骸并通知拥有者
-- ============================================================================
INC_SERVER()

-- ==== Initialize - 初始化：固定电视模型、关闭物理运动并设置耐久 ====
function ENT:Initialize()
	-- 电视不投射阴影
	self:DrawShadow(false)
	-- 使用电视机模型
	self:SetModel("models/props_c17/tv_monitor01.mdl")
	-- 初始化 vphysics 物理
	self:PhysicsInit(SOLID_VPHYSICS)
	-- 按 E 键触发 Use
	self:SetUseType(SIMPLE_USE)

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		-- 电视固定摆放，不参与物理运动
		phys:EnableMotion(false)
		phys:Wake()
	end

	-- 初始化最大耐久与当前耐久
	self:SetMaxObjectHealth(self.MaxHealth)
	self:SetObjectHealth(self:GetMaxObjectHealth())

	-- 记录正在观看监控画面的玩家
	self.Viewers = {}
end

-- ==== SetObjectHealth - 设置耐久；归零时生成破碎残骸并移除 ====
function ENT:SetObjectHealth(health)
	self:SetDTFloat(3, health)

	-- 耐久归零且未触发过摧毁流程时执行摧毁
	if health <= 0 and not self.Destroyed then
		self.Destroyed = true

		self:EmitSound("npc/manhack/gib.wav")

		-- 生成 manhack 模型残骸并立即破碎、延时清除
		local ent = ents.Create("prop_physics")
		if ent:IsValid() then
			ent:SetPos(self:WorldSpaceCenter())
			ent:SetAngles(self:GetAngles())
			ent:SetModel("models/manhack.mdl")
			ent:Spawn()

			ent:Fire("break")
			ent:Fire("kill", "", 0.05)
		end

		-- 通知拥有者部署物已丢失
		if self:GetObjectOwner():IsValidLivingHuman() then
			self:GetObjectOwner():SendDeployableLostMessage(self)
		end

		self:Remove()
	end
end

-- ==== AltUse - 右键打包收起 ====
function ENT:AltUse(activator, tr)
	self:PackUp(activator)
end

-- ==== OnPackedUp - 打包完成：归还武器与弹药并记录打包物品 ====
function ENT:OnPackedUp(pl)
	pl:GiveEmptyWeapon(self.SWEP)
	pl:GiveAmmo(1, "tv")

	-- 记录打包物品（含剩余耐久）供再次部署
	pl:PushPackedItem(self:GetClass(), self:GetObjectHealth())

	self:Remove()
end

-- ==== OnTakeDamage - 受伤处理：非人类阵营攻击者造成耐久损失 ====
function ENT:OnTakeDamage(dmginfo)
	self:TakePhysicsDamage(dmginfo)

	if dmginfo:GetDamage() <= 0 then return end

	local attacker = dmginfo:GetAttacker()
	-- 仅非人类阵营的攻击（僵尸/环境）才削减耐久
	if not (attacker:IsValid() and attacker:IsPlayer() and attacker:Team() == TEAM_HUMAN) then
		self:ResetLastBarricadeAttacker(attacker, dmginfo)
		self:SetObjectHealth(self:GetObjectHealth() - dmginfo:GetDamage())
	end
end

-- ==== CycleCamera - 在场景中的 prop_camera 间循环切换监控目标 ====
function ENT:CycleCamera(activator)
	local cameras = {}

	-- 收集场景中所有有效的 prop_camera
	for _, camera in pairs(ents.FindByClass("prop_camera")) do
		if camera:IsValid() then
			table.insert(cameras, camera)
		end
	end

	if #cameras == 0 then return end

	-- 查找当前正在观看的相机在列表中的位置
	local index
	for i, camera in pairs(cameras) do
		if activator.Camera == camera then
			index = i
			break
		end
	end

	-- 未在看监控或仅有一个相机时回到第一个
	if not index or #cameras == 1 then
		activator.Camera = cameras[1]
		return
	end

	-- 切换到下一个相机，列表末尾循环回第一个
	activator.Camera = cameras[index + 1] or cameras[1]
end

-- ==== Use - 使用：认领电视或切换监控画面 ====
function ENT:Use(activator, caller)
	-- 仅限存活的人类玩家使用
	if activator:Team() ~= TEAM_HUMAN or not activator:Alive() then return end

	local owner = self:GetObjectOwner()
	-- 尚无拥有者：当前玩家认领
	if not owner:IsValid() then
		self:SetObjectOwner(activator)
		self:GetObjectOwner():SendDeployableClaimedMessage(self)
		return
	end

	-- 已有拥有者：循环切换监控目标
	self:CycleCamera(activator)

	if activator.Camera and activator.Camera:IsValid() then
		self:EmitSound("npc/scanner/combat_scan3.wav", 50, 250)

		-- 登记观看者，并让其监控画面所在位置进入 PVS（保证画面可渲染）
		self.Viewers[activator] = true

		hook.Add("SetupPlayerVisibility", self, function(tv)
			if not tv.Viewers[activator] or not activator.Camera:IsValid() then return end

			AddOriginToPVS(activator.Camera:WorldSpaceCenter())
		end)

		-- 通知客户端切换到对应相机画面
		net.Start(NET_MSG.TVCAMERA)
			net.WriteEntity(activator.Camera)
		net.Send(activator)
	end
end

-- ==== SetMaxObjectHealth - 写入最大耐久（DT 整数 1 号位）====
function ENT:SetMaxObjectHealth(health)
	self:SetDTInt(1, health)
end

-- ==== ClearObjectOwner - 清除拥有者 ====
function ENT:ClearObjectOwner()
	self:SetObjectOwner(NULL)
end

-- ==== SetObjectOwner - 写入拥有者（DT 实体 1 号位）====
function ENT:SetObjectOwner(ent)
	self:SetDTEntity(1, ent)
end
