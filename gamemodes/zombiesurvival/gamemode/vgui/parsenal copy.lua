//描述，这个东西时用于商店的
//注释状态：已完成
local function pointslabelThink(self)//这个函数是用于更新玩家的点数
	local points = MySelf:GetPoints()//获取玩家的点数
	if self.m_LastPoints ~= points then//如果玩家的点数发生了变化
		self.m_LastPoints = points//更新玩家的点数

		self:SetText("点数: "..points)//更新玩家的点数
		self:SizeToContents()//更新玩家的点数
	end
end

hook.Add("Think", "ArsenalMenuThink", function()//这个钩子是用于检测鼠标是否脱离了商店的面板，脱离了就自动关闭
	local pan = GAMEMODE.ArsenalInterface//获取商店的面板
	if pan and pan:IsValid() and pan:IsVisible() then//如果商店的面板存在并且是可见的
		local mx, my = gui.MousePos()//获取鼠标的位置
		local x, y = pan:GetPos()//获取商店的面板的位置
		if mx < x - 16 or my < y - 16 or mx > x + pan:GetWide() + 16 or my > y + pan:GetTall() + 16 then//如果鼠标脱离了商店的面板，这里是鼠标的X坐标小于商店面板的X坐标-16或者鼠标的Y坐标小于商店面板的Y坐标-16或者鼠标的X坐标大于商店面板的X坐标+商店面板的宽度+16或者鼠标的Y坐标大于商店面板的Y坐标+商店面板的高度+16
			pan:SetVisible(false)//就关闭商店的面板
		end
	end
end)

local function ArsenalMenuCenterMouse(self)//这个函数是用于打开时鼠标处于商店面板的中心
	local x, y = self:GetPos()//获取商店面板的位置
	local w, h = self:GetSize()//获取商店面板的大小
	gui.SetMousePos(x + w / 2, y + h / 2)//设置鼠标的位置
end

local function worthmenuDoClick()//这个函数是用于处理初始菜单的点击事件
	MakepWorth()//创建初始菜单
	GAMEMODE.ArsenalInterface:Close()//关闭商店面板
end

local function CanBuy(item, pan)//这个函数是用于判断玩家是否可以购买武器
	if item.NoClassicMode and GAMEMODE:IsClassicMode() then//如果武器不允许在经典模式下购买,并且当前模式是经典模式
		return false//就返回false,也就是不允许购买
	end

	if item.Tier and GAMEMODE.LockItemTiers and not GAMEMODE.ZombieEscape and not GAMEMODE.ObjectiveMap and not GAMEMODE:IsClassicMode() then//如果武器的等级存在并且锁定了武器的等级并且当前模式不是僵尸逃跑模式并且当前模式不是目标模式并且当前模式不是经典模式
		if not GAMEMODE:GetWaveActive() then -- We can buy during the wave break before hand.//如果当前没有活动的波数
			if GAMEMODE:GetWave() + 1 < item.Tier then///这个是默认的//如果当前波数+1小于武器的等级，就返回false，也就是不允许购买
				return false
			end
		elseif GAMEMODE:GetWave() < item.Tier then
			return false
		end
	end

	if item.MaxStock and not GAMEMODE:HasItemStocks(item.Signature) then//如果武器的库存存在并且没有库存
		return false
	end

	if not pan.NoPoints and MySelf:GetPoints() < math.floor(item.Price * (MySelf.ArsenalDiscount or 1)) then//如果武器的没有设置不使用点数并且玩家的点数小于武器的价格
		return false
	elseif pan.NoPoints and MySelf:GetAmmoCount("scrap") < math.ceil(GAMEMODE:PointsToScrap(item.Price)) then//如果武器的价格大于玩家的碎片,
		return false
	end

	return true
end

local function ItemPanelThink(self)//这个函数是用于更新武器的状态
	local itemtab = FindItem(self.ID)//获取武器的信息
	if itemtab then//如果武器的信息存在
		local newstate = CanBuy(itemtab, self)//获取玩家是否可以购买武器,这个函数在上面
		if newstate ~= self.m_LastAbleToBuy then//如果新的状态不等于上一次的状态
			self.m_LastAbleToBuy = newstate//更新状态
			if newstate then//如果新的状态是可以购买
				self.NameLabel:SetTextColor(COLOR_WHITE)//设置武器的名字的颜色为白色
				self.NameLabel:InvalidateLayout()
			else
				self.NameLabel:SetTextColor(COLOR_RED)//设置武器的名字的颜色为红色
				self.NameLabel:InvalidateLayout()
			end
		end

		if self.StockLabel then//如果武器的库存存在
			local stocks = GAMEMODE:GetItemStocks(self.ID)//获取武器的库存
			if stocks ~= self.m_LastStocks then//如果新的库存不等于上一次的库存
				self.m_LastStocks = stocks//更新库存

				self.StockLabel:SetText(stocks.." remaining")//设置库存的文本
				self.StockLabel:SizeToContents()//设置库存的大小
				self.StockLabel:AlignRight(10)
				self.StockLabel:SetTextColor(stocks > 0 and COLOR_GRAY or COLOR_RED)//设置库存的颜色
				self.StockLabel:InvalidateLayout()
			end
		end
	end
end

local colBG = Color(20, 20, 20)//设置背景颜色
local function ItemPanelPaint(self, w, h)//这个函数是用于绘制武器的面板
	if self.Hovered or self.On then//如果鼠标在武器的面板上或者武器的面板被选中
		local outline//设置边框的颜色
		if self.m_LastAbleToBuy then//如果玩家可以购买武器
			outline = self.Depressed and COLOR_GREEN or COLOR_DARKGREEN//设置边框的颜色为绿色,或者深绿色
		else
			outline = self.Depressed and COLOR_RED or COLOR_DARKRED//设置边框的颜色为红色,或者深红色
		end

		draw.RoundedBox(8, 0, 0, w, h, outline)//绘制圆角边框，里面参数分别是，圆角的大小，x坐标，y坐标，宽度，高度，颜色
	end

	if self.ShopTabl.SWEP and MySelf:HasInventoryItem(self.ShopTabl.SWEP) then//如果玩家有武器
		draw.RoundedBox(8, 2, 2, w - 4, h - 4, COLOR_RORANGE)//绘制圆角边框，里面参数分别是，圆角的大小，x坐标，y坐标，宽度，高度，颜色,这里颜色是橘色,RGB代码是(255,158,0)
	end

	draw.RoundedBox(2, 4, 4, w - 8, h - 8, colBG)//绘制圆角边框，里面参数分别是，圆角的大小，x坐标，y坐标，宽度，高度，颜色,这里颜色是黑色,RGB代码是(20,20,20)

	return true
end

function GM:ViewerStatBarUpdate(viewer, display, sweptable)//这个函数是选中武器后商店界面右边的介绍 ,第一个参数是预览者，第二个参数是显示类型，第三个数武器的属性表
	local done, statshow = {}//设置done和statshow
	local speedtotext = GAMEMODE.SpeedToText//设置速度的文本
	for i = 1, 6 do//循环6次
		if display then//如果显示
			viewer.ItemStats[i]:SetText("")//设置武器的属性为空
			viewer.ItemStatValues[i]:SetText("")//设置武器的属性值为空
			viewer.ItemStatBars[i]:SetVisible(false)//设置武器的属性条不可见
			continue//跳出循环
		end
		local statshowbef = statshow//设置statshowbef为statshow
		for k, stat in pairs(GAMEMODE.WeaponStatBarVals) do//循环武器的属性,这个在cl_options.lua里面
			local statval = stat[6] and sweptable[stat[6]][stat[1]] or sweptable[stat[1]]//获取武器的属性值,这里的sweptable是武器的表,stat[6]是武器的属性,stat[1]是武器的属性值
			if not done[stat] and statval and statval ~= -1 then
				statshow = stat
				done[stat] = true

				break
			end
		end
		if statshowbef and statshowbef[1] == statshow[1] then//如果statshowbef存在并且statshowbef的第一个值等于statshow的第一个值
			viewer.ItemStats[i]:SetText("")//设置武器的属性为空
			viewer.ItemStatValues[i]:SetText("")//设置武器的属性值为空
			viewer.ItemStatBars[i]:SetVisible(false)//	设置武器的属性条不可见
			continue
		end

		local statnum, stattext = statshow[6] and sweptable[statshow[6]][statshow[1]] or sweptable[statshow[1]]//获取武器的属性值,这里的sweptable是武器的表,statshow[6]是武器的属性,statshow[1]是武器的属性值
		if statshow[1] == "Damage" and sweptable.Primary.NumShots and sweptable.Primary.NumShots > 1 then//如果
			stattext = statnum .. " x " .. sweptable.Primary.NumShots-- .. " (" .. (statnum * sweptable.Primary.NumShots) .. ")"//这里应该是伤害值是武器的伤害成子弹数
		elseif statshow[1] == "WalkSpeed" then//如果武器的属性是移动速度
			stattext = speedtotext[SPEED_NORMAL]//设置武器的移动速度
			if speedtotext[sweptable[statshow[1]]] then//如果武器的移动速度存在
				stattext = speedtotext[sweptable[statshow[1]]]//设置武器的移动速度
			elseif sweptable[statshow[1]] < SPEED_SLOWEST then//如果武器的移动速度小于最慢的移动速度
				stattext = speedtotext[-1]//设置武器的移动速度
			end
		elseif statshow[1] == "ClipSize" then//如果武器的属性是弹药容量
			stattext = statnum / sweptable.RequiredClip//设置武器的弹药容量
		else
			stattext = statnum//设置武器的属性值
		end

		viewer.ItemStats[i]:SetText(statshow[2])//设置武器的属性
		viewer.ItemStatValues[i]:SetText(stattext)//设置武器的属性值

		if statshow[1] == "Damage" then//如果武器的属性是伤害
			statnum = statnum * sweptable.Primary.NumShots//设置武器的属性值
		elseif statshow[1] == "ClipSize" then
			statnum = statnum / sweptable.RequiredClip
		end

		viewer.ItemStatBars[i].Stat = statnum//设置武器的属性值
		viewer.ItemStatBars[i].StatMin = statshow[3]//设置武器的属性最小值
		viewer.ItemStatBars[i].StatMax = statshow[4]//设置武器的属性最大值
		viewer.ItemStatBars[i].BadHigh = statshow[5]//设置武器的属性最大值
		viewer.ItemStatBars[i]:SetVisible(true)
	end
end

function GM:HasPurchaseableAmmo(sweptable)//这个函数是判断武器是否可以购买弹药，第一个参数是武器的属性表
	if sweptable.Primary and self.AmmoToPurchaseNames[sweptable.Primary.Ammo] then//如果武器的主要属性存在并且武器的主要属性的弹药存在
		return true//返回true
	end
end

function GM:SupplyItemViewerDetail(viewer, sweptable, shoptbl)//这个函数是武器的详细信息，第一个参数是武器的详细信息，第二个参数是武器的属性表，第三个参数是武器的商店表
	viewer.m_Title:SetText(sweptable.PrintName)
	viewer.m_Title:PerformLayout()

	local desctext = sweptable.Description or ""//设置武器的详细信息
	if not self.ZSInventoryItemData[shoptbl.SWEP] then//如果武器的属性表不存在
		viewer.ModelPanel:SetModel(sweptable.WorldModel)//设置武器的模型
		local mins, maxs = viewer.ModelPanel.Entity:GetRenderBounds()//获取武器的模型的最小值和最大值
		viewer.ModelPanel:SetCamPos(mins:Distance(maxs) * Vector(1.15, 0.75, 0.5))//设置武器的模型的相机位置
		viewer.ModelPanel:SetLookAt((mins + maxs) / 2)//设置武器的模型的看向位置
		viewer.m_VBG:SetVisible(true)//设置武器的详细信息可见

		if sweptable.NoDismantle then//如果武器的属性表的NoDismantle属性存在
			desctext = desctext .. "\nCannot be dismantled for scrap."//设置武器的详细信息
		end

		viewer.m_Desc:MoveBelow(viewer.m_VBG, 8)//设置武器的详细信息的位置,将面板放置在具有指定偏移的传递面板下方。这里是将武器的详细信息放置在武器的模型下方8个像素的位置
		viewer.m_Desc:SetFont("ZSBodyTextFont")//设置武器的详细信息的字体
	else
		viewer.ModelPanel:SetModel("")//设置武器的模型为空
		viewer.m_VBG:SetVisible(false)//设置武器的详细信息不可见

		viewer.m_Desc:MoveBelow(viewer.m_Title, 20)//设置武器的详细信息的位置,将面板放置在具有指定偏移的传递面板下方。这里是将武器的详细信息放置在武器的标题下方20个像素的位置
		viewer.m_Desc:SetFont("ZSBodyTextFontBig")//设置武器的详细信息的字体
	end
	viewer.m_Desc:SetText(desctext)//设置武器的详细信息

	self:ViewerStatBarUpdate(viewer, shoptbl.Category ~= ITEMCAT_GUNS and shoptbl.Category ~= ITEMCAT_MELEE, sweptable)//更新武器的属性,第一个参数是观察者，也就是玩家，第二个是武器的类型，第三个是武器的属性表

	if self:HasPurchaseableAmmo(sweptable) and self.AmmoNames[string.lower(sweptable.Primary.Ammo)] then//如果武器可以购买弹药并且武器的主要属性的弹药存在
		local lower = string.lower(sweptable.Primary.Ammo)//设置武器的主要属性的弹药的小写

		viewer.m_AmmoType:SetText(self.AmmoNames[lower])//设置武器的主要属性的弹药的名字
		viewer.m_AmmoType:PerformLayout()//设置武器的主要属性的弹药的位置

		local ki = killicon.Get(self.AmmoIcons[lower])//设置武器的主要属性的弹药的图标，也就是上面图片里面的子弹图标

		viewer.m_AmmoIcon:SetImage(ki[1])//设置武器的主要属性的弹药的图标
		if ki[2] then viewer.m_AmmoIcon:SetImageColor(ki[2]) end//设置武器的主要属性的弹药的图标的颜色

		viewer.m_AmmoIcon:SetVisible(true)//设置武器的主要属性的弹药的图标可见
	else
		viewer.m_AmmoType:SetText("")//设置武器的主要属性的弹药的名字为空
		viewer.m_AmmoIcon:SetVisible(false)//设置武器的主要属性的弹药的图标不可见
	end
end

local function ItemPanelDoClick(self)//这个函数是处理物品面板的点击事件，第一个参数是武器的面板
	local shoptbl = self.ShopTabl//设置武器的商店表
	local viewer = self.NoPoints and GAMEMODE.RemantlerInterface.TrinketsFrame.Viewer or GAMEMODE.ArsenalInterface.Viewer//设置武器的观察者，也就是玩家

	if not shoptbl then return end//如果武器的商店表不存在，就返回
	local sweptable = GAMEMODE.ZSInventoryItemData[shoptbl.SWEP] or weapons.Get(shoptbl.SWEP)//设置武器的属性表，如果武器的属性表不存在，就设置为武器的属性表，如果武器的属性表存在，就设置为武器的属性表

	if not sweptable or GAMEMODE.AlwaysQuickBuy then//如果武器的属性表不存在或者总是快速购买
		RunConsoleCommand("zs_pointsshopbuy", self.ID, self.NoPoints and "scrap")//运行控制台命令，zs_pointsshopbuy，第一个参数是武器的ID，第二个参数是武器的类型
		return//返回
	end

	for _, v in pairs(self:GetParent():GetChildren()) do//遍历武器的父面板的子面板
		v.On = false//设置武器的子面板的On属性为false
	end
	self.On = true//设置武器的On属性为true

	GAMEMODE:SupplyItemViewerDetail(viewer, sweptable, shoptbl)//设置武器的详细信息，第一个参数是观察者，也就是玩家，第二个是武器的属性表，第三个是武器的商店表

	local screenscale = BetterScreenScale()//设置屏幕比例
	local canammo = GAMEMODE:HasPurchaseableAmmo(sweptable)//设置武器是否可以购买弹药

	local purb = viewer.m_PurchaseB//设置武器的购买按钮
	purb.ID = self.ID//	设置武器的购买按钮的ID
	purb.DoClick = function() RunConsoleCommand("zs_pointsshopbuy", self.ID, self.NoPoints and "scrap") end//设置武器的购买按钮的点击事件，运行控制台命令，zs_pointsshopbuy，第一个参数是武器的ID，第二个参数是武器的类型
	purb:SetPos(canammo and viewer:GetWide() / 4 - viewer:GetWide() / 8 - 20 or viewer:GetWide() / 4, viewer:GetTall() - 64 * screenscale)//设置武器的购买按钮的位置
	purb:SetVisible(true)//设置武器的购买按钮可见

	local purl = viewer.m_PurchaseLabel//设置武器的购买标签
	purl:SetPos(purb:GetWide() / 2 - purl:GetWide() / 2, purb:GetTall() * 0.35 - purl:GetTall() * 0.5)//设置武器的购买标签的位置
	purl:SetVisible(true)//设置武器的购买标签可见

	local ppurbl = viewer.m_PurchasePrice//设置武器的购买价格
	local price = self.NoPoints and math.ceil(GAMEMODE:PointsToScrap(shoptbl.Worth)) or math.floor(shoptbl.Worth * (MySelf.ArsenalDiscount or 1))//设置武器的购买价格
	ppurbl:SetText(price .. (self.NoPoints and " 零件" or " 点数"))//设置武器的购买价格的文本
	ppurbl:SizeToContents()//设置武器的购买价格的大小
	ppurbl:SetPos(purb:GetWide() / 2 - ppurbl:GetWide() / 2, purb:GetTall() * 0.75 - ppurbl:GetTall() * 0.5)//设置武器的购买价格的位置
	ppurbl:SetVisible(true)//	

	purb = viewer.m_AmmoB//设置武器的弹药购买按钮
	if canammo then//如果武器可以购买弹药
		purb.AmmoType = GAMEMODE.AmmoToPurchaseNames[sweptable.Primary.Ammo]//设置武器的弹药购买按钮的弹药类型
		purb.DoClick = function() RunConsoleCommand("zs_pointsshopbuy", "ps_"..purb.AmmoType) end//设置武器的弹药购买按钮的点击事件，运行控制台命令，zs_pointsshopbuy，第一个参数是弹药的类型
	end
	purb:SetPos(viewer:GetWide() * (3/4) - purb:GetWide() / 2, viewer:GetTall() - 64 * screenscale)//设置武器的弹药购买按钮的位置
	purb:SetVisible(canammo)//设置武器的弹药购买按钮可见

	purl = viewer.m_AmmoL//设置武器的弹药购买标签
	purl:SetPos(purb:GetWide() / 2 - purl:GetWide() / 2, purb:GetTall() * 0.35 - purl:GetTall() * 0.5)//设置武器的弹药购买标签的位置
	purl:SetVisible(canammo)//设置武器的弹药购买标签可见

	ppurbl = viewer.m_AmmoPrice//设置武器的弹药购买价格
	price = math.floor(5 * (MySelf.ArsenalDiscount or 1))//设置武器的弹药购买价格
	ppurbl:SetText(price .. " Points")//设置弹药价格的文本
	ppurbl:SizeToContents()//设置弹药价格的大小
	ppurbl:SetPos(purb:GetWide() / 2 - ppurbl:GetWide() / 2, purb:GetTall() * 0.75 - ppurbl:GetTall() * 0.5)//设置弹药价格的位置
	ppurbl:SetVisible(canammo)//设置弹药价格可见
end

local function ArsenalMenuThink(self)//商店界面
end
-------------------我是分割线-------------------
--应用武器图标
function GM:AttachKillicon(kitbl, itempan, mdlframe, ammo, missing_skill)//武器图标,武器面板,武器模型,弹药,缺少技能
	local function imgAdj(img, maximgx, maximgy)//调整武器图标,最大武器图标X,最大武器图标Y
		img:SizeToContents()//设置武器图标大小
		local iwidth, height = img:GetSize()//设置武器图标大小
		if height > maximgy then//如果武器图标高度大于最大武器图标Y
			img:SetSize(maximgy / height * img:GetWide(), maximgy)//设置武器图标大小,这里设置为最大武器图标Y的大小除以图片高度乘以图片宽度,最大武器图标Y
			iwidth, height = img:GetSize()//设置武器图标大小
		end
		if iwidth > maximgx then//如果武器图标宽度大于最大武器图标X
			img:SetWidth(maximgx)//设置武器图标宽度为最大武器图标X
		end

		img:Center()//设置武器图标居中
	end
	-------------------我是分割线-------------------
	--这个是商店中武器图标
	
	if #kitbl == 2 then//如果武器图标的类型等于2，也就是类型是BUFF那一栏
		local img = vgui.Create("DImage", mdlframe)//创建一个武器图标
		img:SetImage(kitbl[1])//设置武器图标
		if kitbl[2] then//如果武器图标等于2
			img:SetImageColor(kitbl[2])//设置武器图标颜色
		end
		if missing_skill then img:SetAlpha(50) end//如果缺少技能,设置武器图标透明度为50

		imgAdj(img, mdlframe:GetWide() - 6, mdlframe:GetTall() - 3)
		if ammo then img:SetSize(img:GetWide() + 3, img:GetTall() + 3) end

		img:Center()
		itempan.m_Icon = img
	elseif #kitbl == 3 then//如果武器图标的类型等于3
		local label = vgui.Create("DLabel", mdlframe)//创建一个武器图标文本
		label:SetText(kitbl[2])//设置武器图标文本
		label:SetFont(kitbl[1] .. "pa" or DefaultFont)//设置武器图标文本字体
		label:SetTextColor(kitbl[3] or color_white)//设置武器图标文本颜色
		label:SizeToContents()
		label:SetContentAlignment(8)//设置武器图标文本对齐方式,8是顶部居中对齐
		label:DockMargin(0, label:GetTall() * 0.05, 0, 0)//设置武器图标文本边距
		label:Dock(FILL)//设置武器图标文本停靠方式
		itempan.m_Icon = label//设置武器图标文本
	end

	if missing_skill then//如果缺少技能
		local img = vgui.Create("DImage", mdlframe)//创建一个图标
		img:SetImage("zombiesurvival/padlock.png")//设置缺少的图标
		img:SetImageColor(Color(255, 30, 30))//设置图标颜色
		imgAdj(img, mdlframe:GetWide(), mdlframe:GetTall())//调整图标大小

		img:Center()//设置图标居中
		itempan.m_Padlock = img//设置图标
	end
end
-------------------我是分割线-------------------


-------------------我是分割线-------------------
--添加商店物品
function GM:AddShopItem(list, i, tab, issub, nopointshop)//商店列表,商店物品,商店物品,是否是子商店,是否是点数商店
	local screenscale = BetterScreenScale()//获取屏幕比例

	local nottrinkets = tab.Category ~= ITEMCAT_TRINKETS//如果物品类型不等于饰品
	local missing_skill = tab.SkillRequirement and not MySelf:IsSkillActive(tab.SkillRequirement)//如果缺少技能
	local wid = 280//默认宽度

	local itempan = vgui.Create("DButton")//创建一个按钮
	itempan:SetText("")//设置按钮文本
	itempan:SetSize(wid * screenscale, (nottrinkets and 100 or 60) * screenscale)//设置按钮大小
	itempan.ID = tab.Signature or i//设置按钮ID,签名或者是i
	itempan.NoPoints = nopointshop//设置按钮是否是点数商店
	itempan.ShopTabl = tab//设置按钮商店物品
	itempan.Think = ItemPanelThink//设置按钮Think
	itempan.Paint = ItemPanelPaint//设置按钮Paint
	itempan.DoClick = ItemPanelDoClick//设置按钮的点击时间
	itempan.DoRightClick = function()//设置按钮的右击事件
		local menu = DermaMenu(itempan)//创建一个菜单
		menu:AddOption("Buy", function() RunConsoleCommand("zs_pointsshopbuy", itempan.ID, itempan.NoPoints and "scrap") end)//添加一个选项
		menu:Open()//打开菜单
	end
	list:AddItem(itempan)//添加按钮到商店列表

	if nottrinkets then//如果不是饰品
		local mdlframe = vgui.Create("DPanel", itempan)//创建一个面板
		mdlframe:SetSize(wid/2 * screenscale, 100/2 * screenscale)//设置面板大小
		mdlframe:SetPos(wid/4 * screenscale, 100/5 * screenscale)//设置面板位置
		mdlframe:SetMouseInputEnabled(false)//设置面板鼠标输入
		mdlframe.Paint = function() end

		local kitbl = killicon.Get(GAMEMODE.ZSInventoryItemData[tab.SWEP] and "weapon_zs_craftables" or tab.SWEP or tab.Model)//获取武器图标
		if kitbl then//如果武器图标存在
			self:AttachKillicon(kitbl, itempan, mdlframe, tab.Category == ITEMCAT_AMMO, missing_skill)//添加武器图标,按钮,面板,是否是弹药,是否缺少技能
		elseif tab.Model then//如果武器图标不存在,但是模型存在
			if tab.Model then//如果模型存在
				local mdlpanel = vgui.Create("DModelPanel", mdlframe)//创建一个模型面板，也就是点击商店物品后右边显示的模型
				mdlpanel:SetSize(mdlframe:GetSize())//设置模型面板大小
				mdlpanel:SetModel(tab.Model)//设置模型面板模型
				local mins, maxs = mdlpanel.Entity:GetRenderBounds()//获取模型面板的最小和最大
				mdlpanel:SetCamPos(mins:Distance(maxs) * Vector(0.75, 0.75, 0.5))//设置模型面板的相机位置
				mdlpanel:SetLookAt((mins + maxs) / 2)//设置模型面板的看向
			end
		end
	end

	if tab.SWEP or tab.Countables then//如果是武器或者是可计数的
		local counter = vgui.Create("ItemAmountCounter", itempan)//创建物品计数
		counter:SetItemID(i)//
	end

	local name = tab.Name or ""//获取物品名称,如果没有就是空
	local namelab = EasyLabel(itempan, name, "ZSHUDFontSmaller", COLOR_WHITE)//创建一个文本,按钮,文本,颜色
	namelab:SetPos(12 * screenscale, itempan:GetTall() * (nottrinkets and 0.8 or 0.7) - namelab:GetTall() * 0.5)//设置文本位置
	if missing_skill then//如果缺少技能
		namelab:SetAlpha(30)//设置文本透明度
	end
	itempan.NameLabel = namelab//设置按钮文本

	local alignri = (issub and (320 + 32) or (nopointshop and 32 or 20)) * screenscale//设置对齐右边

	local pricelabel = EasyLabel(itempan, "", "ZSHUDFontTiny")//创建一个价格标签
	if missing_skill then//如果缺少技能
		pricelabel:SetTextColor(COLOR_RED)//设置价格标签为红色
		pricelabel:SetText(GAMEMODE.Skills[tab.SkillRequirement].Name)//设置价格标签文本
	else//如果没有缺少技能
		local points = math.floor(tab.Price * (MySelf.ArsenalDiscount or 1))//获取价格
		local price = tostring(points)//转换为字符串
		if nopointshop then//如果不是点数商店
			price = tostring(math.ceil(self:PointsToScrap(tab.Price)))//转换为字符串,并且向上取整
		end
		pricelabel:SetText(price..(nopointshop and " Scrap" or " Points"))//设置价格标签文本
	end
	pricelabel:SizeToContents()//设置价格标签大小
	pricelabel:AlignRight(alignri)//设置价格标签对齐右边
	--如果有设置最大销售数量的话
	if tab.MaxStock then
		local stocklabel = EasyLabel(itempan, tab.MaxStock.." remaining", "ZSHUDFontTiny")//创建一个库存标签
		stocklabel:SizeToContents()//设置库存标签大小
		stocklabel:AlignRight(alignri)//设置库存标签对齐右边
		stocklabel:SetPos(itempan:GetWide() - stocklabel:GetWide(), itempan:GetTall() * 0.45 - stocklabel:GetTall() * 0.5)//设置库存标签位置,按钮宽度-库存标签宽度,按钮高度*0.45-库存标签高度*0.5
		itempan.StockLabel = stocklabel//设置按钮库存标签
	end
	pricelabel:SetPos(//设置价格标签位置
		itempan:GetWide() - pricelabel:GetWide() - 12 * screenscale,//按钮宽度-价格标签宽度-12*屏幕比例
		itempan:GetTall() * (nottrinkets and 0.15 or 0.3) - pricelabel:GetTall() * 0.5//按钮高度*0.15-价格标签高度*0.5
	)

	if missing_skill or tab.NoClassicMode and isclassic or tab.NoZombieEscape and GAMEMODE.ZombieEscape then//如果缺少技能或者是经典模式或者是僵尸逃跑模式
		itempan:SetAlpha(160)//设置按钮透明度
	end

	if not nottrinkets and tab.SubCategory then//如果不是饰品并且有子类
		local catlabel = EasyLabel(itempan, GAMEMODE.ItemSubCategories[tab.SubCategory], "ZSBodyTextFont")//创建一个子类标签
		catlabel:SizeToContents()//设置子类标签大小
		catlabel:SetPos(10, itempan:GetTall() * 0.3 - catlabel:GetTall() * 0.5)//设置子类标签位置
	end

	return itempan//返回按钮
end

function GM:ConfigureMenuTabs(tabs, tabhei, callback)//配置菜单标签,标签,标签高度,回调,这个就是商店上面的子标签
	local screenscale = BetterScreenScale()//获取屏幕比例

	for _, tab in pairs(tabs) do//遍历标签
		tab:SetFont(screenscale > 0.85 and "ZSHUDFontTiny" or "DefaultFontAA")//设置标签字体
		tab.GetTabHeight = function()//获取标签高度
			return tabhei
		end
		tab.PerformLayout = function(me)//设置标签布局
			me:ApplySchemeSettings()//应用方案设置

			if not me.Image then return end//如果没有图片就返回
			me.Image:SetPos(7, me:GetTabHeight()/2 - me.Image:GetTall()/2 + 3)//设置图片位置
			me.Image:SetImageColor(Color(255, 255, 255, not me:IsActive() and 155 or 255))//设置图片颜色
		end
		tab.DoClick = function(me)//点击标签
			me:GetPropertySheet():SetActiveTab(me)//设置标签活动标签

			if callback then callback(tab) end
		end
	end
end

////////////////////////////////
//选中物品后右边显示的条形图界面//
////////////////////////////////

local PANEL = {}

PANEL.Stat = 50//设置状态
PANEL.StatMin = 0//设置最小状态
PANEL.StatMax = 100//设置最大状态
PANEL.BadHigh = false//设置高度
PANEL.LerpStat = 50//设置状态
function PANEL:Init()
	self:SetMouseInputEnabled(false)//设置鼠标输入,这个是不允许鼠标输入
	self:SetKeyboardInputEnabled(false)//设置键盘输入,这个是不允许键盘输入
end

local matGradientLeft = CreateMaterial("gradient-l", "UnlitGeneric", {["$basetexture"] = "vgui/gradient-l", ["$vertexalpha"] = "1", ["$vertexcolor"] = "1", ["$ignorez"] = "1", ["$nomip"] = "1"})//创建一个材质,这个是左边渐变材质
function PANEL:Paint(w, h)
	self.LerpStat = Lerp(FrameTime() * 4, self.LerpStat, self.Stat)//设置状态
	local progress = math.Clamp((self.StatMax - self.LerpStat)/(self.StatMax - self.StatMin), 0, 1)//设置进度
	if not self.BadHigh then//如果不是高度
		progress = 1 - progress//设置进度
	end
	surface.SetDrawColor(0, 0, 0, 220)//设置绘制颜色
	surface.DrawRect(0, 0, w, 5)//绘制矩形
	surface.SetDrawColor(250, 250, 250, 20)//	设置绘制颜色
	surface.DrawRect(math.min(w * 0.95, w * progress), 0, 1, 5)//绘制矩形
	surface.SetDrawColor(200 * (1 - progress), 200 * progress, 10, 160)//设置绘制颜色
	surface.SetMaterial(matGradientLeft)//设置材质
	surface.DrawTexturedRect(0, 0, w * progress, 4)//绘制矩形

end
vgui.Register("ZSItemStatBar", PANEL, "Panel")
-------------------我是分割线-------------------
--创建武器预览，就是F2商店右上角偏下点的地方
function GM:CreateItemViewerGenericElems(viewer)//创建武器预览
	local screenscale = BetterScreenScale()//获取屏幕比例
	--创建武器的名字
	local vtitle = EasyLabel(viewer, "", "ZSHUDFontSmaller", COLOR_GRAY)//创建一个武器名字
	vtitle:SetContentAlignment(8)//设置武器名字对齐方式,8是顶部居中
	vtitle:SetSize(viewer:GetWide(), 24 * screenscale)//设置武器名字大小
	viewer.m_Title = vtitle//设置武器名字
	--弹药类型
	local vammot = EasyLabel(viewer, "", "ZSBodyTextFontBig", COLOR_GRAY)//创建一个弹药类型
	vammot:SetContentAlignment(8)//设置弹药类型对齐方式,8是顶部居中
	vammot:SetSize(viewer:GetWide(), 16 * screenscale)//设置弹药类型大小
	vammot:MoveBelow(vtitle, 20)//设置弹药类型位置
	vammot:CenterHorizontal(0.35)///设置弹药类型位置
	viewer.m_AmmoType = vammot//设置弹药类型
	--弹药图标
	local vammoi = vgui.Create("DImage", viewer)//创建一个弹药图标
	vammoi:SetSize(40, 40)//设置弹药图标大小
	vammoi:MoveBelow(vtitle, 8)//设置弹药图标位置
	vammoi:CenterHorizontal(0.7)//设置弹药图标位置
	viewer.m_AmmoIcon = vammoi//设置弹药图标

	local vbg = vgui.Create("DPanel", viewer)//创建一个武器预览背景
	vbg:SetSize(200 * screenscale, 100 * screenscale)//设置武器预览背景大小
	vbg:CenterHorizontal()//设置武器预览背景位置
	vbg:MoveBelow(vammot, 24)//设置武器预览背景位置
	vbg:SetBackgroundColor(Color(0, 0, 0, 255))//设置武器预览背景颜色
	vbg:SetVisible(false)//设置武器预览背景不可见
	viewer.m_VBG = vbg//设置武器预览背景
	--模型预览
	local modelpanel = vgui.Create("DModelPanelEx", vbg)//创建一个模型预览
	modelpanel:SetModel("")//设置模型预览
	modelpanel:AutoCam()//自动摄像头
	modelpanel:Dock(FILL)//全部填充父级
	modelpanel:SetDirectionalLight(BOX_TOP, Color(100, 255, 100))//设置方向光，第一个是从顶部照射，第二个是绿色
	modelpanel:SetDirectionalLight(BOX_FRONT, Color(255, 100, 100))//设置方向光，第一个是从前面照射，第二个是红色
	viewer.ModelPanel = modelpanel//
	--物品介绍
	local itemdesc = vgui.Create("DLabel", viewer)//创建物品介绍
	itemdesc:SetFont("ZSBodyTextFont")//设置物品介绍字体
	itemdesc:SetTextColor(COLOR_GRAY)//设置物品介绍颜色,灰色
	itemdesc:SetMultiline(true)//设置物品介绍多行
	itemdesc:SetWrap(true)//设置物品介绍自动换行
	itemdesc:SetAutoStretchVertical(true)//设置物品介绍自动垂直拉伸
	itemdesc:SetWide(viewer:GetWide() - 16)//设置物品介绍宽度,父级宽度-16
	itemdesc:CenterHorizontal()//设置物品介绍位置
	itemdesc:SetText("")//设置物品
	itemdesc:MoveBelow(vbg, 8)//设置物品介绍位置,预览背景下方8个像素
	viewer.m_Desc = itemdesc//设置物品介绍	

	local itemstats, itemsbs, itemsvs = {}, {}, {}
	for i = 1, 6 do
		local itemstat = vgui.Create("DLabel", viewer)//创建物品介绍
		itemstat:SetFont("ZSBodyTextFont")//设置物品介绍字体
		itemstat:SetTextColor(COLOR_GRAY)//设置物品介绍颜色
		itemstat:SetWide(viewer:GetWide() * 0.35)//设置物品介绍宽度
		itemstat:SetText("")//
		itemstat:CenterHorizontal(0.2)//设置物品介绍位置
		itemstat:SetContentAlignment(8)//设置物品介绍对齐方式,8是顶部居中
		itemstat:MoveBelow(i == 1 and vbg or itemstats[i-1], (i == 1 and 100 or 8) * screenscale)//设置物品介绍位置
		table.insert(itemstats, itemstat)//插入物品介绍

		local itemsb = vgui.Create("ZSItemStatBar", viewer)//创建物品状态条
		itemsb:SetWide(viewer:GetWide() * 0.35)//设置物品状态条宽度
		itemsb:SetTall(8 * screenscale)//设置物品状态条高度
		itemsb:CenterHorizontal(0.55)//设置物品状态条位置
		itemsb:SetVisible(false)//设置物品状态条不可见
		itemsb:MoveBelow(i == 1 and vbg or itemstats[i-1], ((i == 1 and 100 or 8) + 6) * screenscale)//设置物品状态条位置
		table.insert(itemsbs, itemsb)//插入物品状态条

		local itemsv = vgui.Create("DLabel", viewer)//创建物品介绍的值
		itemsv:SetFont("ZSBodyTextFont")//设置物品介绍字体
		itemsv:SetTextColor(COLOR_GRAY)//设置物品介绍颜色
		itemsv:SetWide(viewer:GetWide() * 0.3)
		itemsv:SetText("")
		itemsv:CenterHorizontal(0.85)//设置物品介绍位置
		itemsv:SetContentAlignment(8)//设置物品介绍对齐方式,8是顶部居中
		itemsv:MoveBelow(i == 1 and vbg or itemstats[i-1], (i == 1 and 100 or 8) * screenscale)//设置物品介绍位置
		table.insert(itemsvs, itemsv)
	end
	viewer.ItemStats = itemstats
	viewer.ItemStatValues = itemsvs
	viewer.ItemStatBars = itemsbs
end
-------------------我是分割线-------------------
MENU_POINTSHOP = 1//点数商店状态为1
MENU_WORTH = 2//初始商店状态为2
MENU_REMANTLER = 3//改造机状态为3

function GM:CreateItemInfoViewer(frame, propertysheet, topspace, bottomspace, menutype)//创建物品信息预览,参数为框架,属性表,顶部空间,底部空间,菜单类型
	local __, topy = topspace:GetPos()//获取顶部空间的位置
	local ___, boty = bottomspace:GetPos()//获取底部空间的位置
	local screenscale = BetterScreenScale()//获取屏幕比例

	local worthmenu = menutype == MENU_WORTH//判断菜单类型是否为初始商店
	local remantler = menutype == MENU_REMANTLER//判断菜单类型是否为改造机

	local viewer = vgui.Create("DPanel", frame)//创建预览面板

	viewer:SetPaintBackground(false)//设置预览面板不绘制背景
	viewer:SetSize(//设置预览面板大小
		remantler and 320 * screenscale//如果是改造机,设置大小为320
			or frame:GetWide() - propertysheet:GetWide() + (worthmenu and 312 or -16) * screenscale,//如果是初始商店,设置大小为框架宽度-属性表宽度+312
		boty - topy - 8 - topspace:GetTall() - (worthmenu and 32 or 0)//设置预览面板高度,底部空间位置-顶部空间位置-8-顶部空间高度-32
	)

	viewer:MoveBelow(topspace, 4 + (worthmenu and 32 or 0))//设置预览面板位置,顶部空间下方4个像素+32,如果是初始商店,则+32
	if menutype == MENU_POINTSHOP or worthmenu then//如果是点数商店或者初始商店
		viewer:MoveRightOf(propertysheet, 8 - (worthmenu and 328 or 0) * screenscale)//设置预览面板位置,属性表右侧8-如果是初始商店,则-328
	else
		viewer:Dock(RIGHT)//设置预览面板停靠在右侧
	end
	frame.Viewer = viewer//设置框架的预览面板为预览面板

	self:CreateItemViewerGenericElems(viewer)//创建物品预览的通用元素

	local purchaseb = vgui.Create("DButton", viewer)//创建购买按钮
	purchaseb:SetText("")//设置购买按钮文本
	purchaseb:SetSize(viewer:GetWide() / 2, 54 * screenscale)//设置购买按钮大小
	purchaseb:SetVisible(false)//设置购买按钮不可见
	viewer.m_PurchaseB = purchaseb//设置预览面板的购买按钮为购买按钮

	local namelab = EasyLabel(purchaseb, "Purchase", "ZSBodyTextFontBig", COLOR_WHITE)//创建购买按钮的文本
	namelab:SetVisible(false)//设置购买按钮的文本不可见
	viewer.m_PurchaseLabel = namelab//设置预览面板的购买按钮文本为购买按钮的文本

	local pricelab = EasyLabel(purchaseb, "", "ZSBodyTextFont", COLOR_WHITE)//创建购买按钮的价格文本
	pricelab:SetVisible(false)//设置购买按钮的价格文本不可见
	viewer.m_PurchasePrice = pricelab//设置预览面板的购买按钮价格文本为购买按钮的价格文本

	local ammopb = vgui.Create("DButton", viewer)//创建弹药购买按钮
	ammopb:SetText("")//设置弹药购买按钮文本
	ammopb:SetSize(viewer:GetWide() / 4, 54 * screenscale)//设置弹药购买按钮大小
	ammopb:SetVisible(false)//设置弹药购买按钮不可见
	viewer.m_AmmoB = ammopb//设置预览面板的弹药购买按钮为弹药购买按钮

	namelab = EasyLabel(ammopb, "弹药", "ZSBodyTextFontBig", COLOR_WHITE)//创建弹药购买按钮的文本
	namelab:SetVisible(false)//设置弹药购买按钮的文本不可见
	viewer.m_AmmoL = namelab//设置预览面板的弹药购买按钮文本为弹药购买按钮的文本

	pricelab = EasyLabel(ammopb, "", "ZSBodyTextFont", COLOR_WHITE)//创建弹药购买按钮的价格文本
	pricelab:SetVisible(false)//设置弹药购买按钮的价格文本不可见
	viewer.m_AmmoPrice = pricelab//设置预览面板的弹药购买按钮价格文本为弹药购买按钮的价格文本
end

function GM:OpenArsenalMenu()//打开军火库菜单
	if self.ArsenalInterface and self.ArsenalInterface:IsValid() then//如果军火库菜单存在
		self.ArsenalInterface:SetVisible(true)//设置军火库菜单可见
		self.ArsenalInterface:CenterMouse()//设置军火库菜单鼠标居中
		return
	end

	local screenscale = BetterScreenScale()//获取屏幕比例
	local wid, hei = math.min(ScrW(), 900) * screenscale * 1.5, math.min(ScrH(), 800) * screenscale//设置宽度和高度
	local tabhei = 24 * screenscale//设置标签高度

	local frame = vgui.Create("DFrame")//创建框架
	frame:SetSize(wid, hei)//设置框架大小
	frame:Center()//设置框架居中
	frame:SetDeleteOnClose(false)//设置框架关闭时不删除
	frame:SetTitle("")//设置框架标题
	frame:SetDraggable(false)//设置框架不可拖动
	if frame.btnClose and frame.btnClose:IsValid() then frame.btnClose:SetVisible(false) end//设置框架关闭按钮不可见
	if frame.btnMinim and frame.btnMinim:IsValid() then frame.btnMinim:SetVisible(false) end//设置框架最小化按钮不可见
	if frame.btnMaxim and frame.btnMaxim:IsValid() then frame.btnMaxim:SetVisible(false) end//设置框架最大化按钮不可见
	frame.CenterMouse = ArsenalMenuCenterMouse//设置框架鼠标居中函数
	frame.Think = ArsenalMenuThink//设置框架Think函数
	self.ArsenalInterface = frame//设置军火库菜单为框架
	-------------------我是分割线-------------------
	--[[
		商店顶部那个大标题
	]]
	local topspace = vgui.Create("DPanel", frame)//创建顶部面板
	topspace:SetWide(wid - 16)

	local title = EasyLabel(topspace, "The Points Shop", "ZSHUDFontSmall", COLOR_WHITE)//创建标题
	title:CenterHorizontal()
	local subtitle = EasyLabel(topspace, "For all of your zombie apocalypse needs!", "ZSHUDFontTiny", COLOR_WHITE)//创建副标题
	subtitle:CenterHorizontal()//设置副标题居中
	subtitle:MoveBelow(title, 4)//设置副标题在标题下方4像素

	local _, y = subtitle:GetPos()//获取副标题的位置
	topspace:SetTall(y + subtitle:GetTall() + 4)//设置顶部面板的高度
	topspace:AlignTop(8)//设置顶部面板的顶部对齐
	topspace:CenterHorizontal()//设置顶部面板居中

	local wsb = EasyButton(topspace, "Worth Menu", 8, 4)//创建初始菜单按钮
	wsb:SetFont("ZSHUDFontSmaller")//设置初始菜单按钮字体
	wsb:SizeToContents()//设置初始菜单按钮大小
	wsb:AlignRight(8)//设置初始菜单按钮右对齐
	wsb:AlignTop(8)//设置初始菜单按钮顶部对齐
	wsb.DoClick = worthmenuDoClick//设置初始菜单按钮点击函数

	local bottomspace = vgui.Create("DPanel", frame)//创建底部面板
	bottomspace:SetWide(topspace:GetWide())
	-------------------我是分割线-------------------
	local pointslabel = EasyLabel(bottomspace, "Points to spend: 0", "ZSHUDFontTiny", COLOR_GREEN)//创建点数标签
	pointslabel:AlignTop(4)//设置点数标签顶部对齐
	pointslabel:AlignLeft(8)//设置点数标签左对齐
	pointslabel.Think = pointslabelThink

	local lab = EasyLabel(bottomspace, " ", "ZSHUDFontTiny")//创建空格标签
	lab:AlignTop(4)//设置空格标签顶部对齐
	lab:AlignRight(4)//设置空格标签右对齐
	frame.m_SpacerBottomLabel = lab//设置框架的底部空格标签为空格标签

	_, y = lab:GetPos()
	bottomspace:SetTall(y + lab:GetTall() + 4)
	bottomspace:AlignBottom(8)
	bottomspace:CenterHorizontal()

	local __, topy = topspace:GetPos()//获取顶部空间的位置
	local ___, boty = bottomspace:GetPos()//获取底部空间的位置
	--[[
		一个面向选项卡的控件，您可以在其中创建包含项的多个选项卡。主要用于组织。
		设置大小
		将面板放置在具有指定偏移的传递面板下方。
	]]
	local propertysheet = vgui.Create("DPropertySheet", frame)//创建属性表
	propertysheet:SetSize(wid - 320 * screenscale, boty - topy - 8 - topspace:GetTall())//设置属性表大小
	propertysheet:MoveBelow(topspace, 4)--将面板放置在具有指定偏移的传递面板下方。这里是距离顶部空间4个数字偏移量
	propertysheet:SetPadding(1)//设置面板的填充
	propertysheet:CenterHorizontal(0.33)//设置面板的水平居中,0.33是偏移量	

	for catid, catname in ipairs(GAMEMODE.ItemCategories) do//遍历物品分类
		local hasitems = false//是否有物品
		for i, tab in ipairs(GAMEMODE.Items) do//遍历物品
			if tab.Category == catid and tab.PointShop then//如果物品分类等于catid并且物品在点数商店
				hasitems = true//有物品
				break//跳出循环
			end
		end

		if hasitems then//如果有物品
			local tabpane = vgui.Create("DPanel", propertysheet)//创建面板
			tabpane.Paint = function() end//设置面板的绘制函数为空
			tabpane.Grids = {}//设置面板的网格为空
			tabpane.Buttons = {}//设置面板的按钮为空
			//设置传输的tabpane的位置
			--tabpane:SetPos(50, 30)//设置面板的位置
			local usecats = catid == ITEMCAT_GUNS or catid == ITEMCAT_MELEE or catid == ITEMCAT_TRINKETS//是否使用物品分类,如果是枪械或者近战或者饰品
			local trinkets = catid == ITEMCAT_TRINKETS//是否是饰品
			local offset = 64 * screenscale --内容显示列表距离阶级垂直距离，数字越大里的越远，正数是往下移，负数往上
			-------------------我是分割线-------------------
			local itemframe = vgui.Create("DScrollPanel", tabpane)//创建滚动面板
			itemframe:SetSize(propertysheet:GetWide(), propertysheet:GetTall() - (usecats and (32 + offset) or 32))//设置滚动面板大小
			itemframe:SetPos(0, usecats and offset or 0)//设置滚动面板位置

			local mkgrid = function()//创建网格函数
				local list = vgui.Create("DGrid", itemframe)//创建网格
				list:SetPos(0, 0)--距离左侧位置
				list:SetSize(propertysheet:GetWide() - 312, propertysheet:GetTall())//设置网格大小
				list:SetCols(2)--列数
				list:SetColWide(280 * screenscale)--每一列的宽度
				list:SetRowHeight((trinkets and 64 or 100) * screenscale)--每一列的宽度

				return list
			end
			-------------------我是分割线-------------------
			--内容具体显示
			local subcats = GAMEMODE.ItemSubCategories//获取物品子分类
			if usecats then//如果使用物品分类
				local ind, tbn = 1//设置ind为1,tbn为空
				for i = ind, (trinkets and #subcats or 5) do//遍历物品子分类,如果是饰品就遍历物品子分类的长度,否则遍历6次
					local ispacer = trinkets and ((i-1) % 3)+1 or i//如果是饰品就设置ispacer为i-1的余数+1,否则设置ispacer为i
					local start = i == (catid == ITEMCAT_GUNS and 2 or ind)//如果i等于枪械就设置start为2,否则设置start为ind

					tbn = EasyButton(tabpane, trinkets and subcats[i] or ("Tier " .. i), 2, 6)--//创建按钮
					tbn:SetFont(trinkets and "ZSHUDFontSmallest" or "ZSHUDFontSmall")//设置字体
					tbn:SetAlpha(start and 255 or 70)//设置透明度
					tbn:AlignRight((trinkets and -35 or -15) * screenscale -
						(ispacer - ind) * (ind == 1 and (trinkets and 190 or 110) or 145) * screenscale//设置按钮距离右侧的位置,如果是饰品就设置-120,否则设置-100,然后减去ispacer-ind乘以ind==1的结果,如果是饰品就设置190,否则设置110,否则设置145,然后乘以屏幕比例
					)--顶部得阶级属性，距离边缘左侧的位置
					--[[
					tbn:AlignRight((trinkets and -35 or -15) * screenscale -
						(ispacer - ind) * (ind == 1 and (trinkets and 190 or 110) or 145) * screenscale
					)
					]]
					tbn:AlignTop(trinkets and i <= 3 and 0 or trinkets and 28 or 16)//设置按钮距离顶部的位置,如果是饰品并且i小于等于3就设置为0,否则如果是饰品就设置为28,否则设置为16
					tbn:SetContentAlignment(5)//设置按钮的对齐方式
					tbn:SizeToContents()//设置按钮大小
					tbn.DoClick = function(me)//按钮点击事件
						for k, v in pairs(tabpane.Grids) do//遍历网格
							v:SetVisible(k == i)//设置网格是否可见
							tabpane.Buttons[k]:SetAlpha(k == i and 255 or 70)//设置按钮透明度
						end//遍历结束
					end

					tabpane.Grids[i] = mkgrid()//创建网格
					tabpane.Grids[i]:SetVisible(start)//设置网格是否可见
					tabpane.Buttons[i] = tbn//设置按钮
				end
			else
				tabpane.Grid = mkgrid()//创建网格
			end
			--这个是阶级和内容列表整体移动--

			local sheet = propertysheet:AddSheet(catname, tabpane, GAMEMODE.ItemCategoryIcons[catid], false, false)//添加标签,设置标签名字,设置标签面板,设置标签图标,设置是否可关闭,设置是否可活动
			sheet.Panel:SetPos(0, tabhei + 2)//设置标签面板位置
			-----分割线-----
			for i, tab in ipairs(GAMEMODE.Items) do//遍历物品
				if tab.PointShop and tab.Category == catid then//如果物品是商店物品并且物品分类等于catid
					self:AddShopItem(
						trinkets and tabpane.Grids[tab.SubCategory] or tabpane.Grid or tabpane.Grids[tab.Tier or 1],//如果是饰品就设置网格为tabpane.Grids[tab.SubCategory],否则设置网格为tabpane.Grid或者tabpane.Grids[tab.Tier或者1]
						i, tab
					)
				end
			end

			local scroller = propertysheet:GetChildren()[1]//获取滚动面板的子控件
			local dragbase = scroller:GetChildren()[1]//获取滚动面板的子控件的子控件
			local tabs = dragbase:GetChildren()//获取滚动面板的子控件的子控件的子控件

			self:ConfigureMenuTabs(tabs, tabhei)////设置标签的位置
		end
	end

	self:CreateItemInfoViewer(frame, propertysheet, topspace, bottomspace, MENU_POINTSHOP)//创建物品信息查看器

	frame:MakePopup()//使窗口可见
	frame:CenterMouse()//使鼠标居中
end
