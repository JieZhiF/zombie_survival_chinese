-- ============================================================================
-- status_zombie_regen - 僵尸再生状态实体（共享端）
-- 负责：网络同步剩余治疗量与生效时间，并在客户端注册绘制钩子渲染回血粒子
-- ============================================================================

-- 实体类型：动画实体
ENT.Type = "anim"
-- 母类：通用状态实体基类
ENT.Base = "status__base"

-- 瞬时状态：不显示在玩家状态栏中
ENT.Ephemeral = true

-- ==== Initialize - 关闭阴影并记录状态生效时间；客户端注册全局 Draw 钩子以渲染回血特效 ====
function ENT:Initialize()
	self:DrawShadow(false)
	-- 生效时间未设置时记录当前时间（用于判断状态时长）
	if self:GetDTFloat(1) == 0 then
		self:SetDTFloat(1, CurTime())
	end

	if CLIENT then
		hook.Add("Draw", self, self.Draw)
	end
end

-- ==== SetHealLeft - 网络同步剩余治疗量（单次上限 75 点） ====
function ENT:SetHealLeft(healleft)
	self:SetDTFloat(0, math.min(75, healleft))
end

-- ==== GetHealLeft - 读取剩余治疗量 ====
function ENT:GetHealLeft()
	return self:GetDTFloat(0)
end
