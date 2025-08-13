//这个是用于创建提示的面板
//注释状态：已完成，
GM.NotifyFadeTime = 8 //通知淡出时间
local DefaultFont = "ZSHUDFontSmallest"//默认字体
local DefaultFontEntity = "ZSHUDFontSmallest"//默认实体字体

local PANEL  = {}

function PANEL:Init()//初始化
	self:DockPadding(8, 2, 8, 2)//设置边距,上下左右,单位像素

	self:SetKeyboardInputEnabled(false)//禁用键盘输入
	self:SetMouseInputEnabled(false)//禁用鼠标输入
end

local matGrad = Material("VGUI/gradient-r") //材质
function PANEL:Paint()
	surface.SetMaterial(matGrad)//设置材质
	surface.SetDrawColor(0, 0, 0, 180)//设置颜色

	local align = self:GetParent():GetAlign()//获取父面板的对齐方式
	if align == RIGHT then//如果对齐方式是右对齐
		surface.DrawTexturedRect(self:GetWide() * 0.25, 0, self:GetWide(), self:GetTall())//绘制材质,起始点x,y,宽度,高度
	elseif align == CENTER then//如果对齐方式是居中
		surface.DrawTexturedRect(self:GetWide() * 0.25, 0, self:GetWide() * 0.25, self:GetTall())//绘制材质,起始点x,y,宽度,高度
		surface.DrawTexturedRectRotated(self:GetWide() * 0.625, self:GetTall() / 2, self:GetWide() * 0.25, self:GetTall(), 180)//绘制材质,起始点x,y,宽度,高度,旋转角度
	else
		surface.DrawTexturedRectRotated(self:GetWide() * 0.25, self:GetTall() / 2, self:GetWide() / 2, self:GetTall(), 180)
	end
end

function PANEL:AddLabel(text, col, font, extramargin)//添加标签,文本,颜色,字体,是否额外边距
	local label = vgui.Create("DLabel", self)//创建标签
	label:SetText(text)//设置文本
	label:SetFont(font or DefaultFont)//设置字体
	label:SetTextColor(col or color_white)//设置颜色
	label:SizeToContents()//设置大小
	if extramargin then//如果额外边距
		label:SetContentAlignment(7)//设置对齐方式，7是左上角对齐
		label:DockMargin(0, label:GetTall() * 0.2, 0, 0)//设置边距,上下左右,单位像素
	else
		label:SetContentAlignment(4)//设置对齐方式，4是居中左对齐
	end
	label:Dock(LEFT)//设置停靠方式，左
end

function PANEL:AddImage(mat, col)//添加图片,材质,颜色
	local img = vgui.Create("DImage", self)//创建图片
	img:SetImage(mat)//设置图像
	if col then//若有颜色
		img:SetImageColor(col)//设置图像颜色为传入的颜色
	end
	img:SizeToContents()//设置大小
	local height = img:GetTall()//获取高度
	if height > self:GetTall() then//如果高度大于面板高度
		img:SetSize(self:GetTall() / height * img:GetWide(), self:GetTall())//设置大小,这里被设为了自高除以图像高度再乘以图像宽度,这样就能保证图像不会超出面板
	end
	img:DockMargin(0, (self:GetTall() - img:GetTall()) / 2, 0, 0)//设置边距,上下左右,单位像素,这里被设为了自身高度减去图像高度再除以2,这样就能保证图像居中
	img:Dock(LEFT)//设置停靠方式，左
end

function PANEL:AddKillIcon(class)//添加击杀图标,击杀图标
	local icondata = killicon.GetIcon(class)//获取击杀图标

	if icondata then//
		self:AddImage(icondata[1], icondata[2])//添加图片,材质,颜色
	else//如果没有击杀图标
		local fontdata = killicon.GetFont(class) or killicon.GetFont("default")//获取击杀字体
		if fontdata then//如果有击杀字体
			self:AddLabel(fontdata[2], fontdata[3], fontdata[1], true)//添加标签,文本,颜色,字体,是否额外边距
		end
	end
end

function PANEL:SetNotification(...)//设置通知
	local args = {...}//获取参数

	local defaultcol = color_white//设置默认颜色
	local defaultfont//设置默认字体
	for k, v in ipairs(args) do//遍历参数
		local vtype = type(v)//获取参数类型

		if vtype == "table" then//如果是表
			if v.r and v.g and v.b then//如果是颜色
				defaultcol = v//设置默认颜色为传入的颜色
			elseif v.font then//如果传入了字体
				if v.font == "" then//如果字体为空
					defaultfont = nil//设置默认字体为空
				else//如果字体不为空
					local th = draw.GetFontHeight(v.font)//获取字体高度
					if th then//如果有字体高度
						defaultfont = v.font//设置默认字体为传入的字体
					end
				end
			elseif v.killicon then//如果传入了击杀图标
				self:AddKillIcon(v.killicon)//添加击杀图标
				if v.headshot then//如果是爆头
					self:AddKillIcon("headshot")//添加击杀图标
				end
			elseif v.image then//如果传入了图片
				self:AddImage(v.image, v.color)//添加图片,材质,颜色
			end
		elseif vtype == "Player" then//如果是玩家
			local avatar = vgui.Create("AvatarImage", self)//创建头像
			local size = self:GetTall() >= 32 and 32 or 16//设置大小,如果面板高度大于等于32,则为32,否则为16
			avatar:SetSize(size, size)//设置大小
			if v:IsValid() then//如果玩家有效
				avatar:SetPlayer(v, size)//设置玩家,大小
			end
			avatar:SetAlpha(220)//设置透明度
			avatar:Dock(LEFT)//设置停靠方式，左	
			avatar:DockMargin(0, (self:GetTall() - avatar:GetTall()) / 2, 0, 0)//设置边距,上下左右,单位像素,这里被设为了自身高度减去头像高度再除以2,这样就能保证头像居中

			if v:IsValid() then//如果玩家有效
				self:AddLabel(" "..v:Name(), team.GetColor(v:Team()), DefaultFontEntity)//添加标签,文本,颜色,字体,这里是玩家名字,玩家队伍颜色,默认字体
			else//如果玩家无效
				self:AddLabel(" ?", team.GetColor(TEAM_UNASSIGNED), DefaultFontEntity)//添加标签,文本,颜色,字体,这里是问号,无队伍颜色,默认字体
			end
		elseif vtype == "Entity" then//如果是实体
			self:AddLabel("["..(v:IsValid() and v:GetClass() or "?").."]", COLOR_RED, DefaultFontEntity)//添加标签,文本,颜色,字体,这里是实体类名,红色,默认字体
		else
			local text = tostring(v)//转换为字符串

			self:AddLabel(text, defaultcol, defaultfont)//添加标签,文本,颜色,字体
		end
	end
end

vgui.Register("DEXNotification", PANEL, "Panel")

local PANEL  = {}

AccessorFunc(PANEL, "m_Align", "Align", FORCE_NUMBER)//设置面板停靠方式,强制数字
AccessorFunc(PANEL, "m_MessageHeight", "MessageHeight", FORCE_NUMBER)//设置面板消息高度,强制数字

function PANEL:Init()//初始化
	self:SetAlign(LEFT)//设置停靠方式，左
	self:SetMessageHeight(32)//设置消息高度
	self:ParentToHUD()//设置父面板为HUD
	self:InvalidateLayout()//重设布局
end

function PANEL:PerformLayout()
end

function PANEL:Paint()
end

function PANEL:AddNotification(...)//添加通知
	local notif = vgui.Create("DEXNotification", self)//创建通知,父面板为自身
	notif:SetTall(BetterScreenScale() * self:GetMessageHeight())//设置高度,这里是消息高度
	notif:SetNotification(...)//设置通知
	local w = 0//设置宽度
	for _, p in pairs(notif:GetChildren()) do//遍历子面板
		w = w + p:GetWide()//累加宽度,这里是子面板宽度
	end
	if self:GetAlign() == RIGHT then//如果停靠方式为右
		notif:DockPadding(self:GetWide() - w - 32, 0, 8, 0)//设置边距,上下左右。单位像素,这里是自身宽度减去累加宽度再减去32,0,8,0
	elseif self:GetAlign() == CENTER then//如果停靠方式为中
		notif:DockPadding((self:GetWide() - w) / 2, 0, 0, 0)//设置边距,上下左右。单位像素,这里是自身宽度减去累加宽度再除以2,0,0,0
	else//如果停靠方式为左
		notif:DockPadding(8, 0, 8, 0)//设置边距,上下左右。单位像素,这里是8,0,8,0
	end

	notif:Dock(TOP)//设置停靠方式，上

	local args = {...}//获取参数

	local FadeTime = GAMEMODE.NotifyFadeTime//获取通知淡出时间

	for k, v in pairs(args) do//遍历参数
		if type(v) == "table" and v.CustomTime and type(v.CustomTime == "number") then//如果是表且自定义时间存在且自定义时间是数字
			FadeTime = v.CustomTime//设置淡出时间
			break//跳出循环
		end
	end

	notif:SetAlpha(1)//设置透明度
	notif:AlphaTo(255, 0.15)//设置透明度。第一个参数为目标透明度,第二个参数为时间,单位秒
	notif:AlphaTo(1, 1, FadeTime - 1)//设置透明度。第一个参数为目标透明度,第二个参数为时间,单位秒,第三个参数为延迟时间,单位秒

	notif.DieTime = CurTime() + FadeTime//设置死亡时间

	return notif
end

function PANEL:Think()//面板思考
	local time = CurTime()//获取当前时间

	for i, pan in pairs(self:GetChildren()) do//遍历子面板
		if pan.DieTime and time >= pan.DieTime then//如果子面板死亡时间存在且当前时间大于等于子面板死亡时间
			pan:Remove()//移除子面板
			local dummy = vgui.Create("Panel", self)//创建面板
			dummy:SetTall(0)//设置高度
			dummy:Dock(TOP)//设置停靠方式,上
			dummy:Remove()//移除面板
		end
	end
end

vgui.Register("DEXNotificationsList", PANEL, "Panel")//注册面板,面板名,面板,基础面板,
