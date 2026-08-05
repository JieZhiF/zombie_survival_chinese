-- ============================================================================
-- DModelPanelEx - 模型面板扩展
-- 继承自 DModelPanel，增强 SetModel 的序列回退与 AutoCam 自动取景
-- ============================================================================
-- 区域地图（VGUI 四字段）
-- [区域] 模型加载
-- [位置] SetModel()
-- [作用] 清理旧实体并按序列回退创建客户端模型
-- [常改] 回退序列列表、渲染组
--
-- [区域] 自动取景
-- [位置] AutoCam()
-- [作用] 按模型包围盒自动设置相机位置与观察点
-- [常改] 相机距离系数
-- ============================================================================

local PANEL = {}

-- ============================================================================
-- SetModel - 创建客户端模型并选择默认动画序列
-- ============================================================================
function PANEL:SetModel(strModelName)
	if IsValid(self.Entity) then
		self.Entity:Remove()
		self.Entity = nil
	end

	if not ClientsideModel then return end

	self.Entity = ClientsideModel(strModelName, RENDER_GROUP_OPAQUE_ENTITY)
	if not IsValid(self.Entity) then return end

	self.Entity:SetNoDraw(true)

	local iSeq = self.Entity:LookupSequence("walk")
	if iSeq <= 0 then iSeq = self.Entity:LookupSequence("Run1") end
	if iSeq <= 0 then iSeq = self.Entity:LookupSequence("walk_all") end
	if iSeq <= 0 then iSeq = self.Entity:LookupSequence("WalkUnarmed_all") end
	if iSeq <= 0 then iSeq = self.Entity:LookupSequence("walk_all_moderate") end
	if iSeq > 0 then self.Entity:ResetSequence(iSeq) end
end

-- ============================================================================
-- AutoCam - 按模型包围盒自动取景
-- ============================================================================
function PANEL:AutoCam()
	if IsValid(self.Entity) then
		local mins, maxs = self.Entity:GetRenderBounds()
		self:SetCamPos(mins:Distance(maxs) * Vector(0.75, 0.75, 0.5))
		self:SetLookAt((mins + maxs) / 2)
	end
end

vgui.Register("DModelPanelEx", PANEL, "DModelPanel")
