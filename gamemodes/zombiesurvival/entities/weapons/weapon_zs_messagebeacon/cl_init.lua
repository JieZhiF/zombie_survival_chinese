-- ============================================================================
-- weapon_zs_messagebeacon/cl_init.lua - 消息信标武器（客户端部分）
-- 负责：信标的栏位与准星设置，以及右键打开"选择信标消息"菜单
-- ============================================================================
INC_CLIENT() -- 客户端专用文件标记
-- 武器栏位：放入"可部署物品"分类
SWEP.Slot = GAMEMODE:GetWeaponSlot("WeaponSelectSlotDeployables")
-- 栏位组：可部署物品栏
SWEP.SlotGroup = WEPSELECT_DEPLOYABLES
SWEP.DrawCrosshair = false -- 不绘制准星（用屏幕中心点代替）

-- ==== Deploy - 武器展开时 ====
-- 通知游戏模式该武器已部署
function SWEP:Deploy()
	gamemode.Call("WeaponDeployed", self:GetOwner(), self)

	return true
end

-- ==== DrawHUD - 绘制 HUD 准星 ====
-- 仅当玩家开启了准星设置时，绘制屏幕中心的信标落点指示点
function SWEP:DrawHUD()
	if GetConVar("crosshair"):GetInt() ~= 1 then return end
	self:DrawCrosshairDot()
end

-- ==== PrimaryAttack - 左键（空实现） ====
-- 放置信标的实际逻辑由共享/服务器端处理
function SWEP:PrimaryAttack()
end

-- ==== DrawWeaponSelection - 武器选择界面图标 ====
-- 使用基础武器母本的默认绘制
function SWEP:DrawWeaponSelection(x, y, w, h, alpha)
	self:BaseDrawWeaponSelection(x, y, w, h, alpha)
end

-- ==== Think - 客户端思考帧（空实现） ====
function SWEP:Think()
end

-- ==== okclick - 点击"确定"按钮 ====
-- 把选中的消息编号通过控制台命令发给服务器，并关闭菜单
local function okclick(self)
	RunConsoleCommand("setmessagebeaconmessage", self:GetParent().Choice)
	self:GetParent():Close()
end

-- ==== onselect - 下拉框选中回调 ====
-- 记录玩家当前选择的信标消息编号
local function onselect(self, index, value, data)
	self:GetParent().Choice = data
end

local Menu -- 消息选择菜单的全局引用（菜单打开期间保持常驻）
-- ==== SecondaryAttack - 右键：打开/显示消息选择菜单 ====
function SWEP:SecondaryAttack()
	-- 菜单已存在则直接重新显示，不重复创建
	if Menu and Menu:IsValid() then
		Menu:SetVisible(true)
		return
	end

	-- 创建消息选择窗口
	Menu = vgui.Create("DFrame")
	Menu:SetDeleteOnClose(false) -- 关闭时不销毁，便于再次打开
	Menu:SetSize(200, 100)
	Menu:SetTitle("Select a message")
	Menu:Center()
	Menu.Choice = 1 -- 默认选择第一条消息

	-- 创建下拉框，列出游戏模式中所有合法的信标消息
	local choice = vgui.Create("DComboBox", Menu)
	for k, v in ipairs(GAMEMODE.ValidBeaconMessages) do
		choice:AddChoice(translate.Get(v), k)
	end
	choice:ChooseOption(GAMEMODE.ValidBeaconMessages[1], 1) -- 默认选中第一条
	choice:SizeToContents()
	choice:SetWide(Menu:GetWide() - 16)
	choice:Center()
	choice.OnSelect = onselect

	-- 创建"确定"按钮
	local ok = EasyButton(Menu, "OK", 8, 4)
	ok:AlignBottom(8)
	ok:CenterHorizontal()
	ok.DoClick = okclick

	Menu:MakePopup() -- 弹出并捕获输入焦点
end
