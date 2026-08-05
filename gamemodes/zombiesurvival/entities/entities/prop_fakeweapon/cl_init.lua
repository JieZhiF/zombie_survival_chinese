-- ============================================================================
-- prop_fakeweapon/cl_init.lua - 假武器掉落物（客户端）
-- 负责：按武器类型动态创建/移除武器附加模型（WElements），支持隐藏实体
--       基础模型、仅显示武器部件的透明绘制模式
-- ============================================================================
INC_CLIENT()
include("cl_animations.lua")

-- ==== DrawTranslucent - 透明绘制：按需隐藏基础模型并渲染附加武器模型 ====
function ENT:DrawTranslucent()
	-- 不显示基础模型时暂时将混合度设为 0，隐藏实体自带模型
	if not self.ShowBaseModel then
		render.SetBlend(0)
	end
	self:DrawModel()
	if not self.ShowBaseModel then
		render.SetBlend(1)
	end
	-- 存在附加武器模型且未禁止绘制子模型时渲染它们
	if self.RenderModels and not self.NoDrawSubModels then
		self:RenderModels(ble, cmod)
	end
end

-- ==== Think - 监听武器类型变化并重建对应的武器模型 ====
function ENT:Think()
	local class = self:GetWeaponType()
	-- 仅当武器类型发生变化时才重建模型
	if class ~= self.LastWeaponType then
		self.LastWeaponType = class

		-- 清理旧模型，避免残留
		self:RemoveModels()

		-- 从 SWEP 表读取世界模型与 WElements 配置
		local weptab = weapons.Get(class)
		if weptab then
			-- 决定是否显示基础模型：武器未指定 ShowWorldModel 且无手部骨骼/未禁止掉落模型时隐藏
			local showmdl = weptab.ShowWorldModel or not self:LookupBone("ValveBiped.Bip01_R_Hand") and not weptab.NoDroppedWorldModel
			self.ShowBaseModel = weptab.ShowWorldModel == nil and true or showmdl

			-- 武器表定义了 WElements 时复制并创建这些附加模型
			if weptab.WElements then
				self.WElements = table.FullCopy(weptab.WElements)
				self:CreateModels(self.WElements)
			end
		end
	end
end

-- ==== OnRemove - 实体移除时清理所有附加武器模型 ====
function ENT:OnRemove()
	self:RemoveModels()
end
