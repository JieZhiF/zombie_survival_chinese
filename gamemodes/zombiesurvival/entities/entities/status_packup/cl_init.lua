-- ============================================================================
-- status_packup/cl_init.lua - 收包状态（客户端）
-- 负责：收包状态在客户端上的显示初始化：隐藏阴影、设置渲染边界、
--       记录开始时间与玩家身上的收包引用（供 HUD 读取进度）
-- ============================================================================

-- 客户端加载入口（INC_CLIENT 系列约定写法）
INC_CLIENT()

-- ==== Initialize - 客户端初始化 ====
function ENT:Initialize()
	-- 收包状态实体不绘制阴影
	self:DrawShadow(false)
	-- 设置渲染边界，避免状态实体被视锥裁剪过早隐藏
	self:SetRenderBounds(Vector(-40, -40, -18), Vector(40, 40, 80))

	-- 首次创建时记录开始时间（网络同步迟到时的兜底）
	if self:GetStartTime() == 0 then
		self:SetStartTime(CurTime())
	end

	-- 在玩家身上记录收包状态实体引用，供 HUD 查询收包进度
	self:GetOwner().PackUp = self
end

-- ==== OnRemove - 状态移除时（客户端无额外处理） ====
function ENT:OnRemove()
end

-- ==== Think - 每帧逻辑（客户端无额外处理） ====
function ENT:Think()
end

-- ==== Draw - 绘制（不可见状态实体，不绘制） ====
function ENT:Draw()
end
