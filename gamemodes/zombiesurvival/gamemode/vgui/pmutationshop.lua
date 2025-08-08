//僵尸突变商店的界面
local TokensRemaining = 0//剩余的突变点数
local MutationButtons = {}//突变按钮
local function Checkout(tobuy)//购买突变
	if tobuy and #tobuy > 0 then//如果要购买的突变存在且数量大于0
		RunConsoleCommand("zs_mutationshop_click", unpack(tobuy))//发送购买突变的命令
		if pMutation and pMutation:Valid() then
			pMutation:Close()
		end
	else
		surface.PlaySound("buttons/combine_button_locked.wav")//播放按钮被锁定的音效
	end
end


local function CheckoutDoClick(self)//购买按钮的点击事件
	draw.SimpleText(translate.Get("mutation_Purchase"), "ZSHUDFontSmall", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	local tobuy = {}//要购买的突变

	for _, btn in pairs(MutationButtons) do//遍历突变按钮
		if btn and btn.On and btn.ID then//如果突变按钮存在且被选中
			table.insert(tobuy, btn.ID)//将突变按钮的ID加入要购买的突变
		end
	end//遍历结束
	Checkout(tobuy)//购买突变
end

function MakepMutationShop(used)
	if pMutation and pMutation:Valid() then//如果突变商店存在
		pMutation:Remove()//移除突变商店
		pMutation = nil
	end
	local BetterScreenScale = BetterScreenScale()//获取比例
	local maxtokens = math.floor(MySelf:GetTokens())//最大突变点数

	TokensRemaining = maxtokens
	local wid, hei = ScrW() * 0.61 * BetterScreenScale, ScrH() * 0.68 * BetterScreenScale//突变商店的宽度和高度

	local frame = vgui.Create("DFrame")//创建窗口
	pMutation = frame//设置突变商店的窗口
	frame:SetSize(wid, hei)//设置窗口的大小
	frame:SetDraggable(false)//禁用拖动窗口
	frame:SetDeleteOnClose(true)//关闭窗口时删除窗口
	frame:SetKeyboardInputEnabled(false)//禁用键盘输入
	frame:SetTitle("")//设置窗口的标题
	frame.Paint = function() draw.RoundedBox( 15, 0, 0, wid, hei, Color( 0, 0, 0, 150) ) end//绘制窗口的背景


	local title = EasyLabel(frame, translate.Get("mutation_MutationShop"), "ZSHUDFontSmaller", COLOR_WHITE) // 创建标题
	title:CenterHorizontal()
	local subtitle = EasyLabel(frame, translate.Get("mutation_ZombiesGetStronger"), "ZSHUDFontSmaller", COLOR_WHITE) // 创建副标题
	
	subtitle:CenterHorizontal()//设置副标题居中
	subtitle:MoveBelow(title, 4)//设置副标题在标题下方4像素
	local propertysheet = vgui.Create("DPropertySheet", frame)//创建属性表
	propertysheet:StretchToParent(4, 60, 450, 50)//设置属性表的位置
	--propertysheet:StretchToParent(4, 24, 4, 50)//设置属性表的位置
	propertysheet.Paint = function() end//绘制属性表的背景

	local panfont = "ZSHUDFontSmall"//字体
	local panhei = 40//高度
	
	for catid, catname in ipairs(GAMEMODE.ItemCategories) do//遍历物品分类
		local hasitems = false//是否有物品
		for i, tab in ipairs(GAMEMODE.Mutations) do//遍历突变
			if tab.Category == catid and tab.MutationShop then//如果突变的分类与当前分类相同且突变商店存在
				hasitems = true//有物品
				break//跳出循环
			end
		end

		if hasitems then//如果有物品
			local list = vgui.Create("DPanelList", propertysheet)//创建列表
			list:SetPaintBackground(false)//绘制背景
			propertysheet:AddSheet(catname, list, GAMEMODE.ItemCategoryIcons[catid], false, false)//添加标签
			list:EnableVerticalScrollbar(true)//启用垂直滚动条
			list:SetWide(propertysheet:GetWide() - 16)//设置列表的宽度
			list:SetSpacing(2)//设置列表的间距
			list:SetPadding(2)//设置列表的填充

			for i, tab in ipairs(GAMEMODE.Mutations) do//遍历突变
				if tab.Category == catid and tab.MutationShop then//如果突变的分类与当前分类相同且突变商店存在
					local button = vgui.Create("ZSMutationButton")//创建突变按钮
					button:SetMutationID(i)//设置突变ID
					list:AddItem(button)//添加突变按钮
					MutationButtons[i] = button//设置突变按钮
					
				end
			end
		end
	end	



	local worthlab = EasyLabel(frame, translate.Get("mutationsdamagetokens")..": "..tostring(TokensRemaining), "ZSHUDFontSmall", COLOR_LIMEGREEN)//创建突变点数标签
	worthlab:SetPos(8, frame:GetTall() - worthlab:GetTall() - 8)//设置突变点数标签的位置
	frame.WorthLab = worthlab

	-- 创建一个容器
	local container = vgui.Create("DPanel", frame)
	container:SetName("containerName")
	container:SetSize(frame:GetWide() * 0.15 *BetterScreenScale, frame:GetTall() * 0.69 *BetterScreenScale)  -- 调整容器的大小以适应竖直排列
	container:SetPos(frame:GetWide() * 0.59 * BetterScreenScale, frame:GetTall() * 0.05 * BetterScreenScale)  -- 设置容器的位置
	container.Paint = function(self, w, h)  -- 设置容器的背景为黑色透明
		draw.RoundedBox(10, 0, 0, w, h, Color(0, 0, 0, 130))  -- 可以调整最后一个参数来改变透明度
	end

		
	local BuyFreame = vgui.Create("DPanel", container)//创建购买预览背景
	BuyFreame:SetSize(300, 50)//设置购买预览背景的大小
	BuyFreame:SetPos(container:GetWide() * 0.1*BetterScreenScale,container:GetTall()* 0.68 * BetterScreenScale)//设置购买预览背景的位置
	BuyFreame.Paint = function ()
		surface.SetDrawColor(0,0,0,190)
		surface.DrawOutlinedRect(0,0,BuyFreame:GetWide() * BetterScreenScale,BuyFreame:GetTall() * BetterScreenScale,1)
	end

	--BuyFreame:SetVisible(false)//隐藏购买预览背景

	local checkout = vgui.Create("DButton", BuyFreame)
	checkout:SetFont("ZSHUDFontSmall")
	checkout:SetText("")
	checkout:SizeToContents()
	checkout:SetSize(299, 48)
	checkout:SetPos((BuyFreame:GetWide() - checkout:GetWide()) / 2, (BuyFreame:GetTall() - checkout:GetTall()) / 2)  -- 设置购买按钮的位置在购买预览背景的中间
	checkout.Paint = function(self, w, h)
		surface.SetDrawColor(0, 0, 0, 150)
		surface.DrawRect(0, 0, w, h)
		draw.SimpleText(""..translate.Get("mutation_Purchase"), "ZSHUDFontSmall", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	checkout.DoClick = CheckoutDoClick

	local BuyIcon = vgui.Create("DImage", checkout)//创建购买图标
	BuyIcon:SetImage("zombiesurvival/zombieshopcart.png")//设置购买图标的图片
	BuyIcon:SetSize(64, 64)//设置购买图标的大小
	local IconWide,IconTall = BuyIcon:GetWide(),BuyIcon:GetTall()//获取购买图标的大小
	BuyIcon:SetPos(0 , -5)//设置购买图标的位置

	local viewname = vgui.Create("DLabel", container)
	viewname:SetName("viewname")
	viewname:SetFont("ZSHUDFontSmaller")
	viewname:SetWide(150 * BetterScreenScale)
	viewname:SetTall(70 * BetterScreenScale)
	viewname:SetTextColor(COLOR_WHITE)
	viewname:SetText("")
	local xPos = math.Round((container:GetWide() / 2) - (viewname:GetWide() / 2))
	viewname:CenterHorizontal(0.5)
	viewname:CenterVertical(0.5)
	viewname:SetPos(xPos, 0)
	

	-- 创建 itemDescription，并将其父级设置为容器
	local itemDescription = vgui.Create("DLabel", container)
	itemDescription:SetName("itemDescription")
	itemDescription:SetFont("ZSHUDFontSmallest")
	itemDescription:SetTextColor(COLOR_GRAY)
	itemDescription:SetMultiline(true)
	itemDescription:SetWrap(true)
	itemDescription:SetAutoStretchVertical(true)
	itemDescription:SetWide(300 * BetterScreenScale)
	itemDescription:SetTall(340 * BetterScreenScale)
	itemDescription:SetPos(0, 70)  -- 设置 itemDescription 的位置紧跟在 viewname 下面
	itemDescription:SetText("")


	frame:Center()//设置突变商店的位置
	frame:SetAlpha(0)//设置突变商店的透明度
	frame:AlphaTo(255, 0.5, 0)//设置突变商店的透明度,持续时间,延迟时间
	frame:MakePopup()//设置突变商店为弹出窗口
	return frame
end

function SetItemDescription(itemname, itemDescription)
    local ItemName = tostring(itemname)
    local ItemDescription = tostring(itemDescription)
    local container = nil
    -- 遍历 frame 的所有子级来找到 container
    for _, v in ipairs(pMutation:GetChildren()) do
        if v:GetName() == "containerName" then  -- 确保这里的 "containerName" 与你创建 container 时设置的名称相匹配
            container = v
            break
        end
    end
    
	if container then
		-- 遍历 container 的所有子级
		for _, v in ipairs(container:GetChildren()) do
			if v:GetName() == "viewname" then
				v:SetText(ItemName)
			elseif v:GetName() == "itemDescription" then
				v:SetText("" .. ItemDescription)  -- 在描述文本前添加两个空格
			end
		end
	end
end
	


local PANEL = {}
PANEL.m_ItemID = 0
PANEL.RefreshTime = 1
PANEL.NextRefresh = 0

function PANEL:Init()
	self:SetFont("DefaultFontSmall")
end

function PANEL:Think()
	if CurTime() >= self.NextRefresh then
		self.NextRefresh = CurTime() + self.RefreshTime
		self:Refresh()
	end
end

function PANEL:Refresh()
	local count = GAMEMODE:GetCurrentEquipmentCount(self:GetItemID())
	if count == 0 then
		self:SetText(" ")
	else
		self:SetText(count)
	end
	self:SizeToContents()
end

function PANEL:SetItemID(id) self.m_ItemID = id end
function PANEL:GetItemID() return self.m_ItemID end

vgui.Register("ItemAmountCounter", PANEL, "DLabel")

PANEL = {}

function PANEL:Init()
    self:SetText("")
    self:DockPadding(4, 4, 4, 4)
    self:SetTall(48)

    self.NameLabel = EasyLabel(self, "", "ZSHUDFontSmall")
    self.NameLabel:SetContentAlignment(4)
    self.NameLabel:Dock(FILL)
    self.NameLabel:DockMargin(4, 0, 0, 0)  -- 减小左边距

    self.PriceLabel = EasyLabel(self, "", "ZSHUDFontTiny")
    self.PriceLabel:SetWide(220 * BetterScreenScale())
    self.PriceLabel:SetContentAlignment(6)
    self.PriceLabel:Dock(RIGHT)
    self.PriceLabel:DockMargin(4, 0, 4, 0)  -- 减小左边距

    self:SetMutationID(nil)
end

function PANEL:SetMutationID(id)//设置突变ID
	self.ID = id

	local tab = FindMutation(id)//根据突变ID获取突变

	if not tab then//如果突变不存在
		self.NameLabel:SetText("")//设置突变名称为空
		return
	end
	
	for k,v in pairs(UsedMutations) do//遍历已经购买的突变
		if v == tab.Signature then//如果已经购买的突变的签名与当前突变的签名相同
			self.NameLabel:SetTextColor(COLOR_RED)//设置突变名称的颜色为红色
		end//结束判断
	end

	local mdl = tab.Model or (weapons.GetStored(tab.SWEP) or tab).WorldModel


	if tab.Worth then
		self.PriceLabel:SetText(tostring(tab.Worth).." "..translate.Get("mutationstokens"))
	else
		self.PriceLabel:SetText("")
	end

	self.NameLabel:SetText(tab.Name or "")
end

function PANEL:Paint(w, h)
	local outline
	
	if self.Hovered then
		outline = self.On and COLOR_GREEN or COLOR_GRAY
	else
		outline = self.On and COLOR_DARKGREEN or COLOR_DARKGRAY
	end

	draw.RoundedBox(8, 0, 0, w, h, outline)
	draw.RoundedBox(4, 4, 4, w - 8, h - 8, color_black)
end

function PANEL:DoClick(silent, force)
	local id = self.ID
	local tab = FindMutation(id)
	if not tab then return end
	
	if self.On then
		self.On = nil
		if not silent then
			surface.PlaySound("buttons/button18.wav")
		end
		TokensRemaining = TokensRemaining + tab.Worth
	else
		itemname = tab.Name
		itemDescription = tab.Description
		SetItemDescription(itemname,itemDescription)
		
		for k,v in pairs(UsedMutations) do
			if v == tab.Signature then
				surface.PlaySound("buttons/button8.wav")
				return
			end

		end

		
		
		if TokensRemaining < tab.Worth and not force then
			surface.PlaySound("buttons/button8.wav")
			return
		end
		
		
		self.On = true
		if not silent then
			surface.PlaySound("buttons/button17.wav")
		end
		TokensRemaining = TokensRemaining - tab.Worth
	end

	pMutation.WorthLab:SetText(translate.Get("mutationsdamagetokens")..": ".. TokensRemaining)
	if TokensRemaining <= 0 then
		pMutation.WorthLab:SetTextColor(COLOR_RED)
		pMutation.WorthLab:InvalidateLayout()
	elseif TokensRemaining <= MySelf:GetTokens() * 0.25 then
		pMutation.WorthLab:SetTextColor(COLOR_YELLOW)
		pMutation.WorthLab:InvalidateLayout()
	else
		pMutation.WorthLab:SetTextColor(COLOR_LIMEGREEN)
		pMutation.WorthLab:InvalidateLayout()
	end
	pMutation.WorthLab:SizeToContents()
end

vgui.Register("ZSMutationButton", PANEL, "DButton")
