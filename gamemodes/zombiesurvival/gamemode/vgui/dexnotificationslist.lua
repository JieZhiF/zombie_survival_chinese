GM.NotifyFadeTime = 8

local DefaultFont = "ZSHUDFontSmallest"
local DefaultFontEntity = "ZSHUDFontSmallest"

local PANEL  = {}

function PANEL:Init()
	self:DockPadding(8, 2, 8, 2)

	self:SetKeyboardInputEnabled(false)
	self:SetMouseInputEnabled(false)
end

local matGrad = Material("VGUI/gradient-r")
function PANEL:Paint()
	surface.SetMaterial(matGrad)
	surface.SetDrawColor(0, 0, 0, 180)

	local align = self:GetParent():GetAlign()
	if align == RIGHT then
		surface.DrawTexturedRect(self:GetWide() * 0.25, 0, self:GetWide(), self:GetTall())
	elseif align == CENTER then
		surface.DrawTexturedRect(self:GetWide() * 0.25, 0, self:GetWide() * 0.25, self:GetTall())
		surface.DrawTexturedRectRotated(self:GetWide() * 0.625, self:GetTall() / 2, self:GetWide() * 0.25, self:GetTall(), 180)
	else
		surface.DrawTexturedRectRotated(self:GetWide() * 0.25, self:GetTall() / 2, self:GetWide() / 2, self:GetTall(), 180)
	end
end

function PANEL:AddLabel(text, col, font, extramargin)
	local label = vgui.Create("DLabel", self)
	label:SetText(text)
	label:SetFont(font or DefaultFont)
	label:SetTextColor(col or color_white)
	label:SizeToContents()
	if extramargin then
		label:SetContentAlignment(7)
		label:DockMargin(0, label:GetTall() * 0.2, 0, 0)
	else
		label:SetContentAlignment(4)
	end
	label:Dock(LEFT)

	return label
end

function PANEL:AddImage(mat, col)
	local img = vgui.Create("DImage", self)
	img:SetImage(mat)
	if col then
		img:SetImageColor(col)
	end
	img:SizeToContents()
	local height = img:GetTall()
	if height > self:GetTall() then
		img:SetSize(self:GetTall() / height * img:GetWide(), self:GetTall())
	end
	img:DockMargin(0, (self:GetTall() - img:GetTall()) / 2, 0, 0)
	img:Dock(LEFT)
end

function PANEL:AddKillIcon(class)
	local icondata = killicon.GetIcon(class)

	if icondata then
		self:AddImage(icondata[1], icondata[2])
	else
		local fontdata = killicon.GetFont(class) or killicon.GetFont("default")
		if fontdata then
			self:AddLabel(fontdata[2], fontdata[3], fontdata[1], true)
		end
	end
end

-- 用于生成去重 key 的辅助函数：把参数序列化成一个可比较的字符串
-- 忽略 CustomTime 等不影响外观的控制字段
local function BuildNotifyKey(args)
	local parts = {}

	for k, v in ipairs(args) do
		local vtype = type(v)

		if vtype == "table" then
			if v.r and v.g and v.b then
				parts[#parts + 1] = "col:" .. v.r .. "," .. v.g .. "," .. v.b .. "," .. (v.a or 255)
			elseif v.font then
				parts[#parts + 1] = "font:" .. tostring(v.font)
			elseif v.killicon then
				parts[#parts + 1] = "killicon:" .. tostring(v.killicon) .. (v.headshot and ":hs" or "")
			elseif v.image then
				parts[#parts + 1] = "image:" .. tostring(v.image)
			end
			-- CustomTime 等其他控制字段不参与 key 计算
		elseif vtype == "Player" then
			parts[#parts + 1] = "player:" .. (IsValid(v) and v:SteamID64() or "invalid")
		elseif vtype == "Entity" then
			parts[#parts + 1] = "ent:" .. (IsValid(v) and v:GetClass() or "invalid")
		else
			parts[#parts + 1] = "s:" .. tostring(v)
		end
	end

	return table.concat(parts, "|")
end

function PANEL:SetNotification(...)
	local args = {...}

	local defaultcol = color_white
	local defaultfont
	for k, v in ipairs(args) do
		local vtype = type(v)

		if vtype == "table" then
			if v.r and v.g and v.b then
				defaultcol = v
			elseif v.font then
				if v.font == "" then
					defaultfont = nil
				else
					local th = draw.GetFontHeight(v.font)
					if th then
						defaultfont = v.font
					end
				end
			elseif v.killicon then
				self:AddKillIcon(v.killicon)
				if v.headshot then
					self:AddKillIcon("headshot")
				end
			elseif v.image then
				self:AddImage(v.image, v.color)
			end
		elseif vtype == "Player" then
			local avatar = vgui.Create("AvatarImage", self)
			local size = self:GetTall() >= 32 and 32 or 16
			avatar:SetSize(size, size)
			if v:IsValid() then
				avatar:SetPlayer(v, size)
			end
			avatar:SetAlpha(220)
			avatar:Dock(LEFT)
			avatar:DockMargin(0, (self:GetTall() - avatar:GetTall()) / 2, 0, 0)

			if v:IsValid() then
				self:AddLabel(" "..v:Name(), team.GetColor(v:Team()), DefaultFontEntity)
			else
				self:AddLabel(" ?", team.GetColor(TEAM_UNASSIGNED), DefaultFontEntity)
			end
		elseif vtype == "Entity" then
			self:AddLabel("["..(v:IsValid() and v:GetClass() or "?").."]", COLOR_RED, DefaultFontEntity)
		else
			local text = tostring(v)

			self:AddLabel(text, defaultcol, defaultfont)
		end
	end

	-- 记录 key，供堆叠比对使用
	self.NotifyKey = BuildNotifyKey(args)

	-- 创建一个专门用于显示堆叠次数的标签（初始隐藏/空）
	self.StackCount = 1
	self.StackLabel = self:AddLabel("", defaultcol, defaultfont)
	self.StackLabel:SetVisible(false)
end

function PANEL:SetStackCount(n)
	self.StackCount = n
	if n > 1 then
		self.StackLabel:SetText(" x" .. n)
		self.StackLabel:SizeToContents()
		self.StackLabel:SetVisible(true)
	else
		self.StackLabel:SetVisible(false)
	end
end

vgui.Register("DEXNotification", PANEL, "Panel")

local PANEL  = {}

AccessorFunc(PANEL, "m_Align", "Align", FORCE_NUMBER)
AccessorFunc(PANEL, "m_MessageHeight", "MessageHeight", FORCE_NUMBER)

function PANEL:Init()
	self:SetAlign(LEFT)
	self:SetMessageHeight(32)
	self:ParentToHUD()
	self:InvalidateLayout()
end

function PANEL:PerformLayout()
end

function PANEL:Paint()
end

-- 重新计算某条通知的 DockPadding（因为堆叠计数标签会改变总宽度）
function PANEL:RelayoutNotification(notif)
	local w = 0
	for _, p in pairs(notif:GetChildren()) do
		if p:IsVisible() then
			w = w + p:GetWide()
		end
	end

	if self:GetAlign() == RIGHT then
		notif:DockPadding(self:GetWide() - w - 32, 0, 8, 0)
	elseif self:GetAlign() == CENTER then
		notif:DockPadding((self:GetWide() - w) / 2, 0, 0, 0)
	else
		notif:DockPadding(8, 0, 8, 0)
	end

	notif:InvalidateLayout(true)
end

function PANEL:AddNotification(...)
	local args = {...}

	local key = BuildNotifyKey(args)

	local FadeTime = GAMEMODE.NotifyFadeTime
	for k, v in pairs(args) do
		if type(v) == "table" and v.CustomTime and type(v.CustomTime == "number") then
			FadeTime = v.CustomTime
			break
		end
	end

	-- 查找是否已有相同内容且尚未过期的通知，若有则直接堆叠刷新
	if key ~= "" then
		for _, pan in pairs(self:GetChildren()) do
			if IsValid(pan) and pan.NotifyKey == key and pan.DieTime then
				pan:SetStackCount((pan.StackCount or 1) + 1)
				self:RelayoutNotification(pan)

				pan.DieTime = CurTime() + FadeTime

				-- 重新触发一次淡入提示效果，让玩家注意到刷新
				pan:SetAlpha(255)
				pan:AlphaTo(1, 1, FadeTime - 0.15)

				return pan
			end
		end
	end

	-- 没有可堆叠的，创建新的通知
	local notif = vgui.Create("DEXNotification", self)
	notif:SetTall(BetterScreenScale() * self:GetMessageHeight())
	notif:SetNotification(...)

	self:RelayoutNotification(notif)

	notif:Dock(TOP)

	notif:SetAlpha(1)
	notif:AlphaTo(255, 0.15)
	notif:AlphaTo(1, 1, FadeTime - 1)

	notif.DieTime = CurTime() + FadeTime

	return notif
end

function PANEL:Think()
	local time = CurTime()

	for i, pan in pairs(self:GetChildren()) do
		if pan.DieTime and time >= pan.DieTime then
			pan:Remove()
			local dummy = vgui.Create("Panel", self)
			dummy:SetTall(0)
			dummy:Dock(TOP)
			dummy:Remove()
		end
	end
end

vgui.Register("DEXNotificationsList", PANEL, "Panel")