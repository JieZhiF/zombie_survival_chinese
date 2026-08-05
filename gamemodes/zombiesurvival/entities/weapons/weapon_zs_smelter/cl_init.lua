-- ============================================================================
-- weapon_zs_smelter/cl_init.lua - 客户端：熔炉炮外观与第一人称视角表现
-- 负责：3D 武器 HUD 参数、第一人称/世界模型显隐、SCK 自定义拼装元素、视角动画
-- ============================================================================
INC_CLIENT()

-- 3D 武器 HUD 绑定的骨骼：以 M3 枪械模型的父级骨骼为基准点
SWEP.HUD3DBone = "v_weapon.M3_PARENT"
-- 3D 武器 HUD 的偏移位置
SWEP.HUD3DPos = Vector(-0.5, -4.2, -0)
-- 3D 武器 HUD 的旋转角度
SWEP.HUD3DAng = Angle(0, 0, -20)
-- 3D 武器 HUD 的缩放比例
SWEP.HUD3DScale = 0.015

-- 第一人称视野角度（FOV 越大视野越开阔）
SWEP.ViewModelFOV = 70
-- 是否镜像翻转第一人称模型
SWEP.ViewModelFlip = false

-- 隐藏第一人称模型（武器外观完全由 SCK 自定义元素拼装）
SWEP.ShowViewModel = false
-- 隐藏世界模型（第三人称下同样由自定义元素拼装）
SWEP.ShowWorldModel = false

-- 武器栏位：归属螺栓/发射器类武器选择槽
SWEP.Slot = GAMEMODE:GetWeaponSlot("WeaponSelectSlotBolt")
SWEP.SlotGroup = WEPSELECT_BOLT
-- 槽位内的排序位置
SWEP.SlotPos = 0

-- 第一人称附加模型元素（SCK 拼装：开火时由"1"/"1+"等部件模拟枪机与弹壳运动）
SWEP.VElements = {
	["edgeleft++"] = { type = "Model", model = "models/props_lab/monitor01b.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "1", pos = Vector(2.305, -17.574, 0), angle = Angle(180, 0, 0), size = Vector(0.351, 0.556, 0.435), color = Color(100, 75, 0, 255), surpresslightning = false, material = "models/props_pipes/pipemetal001a", skin = 0, bodygroup = {} },
	["1"] = { type = "Model", model = "models/props_vehicles/carparts_tire01a.mdl", bone = "v_weapon.M3_PARENT", rel = "", pos = Vector(0.039, -0.797, -15.662), angle = Angle(180, 0, -90), size = Vector(0.174, 0.847, 0.174), color = Color(100, 75, 0, 255), surpresslightning = false, material = "models/props_pipes/pipemetal001a", skin = 0, bodygroup = {} },
	["1+"] = { type = "Model", model = "models/props_vehicles/carparts_tire01a.mdl", bone = "v_weapon.M3_PARENT", rel = "1", pos = Vector(0, -17.782, 0), angle = Angle(0, 0, 0), size = Vector(0.174, 0.838, 0.174), color = Color(100, 75, 0, 255), surpresslightning = false, material = "models/props_pipes/pipemetal001a", skin = 0, bodygroup = {} },
	["pipe"] = { type = "Model", model = "models/props_pipes/valve002.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "1", pos = Vector(3.494, -14.778, 0.214), angle = Angle(90, 90, 0), size = Vector(0.118, 0.118, 0.208), color = Color(125, 125, 115, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
	["shellpusher"] = { type = "Model", model = "models/XQM/panel360.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "1", pos = Vector(0, -19.056, 0), angle = Angle(0, 90, 0), size = Vector(8, 0.079, 0.079), color = Color(125, 125, 115, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
	["edgeleft+++"] = { type = "Model", model = "models/props_lab/monitor01b.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "1", pos = Vector(-2.306, -17.574, 0), angle = Angle(180, 180, 0), size = Vector(0.351, 0.556, 0.435), color = Color(100, 75, 0, 255), surpresslightning = false, material = "models/props_pipes/pipemetal001a", skin = 0, bodygroup = {} },
	["edgeleft+"] = { type = "Model", model = "models/props_lab/monitor01b.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "1", pos = Vector(-2.306, 0, 0), angle = Angle(180, 180, 0), size = Vector(0.345, 0.556, 0.435), color = Color(100, 75, 0, 255), surpresslightning = false, material = "models/props_pipes/pipemetal001a", skin = 0, bodygroup = {} },
	-- 弹壳元素：PostDrawViewModel 中动态驱动其下移，表现开火抛壳动画
	["SHELL"] = { type = "Model", model = "models/props_phx/misc/flakshell_big.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "1", pos = Vector(0, -3.961, 0), angle = Angle(0, 0, 90), size = Vector(0.127, 0.127, 0.18), color = Color(245, 215, 0, 255), surpresslightning = false, material = "models/props_lab/door_klab01", skin = 0, bodygroup = {} },
	["pipe+"] = { type = "Model", model = "models/props_pipes/valve002.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "1", pos = Vector(-3.495, -14.778, 0.214), angle = Angle(90, 90, 0), size = Vector(0.118, 0.118, 0.208), color = Color(125, 125, 115, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
	["black_filler"] = { type = "Model", model = "models/XQM/panel360.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "1", pos = Vector(0, -3.412, 0), angle = Angle(0, 90, 0), size = Vector(1.694, 0.079, 0.079), color = Color(0, 0, 0, 255), surpresslightning = false, material = "models/debug/debugwhite", skin = 0, bodygroup = {} },
	["edgeleft"] = { type = "Model", model = "models/props_lab/monitor01b.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "1", pos = Vector(2.305, 0, 0), angle = Angle(180, 0, 0), size = Vector(0.345, 0.556, 0.435), color = Color(100, 75, 0, 255), surpresslightning = false, material = "models/props_pipes/pipemetal001a", skin = 0, bodygroup = {} }
}

-- 世界模型附加元素（SCK 拼装：第三人称/他人视角下的武器外观）
SWEP.WElements = {
	["edgeleft"] = { type = "Model", model = "models/props_lab/monitor01b.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "1", pos = Vector(2.305, 0, 0), angle = Angle(180, 0, 0), size = Vector(0.345, 0.556, 0.435), color = Color(100, 75, 0, 255), surpresslightning = false, material = "models/props_pipes/pipemetal001a", skin = 0, bodygroup = {} },
	["1"] = { type = "Model", model = "models/props_vehicles/carparts_tire01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(21.385, 1.429, -5.041), angle = Angle(180, 90, 0), size = Vector(0.174, 0.847, 0.174), color = Color(100, 75, 0, 255), surpresslightning = false, material = "models/props_pipes/pipemetal001a", skin = 0, bodygroup = {} },
	["1+"] = { type = "Model", model = "models/props_vehicles/carparts_tire01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "1", pos = Vector(0, -14.903, 0), angle = Angle(0, 0, 0), size = Vector(0.174, 0.838, 0.174), color = Color(100, 75, 0, 255), surpresslightning = false, material = "models/props_pipes/pipemetal001a", skin = 0, bodygroup = {} },
	-- 弹匣元素：随剩余弹药状态显示/隐藏
	["clip"] = { type = "Model", model = "models/Items/combine_rifle_cartridge01.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "1+", pos = Vector(0, 2.381, -2.79), angle = Angle(-87.457, -90, 0), size = Vector(0.741, 1.69, 0.741), color = Color(115, 115, 115, 255), surpresslightning = false, material = "models/props_canal/metalwall005b", skin = 0, bodygroup = {} },
	["pipe"] = { type = "Model", model = "models/props_pipes/valve002.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "1", pos = Vector(3.494, -12.018, 0.214), angle = Angle(90, 90, 0), size = Vector(0.118, 0.118, 0.115), color = Color(125, 125, 115, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
	["black_filler+"] = { type = "Model", model = "models/XQM/panel360.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "1", pos = Vector(0, -16.862, 0), angle = Angle(0, 90, 0), size = Vector(6.394, 0.079, 0.079), color = Color(100, 75, 0, 255), surpresslightning = false, material = "models/props_pipes/pipemetal001a", skin = 0, bodygroup = {} },
	["edgeleft++"] = { type = "Model", model = "models/props_lab/monitor01b.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "1", pos = Vector(2.305, -14.907, 0), angle = Angle(180, 0, 0), size = Vector(0.351, 0.556, 0.435), color = Color(100, 75, 0, 255), surpresslightning = false, material = "models/props_pipes/pipemetal001a", skin = 0, bodygroup = {} },
	["edgeleft+++"] = { type = "Model", model = "models/props_lab/monitor01b.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "1", pos = Vector(-2.306, -14.907, 0), angle = Angle(180, 180, 0), size = Vector(0.351, 0.556, 0.435), color = Color(100, 75, 0, 255), surpresslightning = false, material = "models/props_pipes/pipemetal001a", skin = 0, bodygroup = {} },
	["edgeleft+"] = { type = "Model", model = "models/props_lab/monitor01b.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "1", pos = Vector(-2.306, 0, 0), angle = Angle(180, 180, 0), size = Vector(0.345, 0.556, 0.435), color = Color(100, 75, 0, 255), surpresslightning = false, material = "models/props_pipes/pipemetal001a", skin = 0, bodygroup = {} },
	-- 握把元素：供持枪手抓握的枪柄部件
	["GRIP"] = { type = "Model", model = "models/weapons/w_pist_usp.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "1+", pos = Vector(0, -2.672, -6.75), angle = Angle(0, -90, 0), size = Vector(0.575, 1, 1), color = Color(100, 75, 0, 255), surpresslightning = false, material = "models/props_pipes/pipemetal001a", skin = 0, bodygroup = {} },
	["pipe+"] = { type = "Model", model = "models/props_pipes/valve002.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "1", pos = Vector(-3.495, -12.018, 0.214), angle = Angle(90, 90, 0), size = Vector(0.118, 0.118, 0.115), color = Color(125, 125, 115, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
	["SHELL"] = { type = "Model", model = "models/props_phx/misc/flakshell_big.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "1", pos = Vector(0, -3.961, 0), angle = Angle(0, 0, 90), size = Vector(0.127, 0.127, 0.18), color = Color(245, 215, 0, 255), surpresslightning = false, material = "models/props_lab/door_klab01", skin = 0, bodygroup = {} },
	["black_filler"] = { type = "Model", model = "models/XQM/panel360.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "1", pos = Vector(0, -1.961, 0), angle = Angle(0, 90, 0), size = Vector(6.394, 0.079, 0.079), color = Color(0, 0, 0, 255), surpresslightning = false, material = "models/debug/debugwhite", skin = 0, bodygroup = {} }
}

-- ==== PostDrawViewModel - 绘制第一人称模型后处理 3D 武器 HUD 与弹壳弹出动画 ====
function SWEP:PostDrawViewModel(vm, pl, wep)
	-- 游戏模式允许时，绘制绑定在枪身上的 3D 武器 HUD
	if self.HUD3DPos and GAMEMODE:ShouldDraw3DWeaponHUD() then
		local pos, ang = self:GetHUD3DPos(vm)
		if pos then
			self:Draw3DHUD(vm, pos, ang)
		end
	end

	-- 以距上次开火的时间差的三次方作为弹壳位移强度（空仓时不触发）
	local lol = self:Clip1() == 0 and 0 or (CurTime() - self:GetLastFired())^3.5
	-- 将强度限制在 0~1 后映射为 0~20 的位移量
	local shelllol = math.Clamp(lol, 0, 1) * 20

	-- 将位移量施加到第一人称弹壳元素上（向后下方弹出）
	local shellpos = self.VElements["SHELL"].pos
	shellpos.y = -24 + shelllol
end

-- 幽灵化插值系数：放置路障或换弹收尾阶段视角倾斜的平滑过渡值
local ghostlerp = 0
-- ==== CalcViewModelView - 计算第一人称视角位置与角度（幽灵化时枪口下压倾斜） ====
function SWEP:CalcViewModelView(vm, oldpos, oldang, pos, ang)
	-- 玩家处于路障幽灵放置状态或武器换弹收尾阶段时，视角逐步下压
	if self:GetOwner():GetBarricadeGhosting() or self:GetReloadFinish() > 0 then
		ghostlerp = math.min(1, ghostlerp + FrameTime() * 1)
	elseif ghostlerp > 0 then
		ghostlerp = math.max(0, ghostlerp - FrameTime() * 1.5)
	end

	-- 按插值系数绕视线右轴旋转视角（最大下压 15 度）
	if ghostlerp > 0 then
		ang:RotateAroundAxis(ang:Right(), -15 * ghostlerp)
	end

	return pos, ang
end
