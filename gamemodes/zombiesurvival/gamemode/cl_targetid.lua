-- 本文件负责在玩家准星瞄准其他玩家或特定实体时，在屏幕上绘制出目标的信息ID，如名称、生命值、状态效果、等级和所持武器等。

-- GM:DrawTargetID 绘制目标玩家的详细信息，包括名字、生命值、各种状态（中毒、流血等）、等级和装备。
-- GM:DrawSigilTargetHint 当目标是传送符文（Sigil）时，绘制一个特殊的提示信息。
-- GM.TraceTarget 存储玩家当前准星所指向的实体。
-- FuncFilterPlayers 一个用于射线检测的过滤器函数，会忽略所有玩家。
-- FuncFilterTeam 一个用于射线检测的过滤器函数，会忽略与玩家同队的队友。
-- GM:HUDDrawTargetID 核心的HUD绘制函数，它执行射线检测以确定玩家的目标，并调用相应的绘制函数来显示目标信息，同时处理信息的淡出效果。

-- 缓存全局函数到本地变量，提升性能并避免全局查找开销
local TEXT_ALIGN_CENTER = TEXT_ALIGN_CENTER
local EyePos = EyePos
local EyeVector = EyeVector
local CurTime = CurTime
local string_format = string.format
local string_match = string.match
local math_max = math.max
local math_ceil = math.ceil
local draw = draw
local util = util

-- 射线检测用的结构体，使用MASK_SHOT遮罩，设置碰撞箱大小
local trace = {mask = MASK_SHOT, mins = Vector(-2, -2, -2), maxs = Vector(2, 2, 2)}
-- 用于存储射线检测过滤器的表
local filter = {}
-- 用于存储当前可见实体的表，键为实体，值为上次可见的时间
local entitylist = {}

-- 临时颜色变量，用于绘制时避免反复创建Color对象
local colTemp = Color(255, 255, 255)

-- 绘制目标玩家的详细信息
function GM:DrawTargetID(ent, fade)
	-- 如果未传入淡出因子，默认为1（完全不透明）
	fade = fade or 1
	-- 获取实体的位置，并在Z轴偏移16单位使其显示在角色头顶
	local pos = ent:GetPos()
	pos.z = pos.z + 16
	-- 将世界坐标转换为屏幕坐标
	local ts = pos:ToScreen()
	local x, y = ts.x, math.Clamp(ts.y, 0, ScrH() * 0.95)

	-- 设置颜色透明度，乘以淡出因子实现平滑淡出效果
	colTemp.a = fade * 255
	util.ColorCopy(COLOR_FRIENDLY, colTemp)

	-- 绘制目标玩家的名字，使用较小的字体
	local name = ent:Name()
	draw.SimpleTextBlur(name, "ZSHUDFontSmaller", x, y, colTemp, TEXT_ALIGN_CENTER)
	y = y + draw.GetFontHeight("ZSHUDFontSmaller") + 3

	-- 计算生命值比例：对于亡灵阵营使用最大僵尸生命值，其他阵营使用普通最大生命值
	local healthfraction = math_max(ent:Health() / (ent:Team() == TEAM_UNDEAD and ent:GetMaxZombieHealth() or ent:GetMaxHealth()), 0)
	-- 如果生命值不是满血（不等于1），则绘制生命值信息
	if healthfraction ~= 1 then
		-- 根据生命值比例选择不同的颜色：健康(>=75%)、擦伤(>=50%)、受伤(>=25%)、危急(<25%)
		util.ColorCopy(0.75 <= healthfraction and COLOR_HEALTHY or 0.5 <= healthfraction and COLOR_SCRATCHED or 0.25 <= healthfraction and COLOR_HURT or COLOR_CRITICAL, colTemp)

		-- 根据设置决定显示具体HP数值还是百分比
		local hptxt = self.HealthTargetDisplay == 1 and math_ceil(ent:Health()).." HP" or math_ceil(healthfraction * 100).."%"

		-- 绘制生命值文本
		draw.SimpleTextBlur(hptxt, "ZSHUDFont", x, y, colTemp, TEXT_ALIGN_CENTER)
		y = y + draw.GetFontHeight("ZSHUDFont") + 3

		-- 如果开启了医疗光环效果，绘制额外的状态信息
		if self.MedicalAura then
			-- 检查是否有脆弱（FRAIL）状态
			if ent:GetDTBool(DT_PLAYER_BOOL_FRAIL) then
				util.ColorCopy(COLOR_LBLUE, colTemp)
				draw.SimpleTextBlur("(FRAIL)", "ZSHUDFontSmaller", x, y, colTemp, TEXT_ALIGN_CENTER)
				y = y + draw.GetFontHeight("ZSHUDFontSmaller") + 2
			end

			-- 读取中毒、流血和幻影伤害值
			local poison = ent:GetPoisonDamage()
			local bleed = ent:GetBleedDamage()
			local phant = ent:GetPhantomHealth()
			-- 如果中毒伤害>=1，显示中毒状态及数值
			if poison >= 1 then
				util.ColorCopy(COLOR_LIMEGREEN, colTemp)
				draw.SimpleTextBlur("(POISON - " .. math.floor(poison) ..")", "ZSHUDFontSmaller", x, y, colTemp, TEXT_ALIGN_CENTER)
				y = y + draw.GetFontHeight("ZSHUDFontSmaller") + 2
			end
			-- 如果流血伤害>=1，显示流血状态及数值
			if bleed >= 1 then
				util.ColorCopy(COLOR_SOFTRED, colTemp)
				draw.SimpleTextBlur("(BLEED - " .. math.floor(bleed) ..")", "ZSHUDFontSmaller", x, y, colTemp, TEXT_ALIGN_CENTER)
				y = y + draw.GetFontHeight("ZSHUDFontSmaller") + 2
			end
			-- 如果幻影生命值>=1，显示血怒（BLOODLUST）状态
			if phant >= 1 then
				util.ColorCopy(COLOR_MIDGRAY, colTemp)
				draw.SimpleTextBlur("(BLOODLUST)", "ZSHUDFontSmaller", x, y, colTemp, TEXT_ALIGN_CENTER)
				y = y + draw.GetFontHeight("ZSHUDFontSmaller") + 2
			end
		end
	end

	-- 重置颜色为白色，不透明度保留当前淡出值
	util.ColorCopy(color_white, colTemp)

	-- 根据目标阵营分别显示不同的信息
	if ent:Team() == TEAM_UNDEAD then
		-- 亡灵阵营：显示僵尸类别名称（优先使用翻译名称）
		local classtab = ent:GetZombieClassTable()
		local classname = classtab.TranslationName and translate.Get(classtab.TranslationName) or classtab.Name
		if classname then
			draw.SimpleTextBlur(classname, "ZSHUDFontTiny", x, y, colTemp, TEXT_ALIGN_CENTER)
		end
	else
		-- 人类阵营：显示所持有的物品或武器
		local holding = ent:GetHolding()
		if holding:IsValid() then
			-- 如果正在搬运物体，显示物体模型名称（提取文件名部分）
			draw.SimpleTextBlur(string_format("Carrying [%s]", string_match(holding:GetModel(), ".*/(.+)%.mdl") or "object"), "ZSHUDFontTiny", x, y, colTemp, TEXT_ALIGN_CENTER)
		else
			-- 否则显示当前激活的武器名称
			local wep = ent:GetActiveWeapon()
			if wep:IsValid() then
				draw.SimpleTextBlur(wep:GetPrintName(), "ZSHUDFontTiny", x, y, colTemp, TEXT_ALIGN_CENTER)
			end
		end

		-- 获取玩家等级和转生等级
		local level = ent:GetZSLevel()
		local remortlevel = ent:GetZSRemortLevel()
		y = y + draw.GetFontHeight("ZSHUDFontTiny") + 4
		-- 如果有转生等级，同时显示等级和转生等级
		if remortlevel >= 1 then
			draw.SimpleTextBlur(string_format("LVL %d R.LVL %d", level, remortlevel), "ZSHUDFontTiny", x, y, colTemp, TEXT_ALIGN_CENTER)
		else
			draw.SimpleTextBlur("LVL "..level, "ZSHUDFontTiny", x, y, colTemp, TEXT_ALIGN_CENTER)
		end
	end
end

-- 当目标是传送符文（Sigil）时绘制特殊提示信息
function GM:DrawSigilTargetHint(ent, fade)
	-- 如果未传入淡出因子，默认为1
	fade = fade or 1
	-- 获取符文位置并在Z轴偏移16单位
	local pos = ent:GetPos()
	pos.z = pos.z + 16
	-- 转换为屏幕坐标
	local ts = pos:ToScreen()
	local x, y = ts.x, math.Clamp(ts.y, 0, ScrH() * 0.95)

	-- 设置半透明颜色，透明度为淡出因子的128
	colTemp.a = fade * 128
	util.ColorCopy(color_white, colTemp)

	-- 绘制"传送符文"文本
	draw.SimpleTextBlur(""..translate.Get("sigil"), "ZSHUDFontSmaller", x, y, colTemp, TEXT_ALIGN_CENTER)
	y = y + draw.GetFontHeight("ZSHUDFontSmaller") + 0

	-- 绘制"传送符文 - 点击传送"提示文本
	draw.SimpleTextBlur(""..translate.Get("sigil_teleport_text"), "ZSHUDFontTiny", x, y, colTemp, TEXT_ALIGN_CENTER)
end

-- 存储玩家当前准星所指向的实体对象
GM.TraceTarget = NULL

-- 射线检测过滤器：排除所有玩家（仅检测非玩家实体）
local function FuncFilterPlayers(ent)
	return not ent:IsPlayer()
end

-- 射线检测过滤器：排除与本地玩家同队的队友
local function FuncFilterTeam(ent)
	return not (ent:IsPlayer() and ent:Team() == MySelf:Team())
end

-- 核心HUD绘制函数：执行射线检测并绘制目标信息
function GM:HUDDrawTargetID(teamid)
	-- 射线检测节流：每 0.1 秒一次（TraceTarget* 字段供钉子/目标辅助等外部读取，保持更新）
	if CurTime() >= (self.NextTargetIDTrace or 0) then
		self.NextTargetIDTrace = CurTime() + 0.1

		-- 获取玩家眼睛位置和朝向向量作为射线起点和方向
		local start = EyePos()
		trace.start = start
		trace.endpos = start + EyeVector() * 2048
		-- 设置射线过滤器：排除玩家自身以及观察目标
		filter[1] = MySelf.TargetIDFilter or MySelf
		filter[2] = MySelf:GetObserverTarget()
		trace.filter = filter

		-- 判断玩家是否为旁观者模式
		local isspectator = MySelf:IsSpectator()

		-- 执行包围盒射线检测，获取射线命中的实体
		local entity = util.TraceHull(trace).Entity
		self.TraceTarget = entity
		-- 执行纯射线检测（排除所有玩家），获取命中的非玩家实体
		trace.filter = FuncFilterPlayers
		self.TraceTargetNoPlayers = util.TraceLine(trace).Entity

		-- 如果玩家具有目标焦点（TargetLocus）能力，额外进行排除队友的射线检测
		if MySelf.TargetLocus then
			trace.filter = FuncFilterTeam
			self.TraceTargetTeam = util.TraceLine(trace).Entity
		end

		-- 如果目标是有效的玩家（同队或旁观者）或者是符文，记录当前时间用于显示淡出
		if entity:IsValid() and (entity:IsPlayer() and (entity:Team() == teamid or isspectator) or entity.Sigil) then
			entitylist[entity] = CurTime()
		end
	end

	-- 遍历所有已记录的可见实体，根据当前时间决定绘制或移除
	for ent, time in pairs(entitylist) do
		-- 如果是有效的玩家且符合队伍条件，绘制玩家信息（1.5秒内淡出）
		if ent:IsValidPlayer() and (ent:Team() == teamid or isspectator) and CurTime() < time + 1.5 then
			self:DrawTargetID(ent, 1 - math.Clamp((CurTime() - time) / 1.5, 0, 1))
		-- 如果是人类阵营的符文，绘制符文提示（0.5秒内淡出）
		elseif teamid == TEAM_HUMAN and ent.Sigil and CurTime() < time + 0.5 then
			self:DrawSigilTargetHint(ent, 1 - math.Clamp((CurTime() - time) / 0.5, 0, 1))
		else
			-- 超出显示时间，从列表中移除
			entitylist[ent] = nil
		end
	end
end
