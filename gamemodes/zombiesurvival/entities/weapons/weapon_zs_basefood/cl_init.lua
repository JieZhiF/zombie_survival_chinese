-- ============================================================================
-- weapon_zs_basefood/cl_init.lua - 食物武器母本（客户端部分）
-- 负责：将食物武器放入食物栏位、隐藏所有模型，并实现吃东西时的视角晃动动画
-- ============================================================================
INC_CLIENT() -- 客户端专用文件标记
-- 武器栏位：放入武器选择栏的"食物"分类
SWEP.Slot = GAMEMODE:GetWeaponSlot("WeaponSelectSlotFood")
-- 栏位组：对应食物栏（和武器选择界面按键绑定相关）
SWEP.SlotGroup = WEPSELECT_FOOD
SWEP.ViewModelFOV = 60 -- 第一人称视野大小
SWEP.ViewModelFlip = false -- 不翻转第一人称模型

-- 不显示第一人称模型
SWEP.ShowViewModel = false
-- 不显示世界模型
SWEP.ShowWorldModel = false

-- ==== CalcViewModelView - 计算吃东西时的第一人称视角偏移与旋转 ====
-- 在吃东西期间让视角按正弦规律抖动，模拟"咀嚼"的晃动效果
function SWEP:CalcViewModelView(vm, oldpos, oldang, pos, ang)
	local eattime = self:GetEatEndTime() -- 吃东西结束时间
	if eattime == 0 then return end -- 不在吃东西状态则不做处理

	-- 计算吃东西进度的 0~1 插值进度
	local delta = math.Clamp((CurTime() - self:GetEatStartTime()) / self:GetFoodEatTime(), 0, 1)
	if delta > 0 then
		-- 用正弦绝对值产生反复的抖动强度（每秒 3 次完整摆动）
		local lerp = math.sin(6 * math.pi * delta)
		lerp = math.abs(lerp)

		local Offset = self.EatViewOffset -- 吃东西时的视角位置偏移量

		-- 若定义了视角旋转量，则围绕右/上/前轴按抖动强度旋转
		if self.EatViewAngles then
			ang = Angle(ang.p, ang.y, ang.r)
			ang:RotateAroundAxis(ang:Right(), self.EatViewAngles.x * lerp)
			ang:RotateAroundAxis(ang:Up(), self.EatViewAngles.y * lerp)
			ang:RotateAroundAxis(ang:Forward(), self.EatViewAngles.z * lerp)
		end

		-- 按抖动强度将偏移量施加到视角位置上
		pos = pos + Offset.x * lerp * ang:Right() + Offset.y * lerp * ang:Forward() + Offset.z * lerp * ang:Up()
	end

	return pos, ang -- 返回计算后的位置与角度
end
