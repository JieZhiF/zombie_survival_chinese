-- ============================================================================
-- floatingscore.lua - 漂浮得分文字特效（客户端）
-- 负责：在击杀/助攻位置显示向上飘动的得分数字，支持整数/小数格式与
--       助攻标记，带横向摆动与渐隐效果，3D 文字始终面向玩家相机
-- ============================================================================

-- 特效总时长（秒）：决定文字漂浮时间与渐隐节奏
EFFECT.LifeTime = 3

-- ==== Init - 特效初始化：记录得分信息与消亡时刻 ====
function EFFECT:Init(data)
	-- 扩大渲染包围盒，避免文字显示时被引擎裁剪
	self:SetRenderBounds(Vector(-64, -64, -64), Vector(64, 64, 64))

	-- 随机相位种子，用于让每条得分文字的摆动不同步
	self.Seed = math.Rand(0, 10)

	-- 记录得分位置、数值（保留两位小数）与显示标志（颜色/助攻类型）
	self.Pos = data:GetOrigin()
	self.Amount = math.Round(data:GetMagnitude(), 2)
	self.Flag = math.Round(data:GetScale()) or 0

	-- 记录消亡时刻，Think 据此判断特效存活
	self.DeathTime = CurTime() + self.LifeTime
end

-- ==== Think - 逐帧上移得分文字，未到消亡时刻则继续渲染 ====
function EFFECT:Think()
	-- 文字以每秒 32 单位的速度向上漂浮
	self.Pos.z = self.Pos.z + FrameTime() * 32
	return CurTime() < self.DeathTime
end


-- 缓存常用全局函数，减少逐帧渲染时的查找开销
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

-- 得分文字颜色表：0 = 普通（灰白），1 = 暴击/击杀（金黄），2 = 其他（红色）
local cols = {}
cols[0] = Color(190, 190, 220, 255)
cols[1] = Color(255, 255, 10, 255)
cols[2] = Color(255, 10, 10, 255)
-- ==== Render - 逐帧渲染：面向相机的 3D 得分文字 ====
function EFFECT:Render()
	-- 剩余时间比例（1 → 0），同时控制透明度与横向摆动幅度
	local delta = math_Clamp(self.DeathTime - CurTime(), 0, self.LifeTime) / self.LifeTime
	-- 按标志选取文字颜色，无匹配时回退为普通色
	local flag = self.Flag
	local col = cols[flag] or cols[0]
	col.a = delta * 240

	-- 取相机视角：旋转角度让文字正面朝向玩家，并用 right 向量做横向摆动
	local ang = EyeAngles()
	local right = ang:Right()
	ang:RotateAroundAxis(ang:Up(), 270)
	ang:RotateAroundAxis(ang:Forward(), 90)

	cam_IgnoreZ(true)
	-- 在漂浮位置绘制 3D 文字，随正弦摆动并随剩余时间缩小
	cam_Start3D2D(self.Pos + math_sin(CurTime() + self.Seed) * 30 * delta * right, ang, (delta * 0.12 + 0.045) / 2)
		-- 整数得分直接居中显示
		local amount = self.Amount
		local flooramount = math_floor(amount)
		if amount == flooramount then
			if flag == 0 then
				draw_SimpleText(amount, "ZS3D2DFont2Big", 0, 0, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			else
				-- 非普通得分：右侧显示数值，左侧补充助攻标记文字
				draw_SimpleText(amount, "ZS3D2DFont2Big", 0, 0, col, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
				draw_SimpleText(flag == FM_LOCALKILLOTHERASSIST and " (assisted)" or flag == FM_LOCALASSISTOTHERKILL and " (assist)" or "", "ZS3D2DFont2", 0, 0, col, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			end
		else
			-- 小数得分：整数部分用大字号靠右，小数部分用小字号紧跟其后
			draw_SimpleText(flooramount, "ZS3D2DFont2Big", 0, -21, col, TEXT_ALIGN_RIGHT)
			local righttext
			if flag == 0 then
				righttext = tostring(amount - flooramount):sub(2)
			else
				-- 非普通得分：小数部分后附加助攻标记
				righttext = tostring(amount - flooramount):sub(2)..(flag == FM_LOCALKILLOTHERASSIST and " (assisted)" or flag == FM_LOCALASSISTOTHERKILL and " (assist)" or "")
			end
			draw_SimpleText(righttext, "ZS3D2DFont2", 2, 8, col, TEXT_ALIGN_LEFT)
		end
	cam_End3D2D()
	cam_IgnoreZ(false)
end
