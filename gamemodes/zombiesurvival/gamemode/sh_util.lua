-- ============================================================================
-- 文件: sh_util.lua (共享实用工具库)
-- 作用: 本文件是一个共享的实用工具库，包含大量用于游戏模式的辅助函数，
--       可在服务器和客户端上通用。它提供了玩家管理、数据查找、可见性检查、
--       伤害计算、数学插值、字符串和表格处理等多种功能。
-- ============================================================================

-- ============================================================================
-- 文件头部 —— 函数快捷参考（供快速查阅）
-- ============================================================================
-- player.GetAllActive 获取所有非观察者玩家
-- player.GetAllSpectators 获取所有观察者玩家
-- FindStartingItem 根据ID查找一个可在商店中购买的初始物品
-- FindItem 根据ID查找一个游戏模式中的物品
-- FindMutation 根据ID或签名查找一个可在商店中购买的变异
-- TrueVisible 检查两点之间是否有障碍物（已弃用）
-- TrueVisibleFilters 使用可变参数过滤器检查两点之间是否有障碍物（已弃用）
-- INC_SERVER 用于服务器脚本的宏，包含共享脚本并添加客户端脚本
-- INC_CLIENT 用于客户端脚本的宏，包含共享脚本
-- INC_CLIENT_NO_SHARED INC_CLIENT的别名
-- INC_SERVER_NO_SHARED 用于服务器脚本的宏，仅添加客户端脚本
-- INC_SERVER_NO_CLIENT 用于服务器脚本的宏，仅添加共享脚本
-- INC_SHARED 一个空宏，无任何作用
-- LightVisible 检查光线是否能在两点之间无障碍地传播
-- WorldVisible 仅考虑世界几何体，检查两点之间是否可见
-- CosineInterpolation 执行余弦插值
-- CubicInterpolate 执行三次插值
-- CatmullInterpolate 执行Catmull-Rom样条插值
-- string.AndSeparate 将字符串列表用逗号和"and"连接成自然语言格式
-- util.SkewedDistance 计算两个向量之间的倾斜距离，Z轴有权重
-- util.IsServerOrClient 返回当前代码运行环境是"SERVER"还是"CLIENT"
-- util.Blood 创建一个血液效果
-- util.BlastDamagePlayer 对玩家造成爆炸伤害，会应用玩家特有的伤害和范围乘数
-- util.BlastDamageEx 对球形范围内的实体造成爆炸伤害，并进行可见性检查
-- util.BlastDamageExAlloc 与BlastDamageEx类似，但返回一个记录了受伤害实体和伤害值的表
-- util.BlastAlloc 返回爆炸范围内所有可见的实体
-- util.FindValidInSphere 查找球形范围内所有有效的实体
-- util.PoisonBlastDamage 在球形范围内造成毒素伤害，并进行可见性检查
-- util.ToMinutesSeconds 将秒数转换为"MM:SS"格式的字符串
-- util.ToMinutesSecondsCD 将秒数转换为用于倒计时的"MM:SS"格式，会向上取整
-- util.ToMinutesSecondsMilliseconds 将秒数转换为"MM:SS.ms"格式的字符串
-- util.RemoveAll 移除指定类别下的所有实体
-- util.CompressBitTable 将一个布尔值表压缩成字符串以便存储
-- util.DecompressBitTable 将压缩后的字符串解压回布尔值表
-- table.IsAssoc 检查一个表是否为关联表（键值对形式的集合）
-- table.ToAssoc 将索引数组转换为关联表
-- table.ToKeyValues 将关联表转换回索引数组
-- team.GetSpawnPointGrouped 获取分组的队伍出生点，确保点之间有最小距离
-- AccessorFuncDT 为实体动态创建DT变量的Get/Set访问器函数
-- team.GetValidSpawnPoint 获取一个队伍所有有效的出生点
-- ents.CreateLimited 在不超过数量限制的情况下创建一个实体
-- string.CommaSeparate 为数字字符串添加千位分隔符
-- tonumbersafe 一个更安全的tonumber版本，会处理NaN情况
-- util.IntersectRayWithQuad 计算射线与一个四边形的交点
-- util.CreatePulseImpactEffect 创建一个脉冲武器的撞击效果
-- table.FullCopy 深度复制一个表，包括嵌套的表、向量和角度

-- ============================================================================
-- player.GetAllActive —— 获取所有非观察者玩家列表
-- 作用：遍历服务器中的所有玩家，过滤掉状态为观察者的玩家，
--       返回一个只包含活跃玩家的数组。
-- 参数：无
-- 返回：table —— 活跃玩家（非观察者）的列表
-- ============================================================================
function player.GetAllActive()
	-- 创建一个空表，用于存放活跃玩家
	local t = {}

	-- 遍历服务器上所有玩家
	for _, pl in pairs(player.GetAll()) do
		-- 如果玩家不是观察者，则将其添加到结果表中
		if not pl:IsSpectator() then
			t[#t + 1] = pl
		end
	end

	return t
end

-- ============================================================================
-- player.GetAllSpectators —— 获取所有观察者玩家列表
-- 作用：遍历服务器中的所有玩家，过滤出状态为观察者的玩家，
--       返回一个只包含观察者的数组。
-- 参数：无
-- 返回：table —— 观察者玩家的列表
-- ============================================================================
function player.GetAllSpectators()
	-- 创建一个空表，用于存放观察者玩家
	local t = {}

	-- 遍历服务器上所有玩家
	for _, pl in pairs(player.GetAll()) do
		-- 如果玩家是观察者，则将其添加到结果表中
		if pl:IsSpectator() then
			t[#t + 1] = pl
		end
	end

	return t
end

-- ============================================================================
-- FindStartingItem —— 根据ID查找一个可在商店中购买的初始物品
-- 作用：先调用 FindItem 通过物品ID查找物品，然后检查该物品是否
--       有 WorthShop 属性（即是否可在商店中购买）。
-- 参数：id —— 物品的唯一标识符（字符串或数字）
-- 返回：table / nil —— 如果找到且可在商店购买则返回物品表，否则返回 nil
-- ============================================================================
function FindStartingItem(id)
	-- 通过 FindItem 查找物品
	local item = FindItem(id)
	-- 如果物品存在且 WorthShop 属性为真（可在商店购买），则返回该物品
	if item and item.WorthShop then return item end
end

-- ============================================================================
-- FindItem —— 根据ID查找一个游戏模式中的物品
-- 作用：从全局游戏模式表 GAMEMODE.Items 中按ID索引查找物品定义。
-- 参数：id —— 物品的唯一标识符（通常在 sh_options.lua 中定义）
-- 返回：table / nil —— 找到的物品表，未找到则返回 nil
-- ============================================================================
function FindItem(id)
	return GAMEMODE.Items[id]
end

-- ============================================================================
-- FindMutation —— 根据ID或签名查找一个可在商店中购买的变异
-- 作用：支持两种查找方式：如果传入数字ID，则直接从 GAMEMODE.Mutations
--       索引表查找；如果传入字符串，则遍历所有突变查找与其 Signature
--       属性匹配的项。
-- 参数：id —— 突变的数字索引或字符串签名
-- 返回：table / nil —— 找到的变异表，未找到则返回 nil
-- ============================================================================
-- 随便放
function FindMutation(id)
	-- 如果ID为空，直接返回
	if not id then return end

	-- 用于存放找到的变异表
	local t

	-- 尝试将ID转换为数字
	local num = tonumber(id)
	if num then
		-- 如果是数字，直接从 GAMEMODE.Mutations 索引表中查找
		t = GAMEMODE.Mutations[num]
	else
		-- 如果是字符串（签名），遍历所有变异，查找匹配 Signature 的项
		for i, tab in pairs(GAMEMODE.Mutations) do
			if tab.Signature == id then
				t = tab
				break
			end
		end
	end

	-- 如果找到了变异表则返回
	if t then return t end
end

-- ============================================================================
-- TrueVisible —— 检查两点之间是否有障碍物（已弃用）
-- 作用：
-- 注意：此函数已弃用。CachedInvisibleEntities 和 filter 表的方式不合理，
--       建议改用函数式方法。
-- 参数：
--   posa (Vector) —— 起点位置
--   posb (Vector) —— 终点位置
--   filter (Entity) —— 要排除的额外实体（不阻挡视线）
-- 返回：boolean —— true表示两点之间无障碍物（可见），false表示有阻挡
-- ============================================================================
-- 预定义用于可见性检测的追踪参数表，掩码设为 MASK_SHOT（射击追踪掩码）
local TrueVisibleTrace = {mask = MASK_SHOT}
function TrueVisible(posa, posb, filter)
	-- 默认过滤掉所有投射物实体（projectile_*），以免子弹/火箭等阻挡视线
	local filt = ents.FindByClass("projectile_*")
	-- 如果在服务器端，额外过滤掉 CachedInvisibleEntities（已缓存的隐形实体）；
	-- 如果在客户端，过滤掉所有玩家（避免玩家身体阻挡视线判断）
	filt = table.Add(filt, SERVER and GAMEMODE.CachedInvisibleEntities or player.GetAll())
	-- 如果有自定义过滤实体，将其加入过滤器列表
	if filter then
		filt[#filt + 1] = filter
	end

	-- 设置追踪起点
	TrueVisibleTrace.start = posa
	-- 设置追踪终点
	TrueVisibleTrace.endpos = posb
	-- 设置要过滤掉的实体列表
	TrueVisibleTrace.filter = filt
	-- 确保掩码为射击掩码
	TrueVisibleTrace.mask = MASK_SHOT

	-- 如果射线未击中任何物体（Hit为false），则可见
	return not util.TraceLine(TrueVisibleTrace).Hit
end

-- ============================================================================
-- TrueVisibleFilters —— 使用可变参数过滤器检查两点之间是否可见（已弃用）
-- 作用：与 TrueVisible 类似，但接受可变数量的实体作为过滤器参数。
-- 注意：此函数已弃用。CachedInvisibleEntities 和 filter 表的方式不合理，
--       建议改用函数式方法。
-- 参数：
--   posa (Vector) —— 起点位置
--   posb (Vector) —— 终点位置
--   ... (Entity) —— 可变数量的要过滤掉的实体
-- 返回：boolean —— true表示可见，false表示不可见
-- ============================================================================
-- 预定义用于可见性检测的追踪参数表（函数内共用）
-- DEPRECATED behavior. CachedInvisibleEntities and filter tables is nonsense. Move to using functions.
function TrueVisibleFilters(posa, posb, ...)
	-- 默认过滤掉所有投射物实体
	local filt = ents.FindByClass("projectile_*")
	-- 服务器端过滤隐形实体，客户端过滤所有玩家
	filt = table.Add(filt, SERVER and GAMEMODE.CachedInvisibleEntities or player.GetAll())
	-- 如果传入了额外的过滤实体参数，将它们也加入过滤器列表
	if ... ~= nil then
		filt = table.Add(filt, {...})
	end

	-- 设置追踪起点
	TrueVisibleTrace.start = posa
	-- 设置追踪终点
	TrueVisibleTrace.endpos = posb
	-- 设置过滤器
	TrueVisibleTrace.filter = filt
	-- 设置掩码
	TrueVisibleTrace.mask = MASK_SHOT

	-- 如果射线未击中任何物体，则可见
	return not util.TraceLine(TrueVisibleTrace).Hit
end

-- ============================================================================
-- TrueVisibleFiltered —— 函数式可见性过滤器（推荐使用）
-- 作用：与 TrueVisibleFilters 语义完全一致，但过滤器使用函数而非实体表，
--       避免了每次调用时 ents.FindByClass("projectile_*") 的全场景扫描
--       和多次表分配（GC 压力），在 FindInSphere 循环内调用时收益明显。
-- 参数：
--   posa (Vector) —— 起点位置
--   posb (Vector) —— 终点位置
--   ... (Entity) —— 可变数量的要过滤掉的实体
-- 返回：boolean —— true表示可见，false表示不可见
-- ============================================================================
function TrueVisibleFiltered(posa, posb, ...)
	-- 额外需要过滤掉的实体（通常是自身和伤害来源）
	local extra = {...}

	-- 设置追踪参数
	TrueVisibleTrace.start = posa
	TrueVisibleTrace.endpos = posb
	TrueVisibleTrace.mask = MASK_SHOT
	-- 函数式过滤器：返回 false 表示该实体被忽略（不阻挡视线）
	TrueVisibleTrace.filter = function(ent)
		-- 过滤所有投射物实体（等价于旧版 FindByClass("projectile_*") 的 O(1) 前缀判断）
		if ent:GetClass():sub(1, 11) == "projectile_" then return false end

		-- 过滤额外传入的实体
		for i = 1, #extra do
			if extra[i] == ent then return false end
		end

		-- 服务器端过滤隐形实体，客户端过滤所有玩家
		if SERVER then
			local invis = GAMEMODE.CachedInvisibleEntities
			if invis then
				for _, e in pairs(invis) do
					if e == ent then return false end
				end
			end
		elseif ent:IsPlayer() then
			return false
		end

		return true
	end

	-- 如果射线未击中任何物体，则可见
	return not util.TraceLine(TrueVisibleTrace).Hit
end

-- ============================================================================
-- INC_SERVER —— 用于服务器脚本的包含宏
-- 作用：在服务器端运行 shared.lua，并将 shared.lua 和 cl_init.lua
--       注册为客户端需要下载的文件。
-- 使用场景：放在 init.lua（服务器端入口）中调用。
-- 参数：无
-- 返回：无
-- ============================================================================
-- Useful macros for the 3 file system
function INC_SERVER()
	-- 将 shared.lua 标记为客户端需下载的文件
	AddCSLuaFile("shared.lua")
	-- 将 cl_init.lua 标记为客户端需下载的文件
	AddCSLuaFile("cl_init.lua")
	-- 在服务器端执行 shared.lua（共享逻辑）
	include("shared.lua")
end

-- ============================================================================
-- INC_CLIENT —— 用于客户端脚本的包含宏
-- 作用：在客户端执行 shared.lua 中的共享逻辑。
-- 使用场景：放在 cl_init.lua（客户端入口）中调用。
-- 参数：无
-- 返回：无
-- ============================================================================
function INC_CLIENT()
	-- 在客户端执行 shared.lua
	include("shared.lua")
end
-- INC_CLIENT_NO_SHARED 是 INC_CLIENT 的别名，两者功能相同
INC_CLIENT_NO_SHARED = INC_CLIENT

-- ============================================================================
-- INC_SERVER_NO_SHARED —— 仅添加客户端脚本的服务器宏
-- 作用：仅将 cl_init.lua 注册为客户端需下载的文件，
--       不包含 shared.lua。
-- 使用场景：当服务器不需要执行共享逻辑时使用。
-- 参数：无
-- 返回：无
-- ============================================================================
function INC_SERVER_NO_SHARED()
	-- 将 cl_init.lua 标记为客户端需下载的文件
	AddCSLuaFile("cl_init.lua")
end

-- ============================================================================
-- INC_SERVER_NO_CLIENT —— 仅添加共享脚本的服务器宏
-- 作用：仅将 shared.lua 注册为客户端需下载的文件，
--       不在服务器端执行它。
-- 使用场景：当服务器不需要立即执行共享逻辑，但客户端需要时使用。
-- 参数：无
-- 返回：无
-- ============================================================================
function INC_SERVER_NO_CLIENT()
	-- 将 shared.lua 标记为客户端需下载的文件
	AddCSLuaFile("shared.lua")
end

-- ============================================================================
-- INC_SHARED —— 空宏（不执行任何操作）
-- 作用：防止因为误加了 INC_SHARED 而报错。
--       这个函数实际上什么都不做。
-- 参数：无
-- 返回：无
-- ============================================================================
-- Just in case you add this by mistake because it does nothing
function INC_SHARED()
end

-- ============================================================================
-- MASK_SHOT_OPAQUE —— 射击掩码与不透明内容的组合掩码
-- 作用：组合了 MASK_SHOT（标准射击追踪掩码）和
--       CONTENTS_OPAQUE（不透明内容标记），用于光线追踪以忽略
--       半透明和玻璃等物体。
-- ============================================================================
MASK_SHOT_OPAQUE = bit.bor(MASK_SHOT, CONTENTS_OPAQUE)

-- 预分配用于 LightVisible 的追踪参数表（避免重复创建）
-- Literally if photon particles can reach point b from point a.
local LightVisibleTrace = {mask = MASK_SHOT_OPAQUE}

-- ============================================================================
-- LightVisible —— 检查光线是否能在两点之间无障碍地传播
-- 作用：使用 MASK_SHOT_OPAQUE 掩码（忽略半透明/玻璃）检查两点之间
--       是否完全可见。相当于模拟光子能否从A点到达B点。
-- 参数：
--   posa (Vector) —— 起点位置（光源）
--   posb (Vector) —— 终点位置
--   ... (Entity) —— 可选的要过滤掉的实体（不阻挡光线）
-- 返回：boolean —— true表示光线可以无阻挡传播，false表示有阻挡
-- ============================================================================
function LightVisible(posa, posb, ...)
	-- 根据可变参数创建过滤器表
	local filter
	if ... ~= nil then
		filter = {...}
	end

	-- 设置追踪起点
	LightVisibleTrace.start = posa
	-- 设置追踪终点
	LightVisibleTrace.endpos = posb
	-- 设置过滤实体
	LightVisibleTrace.filter = filter

	-- 如果射线未击中任何物体，则光线可通过
	return not util.TraceLine(LightVisibleTrace).Hit
end

-- 预分配用于 WorldVisible 的追踪参数表（仅考虑固体笔刷几何体）
local WorldVisibleTrace = {mask = MASK_SOLID_BRUSHONLY}

-- ============================================================================
-- WorldVisible —— 仅考虑世界几何体检查两点之间是否可见
-- 作用：使用 MASK_SOLID_BRUSHONLY 掩码（仅检测世界地图的固体笔刷），
--       忽略所有实体（玩家、道具等），只判断地图几何体是否阻挡视线。
-- 参数：
--   posa (Vector) —— 起点位置
--   posb (Vector) —— 终点位置
-- 返回：boolean —— true表示世界几何体没有阻挡，false表示有阻挡
-- ============================================================================
function WorldVisible(posa, posb)
	-- 设置追踪起点
	WorldVisibleTrace.start = posa
	-- 设置追踪终点
	WorldVisibleTrace.endpos = posb
	-- 如果射线未击中任何世界笔刷几何体，则可见
	return not util.TraceLine(WorldVisibleTrace).Hit
end

-- ============================================================================
-- CosineInterpolation —— 执行余弦插值
-- 作用：使用余弦函数在两个值之间进行平滑插值，结果比线性插值更平滑。
--       常用于动画和过渡效果的缓动（easing）计算。
-- 参数：
--   y1 (number) —— 起始值
--   y2 (number) —— 结束值
--   mu (number) —— 插值因子，范围0~1，0返回y1，1返回y2
-- 返回：number —— 插值后的结果值
-- ============================================================================
function CosineInterpolation(y1, y2, mu)
	-- 计算经过余弦缓动后的插值因子 mu2（范围0~1）
	local mu2 = (1 - math.cos(mu * math.pi)) / 2
	-- 使用 mu2 对 y1 和 y2 进行线性混合插值
	return y1 * (1 - mu2) + y2 * mu2
end

-- ============================================================================
-- CubicInterpolate —— 执行三次插值
-- 作用：使用四个控制点进行三次（立方）多项式插值，提供比线性插值
--       更平滑的曲线过渡。常用于动画曲线和音频重采样。
-- 参数：
--   y0 (number) —— 第一个控制点（插值点之前的值）
--   y1 (number) —— 第二个控制点（起始值）
--   y2 (number) —— 第三个控制点（结束值）
--   y3 (number) —— 第四个控制点（插值点之后的值）
--   mu (number) —— 插值因子，范围0~1
-- 返回：number —— 插值后的结果值
-- ============================================================================
function CubicInterpolate(y0, y1, y2, y3, mu)
	-- 计算 mu 的平方
	local mu2 = mu * mu
	-- 计算三次项系数 a0
	local a0 = y3 - y2 - y0 + y1
	-- 计算二次项系数 a1
	local a1 = y0 - y1 - a0
	-- 计算一次项系数 a2
	local a2 = y2 - y0

	-- 组装三次多项式：a0 * mu^3 + a1 * mu^2 + a2 * mu + y1
	return a0 * mu * mu2 + a1 * mu2 + a2 * mu + y1
end

-- ============================================================================
-- 原 CatmullInterpolate 实现（已注释掉）
-- 使用不同公式的古老版本，已替换为下面的新版本
-- ============================================================================
--[[function CatmullInterpolate(y0, y1, y2, y3, mu)
	local mu2 = mu * mu
	local a0 = -0.5 * y0 + 1.5 * y1 - 1.5 * y2 + 0.5 * y3
	local a1 = y0 - 2.5 * y1 + 2 * y2 - 0.5 * y3
	local a2 = -0.5 * y0 + 0.5 * y2

	return a0 * mu * mu2 + a1 * mu2 + a2 * mu + y1
end]]

-- ============================================================================
-- CatmullInterpolate —— 执行Catmull-Rom样条插值（使用持续时间版）
-- 作用：使用四个控制点和经过时间进行 Catmull-Rom 样条插值，
--       产生平滑的曲线过渡。与上面的三次插值不同，此版本使用
--       经过时间与持续时间的比率作为插值因子。
-- 参数：
--   previous (number) —— 第一个控制点（之前的值）
--   start (number) —— 第二个控制点（起始值）
--   last (number) —— 第三个控制点（结束值）
--   nextp (number) —— 第四个控制点（之后的值）
--   elapsedTime (number) —— 已过去的时间
--   duration (number) —— 总持续时间
-- 返回：number —— 插值后的结果值
-- ============================================================================
function CatmullInterpolate(previous, start, last, nextp, elapsedTime, duration)
		-- 计算插值进度百分比（已完成时间 / 总时间）
		local percentComplete = elapsedTime / duration
		-- 计算百分比的平方
		local percentCompleteSquared = percentComplete * percentComplete
		-- 计算百分比的立方
		local percentCompleteCubed = percentCompleteSquared * percentComplete

		-- 使用 Catmull-Rom 样条公式计算结果值
		-- 公式拆解：每个控制点乘以对应的基函数系数后求和
		return previous * (-0.5 * percentCompleteCubed +
								   percentCompleteSquared -
							0.5 * percentComplete) +
				start * (1.5 * percentCompleteCubed +
						   -2.5 * percentCompleteSquared + 1.0) +
				last * (-1.5 * percentCompleteCubed +
							2.0 * percentCompleteSquared +
							0.5 * percentComplete) +
				nextp * (0.5 * percentCompleteCubed -
							0.5 * percentCompleteSquared)
end

-- ============================================================================
-- string.AndSeparate —— 将字符串列表连接成自然语言格式
-- 作用：将一个字符串数组用逗号和"and"连接成英文自然语言的列表格式。
--       例如：{"a","b","c"} -> "a, b, and c"
-- 参数：
--   list (table) —— 字符串数组
-- 返回：string —— 格式化后的字符串；空表返回空字符串
-- ============================================================================
function string.AndSeparate(list)
	-- 获取列表长度
	local length = #list
	-- 如果列表为空，返回空字符串
	if length <= 0 then return "" end
	-- 如果只有一个元素，直接返回该元素
	if length == 1 then return list[1] end
	-- 如果有两个元素，用" and "连接
	if length == 2 then return list[1].." and "..list[2] end

	-- 三个及以上元素：前n-1个用", "连接，最后一个用", and "连接
	return table.concat(list, ", ", 1, length - 1)..", and "..list[length]
end

-- ============================================================================
-- util.SkewedDistance —— 计算两个向量之间的倾斜距离
-- 作用：计算3D空间中两点之间的距离，但允许为Z轴（高度差）指定一个
--       权重因子。当一点在另一点上方时，高度差会乘以倾斜因子。
--       用于模拟某些情况下高度差对距离的影响不如水平距离显著。
-- 参数：
--   a (Vector) —— 第一个点
--   b (Vector) —— 第二个点
--   skew (number) —— Z轴的倾斜权重因子（0~1之间会让高度影响变小）
-- 返回：number —— 计算后的倾斜距离
-- ============================================================================
function util.SkewedDistance(a, b, skew)
	-- 如果 a 点高于 b 点（a.z > b.z），计算带权重的距离
	if a.z > b.z then
		-- 水平距离平方 + (高度差 * 倾斜因子)的平方，再开方
		return math.sqrt((b.x - a.x) ^ 2 + (b.y - a.y) ^ 2 + ((a.z - b.z) * skew) ^ 2)
	end

	-- 如果 a 点不高于 b 点，使用标准欧几里得距离
	return a:Distance(b)
end

-- ============================================================================
-- util.IsServerOrClient —— 返回当前代码运行环境
-- 作用：通过检查全局变量 SERVER 来判断当前是在服务器端还是客户端。
-- 参数：无
-- 返回：string —— "SERVER" 或 "CLIENT"
-- ============================================================================
function util.IsServerOrClient()
	return SERVER and "SERVER" or "CLIENT"
end

-- ============================================================================
-- util.Blood —— 创建一个血液效果
-- 作用：在指定位置生成一个喷血效果，使用预定义的"bloodstream"粒子效果。
-- 参数：
--   pos (Vector) —— 血液效果产生的位置
--   amount (number) —— 血量/血液量（影响效果大小）
--   dir (Vector) —— 血液喷射的方向（法线）
--   force (number) —— 喷射力度（会被限制最小为128）
--   noprediction (boolean) —— 是否禁用预测（可选参数）
-- 返回：无
-- ============================================================================
function util.Blood(pos, amount, dir, force, noprediction)
	-- 创建效果数据对象
	local effectdata = EffectData()
		-- 设置效果发生的位置
		effectdata:SetOrigin(pos)
		-- 设置血液量（幅度）
		effectdata:SetMagnitude(amount)
		-- 设置血液喷射方向
		effectdata:SetNormal(dir)
		-- 设置力度（至少为128）
		effectdata:SetScale(math.max(128, force))
	-- 触发"bloodstream"喷血效果，noprediction控制是否跳过客户端预测
	util.Effect("bloodstream", effectdata, nil, noprediction)
end

-- ============================================================================
-- util.BlastDamagePlayer —— 对玩家造成爆炸伤害（应用玩家专属乘数）
-- 作用：对玩家造成范围爆炸伤害，会自动应用该玩家的爆炸伤害范围乘数
--       (ExpDamageRadiusMul) 和爆炸伤害值乘数 (ExplosiveDamageMul)。
--       如果攻击者不是有效玩家，会输出错误警告。
-- 参数：
--   inf (Entity) —— 伤害来源实体（如发射物）
--   att (Player) —— 攻击者（必须是玩家）
--   center (Vector) —— 爆炸中心位置
--   radius (number) —— 基础爆炸半径
--   damage (number) —— 基础伤害值
--   damagetype (number) —— 伤害类型（如 DMG_BLAST）
--   taperfactor (number) —— 伤害衰减因子（递增伤害递减，可选）
-- ============================================================================
function util.BlastDamagePlayer(inf, att, center, radius, damage, damagetype, taperfactor)
	-- 检查攻击者是否为有效玩家，如果不是则输出错误警告
	if not att:IsValidPlayer() then ErrorNoHalt("[BlastDamagePlayer] Tried to use a nonplayer") end

	-- 调用核心爆炸函数，应用玩家的专属乘数
	util.BlastDamageEx(inf, att, center, radius * (att.ExpDamageRadiusMul or 1), damage * (att.ExplosiveDamageMul or 1), damagetype, taperfactor)
end

-- ============================================================================
-- util.BlastDamageEx —— 对球形范围内的实体造成爆炸伤害（增强版）
-- 作用：与引擎自带的 util.BlastDamage 不同，此函数检测可见性时
--       使用实体的最近点而非中心点，提高了可见性判断的准确性。
--       对范围内每个实体检查三个检测点：最近点、眼睛位置和世界中心。
-- 参数：
--   inflictor (Entity) —— 伤害来源实体
--   attacker (Entity) —— 攻击者
--   epicenter (Vector) —— 爆炸中心
--   radius (number) —— 爆炸半径
--   damage (number) —— 基础伤害值
--   damagetype (number) —— 伤害类型
--   taperfactor (number) —— 每伤害一个玩家后伤害衰减因子（可选）
-- ============================================================================
-- I had to make this since the default function checks visibility vs. the entitiy's center and not the nearest position.
function util.BlastDamageEx(inflictor, attacker, epicenter, radius, damage, damagetype, taperfactor)
	-- 保存初始基础伤害值
	local basedmg = damage

	-- 遍历爆炸球形范围内的所有实体
	for _, ent in pairs(ents.FindInSphere(epicenter, radius)) do
		-- 只处理有效的实体
		if ent:IsValid() then
			-- 获取实体上距离爆炸中心最近的点
			local nearest = ent:NearestPoint(epicenter)
			-- 检查三个关键位置到爆炸中心是否可见（任一位置可见即可造成伤害）
			-- 检测点1：实体上距离爆炸中心最近的点
			-- 检测点2：实体的眼睛位置
			-- 检测点3：实体的世界空间中心
			if TrueVisibleFiltered(epicenter, nearest, inflictor, attacker, ent)
				or TrueVisibleFiltered(epicenter, ent:EyePos(), inflictor, attacker, ent)
				or TrueVisibleFiltered(epicenter, ent:WorldSpaceCenter(), inflictor, attacker, ent) then

				-- 根据距离计算实际伤害（越远伤害越低），并应用特殊伤害系统
				ent:TakeSpecialDamage(((radius - nearest:Distance(epicenter)) / radius) * basedmg, damagetype, attacker, inflictor, nearest)

				-- 如果启用了伤害衰减因子且目标是玩家，对后续目标减少基础伤害
				if taperfactor and ent:IsPlayer() then
					basedmg = basedmg * taperfactor
				end
			end
		end
	end
end

-- ============================================================================
-- util.BlastDamageExAlloc —— 增强版爆炸伤害（记录伤害分配表）
-- 作用：功能与 BlastDamageEx 相同，但额外返回一个记录了每个受伤害
--       实体及其所受伤害值的表。用于需要知道具体伤害分配情况的场景。
-- 参数：
--   inflictor (Entity) —— 伤害来源实体
--   attacker (Entity) —— 攻击者
--   epicenter (Vector) —— 爆炸中心
--   radius (number) —— 爆炸半径
--   damage (number) —— 基础伤害值
--   damagetype (number) —— 伤害类型
-- 返回：table —— 以实体为键、伤害值为值的关联表
-- ============================================================================
function util.BlastDamageExAlloc(inflictor, attacker, epicenter, radius, damage, damagetype)
	-- 临时存储单个实体的伤害值
	local dmg
	-- 用于记录每个实体受到的伤害值
	local t = {}

	-- 遍历爆炸范围内的所有实体
	for _, ent in pairs(ents.FindInSphere(epicenter, radius)) do
		if ent:IsValid() then
			local nearest = ent:NearestPoint(epicenter)
			-- 检查可见性（三选一）
			if TrueVisibleFiltered(epicenter, nearest, inflictor, attacker, ent)
				or TrueVisibleFiltered(epicenter, ent:EyePos(), inflictor, attacker, ent)
				or TrueVisibleFiltered(epicenter, ent:WorldSpaceCenter(), inflictor, attacker, ent) then

				-- 根据距离计算实际伤害
				dmg = ((radius - nearest:Distance(epicenter)) / radius) * damage
				-- 对实体造成特殊伤害
				ent:TakeSpecialDamage(dmg, damagetype, attacker, inflictor, nearest)

				-- 记录该实体受到的伤害值
				t[ent] = dmg
			end
		end
	end

	-- 返回伤害记录表
	return t
end

-- ============================================================================
-- util.BlastAlloc —— 返回爆炸范围内所有可见的实体
-- 作用：不造成伤害，仅查找爆炸球形范围内所有实体中可见的那些，
--       以数组形式返回。用于预检测爆炸会影响到哪些目标。
-- 参数：
--   inflictor (Entity) —— 伤害来源实体
--   attacker (Entity) —— 攻击者
--   epicenter (Vector) —— 爆炸中心
--   radius (number) —— 爆炸半径
-- 返回：table —— 可见实体的数组列表
-- ============================================================================
function util.BlastAlloc(inflictor, attacker, epicenter, radius)
	-- 用于存放可见实体的表
	local t = {}

	-- 遍历爆炸范围内的所有实体
	for _, ent in pairs(ents.FindInSphere(epicenter, radius)) do
		if ent:IsValid() then
			local nearest = ent:NearestPoint(epicenter)
			-- 检查实体的三个关键位置是否至少有一个可见
			if TrueVisibleFiltered(epicenter, nearest, inflictor, attacker, ent)
				or TrueVisibleFiltered(epicenter, ent:EyePos(), inflictor, attacker, ent)
				or TrueVisibleFiltered(epicenter, ent:WorldSpaceCenter(), inflictor, attacker, ent) then
				-- 将可见实体加入列表
				t[#t + 1] = ent
			end
		end
	end

	return t
end

-- ============================================================================
-- util.FindValidInSphere —— 查找球形范围内所有有效的实体
-- 作用：在指定位置和半径的球形范围内查找所有有效实体（过滤掉无效的）。
--       与 ents.FindInSphere 不同，本函数会调用 IsValid 进行有效性检查。
-- 参数：
--   pos (Vector) —— 搜索中心位置
--   radius (number) —— 搜索半径
-- 返回：table —— 有效实体的数组列表
-- ============================================================================
function util.FindValidInSphere(pos, radius)
	-- 用于存放有效实体的表
	local ret = {}

	-- 遍历球形范围内的实体
	for _, ent in pairs(util.FindInSphere(pos, radius)) do
		-- 只添加有效的实体
		if ent:IsValid() then
			ret[#ret + 1] = ent
		end
	end

	return ret
end

-- ============================================================================
-- util.PoisonBlastDamage —— 在球形范围内造成毒素伤害
-- 作用：类似于 BlastDamageEx，但使用毒素伤害系统（PoisonDamage），
--       具有额外的毒素效果参数。距离爆炸中心越远伤害越低。
-- 参数：
--   inflictor (Entity) —— 伤害来源实体
--   attacker (Entity) —— 攻击者
--   epicenter (Vector) —— 爆炸中心
--   radius (number) —— 爆炸半径
--   damage (number) —— 基础毒素伤害
--   noreduce (boolean) —— 是否不减少伤害（传递到 PoisonDamage）
--   instant (boolean) —— 是否立即造成伤害（传递到 PoisonDamage）
-- ============================================================================
function util.PoisonBlastDamage(inflictor, attacker, epicenter, radius, damage, noreduce, instant)
	-- 遍历爆炸范围内的所有实体
	for _, ent in pairs(ents.FindInSphere(epicenter, radius)) do
		if ent:IsValid() then
			local nearest = ent:NearestPoint(epicenter)
			-- 检查可见性
			if TrueVisibleFiltered(epicenter, nearest, inflictor, attacker, ent)
				or TrueVisibleFiltered(epicenter, ent:EyePos(), inflictor, attacker, ent)
				or TrueVisibleFiltered(epicenter, ent:WorldSpaceCenter(), inflictor, attacker, ent) then
				-- 根据距离计算伤害并调用毒素伤害系统
				ent:PoisonDamage(((radius - nearest:Distance(epicenter)) / radius) * damage, attacker, inflictor, nil, noreduce, instant)
			end
		end
	end
end

-- ============================================================================
-- util.ToMinutesSeconds —— 将秒数转换为"MM:SS"格式的字符串
-- 作用：将秒数（可以是小数）格式化为"分:秒"形式，分钟和秒都是两位数。
--       例如：125秒 -> "02:05"，63.7秒 -> "01:03"
-- 参数：
--   seconds (number) —— 要转换的秒数
-- 返回：string —— 格式化的时间字符串，格式为"MM:SS"
-- ============================================================================
function util.ToMinutesSeconds(seconds)
	-- 计算整分钟数（向下取整）
	local minutes = math.floor(seconds / 60)
	-- 计算剩余的秒数（减去已转换为分钟的秒数）
	seconds = seconds - minutes * 60

	-- 格式化为两位数分钟和两位数秒（秒数向下取整）
	return string.format("%02d:%02d", minutes, math.floor(seconds))
end

-- ============================================================================
-- util.ToMinutesSecondsCD —— 将秒数转换为用于倒计时的"MM:SS"格式（向上取整）
-- 作用：与 ToMinutesSeconds 类似，但秒数会向上取整（math.ceil），
--       适用于倒计时显示。剩余不足1秒时显示为"00:01"而非"00:00"。
-- 参数：
--   seconds (number) —— 要转换的秒数
-- 返回：string —— 格式化的倒计时字符串，格式为"MM:SS"
-- ============================================================================
-- More appropriate for count downs. Timer will display 00:01 if less than a second remains and never display 00:00.
function util.ToMinutesSecondsCD(seconds)
	-- 秒数向上取整（确保倒计时不会显示00:00直到真正归零）
	seconds = math.ceil(seconds)
	-- 计算整分钟数
	local minutes = math.floor(seconds / 60)
	-- 计算剩余的秒数
	seconds = seconds - minutes * 60

	-- 格式化为"MM:SS"
	return string.format("%02d:%02d", minutes, seconds)
end

-- ============================================================================
-- util.ToMinutesSecondsMilliseconds —— 将秒数转换为"MM:SS.ms"格式
-- 作用：将秒数格式化为包含毫秒的"分:秒.毫秒"形式，毫秒为两位小数。
--       例如：63.456秒 -> "01:03.45"
-- 参数：
--   seconds (number) —— 要转换的秒数（浮点数）
-- 返回：string —— 格式化的时间字符串，格式为"MM:SS.ms"
-- ============================================================================
function util.ToMinutesSecondsMilliseconds(seconds)
	-- 计算整分钟数
	local minutes = math.floor(seconds / 60)
	-- 计算剩余的秒数
	seconds = seconds - minutes * 60

	-- 提取秒的小数部分并转为毫秒（取百分位两位）
	local milliseconds = math.floor(seconds % 1 * 100)

	-- 格式化为"MM:SS.ms"
	return string.format("%02d:%02d.%02d", minutes, math.floor(seconds), milliseconds)
end

-- ============================================================================
-- util.RemoveAll —— 移除指定类别下的所有实体
-- 作用：查找所有属于指定类别的实体，并将其从世界中移除。
--       用于地图清理或重置游戏状态。
-- 参数：
--   class (string) —— 实体的类别名（如 "npc_*", "weapon_*" 等）
-- 返回：无
-- ============================================================================
function util.RemoveAll(class)
	-- 遍历所有指定类别的实体
	for _, ent in pairs(ents.FindByClass(class)) do
		-- 逐个移除实体
		ent:Remove()
	end
end

-- ============================================================================
-- util.CompressBitTable —— 将一个布尔值表压缩成字符串以便存储
-- 作用：将一个以数字为键、布尔值为值的表压缩为二进制字符串，
--       用于将布尔数据高效地存储到文件中。每个布尔值占1位，
--       每8个布尔值打包为1个字节。网络库已经使用最小比特数，
--       所以此函数仅用于文件存储。
-- 参数：
--   t (table) —— 布尔值表（数字索引，值为true/false）
-- 返回：string —— 压缩后的二进制字符串
-- ============================================================================
-- Takes a table of false/trues with numbers as the keys, compresses to array of chars (8 bits), in other words a string, for storage in files.
-- The net library already uses the smallest number of bits needed so this is only for storing data.
function util.CompressBitTable(t)
	-- 用于存储压缩后字节的缓冲区
	local buf = ""
	-- 记录表中最大的键值，用于确定需要多少个字节
	local maxvalue = 0

	-- 先将表转换为关联表（以值为键）
	t = table.ToAssoc(t)

	-- 找到最大键值，确定布尔值范围
	for k in pairs(t) do
		if k > maxvalue then maxvalue = k end
	end
	-- 计算需要多少个字节来存储所有布尔位
	local num_bytes = math.ceil(maxvalue / 8)

	-- 逐字节处理
	for on_byte = 1, num_bytes do
		-- 当前字节的值（初始为0）
		local byte = 0

		-- 逐位处理，每个字节有8个位
		for bit_slot = 1, 8 do
			-- 如果对应的位在表中为true（键 = bit_slot + 8 * (on_byte - 1)）
			if t[bit_slot + 8 * (on_byte - 1)] then
				-- 将该位设置为1（使用按位或）
				byte = bit.bor(byte, 2 ^ (bit_slot - 1))
			end
		end

		-- 将字节转换为字符并追加到缓冲区
		buf = buf..string.char(byte)
	end

	return buf
end

-- ============================================================================
-- util.DecompressBitTable —— 将压缩后的字符串解压回布尔值表
-- 作用：与 CompressBitTable 相反，将压缩后的二进制字符串恢复为
--       布尔值表。可以选择返回关联表（associative）或索引数组。
-- 参数：
--   str (string) —— 压缩后的二进制字符串
--   associative (boolean) —— 如果为true，返回关联表（{key = true}）；
--                            如果为false，返回索引数组（{value}）
-- 返回：table —— 解压后的布尔值表
-- ============================================================================
function util.DecompressBitTable(str, associative)
	-- 用于存储解压后数据的表
	local t = {}

	-- 逐字节解压
	for on_byte = 1, #str do
		-- 获取当前字节的数值（0~255）
		local byte = str:sub(on_byte, on_byte):byte()
		-- 逐位提取
		for bit_slot = 1, 8 do
			-- 检查最低位是否为1（使用按位与）
			if bit.band(byte, 1) == 1 then
				-- 计算这个位对应的原始键值
				local v = bit_slot + 8 * (on_byte - 1)
				if associative then
					-- 关联模式：存储为 t[键] = true
					t[v] = true
				else
					-- 索引模式：存储为 t[#t+1] = 键
					t[#t + 1] = v
				end
			end
			-- 将字节右移1位，准备检查下一个位
			byte = bit.arshift(byte, 1)
		end
	end

	return t
end

-- ============================================================================
-- table.IsAssoc —— 检查一个表是否为关联表
-- 作用：判断一个表是索引数组（数字连续索引）还是关联表（键值对集）。
--       通过检查表中是否有值为true的键值对来判断。
-- 参数：
--   t (table) —— 要检查的表
-- 返回：boolean —— true表示是关联表，false表示是索引数组
-- ============================================================================
function table.IsAssoc(t)
	-- 遍历表中的所有键值对
	for _, v in pairs(t) do
		-- 检查是否有值为 true 的条目
		if v == true then
			return true
		end

		-- 只检查第一个条目（因为使用 pairs 遍历无序，这只能判断部分情况）
		return false
	end
end

-- ============================================================================
-- table.ToAssoc —— 将索引数组转换为关联表
-- 作用：将值列表转换为以值为键、true为值的关联表。
--       例如：{"a", "b"} -> {a = true, b = true}
--       如果输入的已经是关联表，则直接返回。
-- 参数：
--   t (table) —— 要转换的表
-- 返回：table —— 转换后的关联表
-- ============================================================================
function table.ToAssoc(t)
	-- 如果不是关联表（是索引数组），则进行转换
	if not table.IsAssoc(t) then
		-- 创建新的关联表
		local t2 = {}

		-- 将原表中的值作为新表的键，值设为true
		for k, v in pairs(t) do
			t2[v] = true
		end

		return t2
	end

	-- 如果已经是关联表，直接返回原表
	return t
end

-- ============================================================================
-- table.ToKeyValues —— 将关联表转换回索引数组
-- 作用：ToAssoc 的逆操作。将关联表（{key = true}）转换回
--       只包含键的索引数组。例如：{a = true, b = true} -> {"a", "b"}
--       如果输入的已经是索引数组，则直接返回。
-- 参数：
--   t (table) —— 要转换的关联表
-- 返回：table —— 转换后的索引数组
-- ============================================================================
function table.ToKeyValues(t)
	-- 如果是关联表，则进行转换
	if table.IsAssoc(t) then
		-- 创建新的索引数组
		local t2 = {}

		-- 遍历关联表，将值为true的键添加到数组中
		for k, v in pairs(t) do
			if v then
				t2[#t2 + 1] = k
			end
		end

		return t2
	end

	-- 如果已经是索引数组，直接返回原表
	return t
end

-- ============================================================================
-- TooNear —— 检查出生点是否离已有出生点太近（局部辅助函数）
-- 作用：检查一个出生点实体是否与列表中已有的任何出生点距离小于指定阈值。
--       用于 GetSpawnPointGrouped 中确保出生点之间保持最小距离。
-- 参数：
--   spawn (Entity) —— 要检查的出生点实体
--   tab (table) —— 已有出生点的列表
--   dist (number) —— 最小距离阈值
-- 返回：boolean —— true表示太近（距离小于阈值），false表示可以接受
-- ============================================================================
local function TooNear(spawn, tab, dist)
	-- 将距离平方（避免开方运算，提高性能）
	dist = dist * dist

	-- 获取待检查出生点的位置
	local spawnpos = spawn:GetPos()
	-- 遍历已有出生点列表
	for _, ent in pairs(tab) do
		-- 使用平方距离比较（效率更高）
		if ent:GetPos():DistToSqr(spawnpos) <= dist then
			return true
		end
	end

	return false
end

-- ============================================================================
-- team.GetSpawnPointGrouped —— 获取分组的队伍出生点（保持最小间距）
-- 作用：获取指定队伍的所有出生点，但确保返回的出生点之间至少有指定
--       的最小距离，避免玩家生成时挤在一起。
-- 参数：
--   teamid (number) —— 队伍ID（如 TEAM_ZOMBIE 或 TEAM_SURVIVOR）
--   dist (number) —— 出生点之间的最小距离（默认200）
-- 返回：table —— 筛选后的出生点实体列表
-- ============================================================================
function team.GetSpawnPointGrouped(teamid, dist)
	-- 设置默认最小间距为200单位
	dist = dist or 200

	-- 用于存放筛选后的出生点
	local tab = {}
	-- 获取该队伍的所有出生点
	local spawns = team.GetSpawnPoint(teamid)

	-- 遍历所有出生点，筛选出距离足够远的
	for _, spawn in pairs(spawns) do
		-- 如果当前出生点不与已选中的任何出生点太近
		if not TooNear(spawn, tab, dist) then
			-- 将其加入精选列表
			table.insert(tab, spawn)
		end
	end

	return tab
end

-- ============================================================================
-- AccessorFuncDT —— 为实体动态创建DT变量的Get/Set访问器函数
-- 作用：为指定的DT（DataTable，数据表）网络变量生成 Get 和 Set 方法，
--       方便通过实体对象直接读写网络变量。类似于引擎的 AccessorFunc，
--       但针对网络数据表变量。
-- 参数：
--   tab (table) —— 要添加方法的元表或表（通常是实体的元表）
--   membername (string) —— 成员变量名（用于生成 SetXxx / GetXxx 方法名）
--   type (string) —— 数据类型（"Int", "Bool", "Float" 等）
--   id (number) —— 数据表中的变量槽位ID
-- 返回：无（直接在传入的 tab 上添加 Set 和 Get 方法）
-- ============================================================================
function AccessorFuncDT(tab, membername, type, id)
	-- 获取实体的元表，用于访问实体方法
	local emeta = FindMetaTable("Entity")
	-- 获取对应的 Set 方法引用（如 SetDTInt, SetDTBool）
	local setter = emeta["SetDT"..type]
	-- 获取对应的 Get 方法引用（如 GetDTInt, GetDTBool）
	local getter = emeta["GetDT"..type]

	-- 在传入的表上创建 Set 方法
	tab["Set"..membername] = function(me, val)
		-- 调用实体的 SetDT 方法，设置指定ID的值为val
		setter(me, id, val)
	end

	-- 在传入的表上创建 Get 方法
	tab["Get"..membername] = function(me)
		-- 调用实体的 GetDT 方法，获取指定ID的值
		return getter(me, id)
	end
end

-- ============================================================================
-- team.GetValidSpawnPoint —— 获取一个队伍所有有效的出生点
-- 作用：获取指定队伍的所有出生点，并过滤出有效（IsValid）且未禁用
--       （Disabled 属性为 false）的出生点。
-- 参数：
--   teamid (number) —— 队伍ID
-- 返回：table —— 有效的出生点实体列表
-- ============================================================================
function team.GetValidSpawnPoint(teamid)
	-- 用于存放有效出生点的表
	local t = {}

	-- 获取该队伍的所有出生点
	local spawns = team.GetSpawnPoint(teamid)
	if spawns then
		-- 遍历所有出生点，过滤有效且未被禁用的
		for _, ent in pairs(spawns) do
			-- 检查实体是否有效且未被禁用
			if ent:IsValid() and not ent.Disabled then
				t[#t + 1] = ent
			end
		end
	end

	return t
end

-- ============================================================================
-- ents.CreateLimited —— 在不超过数量限制的情况下创建一个实体
-- 作用：在创建实体前先检查场景中该类实体的数量是否已达到上限，
--       如果已达上限则返回 NULL 而不创建。
--       用于防止玩家滥用生成大量实体导致服务器卡顿。
-- 参数：
--   class (string) —— 要创建的实体类别名
--   limit (number) —— 最大数量限制（默认32）
-- 返回：Entity / NULL —— 成功创建返回实体对象，达到上限返回 NULL
-- ============================================================================
function ents.CreateLimited(class, limit)
	-- 检查现有该类实体数量是否已达到或超过限制（默认32个）
	if #ents.FindByClass(class) >= (limit or 32) then return NULL end

	-- 未超限，正常创建实体
	return ents.Create(class)
end

-- ============================================================================
-- string.CommaSeparate —— 为数字字符串添加千位分隔符
-- 作用：将数字格式化为带千位逗号分隔的字符串。
--       例如：1234567 -> "1,234,567"
-- 参数：
--   num (string) —— 要格式化的数字字符串
-- 返回：string —— 添加了千位分隔符后的字符串
-- ============================================================================
function string.CommaSeparate(num)
	-- 用于匹配替换的临时变量
	local k
	-- 最多循环10000次（足够处理任何实际场景）
	for ___=1, 10000 do
		-- 使用正则：从左边开始，将"数字+三位数字"替换为"数字,三位数字"
		num, k = string.gsub(num, "^(-?%d+)(%d%d%d)", "%1,%2")
		-- 如果没有替换发生（k == 0），表示已处理完毕，退出循环
		if k == 0 then break end
	end
	return num
end

-- ============================================================================
-- tonumbersafe —— 更安全的 tonumber 版本（处理NaN）
-- 作用：标准的 tonumber 函数在遇到 NaN（Not a Number，非数值）时
--       会返回一个无法正常比较的值（n == 0 和 n > 0 都为 false）。
--       此函数检测到NaN时返回0，防止出现不可预期的行为。
-- 参数：
--   a (string / number) —— 要转换的值
-- 返回：number / nil —— 成功转换返回数字，NaN时返回0，
--                        无法转换（如 nil）返回 nil
-- ============================================================================
function tonumbersafe(a)
	-- 尝试将值转换为数字
	local n = tonumber(a)

	if n then
		-- 检查是否为有效的数字（NaN会在所有比较中返回false，包括 n == 0、n > 0）
		-- 正常的数字一定能满足 n == 0 或 n < 0 或 n > 0 之一
		if n == 0 or n < 0 or n > 0 then
			return n
		end

		-- 到这里说明 n 是 NaN，返回0
		return 0
	end

	-- 无法转换为数字（如nil或非数字字符串），返回 nil
	return nil
end

-- ============================================================================
-- util.IntersectRayWithQuad —— 计算射线与一个四边形的交点
-- 作用：计算从起点出发沿指定方向的射线与一个四边形平面的交点，
--       并返回交点在四边形上的局部坐标。四边形由左下角顶点、
--       角度和宽高定义。
-- 注意：从左上角算起的 y 坐标可以用 quad_h - y 获得。
-- 参数：
--   start (Vector) —— 射线起点
--   dir (Vector) —— 射线方向
--   quad_bottom_left (Vector) —— 四边形左下角的世界坐标
--   quad_angles (Angle) —— 四边形的欧拉角（用于确定法线方向）
--   quad_w (number) —— 四边形的宽度（局部x轴方向）
--   quad_h (number) —— 四边形的高度（局部y轴方向）
--   double_sided (boolean) —— 是否双面检测（true表示正面和背面都检测）
-- 返回：Vector, number, number / nil ——
--         hitpos: 交点世界坐标；x, y: 交点在四边形上的局部坐标；
--         如果没有交点则返回 nil
-- ============================================================================
-- y from the top left can be retrieved with quad_h - y
function util.IntersectRayWithQuad(start, dir, quad_bottom_left, quad_angles, quad_w, quad_h, double_sided)
	-- 计算四边形的法线方向（取角度的前方向量）
	local quad_normal = quad_angles:Forward()

	-- 如果不是双面检测，且射线方向与法线方向大于90度（背向四边形），则无交点
	if not double_sided and dir:Dot(quad_normal) > 0 then return end

	-- 计算射线与四边形所在平面的交点
	local hitpos = util.IntersectRayWithPlane(start, dir, quad_bottom_left, quad_normal)
	if hitpos then
		-- 将交点的世界坐标转换为四边形的局部坐标
		local lpos, _ = WorldToLocal(hitpos, quad_angles, quad_bottom_left, quad_angles)
		-- 提取局部坐标：将引擎返回的局部坐标映射到自定义的xy坐标系
		local x = lpos.y
		local y = lpos.z
		-- 检查局部坐标是否在四边形的宽高范围内
		if x >= 0 and x <= quad_w and y >= 0 and y <= quad_h then
			-- 返回交点世界坐标和局部xy坐标
			return hitpos, x, y
		end
	end
end

-- ============================================================================
-- util.CreatePulseImpactEffect —— 创建一个脉冲武器的撞击效果
-- 作用：在指定位置和法线方向生成一个脉冲撞击粒子效果。
--       使用预分配的 EffectData 对象 pulseeffect 来提高性能。
-- 参数：
--   hitpos (Vector) —— 撞击点的世界坐标
--   hitnormal (Vector) —— 撞击点的法线方向（表面的朝向）
-- 返回：无
-- ============================================================================
-- 预分配脉冲效果的数据对象（避免每次创建新对象，提高性能）
local pulseeffect = EffectData()
-- 设置脉冲的半径初始值为8
pulseeffect:SetRadius(8)
-- 设置脉冲的幅度初始值为1
pulseeffect:SetMagnitude(1)
-- 设置脉冲的缩放初始值为1
pulseeffect:SetScale(1)
function util.CreatePulseImpactEffect(hitpos, hitnormal)
	-- 设置撞击点位置
	pulseeffect:SetOrigin(hitpos)
	-- 设置撞击法线方向
	pulseeffect:SetNormal(hitnormal)
	-- 触发"cball_bounce"（弹跳球撞击）粒子效果
	util.Effect("cball_bounce", pulseeffect)
end

-- ============================================================================
-- table.FullCopy —— 深度复制一个表
-- 作用：递归地复制一个表的所有内容，包括嵌套的表（递归复制）、
--       Vector向量和Angle角度对象（创建新实例），以及基本类型值。
--       不会复制元表（metatable）。
-- 参数：
--   tab (table) —— 要深度复制的原始表
-- 返回：table / nil —— 复制后的新表；如果输入为nil则返回nil
-- ============================================================================
function table.FullCopy( tab )

	-- 如果输入为 nil，直接返回 nil
	if (!tab) then return nil end

	-- 创建新的空表，用于存放复制结果
	local res = {}
	-- 遍历原表的所有键值对
	for k, v in pairs( tab ) do
		if (type(v) == "table") then
			-- 如果值是表，递归复制（注意：这可能导致无限递归如果表有循环引用）
			res[k] = table.FullCopy(v) -- recursion ho!
		elseif (type(v) == "Vector") then
			-- 如果值是向量，创建新的向量实例
			res[k] = Vector(v.x, v.y, v.z)
		elseif (type(v) == "Angle") then
			-- 如果值是角度，创建新的角度实例
			res[k] = Angle(v.p, v.y, v.r)
		else
			-- 其他类型（数字、字符串、布尔等）直接赋值
			res[k] = v
		end
	end

	return res

end
