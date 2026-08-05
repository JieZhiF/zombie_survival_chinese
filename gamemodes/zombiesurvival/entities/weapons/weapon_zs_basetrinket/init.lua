-- ============================================================================
-- weapon_zs_basetrinket/init.lua - 饰品母本（服务端）
-- 负责：装备饰品时在玩家身上创建对应的状态实体（TrinketStatus），实现被动效果
-- ============================================================================

INC_SERVER()
-- 定义母本类引用（供 BaseClass 调用）
DEFINE_BASECLASS("weapon_zs_basemelee")

-- 饰品对应的状态实体类名（由子类覆写，如 "status_xxx"）
SWEP.TrinketStatus = ""

-- ==== Initialize - 武器初始化 ====
function SWEP:Initialize()
	BaseClass.Initialize(self)

	-- 延迟一帧再创建状态实体（等待实体完全初始化）
	timer.Simple(0, function()
		if IsValid(self) then
			-- 子类指定了状态实体时才创建
			if self.TrinketStatus ~= "" then
				self:CreateTrinketStatus()
			end
		end
	end)
end

-- ==== Deploy - 出枪（装备饰品） ====
function SWEP:Deploy()
	BaseClass.Deploy(self)

	-- 每次装备时确保状态实体存在（如被移除则重建）
	if self.TrinketStatus ~= "" then
		self:CreateTrinketStatus()
	end

	return true
end

-- ==== CreateTrinketStatus - 在玩家身上创建饰品状态实体 ====
function SWEP:CreateTrinketStatus()
	local owner = self:GetOwner()
	if not owner:IsValid() then return end

	-- 玩家已持有同类状态实体则不重复创建
	local status = self.TrinketStatus
	for _, ent in pairs(ents.FindByClass(status)) do
		if ent:GetOwner() == owner then return end
	end

	-- 创建状态实体并附着到玩家（跟随玩家移动）
	local ent = ents.Create(status)
	if ent:IsValid() then
		ent:SetPos(owner:EyePos())
		ent:SetParent(owner)
		ent:SetOwner(owner)
		ent:Spawn()
	end
end
