local PANEL = {}
//描述：这个文件是按下ALT后右边出现的界面
//注释状态：已完成
PANEL.Spacing = 8//间隔
PANEL.SlideTime = 0 --0.2 ，//滑动时间
PANEL.NextRefresh = 0//下一次刷新

function PANEL:Init()
	self:RefreshSize()//刷新大小
	self:SetPos(ScrW() - 1, 0)//设置位置,屏幕宽度-1,0

	self.Items = {}//项目
end

function PANEL:Think()
	local time = RealTime()//获取时间
	if self.CloseTime and time >= self.CloseTime then//如果关闭时间存在并且时间大于等于关闭时间
		self.CloseTime = nil//关闭时间为空
		self:SetVisible(false)//设置不可见
	elseif self.StartChecking and time >= self.StartChecking then//如果开始检查存在并且时间大于等于开始检查的时间
		if not MySelf:KeyDown(GAMEMODE.MenuKey) then//如果玩家没有按下菜单键,也就是按下
			self:CloseMenu()//关闭菜单
		end
	end
end

function PANEL:RefreshSize()
	self:SetSize(BetterScreenScale() * 256, ScrH())//设置大小,这里被设为了界面DPI比例乘以256,屏幕高度
end

function PANEL:OpenMenu()
	if self.StartChecking and RealTime() < self.StartChecking then return end//如果开始检查存在并且时间小于开始检查的时间

	self.CloseTime = nil//关闭时间为空

	self:RefreshSize()//刷新大小
	self:SetPos(ScrW() - self:GetWide(), 0, self.SlideTime, 0, self.SlideTime * 0.8) --self:MoveTo(ScrW() - self:GetWide(), 0, self.SlideTime, 0, self.SlideTime * 0.8)//设置位置,屏幕宽度-宽度,0,滑动时间,0,滑动时间*0.8
	self:SetVisible(true)//设置可见
	self:MakePopup()//设置弹出
	self.StartChecking = RealTime() + 0.1//开始检查时间为当前时间加0.1
	self:RefreshContents()//刷新内容

	timer.Simple(0, function()//延迟0秒
		gui.SetMousePos(ScrW() * 0.5, ScrH() * 0.5)//设置鼠标位置,屏幕宽度*0.5,屏幕高度*0.5
	end)//结束
end

function PANEL:CloseMenu()//关闭菜单
	self:RefreshContents()//刷新内容

	if self.CloseTime then return end//如果关闭时间存在,返回并结束
	self.CloseTime = RealTime() + self.SlideTime//关闭时间为当前时间加滑动时间

	--self:MoveTo(ScrW() - 1, 0, self.SlideTime, 0, self.SlideTime * 0.8)
end

local texRightEdge = surface.GetTextureID("gui/gradient")//获取纹理ID,这个是一个渐变
function PANEL:Paint()  //绘制
	surface.SetDrawColor(5, 5, 5, 180)//设置绘制颜色,5,5,5,180
	surface.DrawRect(self:GetWide() * 0.4, 0, self:GetWide() * 0.6 + 1, self:GetTall())//绘制矩形,宽度*0.4,0,宽度*0.6+1,高度
	surface.SetTexture(texRightEdge)//设置纹理
	surface.DrawTexturedRectRotated(self:GetWide() * 0.2, self:GetTall() * 0.5, self:GetWide() * 0.4, self:GetTall(), 180)//绘制纹理矩形旋转,宽度*0.2,高度*0.5,宽度*0.4,高度,旋转了180度
end

function PANEL:AddItem(item)//添加项目
	item:SetParent(self)//设置父控件
	item:SetWide(self:GetWide() - 16)//设置宽度,父控件宽度-16

	table.insert(self.Items, item)//插入项目

	self:InvalidateLayout()//重新布局
end

function PANEL:RemoveItem(item)//移除项目
	for k, v in ipairs(self.Items) do//遍历项目
		if v == item then//如果项目等于项目
			item:Remove()//移除项目
			table.remove(self.Items, k)//移除项目
			self:InvalidateLayout()
			break
		end
	end
end

function PANEL:RefreshContents()//刷新内容
	local changed = false//设置没有发生改变

	for k, v in ipairs(self.Items) do//遍历项目，也就是按下ALT后右边出现的子弹那些
		if v.GetAmmoType then//如果项目有获取弹药类型
			if MySelf:GetAmmoCount(v:GetAmmoType()) <= 0 then//如果玩家获取弹药数量小于等于0
				if v:IsVisible() then//如果项目可见
					v:SetVisible(false)//设置不可见
					changed = true//设置发生改变
				end
			elseif not v:IsVisible() then//如果项目不可见
				v:SetVisible(true)//设置可见
				changed = true//设置发生改变
			end
		end
	end

	if changed then//如果发生改变
		self:InvalidateLayout()//重新布局
	end
end

function PANEL:PerformLayout()//布局
	local y = ScrH() / 2//设置y为屏幕高度除以2
	for k, item in ipairs(self.Items) do//遍历项目
		if item and item:IsValid() and item:IsVisible() then//如果项目存在并且有效并且可见
			y = y - (item:GetTall() + self.Spacing) / 2//y为y减去项目高度加间隔除以2
		end
	end

	for k, item in ipairs(self.Items) do//遍历所有物品
		if item and item:IsValid() and item:IsVisible() then//如果存在并且物品可见和有效
			item:SetPos(0, y)//设置位置,0,y
			item:CenterHorizontal()//水平居中
			y = y + item:GetTall() + self.Spacing//y为y加上物品高度加间隔
		end
	end
end

vgui.Register("DSideMenu", PANEL, "DPanel")//注册侧边菜单
