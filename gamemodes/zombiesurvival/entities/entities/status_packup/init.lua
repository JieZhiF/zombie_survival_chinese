-- ============================================================================
-- status_packup/init.lua - 收包状态（服务器端）
-- 负责：玩家对路障/弹药箱等物件执行收包时，持续校验视线与距离，
--       到达结束时间后调用物件的 OnPackedUp 完成收包（回收物件），
--       中途脱离视线或物件消失则取消并移除状态
-- ============================================================================

-- 服务器端加载入口（INC_SERVER 系列约定写法）
INC_SERVER()

-- ==== PlayerSet - 状态施加到玩家身上时 ====
function ENT:PlayerSet(pPlayer, bExists)
	-- 播放开箱音效提示收包开始
	pPlayer:EmitSound("items/ammocrate_open.wav")

	-- 记录玩家当前处于收包状态（供其他系统查询）
	pPlayer.PackUp = pPlayer

	-- 首次施加时记录开始时间
	if self:GetStartTime() == 0 then
		self:SetStartTime(CurTime())
	end
end

-- ==== Think - 每帧收包流程 ====
function ENT:Think()
	-- 已进入移除流程则不再处理
	if self.Removing then return end

	local packer = self:GetOwner()
	local owner = packer
	local pack = self:GetPackUpEntity()

	-- 被收包物件仍然有效时
	if pack:IsValid() then
		local eyepos = owner:EyePos()
		local aimvec = owner:GetAimVector()
		local point = pack:NearestPoint(eyepos)
		local dist = point:DistToSqr(eyepos)
		-- 判定玩家是否仍满足收包条件：近战命中物件，或视线对准且距离够近、中间无遮挡
		if owner:CompensatedMeleeTrace(64, 4, nil, nil, nil, true).Entity == pack or ((dist <= 64 or (point - eyepos):GetNormalized():Dot(aimvec) >= 0.75) and dist <= 4096 and WorldVisible(aimvec, point)) then
			-- 非物件所有者收包时，检查其是否为人类且非管理员（管理员可代收）
			if not self:GetNotOwner() and pack.GetObjectOwner then
				local packowner = pack:GetObjectOwner()
				if packowner:IsValid() and packowner:Team() == TEAM_HUMAN and packowner ~= packer and not gamemode.Call("PlayerIsAdmin", packer) then
					self:SetNotOwner(true)
				end
			end

			-- 收包时间已到
			if CurTime() >= self:GetEndTime() then
				-- 非所有者收包：需检查该物件的并发收包数量上限
				if self:GetNotOwner() then
					local count = 0
					for _, ent in pairs(ents.FindByClass("status_packup")) do
						if ent:GetPackUpEntity() == pack then
							count = count + 1
						end
					end

					-- 超过上限则本帧结束后立即重试，等待其他收包完成
					if count < self.PackUpOverride then
						self:NextThink(CurTime())
						return true
					end

					-- 物件有所有者且为人类时，收包收益归属物件所有者
					if pack.GetObjectOwner then
						local objowner = pack:GetObjectOwner()
						if objowner:IsValid() and objowner:Team() == TEAM_HUMAN and objowner:IsValid() then
							owner = objowner
						end
					end
				end

				-- 调用物件的收包回调；返回 false 表示收包成功，移除物件并结束状态
				if pack.OnPackedUp and not pack:OnPackedUp(owner) then
					owner:EmitSound("items/ammocrate_close.wav")
					self.Removing = true

					-- 通知游戏模式物件已被收包（用于统计/奖励等）
					gamemode.Call("ObjectPackedUp", pack, packer, owner)

					self:Remove()
				end
			end
		else
			-- 玩家脱离视线/距离：播放失败音效并取消收包
			owner:EmitSound("items/medshotno1.wav")

			self:Remove()
			self.Removing = true
		end
	else
		-- 物件已消失：取消收包
		owner:EmitSound("items/medshotno1.wav")

		self:Remove()
		self.Removing = true
	end

	-- 每帧持续检查
	self:NextThink(CurTime())
	return true
end
