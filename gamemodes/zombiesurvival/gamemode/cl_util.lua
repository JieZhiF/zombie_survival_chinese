-- ============================================================
-- cl_util.lua - 客户端辅助函数与控制台命令
-- 包含以下功能模块：
--   1. 调试命令（printdxinfo）
--   2. 弹药快速购买（zs_quickbuyammo）
--   3. 视图模型隐藏（DontDrawViewModel）
--   4. UI 缩放比例计算（BetterScreenScale）
--   5. 光照颜色获取（render.GetLightRGB）
--   6. VGUI 控件快捷创建（EasyLabel / EasyButton）
-- ============================================================

-- 添加 "printdxinfo" 控制台命令：打印客户端的 DirectX 支持信息到控制台
concommand.Add("printdxinfo", function()
	print("DX Level: "..tostring(render.GetDXLevel()))
	print("Supports HDR: "..tostring(render.SupportsHDR()))
	print("Supports Pixel Shaders 1.4: "..tostring(render.SupportsPixelShaders_1_4()))
	print("Supports Pixel Shaders 2.0: "..tostring(render.SupportsPixelShaders_2_0()))
	print("Supports Vertex Shaders 2.0: "..tostring(render.SupportsVertexShaders_2_0()))
end)

-- 弹药类型名到商店购买命令名（不带"ps_"前缀）的映射查找表
-- 键：弹药类型标识符  值：商店购买命令名
local ammonames = {
	["pistol"] = "pistolammo",
	["buckshot"] = "shotgunammo",
	["smg1"] = "smgammo",
	["ar2"] = "assaultrifleammo",
	["357"] = "rifleammo",
	["pulse"] = "pulseammo",
	["battery"] = "25mkit",
	["xbowbolt"] = "crossbowammo",
	["impactmine"] = "impactmine",
	["chemical"] = "chemical",
	["gaussenergy"] = "nail"
}

-- 添加 "zs_quickbuyammo" 控制台命令：快速购买上次补给的弹药类型
concommand.Add("zs_quickbuyammo", function()
	if ammonames[GAMEMODE.CachedResupplyAmmoType] then
		RunConsoleCommand("zs_pointsshopbuy", "ps_"..ammonames[GAMEMODE.CachedResupplyAmmoType])
	end
end)

-- 内部函数：将视图模型位置移到玩家身后极远处，以达到隐藏效果
local function GetViewModelPosition(self, pos, ang)
	return pos + ang:Forward() * -256, ang
end

-- 隐藏当前武器的视图模型（即玩家的手和武器模型）
-- 通过覆写 SWEP.GetViewModelPosition 实现
function DontDrawViewModel()
	if SWEP then
		SWEP.GetViewModelPosition = GetViewModelPosition
	end
end

-- 基于 1080p 分辨率缩放屏幕比例，但在低分辨率下不会让界面过小
-- 返回值：最终的缩放比例（乘上用户自定义的 InterfaceSize）
function BetterScreenScale()
	return math.max(ScrH() / 1080, 0.851) * GAMEMODE.InterfaceSize
end

-- 扩展 render.GetLightRGB：获取指定位置的光照颜色并返回独立的 R、G、B 分量
function render.GetLightRGB(pos)
	local vec = render.GetLightColor(pos)
	return vec.r, vec.g, vec.b
end

-- 快速创建并配置一个 VGUI 标签（DLabel）的辅助函数
-- parent：父面板  text：显示文本  font：字体  textcolor：文字颜色
-- 返回值：创建好的 DLabel 实例
function EasyLabel(parent, text, font, textcolor)
	local dpanel = vgui.Create("DLabel", parent)
	if font then
		dpanel:SetFont(font or "DefaultFont")
	end
	dpanel:SetText(text)
	dpanel:SizeToContents()
	if textcolor then
		dpanel:SetTextColor(textcolor)
	end
	dpanel:SetKeyboardInputEnabled(false)
	dpanel:SetMouseInputEnabled(false)

	return dpanel
end

-- 快速创建并配置一个 VGUI 按钮（DButton）的辅助函数
-- parent：父面板  text：显示文本  xpadding/ypadding：内边距（增加按钮尺寸）
-- 返回值：创建好的 DButton 实例
function EasyButton(parent, text, xpadding, ypadding, textcolor)
	local dpanel = vgui.Create("DButton", parent)
	if textcolor then
		dpanel:SetFGColor(textcolor)
	end
	if text then
		dpanel:SetText(text)
	end
	dpanel:SizeToContents()

	if xpadding then
		dpanel:SetWide(dpanel:GetWide() + xpadding * 2)
	end

	if ypadding then
		dpanel:SetTall(dpanel:GetTall() + ypadding * 2)
	end

	return dpanel
end
