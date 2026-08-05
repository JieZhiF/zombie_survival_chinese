-- ============================================================================
-- status__base/cl_init.lua - 状态实体通用基类（客户端）
-- 负责：客户端侧初始化：隐藏阴影、设置渲染边界、将自身注册到拥有者、
--       每帧跟随拥有者眼睛位置；移除时清理注册
-- ============================================================================
INC_CLIENT()

-- ==== Draw - 默认不绘制任何模型（空实现，由子类覆盖） ====
function ENT:Draw()
end

-- ==== Initialize - 客户端初始化：隐藏阴影并跟随/注册到拥有者 ====
function ENT:Initialize()
	-- 状态实体不参与阴影投射
	self:DrawShadow(false)
	-- 设置渲染边界（比实体本身略大，保证特效/粒子不被裁剪）
	self:SetRenderBounds(Vector(-40, -40, -18), Vector(40, 40, 80))

	-- 注册到拥有者：owner[状态类名] = 状态实体，供外部快速查找
	local owner = self:GetOwner()
	if owner:IsValid() then
		owner[self:GetClass()] = self
	end

	-- 调用派生类的自定义初始化
	self:OnInitialize()
end

-- ==== Think - 每帧跟随拥有者的眼睛位置 ====
function ENT:Think()
	local owner = self:GetOwner()
	if owner:IsValid() then self:SetPos(owner:EyePos()) end
end

-- ==== OnRemove - 移除时清理拥有者身上的状态引用 ====
function ENT:OnRemove()
	local owner = self:GetOwner()
	-- 仅当引用仍指向本实体时才清除，避免误删新附加的同名状态
	if owner:IsValid() and owner[self:GetClass()] == self then
		owner[self:GetClass()] = nil
	end
end
