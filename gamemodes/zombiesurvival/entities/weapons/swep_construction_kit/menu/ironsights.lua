
-- ============================================================================
-- swep_construction_kit/menu/ironsights.lua - SCK 机瞄编辑面板（客户端）
-- 负责：机瞄开关/重置、拖拽模式选择、六轴位置与旋转滑条
-- ============================================================================
-- 拖拽模式：轴组合映射（x/z 同组、pitch/yaw 同组等）
local drag_modes = {
	["x / z"] = { "x", "z" },
	["y"] = { "y" },
	["pitch / yaw"] = { "pitch", "yaw" },
	["roll"] = { "roll" }
}

-- 获取当前持有的 SCK 武器与其机瞄面板
local wep = GetSCKSWEP( LocalPlayer() )
local pironsight = wep.pironsight
local pironsight_enable = SimplePanel( pironsight )

	-- 机瞄开关复选框：切换时通过控制台命令同步
	local icbox = vgui.Create( "DCheckBoxLabel", pironsight_enable )
		icbox:SetSize( 150, 20 )
		icbox:SetText( "Enable ironsights" )
		icbox.OnChange = function()
			if (wep:GetIronSights() ~= icbox:GetChecked()) then
				RunConsoleCommand("swepck_toggleironsights")
			end
		end
		if (wep.save_data.IronSightsEnabled) then icbox:SetValue(1)
		else icbox:SetValue(0) end
	icbox:Dock(LEFT)

	-- 重置机瞄偏移按钮
	local ribtn = vgui.Create( "DButton", pironsight_enable )
		ribtn:SetTall( 20 )
		ribtn:SetText( "Reset ironsights" )
		ribtn.DoClick = function()
			wep:ResetIronSights()
		end
	ribtn:Dock(FILL)

pironsight_enable:DockMargin(0,0,0,5)
pironsight_enable:Dock(TOP)

local pironsight_drag = SimplePanel( pironsight )

	local modlabel = vgui.Create( "DLabel", pironsight_drag )
		modlabel:SetSize( 150, 20 )
		modlabel:SetText( "Drag mode:" )
	modlabel:Dock(LEFT)

	-- 拖拽模式选择框：切换后更新对应轴的拖拽启用状态
	local drbox = vgui.Create( "DComboBox", pironsight_drag )
		drbox:SetTall( 20 )
		drbox:SetText( wep.cur_drag_mode )
		for k, v in pairs( drag_modes ) do
			drbox:AddChoice( k )
		end
		drbox.OnSelect = function(panel,index,value)
			local modes = drag_modes[value]
			wep.cur_drag_mode = value
			for k, v in pairs( wep.ir_drag ) do
				v[1] = table.HasValue( modes, k ) -- set the drag modus
			end
		end
	drbox:Dock(FILL)

pironsight_drag:DockMargin(0,0,0,10)
pironsight_drag:Dock(TOP)

-- 位置 X 滑条（绑定 _sp_ironsight_x 控制台变量）
local ixslider = vgui.Create( "DNumSlider", pironsight )
	ixslider:SetText( "Translate x" )
	ixslider:SetMinMax( -50, 50 )
	ixslider:SetDecimals( 3 )
	ixslider:SetConVar( "_sp_ironsight_x" )
	ixslider:SetValue( wep.save_data.IronSightsPos.x )
	ixslider.ConVarChanged = function( p, value )
		RunConsoleCommand("_sp_ironsight_x",value)
	end
ixslider:DockMargin(0,0,0,10)
ixslider:Dock(TOP)

-- 位置 Y 滑条
local iyslider = vgui.Create( "DNumSlider", pironsight )
	iyslider:SetText( "Translate y" )
	iyslider:SetMinMax( -50, 50 )
	iyslider:SetDecimals( 3 )
	iyslider:SetConVar( "_sp_ironsight_y" )
	iyslider:SetValue( wep.save_data.IronSightsPos.y )
	iyslider.ConVarChanged = function( p, value )
		RunConsoleCommand("_sp_ironsight_y",value)
	end
iyslider:DockMargin(0,0,0,10)
iyslider:Dock(TOP)

-- 位置 Z 滑条
local izslider = vgui.Create( "DNumSlider", pironsight )
	izslider:SetText( "Translate z" )
	izslider:SetMinMax( -50, 50 )
	izslider:SetDecimals( 3 )
	izslider:SetConVar( "_sp_ironsight_z" )
	izslider:SetValue( wep.save_data.IronSightsPos.z )
	izslider.ConVarChanged = function( p, value )
		RunConsoleCommand("_sp_ironsight_z",value)
	end
izslider:DockMargin(0,0,0,10)
izslider:Dock(TOP)

-- 旋转 pitch 滑条
local ipslider = vgui.Create( "DNumSlider", pironsight )
	ipslider:SetText( "Rotate pitch" )
	ipslider:SetMinMax( -100, 100 )
	ipslider:SetDecimals( 3 )
	ipslider:SetConVar( "_sp_ironsight_pitch" )
	ipslider:SetValue( wep.save_data.IronSightsAng.x )
	ipslider.ConVarChanged = function( p, value )
		RunConsoleCommand("_sp_ironsight_pitch",value)
	end
ipslider:DockMargin(0,0,0,10)
ipslider:Dock(TOP)

-- 旋转 yaw 滑条
local iyaslider = vgui.Create( "DNumSlider", pironsight )
	iyaslider:SetText( "Rotate yaw" )
	iyaslider:SetMinMax( -100, 100 )
	iyaslider:SetDecimals( 3 )
	iyaslider:SetConVar( "_sp_ironsight_yaw" )
	iyaslider:SetValue( wep.save_data.IronSightsAng.y )
	iyaslider.ConVarChanged = function( p, value )
		RunConsoleCommand("_sp_ironsight_yaw",value)
	end
iyaslider:DockMargin(0,0,0,10)
iyaslider:Dock(TOP)

-- 旋转 roll 滑条
local irslider = vgui.Create( "DNumSlider", pironsight )
	irslider:SetText( "Rotate roll" )
	irslider:SetMinMax( -100, 100 )
	irslider:SetDecimals( 3 )
	irslider:SetConVar( "_sp_ironsight_roll" )
	irslider:SetValue( wep.save_data.IronSightsAng.z )
	irslider.ConVarChanged = function( p, value )
		RunConsoleCommand("_sp_ironsight_roll",value)
	end
irslider:DockMargin(0,0,0,10)
irslider:Dock(TOP)