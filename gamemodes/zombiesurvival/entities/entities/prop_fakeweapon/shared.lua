-- ============================================================================
-- prop_fakeweapon/shared.lua - 伪武器道具（共享定义）
-- 负责：伪装成指定武器外观的占位道具（不可被人类拾取/持有），
--       按武器表套用模型与缩放，并通过网络字段记录伪装类型
-- ============================================================================
ENT.Type = "anim"

-- 禁止在表面钉挂
ENT.NoNails = true
-- 忽略玩家视线追踪（不可被准星瞄准选中）
ENT.IgnoreTraces = true

-- 渲染组：半透明
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

-- ==== HumanHoldable - 可持有判定：始终不可被人类持有拾取 ====
function ENT:HumanHoldable(pl)
	return false
end

-- ==== SetWeaponType - 设置伪装武器：按武器表应用模型/物理/缩放 ====
function ENT:SetWeaponType(class)
	local weptab = weapons.Get(class)
	if weptab then
		-- 优先使用武器表的伪世界模型，其次使用常规世界模型
		if weptab.FakeWorldModel then
			self:SetModel(weptab.FakeWorldModel)
		elseif weptab.WorldModel then
			self:SetModel(weptab.WorldModel)
		end

		-- 服务器端按武器表初始化物理
		if SERVER then
			self:SetupPhysics(weptab)
		end

		if weptab.ModelScale then
			self:SetModelScale(weptab.ModelScale, 0)
		end
	end

	-- 将伪装类型写入网络字段供客户端/服务器查询
	self:SetDTString(0, class)
end

-- ==== GetWeaponType - 读取伪装武器类型（网络字段） ====
function ENT:GetWeaponType()
	return self:GetDTString(0)
end
