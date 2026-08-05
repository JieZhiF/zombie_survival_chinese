-- ============================================================================
-- floatingscore_und.lua - 僵尸吞噬玩家的漂浮文字特效（客户端）
-- 负责：僵尸吃掉人类时在其位置生成随机吞噬台词（如"MUNCH!"）
--       或"N BRAINS!"文字，随寿命缓慢上飘、渐隐并缩小
-- ============================================================================

-- 随机吞噬台词列表，每次吞噬从中抽取一条
local messages = {
	"MUNCH!",
	"BRAIN GET!",
	"+1!",
	"JOIN US!",
	"ONE OF US!",
	"BUTT MANGLED!",
	"CHOMP!"
}

-- 特效基准寿命（秒）
EFFECT.LifeTime = 3

-- ==== Init - 特效初始化：设置渲染范围并决定显示文字 ====
function EFFECT:Init(data)
	-- 扩大渲染包围盒，防止文字过早被引擎剔除
	self:SetRenderBounds(Vector(-64, -64, -64), Vector(64, 64, 64))

	-- 随机种子，让多条文字的摆动相位错开
	self.Seed = math.Rand(0, 10)

	-- 记录文字出现位置
	self.Pos = data:GetOrigin()

	-- 附带数量大于 1 时显示"N BRAINS!"，否则随机抽取一条台词
	local amount = math.Round(data:GetMagnitude())
	if amount > 1 then
		self.Message = amount.." BRAINS!"
	else
		self.Message = messages[math.random(#messages)]
	end

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
local EyeAngles = EyeAngles
local TEXT_ALIGN_CENTER = TEXT_ALIGN_CENTER

-- 文字主色（绿色）与描边色
local col = Color(40, 255, 40, 255)
local col2 = Color(0, 0, 0, 255)
-- ==== Render - 以 3D 屏幕文字形式绘制上飘文字 ====
function EFFECT:Render()
	-- 剩余寿命比例，控制透明度与缩放
	local delta = math_Clamp(self.DeathTime - CurTime(), 0, self.LifeTime) / self.LifeTime
	col.a = delta * 240
	col2.a = col.a

	-- 让文字始终正对玩家视角
	local ang = EyeAngles()
	local right = ang:Right()
	ang:RotateAroundAxis(ang:Up(), -90)
	ang:RotateAroundAxis(ang:Forward(), 90)

	-- 忽略深度测试使文字不被场景遮挡，并让文字横向摆动、渐隐缩小
	cam_IgnoreZ(true)
	cam_Start3D2D(self.Pos + math_sin(CurTime() + self.Seed) * 30 * delta * right, ang, (delta * 0.24 + 0.09) / 2)
		draw_SimpleText(self.Message, "ZS3D2DFont2", 0, 0, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	cam_End3D2D()
	cam_IgnoreZ(false)
end
