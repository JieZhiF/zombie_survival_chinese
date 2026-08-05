-- ============================================================================
-- prop_resupplybox/cl_init.lua - 补给箱（客户端）
-- 负责：渲染补给箱的 3D2D 信息牌（冷却倒计时、剩余弹药缓存、拥有者、
--       弹药类型）与耐久血条；冷却就绪时播放提示音；通过网络消息
--       同步冷却时间与缓存数量
-- ============================================================================
INC_CLIENT()

-- 是否已播放过就绪提示音（边沿触发标记）
ENT.Dinged = true

-- ==== Initialize - 初始化：扩大渲染边界，避免 3D2D 文字被裁剪 ====
function ENT:Initialize()
	self:SetRenderBounds(Vector(-72, -72, -72), Vector(72, 72, 128))
end

-- ==== SetObjectHealth - 同步网络耐久值（DT 浮点 0 号位）====
function ENT:SetObjectHealth(health)
	self:SetDTFloat(0, health)
end

-- 左右两侧信息牌的 3D2D 挂点偏移与朝向
local vOffset = Vector(16, 0, 0)
local vOffset2 = Vector(-16, 0, 0)
local aOffset = Angle(0, 90, 90)
local aOffset2 = Angle(0, 270, 90)
-- 底部标语牌的挂点偏移
local vOffsetEE = Vector(-15, 0, 8)

-- ==== Think - 冷却就绪的瞬间播放一次提示音 ====
function ENT:Think()
	-- 仅人类玩家生效
	if MySelf:IsValid() and MySelf:Team() == TEAM_HUMAN then
		local nextuse = MySelf.NextUse or 0
		-- 边沿触发：冷却未结束标记为未响铃，冷却结束的瞬间响铃一次
		if self.Dinged then
			if CurTime() < nextuse then
				self.Dinged = false
			end
		elseif CurTime() >= nextuse then
			self.Dinged = true

			self:EmitSound("zombiesurvival/ding.ogg")
		end
	end

	-- 每 0.5 秒检查一次
	self:NextThink(CurTime() + 0.5)
	return true
end

-- ==== RenderInfo - 在指定挂点绘制补给箱信息牌 ====
function ENT:RenderInfo(pos, ang, owner)
	cam.Start3D2D(pos, ang, 0.075)
		-- 补给箱标题：可用时绿色，冷却中暗红
		draw.SimpleText(translate.Get("resupply_box"), "ZS3D2DFont2", 0, -130, (MySelf.NextUse or 0) <= CurTime() and COLOR_GREEN or COLOR_DARKRED, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

		-- 读取剩余缓存次数（由网络消息同步）
		local caches = MySelf.Stowage and MySelf.StowageCaches

		-- 剩余冷却秒数（就绪时显示 "ready"）
		local timeremain = math.ceil(math.max(0, (MySelf.NextUse or 0) - CurTime()))
		if MySelf.NextUse then
			draw.SimpleText(timeremain > 0 and timeremain or translate.Get("ready"), "ZS3D2DFont2", 0, -60, (MySelf.NextUse or 0) <= CurTime() and COLOR_GREEN or COLOR_DARKRED, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
		-- 剩余可领取的弹药缓存次数
		if caches then
			draw.SimpleText(translate.Format("resupply_box_left", caches), "ZS3D2DFont2Small", 0, 0, caches > 0 and COLOR_GREEN or COLOR_DARKRED, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end

		-- 补给箱耐久血条
		self:Draw3DHealthBar(math.Clamp(self:GetObjectHealth() / self:GetMaxObjectHealth(), 0, 1), nil, 190)

		-- 拥有者名称：本人浅蓝，他人灰色
		if owner:IsValid() and owner:IsPlayer() then
			draw.SimpleText("("..owner:ClippedName()..")", "ZS3D2DFont2Small", 0, 30, owner == MySelf and COLOR_LBLUE or COLOR_GRAY, TEXT_ALIGN_CENTER)
		end

		-- 当前补充的弹药类型名
		if MySelf:Team() == TEAM_HUMAN then
			local ammotype = GAMEMODE.CachedResupplyAmmoType
			ammotype = GAMEMODE.AmmoNames[ammotype] or ammotype

			draw.SimpleText("["..ammotype.."]", "ZS3D2DFont2Smaller", 0, 70, COLOR_GRAY, TEXT_ALIGN_CENTER)
		end
	cam.End3D2D()
end

-- ==== Draw - 绘制模型与左右信息牌 ====
function ENT:Draw()
	self:DrawModel()

	-- 仅人类玩家可见信息牌
	if not MySelf:IsValid() or MySelf:Team() ~= TEAM_HUMAN then return end

	local owner = self:GetObjectOwner()
	local ang = self:LocalToWorldAngles(aOffset)

	-- 左右两侧各绘制一块信息牌
	self:RenderInfo(self:LocalToWorld(vOffset), ang, owner)
	self:RenderInfo(self:LocalToWorld(vOffset2), self:LocalToWorldAngles(aOffset2), owner)

	-- 底部标语牌（遗留彩蛋文字）
	cam.Start3D2D(self:LocalToWorld(vOffsetEE), ang, 0.01)

		draw.SimpleText("ur a faget", "ZS3D2DFont2", 0, 0, color_white, TEXT_ALIGN_CENTER)

	cam.End3D2D()
end

-- 同步下次可使用时间（服务器 -> 客户端）
net.Receive(NET_MSG.NEXTRESUPPLYUSE, function(length)
	MySelf.NextUse = net.ReadFloat()
end)

-- 同步剩余弹药缓存次数
net.Receive(NET_MSG.STOWAGECACHES, function(length)
	MySelf.StowageCaches = net.ReadInt(8)
end)
