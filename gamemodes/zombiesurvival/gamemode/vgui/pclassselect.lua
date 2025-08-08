//描述：僵尸选择界面，即按下F3后出现的界面
//注释状态：已完成，
CreateClientConVar("zs_bossclass", "", true, true)//创建客户端变量,第一个参数为变量名,第二个参数为默认值,第三个参数为是否保存,第四个参数为是否只能由服务器修改

local Window//窗口
local HoveredClassWindow//悬停窗口

local function CreateHoveredClassWindow(classtable)//创建悬停窗口
	if HoveredClassWindow and HoveredClassWindow:IsValid() then//如果悬停窗口存在且有效
		HoveredClassWindow:Remove()//移除悬停窗口
	end

	HoveredClassWindow = vgui.Create("ClassInfo")//创建悬停窗口
	HoveredClassWindow:SetSize(ScrW() * 0.5, 128)//设置大小,即宽度为屏幕宽度的一半,高度为128像素
	HoveredClassWindow:CenterHorizontal()//水平居中
	HoveredClassWindow:MoveBelow(Window, 32)//移动到窗口下方32像素
	HoveredClassWindow:SetClassTable(classtable)//设置类,即设置显示的类
end

function GM:OpenClassSelect()//打开选择界面
	if Window and Window:IsValid() then Window:Remove() end

	Window = vgui.Create("ClassSelect")//创建选择界面
	Window:SetAlpha(0)//设置透明度
	Window:AlphaTo(255, 0.1)//透明度渐变

	Window:MakePopup()//聚焦面板并使其能够接收输入。也就是允许调用玩家的鼠标。

	Window:InvalidateLayout()//使面板在下一帧中重新布局。在布局过程中，将在目标面板上调用 PANEL：PerformLayout。也就是重新排版。

	PlayMenuOpenSound()//播放菜单打开音效
end

local PANEL = {}//面板

PANEL.Rows = 2//行数

local bossmode = false//是否为boss模式
local function BossTypeDoClick(self)//点击按钮
	bossmode = not bossmode//切换模式
	GAMEMODE:OpenClassSelect()//打开选择界面
end

function PANEL:Init()//初始化
	self.ClassButtons = {}//按钮列表

	self.ClassTypeButton = EasyButton(nil, translate.Get(bossmode and "zombieselect_OpenZombiePanel" or "zombieselect_OpenBossPanel"), 8, 4)

	self.ClassTypeButton:SetFont("ZSHUDFontSmall")  -- 设置字体
	self.ClassTypeButton:SizeToContents()  -- 自适应大小
	self.ClassTypeButton.DoClick = BossTypeDoClick  -- 设置点击事件
	
	self.CloseButton = EasyButton(nil, translate.Get("zombieselect_Close"), 8, 4)  -- 关闭按钮
	
	self.CloseButton:SetFont("ZSHUDFontSmall")
	self.CloseButton:SizeToContents()
	self.CloseButton.DoClick = function() Window:Remove() end

	self.ButtonGrid = vgui.Create("DGrid", self)//创建网格,第一个参数为父窗口,即ClassSelect窗口,第二个参数为网格列数
	self.ButtonGrid:SetContentAlignment(5)//设置对齐方式,即居中
	self.ButtonGrid:Dock(FILL)//填充父窗口,即填充ClassSelect窗口
	local already_added = {}//已添加的按钮
	local use_better_versions = GAMEMODE:ShouldUseBetterVersionSystem()//是否使用更好的版本系统

	for i=1, #GAMEMODE.ZombieClasses do //遍历僵尸类
		local classtab = GAMEMODE.ZombieClasses[GAMEMODE:GetBestAvailableZombieClass(i)]//获取僵尸类

		if classtab and not classtab.Disabled and not already_added[classtab.Index] then//如果存在且未添加,则添加,否则跳过
			already_added[classtab.Index] = true//标记为已添加

			local ok//是否可用
			if bossmode then//如果为boss模式
				ok = classtab.Boss//如果为boss类,则可用
			else//如果为僵尸模式
				ok = not classtab.Boss and//如果不为boss类
					(not classtab.Hidden or classtab.CanUse and classtab:CanUse(MySelf)) and//如果未隐藏或可用
					(not GAMEMODE.ObjectiveMap or classtab.Unlocked)//如果不为目标地图或已解锁
			end

			if ok then//如果可用
				if not use_better_versions or not classtab.BetterVersionOf or GAMEMODE:IsClassUnlocked(classtab.Index) then//如果不使用更好的版本系统或不为更好的版本或已解锁
					local button = vgui.Create("ClassButton")//创建按钮
					button:SetClassTable(classtab)//设置按钮类
					button.Wave = classtab.Wave or 1//设置按钮波数

					table.insert(self.ClassButtons, button)//添加到按钮列表,用于排序

					self.ButtonGrid:AddItem(button)//添加到网格,用于显示
				end
			end
		end
	end

	self.ButtonGrid:SortByMember("Wave")//按照波数排序,即按照按钮的Wave属性排序
	self:InvalidateLayout()//使面板在下一帧中重新布局。在布局过程中，将在目标面板上调用 PANEL：PerformLayout。
end

function PANEL:PerformLayout()//布局
	if #self.ClassButtons < 8 then self.Rows = 1 end//如果按钮数量小于8,则行数为1,否则为2

	local cols = math.ceil(#self.ClassButtons / self.Rows)//列数为按钮数量除以行数向上取整,即每行按钮数量
	local cell_size = ScrW() / cols//每个按钮的大小
	cell_size = math.min(ScrW() / 7, cell_size)//最小为屏幕宽度的1/7

	self:SetSize(ScrW(), self.Rows * cell_size)//设置大小,即宽度为屏幕宽度,高度为行数乘以每个按钮的大小
	self:CenterHorizontal()//水平居中
	self:CenterVertical(0.35)//垂直居中,即屏幕高度的0.35倍

	self.ClassTypeButton:MoveAbove(self, 16)//移动到上方16像素,即与上方按钮间距为16像素
	self.ClassTypeButton:CenterHorizontal()//水平居中

	self.CloseButton:MoveAbove(self, 16)//移动到上方16像素,即与上方按钮间距为16像素
	self.CloseButton:CenterHorizontal(0.9)//水平居中,即屏幕宽度的0.9倍
	self.ButtonGrid:SetCols(cols)//设置列数,即每行按钮数量
	self.ButtonGrid:SetColWide(cell_size)//设置每列宽度,即每个按钮的大小
	self.ButtonGrid:SetRowHeight(cell_size)//设置每行高度,即每个按钮的大小
end

function PANEL:OnRemove()//移除
	self.ClassTypeButton:Remove()//移除按钮,也就是原版屏幕上面的按钮 --具体查看
	self.CloseButton:Remove()//移除按钮,即右边的关闭按钮 --图片里面的2号按钮
end

local texUpEdge = surface.GetTextureID("gui/gradient_up")////底部往上渐变 
local texDownEdge = surface.GetTextureID("gui/gradient_down")////顶部往下渐变
function PANEL:Paint()//绘制
	local wid, hei = self:GetSize()//获取大小,即宽度和高度
	local edgesize = 16//边缘大小

	DisableClipping(true)//启用或禁用 VGUI 使用的剪裁，将绘图操作限制为面板边界。如果启用剪裁，则在面板边界之外的任何绘图操作都将被忽略。如果禁用剪裁，则可以在面板边界之外绘制。
	surface.SetDrawColor(Color(0, 0, 0, 220))//设置绘制颜色,即黑色
	surface.DrawRect(0, 0, wid, hei)//绘制矩形,即黑色矩形
	surface.SetTexture(texUpEdge)//设置纹理,即底部往上渐变
	surface.DrawTexturedRect(0, -edgesize, wid, edgesize)//绘制纹理,即底部往上渐变
	surface.SetTexture(texDownEdge)//设置纹理,即顶部往下渐变
	surface.DrawTexturedRect(0, hei, wid, edgesize)//绘制纹理,即顶部往下渐变
	DisableClipping(false)//启用或禁用 VGUI 使用的剪裁，将绘图操作限制为面板边界。如果启用剪裁，则在面板边界之外的任何绘图操作都将被忽略。如果禁用剪裁，则可以在面板边界之外绘制。这里被设置为了可以在面板外面绘制

	return true
end

vgui.Register("ClassSelect", PANEL, "Panel")//注册面板,即注册这个面板,面板名为ClassSelect,面板继承自Panel

//描述：ClassButton类，这个就是用来创建选择僵尸的那个按钮
PANEL = {}//面板

function PANEL:Init()//初始化
	self:SetMouseInputEnabled(true)//设置鼠标输入为true,启用或禁用面板的鼠标输入。如果禁用鼠标输入，则面板将不会接收鼠标事件（例如鼠标悬停，点击等）。
	self:SetContentAlignment(5)//设置内容对齐方式,即居中

	self.NameLabel = vgui.Create("DLabel", self)//创建一个标签,即文本,父面板为自己
	self.NameLabel:SetFont("ZSHUDFontSmaller")//设置字体
	self.NameLabel:SetAlpha(170)//设置透明度

	self.Image = vgui.Create("DImage", self)//创建一个图片,父面板为自己

	self:InvalidateLayout()//使面板在下一帧中重新布局。应避免每帧都调用此函数。如果为 true，面板将立即重新布局，而不是等待下一帧
end

function PANEL:PerformLayout()//布局,即设置大小和位置
	local cell_size = self:GetParent():GetColWide()//获取父面板的每列宽度,即每个按钮的大小

	self:SetSize(cell_size, cell_size)//设置大小,即每个按钮的大小

	self.Image:SetSize(cell_size * 0.75, cell_size * 0.75)//设置大小,即图片大小
	self.Image:AlignTop(8)//顶部对齐,即与上方间距为8像素
	self.Image:CenterHorizontal()//水平居中

	self.NameLabel:SizeToContents()////设置大小,即文本大小
	self.NameLabel:AlignBottom(8)//底部对齐,即与下方间距为8像素
	self.NameLabel:CenterHorizontal()//水平居中
end

function PANEL:SetClassTable(classtable)//设置类表
	self.ClassTable = classtable//设置类表

	local len = #translate.Get(classtable.TranslationName)//获取长度,即获取翻译后的类名的长度

	self.NameLabel:SetText(translate.Get(classtable.TranslationName))//设置文本,即设置类名
	self.NameLabel:SetFont(len > 15 and "ZSHUDFontTiny" or len > 11 and "ZSHUDFontSmallest" or "ZSHUDFontSmaller")//设置字体,即设置字体大小,如果长度大于15,则设置为ZSHUDFontTiny,如果长度大于11,则设置为ZSHUDFontSmallest,否则设置为ZSHUDFontSmaller

	self.Image:SetImage(classtable.Icon)//设置图片,即设置图片
	self.Image:SetImageColor(classtable.IconColor or color_white)//设置图片颜色,即设置图片颜色,如果没有设置图片颜色,则设置为白色

	self:InvalidateLayout()//使面板在下一帧中重新布局。应避免每帧都调用此函数。如果为 true，面板将立即重新布局，而不是等待下一帧
end

function PANEL:DoClick()//点击
	if self.ClassTable then//如果类表存在
		if self.ClassTable.Boss then//如果是boss
			RunConsoleCommand("zs_bossclass", self.ClassTable.Name)//运行控制台命令,即设置boss类
			GAMEMODE:CenterNotify(translate.Format("boss_class_select", self.ClassTable.Name))//中心通知,即设置boss类,并翻译
		else//如果不是boss
			net.Start("zs_changeclass")//发送网络消息,即改变类
				net.WriteString(self.ClassTable.Name)//发送字符串,即发送类名
				net.WriteBool(GAMEMODE.SuicideOnChangeClass)//发送布尔值,即是否自杀
			net.SendToServer()//发送到服务器
		end
	end

	surface.PlaySound("buttons/button15.wav")//播放音效

	Window:Remove()//移除窗口
	bossmode = false//boss模式为false
end

function PANEL:Paint()
	return true
end

function PANEL:OnCursorEntered()//鼠标进入
	self.NameLabel:SetAlpha(230)//设置透明度

	CreateHoveredClassWindow(self.ClassTable)//创建悬停类窗口,即创建悬停类窗口,传入类表
end

function PANEL:OnCursorExited()//鼠标退出
	self.NameLabel:SetAlpha(170)//设置透明度

	if HoveredClassWindow and HoveredClassWindow:IsValid() and HoveredClassWindow.ClassTable == self.ClassTable then//如果悬停类窗口存在,并且有效,并且悬停类窗口的类表等于自己的类表
		HoveredClassWindow:Remove()//移除悬停类窗口
	end
end

function PANEL:Think()//即每帧调用
	if not self.ClassTable then return end//如果类表不存在,则返回并结束

	local enabled//是否启用
	if MySelf:GetZombieClass() == self.ClassTable.Index then//如果自己的僵尸类等于类表的索引
		enabled = 2
	elseif self.ClassTable.Boss or gamemode.Call("IsClassUnlocked", self.ClassTable.Index) then//如果是boss,或者调用函数,即是否解锁,传入类表的索引
		enabled = 1
	else
		enabled = 0
	end

	if enabled ~= self.LastEnabledState then//如果当前是否启用的值不等于上一次是否启用的值，则执行某些操作。
		self.LastEnabledState = enabled//设置上一次的是否启用为是否启用

		if enabled == 2 then//如果是否启用为2,也就是自己的僵尸类等于类表的索引
			self.NameLabel:SetTextColor(COLOR_GREEN)//设置文本颜色,即设置为绿色
			self.Image:SetImageColor(self.ClassTable.IconColor or color_white)//设置图片颜色,即设置为类表的图片颜色,如果没有设置图片颜色,则设置为白色
			self.Image:SetAlpha(245)//设置透明度
		elseif enabled == 1 then//如果是否启用为1,也就是是boss,或者调用函数,即是否解锁,传入类表的索引
			self.NameLabel:SetTextColor(COLOR_GRAY)//设置文本颜色,即设置为灰色
			self.Image:SetImageColor(self.ClassTable.IconColor or color_white)//设置图片颜色,即设置为类表的图片颜色,如果没有设置图片颜色,则设置为白色
			self.Image:SetAlpha(245)
		else
			self.NameLabel:SetTextColor(COLOR_DARKRED)
			self.Image:SetImageColor(COLOR_DARKRED)
			self.Image:SetAlpha(170)
		end
	end
end

vgui.Register("ClassButton", PANEL, "Button")//注册类按钮,即注册面板,继承按钮

PANEL = {}

function PANEL:Init()
	self.NameLabel = vgui.Create("DLabel", self)
	self.NameLabel:SetFont("ZSHUDFontSmaller")

	self.DescLabels = self.DescLabels or {}

	self:InvalidateLayout()
end

function PANEL:SetClassTable(classtable)//设置类表,设置僵尸描述窗口的类表
	self.ClassTable = classtable

	self.NameLabel:SetText(translate.Get(classtable.TranslationName))//设置文本,即设置文本为类表的翻译名
	self.NameLabel:SizeToContents()//使标签的大小适合其内容

	self:CreateDescLabels()//创建僵尸描述标签

	self:InvalidateLayout()//使面板在下一帧中重新布局。应避免每帧都调用此函数。如果为 true，面板将立即重新布局，而不是等待下一帧
end

function PANEL:RemoveDescLabels()//移除僵尸描述标签
	for _, label in pairs(self.DescLabels) do
		label:Remove()
	end

	self.DescLabels = {}
end


function PANEL:CreateDescLabels()//僵尸描述标签
	self:RemoveDescLabels()//移除僵尸描述标签

	self.DescLabels = {}

	local classtable = self.ClassTable//类表
	if not classtable or not classtable.Description then return end//如果类表不存在,或者类表的描述不存在,则返回并结束

	local lines = {}//行

	if classtable.Wave and classtable.Wave > 0 then//如果僵尸的波数存在,并且大于0
		table.insert(lines, translate.Format("unlocked_on_wave_x", classtable.Wave))//插入行,即插入解锁在波数x,传入类表的波数
	end

	if classtable.BetterVersion then//如果僵尸有更好的版本存在，也就是进化后的僵尸版本
		local betterclasstable = GAMEMODE.ZombieClasses[classtable.BetterVersion]//获取更好的僵尸类表
		if betterclasstable then
			table.insert(lines, translate.Format("evolves_in_to_x_on_wave_y", betterclasstable.Wave,betterclasstable.Name))//插入行,即插入在波数y进化为x(请根据你服务器的evolves_in_to_x_on_wave_y的参数具体设置),传入更好的僵尸类表的名字和波数,也就是进化后的僵尸版本的名字和波数
		end
	end

	table.insert(lines, " ")//插入行,即插入空行
	table.Add(lines, string.Explode("\n", translate.Get(classtable.Description)))//插入行,即插入翻译的类表的描述

	if classtable.Help then//如果类表的帮助存在
		table.insert(lines, " ")//插入行,即插入空行
		table.Add(lines, string.Explode("\n", translate.Get(classtable.Help)))//插入行,即插入翻译的类表的帮助
	end

	for i, line in ipairs(lines) do//循环行
		local label = vgui.Create("DLabel", self)//创建标签
		local notwaveone = classtable.Wave and classtable.Wave > 0//如果僵尸的波数存在,并且大于0,

		label:SetText(line)//设置文本,即设置文本为行
		if i == (notwaveone and 2 or 1) and classtable.BetterVersion then//如果i等于2,并且有更好的僵尸版本存在,也就是进化后的僵尸版本,或者i等于1,并且有更好的僵尸版本存在,也就是进化后的僵尸版本
			label:SetColor(COLOR_RORANGE)//设置颜色,即设置为橙色
		end
		label:SetFont(i == 1 and notwaveone and "ZSBodyTextFontBig" or "ZSBodyTextFont")//设置字体,如果i等于1,并且僵尸的波数存在,并且大于0,则设置字体为ZSBodyTextFontBig,否则设置字体为ZSBodyTextFont
		label:SizeToContents()//使标签的大小适合其内容
		table.insert(self.DescLabels, label)//插入僵尸描述标签
	end
end

function PANEL:PerformLayout()//布局
	self.NameLabel:SizeToContents()//使标签的大小适合其内容
	self.NameLabel:CenterHorizontal()//使标签水平居中

	local maxw = self.NameLabel:GetWide()//获取标签的宽度
	for _, label in pairs(self.DescLabels) do//循环僵尸描述标签
		maxw = math.max(maxw, label:GetWide())//获取最大的宽度
	end
	self:SetWide(maxw + 64)//设置宽度
	self:CenterHorizontal()//使面板水平居中

	for i, label in ipairs(self.DescLabels) do//循环僵尸描述标签
		label:MoveBelow(self.DescLabels[i - 1] or self.NameLabel)//移动到下面,即移动到僵尸描述标签的上面
		label:CenterHorizontal()//使标签水平居中
	end

	local lastlabel = self.DescLabels[#self.DescLabels] or self.NameLabel//获取最后一个僵尸描述标签,或者获取标签
	local _, y = lastlabel:GetPos()//获取标签的位置,即获取标签的x,y坐标
	self:SetTall(y + lastlabel:GetTall())//设置高度
end

function PANEL:Think()
	if not Window or not Window:IsValid() or not Window:IsVisible() then
		self:Remove()
	end
end

function PANEL:Paint(w, h)
	derma.SkinHook("Paint", "Frame", self, w, h)

	return true
end

vgui.Register("ClassInfo", PANEL, "Panel")//注册面板,面板名字为ClassInfo,面板基类为Panel
