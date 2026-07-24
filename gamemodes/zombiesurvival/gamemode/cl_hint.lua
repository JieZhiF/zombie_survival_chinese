-- ============================================================
-- 世界提示系统
-- 用于在3D世界中绘制浮动提示文字（如任务提示、目标标记等）
-- ============================================================

-- 存储所有活跃的提示信息
local Hints = {}

-- 绘制所有point_worldhint实体的提示
function GM:DrawPointWorldHints()
	for _, ent in pairs(ents.FindByClass("point_worldhint")) do if ent:IsValid() and ent.DrawHint then ent:DrawHint() end end
end

-- 添加一个新的世界提示
-- text: 显示的文本
-- pos: 世界坐标位置
-- ent: 关联实体（可选），提示会跟随实体移动
-- lifetime: 显示持续时间（秒），默认8秒
function GM:WorldHint(text, pos, ent, lifetime)
	lifetime = lifetime or 8

	-- 如果有关联实体，将坐标转换为实体的局部坐标
	if ent and ent:IsValid() then
		if pos then
			pos = ent:WorldToLocal(pos)
		else
			pos = ent:OBBCenter()
		end
	end

	-- 创建提示对象并加入列表
	local hint = {Hint = text, Pos = pos, Entity = ent, StartTime = CurTime(), EndTime = CurTime() + lifetime}
	table.insert(Hints, hint)

	return hint
end

-- 网络接收：服务端发送的世界提示
net.Receive("zs_worldhint", function(length)
	GAMEMODE:WorldHint(net.ReadString(), net.ReadVector(), net.ReadEntity(), net.ReadFloat())
end)

-- 环形纹理材质，用于提示的背景装饰
local matRing = Material("effects/select_ring")
-- 前景文字颜色（浅灰色）
local colFG = Color(220, 220, 220, 255)

-- 绘制单个世界提示
-- hint: 提示文本
-- pos: 世界坐标
-- delta: 淡出因子（0-1，接近0表示即将消失）
-- scale: 缩放比例
function DrawWorldHint(hint, pos, delta, scale)
	-- 如果消息信标显示被禁用，则不绘制
	if not GAMEMODE.MessageBeaconShow then return end

	local eyepos = EyePos()

	delta = delta or 1

	-- 根据delta设置透明度，实现淡出效果
	colFG.a = math.min(220, delta * 220)

	-- 计算提示面向玩家的角度（始终面向摄像机）
	local ang = (eyepos - pos):Angle()
	ang:RotateAroundAxis(ang:Right(), 270)
	ang:RotateAroundAxis(ang:Up(), 90)

	-- 在3D空间中绘制2D文字（忽略Z轴深度测试）
	cam.IgnoreZ(true)
	cam.Start3D2D(pos, ang, (scale or 1) * math.max(250, eyepos:Distance(pos)) * delta * 0.0005)

	-- 绘制感叹号图标
	draw.SimpleText("!", "zshintfont", 0, 0, colFG, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	-- 绘制提示文本
	draw.SimpleText(hint, "ZS3D2DFont2Small", 0, 64, colFG, TEXT_ALIGN_CENTER)

	-- 绘制旋转脉冲光环效果
	surface.SetMaterial(matRing)
	for i=1, 4 do
		colFG.a = colFG.a * (1 / i)
		surface.SetDrawColor(colFG)
		local pulse = math.max(0.25, math.abs(math.sin(RealTime() * 6))) * 30 * i
		surface.DrawTexturedRectRotated(0, 0, 128 + pulse, 128 + pulse, 0)
	end

	cam.End3D2D()
	cam.IgnoreZ(false)
end

-- 绘制所有活跃的世界提示
function GM:DrawWorldHints()
	local drawhint = DrawWorldHint

	-- 如果有活跃的提示，遍历绘制
	if #Hints > 0 then
		local curtime = CurTime()

		local done = true

		for _, hint in pairs(Hints) do
			local ent = hint.Entity
			-- 如果提示未过期且关联实体仍然有效
			if curtime < hint.EndTime and not (ent and not ent:IsValid()) then
				done = false

				-- 绘制提示，将实体局部坐标转回世界坐标
				drawhint(hint.Hint, ent and ent:LocalToWorld(hint.Pos) or hint.Pos, math.Clamp(hint.EndTime - curtime, 0, 1))
			end
		end

		-- 所有提示都已过期，清空列表
		if done then
			Hints = {}
		end
	end
end
