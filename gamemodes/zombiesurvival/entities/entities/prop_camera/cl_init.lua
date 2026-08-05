-- ============================================================================
-- cl_init.lua - 监控摄像头道具（客户端）
-- 负责：同步血量/放置者网络数据，并按玩家阵营与距离控制模型可见性
-- ============================================================================
INC_CLIENT()

-- ==== SetObjectHealth - 写入血量（DT 浮点槽 3，客户端同步）====
function ENT:SetObjectHealth(health)
	self:SetDTFloat(3, health)
end

-- ==== SetObjectOwner - 写入放置者（DT 实体槽 1，客户端同步）====
function ENT:SetObjectOwner(ent)
	self:SetDTEntity(1, ent)
end

local render_SetBlend = render.SetBlend
-- ==== Draw - 按阵营与距离绘制 ====
-- 本地玩家为僵尸时近距离才绘制且随距离渐隐（防穿墙窥视）；人类则正常绘制
function ENT:Draw()
	-- 自己正在通过该摄像头观看时跳过绘制（避免挡视线）
	if FROM_CAMERA == self then return end

	local lp = LocalPlayer()
	if lp:IsValid() and lp:Team() == TEAM_UNDEAD then
		-- 僵尸视角：超过约 122 单位（15000 = 122^2）不再绘制，近距离内渐隐
		local dist = EyePos():DistToSqr(self:GetPos())
		if dist > 15000 then return end

		render_SetBlend(math.Clamp(1 - dist / 7500, 0, 1))

		self:DrawModel()

		render_SetBlend(1)
	else
		self:DrawModel()
	end
end
