-- ============================================================================
-- init.lua - 消息点实体（服务器）：地图触发器驱动的 HUD 通知
-- 负责：响应 Message 输入发送顶部/居中通知（全局/指定队伍/触发者），
--       并支持 HUD 覆盖文字、显示时长与文字颜色的动态设置
-- ============================================================================
-- 点实体类型（无模型，仅存在于触发器中）
ENT.Type = "point"

-- ==== Initialize - 初始化：补齐键值默认值 ====
function ENT:Initialize()
	-- 发送对象：-1 触发者本人，0 全局广播，>0 对应队伍编号
	self.SendTo = self.SendTo or -1
	-- 通知显示时长（默认取全局通知淡出时间）
	self.DisplayTime = self.DisplayTime or GAMEMODE.NotifyFadeTime
	-- 通知位置：center 居中 / top 顶部
	self.Position = self.Position or "center"
	-- 通知文字颜色（默认白色）
	self.Red = self.Red or 255
	self.Green = self.Green or 255
	self.Blue = self.Blue or 255
end

-- ==== Think - 空实现（点实体无需逐帧逻辑） ====
function ENT:Think()
end

-- ==== AcceptInput - 处理触发器输入：发送通知/设置 HUD 覆盖等 ====
function ENT:AcceptInput(name, caller, activator, args)
	name = string.lower(name)
	if name == "message" then
		args = args or ""

		-- 剥离消息中的标签，只保留纯文本
		args = string.gsub(args, "<.-=.->", "")
		args = string.gsub(args, "</.->", "")

		local TextColor = Color(self.Red, self.Green, self.Blue)
		
		-- 全局广播：所有玩家收到通知
		if self.SendTo == 0 then
			if self.Position == "top" then
				GAMEMODE:TopNotifyAll(TextColor, args, {CustomTime = self.DisplayTime})
			else
				GAMEMODE:CenterNotifyAll(TextColor, args, {CustomTime = self.DisplayTime})
			end
		-- 仅发送给触发者本人
		elseif self.SendTo == -1 then
			for _, pl in pairs(player.GetAll()) do
				if pl == activator or pl == caller then
					if self.Position == "top" then
						pl:TopNotify(TextColor, args, {CustomTime = self.DisplayTime})
					else
						pl:CenterNotify(TextColor, args, {CustomTime = self.DisplayTime})
					end
					break
				end
			end
		-- 发送给指定队伍的全部玩家
		else
			for _, pl in pairs(player.GetAll()) do
				if pl:Team() == self.SendTo then
					if self.Position == "top" then
						pl:TopNotify(TextColor, args, {CustomTime = self.DisplayTime})
					else
						pl:CenterNotify(TextColor, args, {CustomTime = self.DisplayTime})
					end
				end
			end
		end

		return true
	-- 设置僵尸队伍 HUD 覆盖文字
	elseif name == "setundeadhudmessage" or name == "setzombiehudmessage" then
		SetGlobalString("hudoverride"..TEAM_UNDEAD, args)
	-- 设置人类队伍 HUD 覆盖文字
	elseif name == "sethumanhudmessage" or name == "setsurvivorhudmessage" then
		SetGlobalString("hudoverride"..TEAM_HUMAN, args)
	-- 清除僵尸队伍 HUD 覆盖文字
	elseif name == "clearundeadhudmessage" or name == "clearzombiehudmessage" then
		SetGlobalString("hudoverride"..TEAM_UNDEAD, "")
	-- 清除人类队伍 HUD 覆盖文字
	elseif name == "clearhumanhudmessage" or name == "clearsurvivorhudmessage" then
		SetGlobalString("hudoverride"..TEAM_HUMAN, "")
	-- 动态修改通知显示时长
	elseif name == "setdisplaytime" then
		self.DisplayTime = tonumber(args)
	-- 动态修改通知文字颜色
	elseif name == "settextcolor" or name == "settextcolour" then
		self:ApplyColor(args)
	end
end

-- ==== KeyValue - 解析地图键值：team/displaytime/position/textcolor ====
function ENT:KeyValue(key, value)
	key = string.lower(key)
	if key == "team" then
		value = string.lower(value or "")
		-- 将队伍关键词映射为发送对象常量
		if value == "zombie" or value == "undead" or value == "zombies" then
			self.SendTo = TEAM_UNDEAD
		elseif value == "human" or value == "humans" then
			self.SendTo = TEAM_HUMAN
		elseif value == "activator" or value == "caller" or value == "private" then
			-- 私有：只通知触发者
			self.SendTo = -1
		else
			-- 其他值：全局广播
			self.SendTo = 0
		end
	elseif key == "displaytime" then
		self.DisplayTime = tonumber(value)
	elseif key == "position" then
		self.Position = string.lower(value)
	elseif key == "textcolor" or key == "textcolour" then
		self:ApplyColor(value)
	end
end

-- ==== ApplyColor - 解析 "R G B" 颜色字符串并写入颜色分量 ====
function ENT:ApplyColor(colorstring)
	local col = string.ToColor(colorstring.." 255")
	self.Red = col.r or 255
	self.Green = col.g or 255
	self.Blue = col.b or 255
end
