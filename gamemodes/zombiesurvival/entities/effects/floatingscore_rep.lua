-- ============================================================================
-- floatingscore_rep.lua - 修理量漂浮文字特效（客户端）
-- 负责：玩家修理物件时在目标位置显示蓝色"XX HP"修理数字，
--       数字缓慢上飘、随寿命渐隐并缩小
-- ============================================================================

-- 特效基准寿命（秒）
EFFECT.LifeTime = 3

-- ==== Init - 特效初始化：记录位置、修理量与消失时间 ====
function EFFECT:Init(data)
	-- 扩大渲染包围盒，防止文字过早被引擎剔除
	self:SetRenderBounds(Vector(-64, -64, -64), Vector(64, 64, 64))

	-- 随机种子，让多条文字的摆动相位错开
	self.Seed = math.Rand(0, 10)

	-- 记录文字位置与修理量（保留两位小数）
	self.Pos = data:GetOrigin()
	self.Amount = math.Round(data:GetMagnitude(), 2)

	-- 记录文字消失时间
	self.DeathTime = CurTime() + self.LifeTime
end

-- ==== Think - 每帧让文字上飘，存活至死亡时间 ====
function EFFECT:Think()
	self.Pos.z = self.Pos.z + FrameTime() * 32
	return CurTime() < self.DeathTime
end

-- 缓存常用函数/常量，提升每帧渲染性能
local cam_IgnoreZ = cam.IgnoreZ
local cam_Start3D2D = cam.Start3D2D
local cam_End3D2D = cam.End3D2D
local draw_SimpleText = draw.SimpleText
local math_Clamp = math.Clamp
local math_sin = math.sin
local math_floor = math.floor
local EyeAngles = EyeAngles
local tostring = tostring
local TEXT_ALIGN_CENTER = TEXT_ALIGN_CENTER
local TEXT_ALIGN_LEFT = TEXT_ALIGN_LEFT
local TEXT_ALIGN_RIGHT = TEXT_ALIGN_RIGHT

-- 文字颜色（蓝色修理色）
local col = Color(60, 190, 245, 255)
-- ==== Render - 以 3D 屏幕文字形式绘制修理数字 ====
function EFFECT:Render()
	-- 剩余寿命比例，控制透明度与缩放
	local delta = math_Clamp(self.DeathTime - CurTime(), 0, self.LifeTime) / self.LifeTime
	col.a = delta * 240

	-- 让文字始终正对玩家视角
	local ang = EyeAngles()
	local right = ang:Right()
	ang:RotateAroundAxis(ang:Up(), 270)
	ang:RotateAroundAxis(ang:Forward(), 90)

	-- 忽略深度测试使文字不被场景遮挡，并让文字横向摆动、渐隐缩小
	cam_IgnoreZ(true)
	cam_Start3D2D(self.Pos + math_sin(CurTime() + self.Seed) * 30 * delta * right, ang, (delta * 0.12 + 0.045) / 2)
		-- 整数血量直接显示"XX HP"；小数血量拆为整数部分（大字号）与小数部分
		local amount = self.Amount
		local flooramount = math_floor(amount)
		if amount == flooramount then
			draw_SimpleText(amount.." HP", "ZS3D2DFont2Big", 0, -21, col, TEXT_ALIGN_CENTER)
		else
			draw_SimpleText(flooramount, "ZS3D2DFont2Big", 0, -21, col, TEXT_ALIGN_RIGHT)
			draw_SimpleText(tostring(amount - flooramount):sub(2).." HP", "ZS3D2DFont2", 2, 8, col, TEXT_ALIGN_LEFT)
		end
	cam_End3D2D()
	cam_IgnoreZ(false)
end
