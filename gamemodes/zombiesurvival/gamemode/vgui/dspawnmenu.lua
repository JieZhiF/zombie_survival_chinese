local PANEL = {}
//描述：这个是僵尸按下ALT后右边弹出的界面，用来选择出生的巢穴的
//注释状态：已完成
PANEL.Spacing = 12//间隔
PANEL.SlideTime = 0 --0.2//滑动时间
PANEL.NextRefresh = 0//下一次刷新时间
PANEL.RefreshTime = 1//刷新时间

function PANEL:Init()
	self:RefreshSize()//刷新大小
	self:SetPos(ScrW() - 1, 0)//设置位置,屏幕宽度-1,0

	self.Items = {}
end

function PANEL:Think()
	local time = RealTime()//获取当前时间

	if self.CloseTime and time >= self.CloseTime then//	如果关闭时间存在且当前时间大于等于关闭时间
		self.CloseTime = nil//关闭时间设置为nil
		self:SetVisible(false)
	elseif self.StartChecking and time >= self.StartChecking then//	如果开始检查时间存在且当前时间大于等于开始检查时间
		if not MySelf:KeyDown(GAMEMODE.MenuKey) then//如果玩家没有按下菜单键
			self:CloseMenu()//关闭菜单
		end
	end
end

function PANEL:RefreshSize()
	self:SetSize(BetterScreenScale() * 320, ScrH())//设置大小,这里设为界面比例乘320像素,屏幕高度
end

function PANEL:OpenMenu()
	if self.StartChecking and RealTime() < self.StartChecking then return end//如果开始检查时间存在且当前时间小于开始检查时间,返回

	self.CloseTime = nil//关闭时间设置为nil

	self:RefreshSize()//刷新大小
	self:SetPos(ScrW() - self:GetWide(), 0, self.SlideTime, 0, self.SlideTime * 0.8) --self:MoveTo(ScrW() - self:GetWide(), 0, self.SlideTime, 0, self.SlideTime * 0.8)
	self:SetVisible(true)//设置可见
	self:MakePopup()//聚焦面板并使其可以接受输入
	self.StartChecking = RealTime() + 0.1//开始检查时间设置为当前时间+0.1
	self:RefreshContents()//刷新内容

	timer.Simple(0, function()
		gui.SetMousePos(ScrW() * 0.5, ScrH() * 0.5)//设置鼠标位置,屏幕宽度*0.5,屏幕高度*0.5
	end)
end

function PANEL:CloseMenu()
	self:RefreshContents()

	if self.CloseTime then return end
	self.CloseTime = RealTime() + self.SlideTime
end

local texRightEdge = surface.GetTextureID("gui/gradient")//请参考上一个文件，这里是一个从左到右的渐变纹理
function PANEL:Paint()
	surface.SetDrawColor(5, 5, 5, 180)
	surface.DrawRect(self:GetWide() * 0.4, 0, self:GetWide() * 0.6 + 1, self:GetTall())
	surface.SetTexture(texRightEdge)
	surface.DrawTexturedRectRotated(self:GetWide() * 0.2, self:GetTall() * 0.5, self:GetWide() * 0.4, self:GetTall(), 180)
end

function PANEL:AddItem(item)
	item:SetParent(self)//设置父面板
	item:SetWide(self:GetWide() - 16)//设置宽度

	table.insert(self.Items, item)//插入表
end

function PANEL:RefreshContents()//刷新内容
	for k, v in pairs(self.Items) do//遍历表
		v:Remove()//移除
	end
	self.Items = {}

	local occurs = {}//出现

	for k, nest in ipairs(GAMEMODE.CachedNests) do//遍历表,这里遍历的是游戏内所有巢穴
		if not nest:IsValid() then continue end//如果巢穴无效,跳过
		local nown = nest:GetNestOwner()//获取巢穴所有者
		occurs[nown] = (occurs[nown] or 0) + 1//出现[巢穴所有者] = (出现[巢穴所有者]或0) + 1
		local ownname = nown:IsValidZombie() and nown:ClippedName() or ""//如果巢穴所有者是有效的僵尸,则获取其名字,否则为空

		local item = EasyButton(self, "巢 (" .. ownname .. " - " .. occurs[nown] .. ")", 8, 4)//创建按钮,父面板,文本,8,4
		item:SetFont("ZSHUDFontSmall")//设置字体
		item:SizeToContents()//自适应大小
		item.DoClick = function()//点击事件
			net.Start("zs_nestspec")//发送网络消息
				net.WriteEntity(nest)//写入巢穴
			net.SendToServer()
		end

		self:AddItem(item)//添加按钮
	end

	for k, baby in ipairs(GAMEMODE.CachedBabies) do//遍历表,这里遍历的是游戏内所有幼体,这个也就是熊孩子BOSS扔出的那个婴儿
		if not baby:IsValid() then continue end//如果幼体无效,跳过

		local item = EasyButton(self, "Gore Child", 8, 4)//创建按钮,父面板,文本,8,4
		item:SetFont("ZSHUDFontSmall")//设置字体
		item:SizeToContents()
		item.DoClick = function()//点击事件
			net.Start("zs_nestspec")
				net.WriteEntity(baby)
			net.SendToServer()
		end

		self:AddItem(item)
	end

	self:InvalidateLayout()
end

function PANEL:PerformLayout()//布局
	local y = ScrH() / 2//屏幕高度/2
	for k, item in ipairs(self.Items) do//遍历表
		if item and item:IsValid() and item:IsVisible() then//如果按钮有效且可见
			y = y - (item:GetTall() + self.Spacing) / 2//y = y - (按钮高度+间隔)/2
		end
	end

	for k, item in ipairs(self.Items) do//遍历表
		if item and item:IsValid() and item:IsVisible() then//如果按钮有效且可见
			item:SetPos(0, y)//设置位置
			item:CenterHorizontal()//水平居中
			y = y + item:GetTall() + self.Spacing//y = y + 按钮高度 + 间隔
		end
	end
end

vgui.Register("DZombieSpawnMenu", PANEL, "DPanel")
