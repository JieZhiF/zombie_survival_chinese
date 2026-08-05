-- ============================================================================
-- gmapex/sh_serialization.lua - 地图扩展(GMAPEX)的序列化工具（SRL 格式）
-- 负责：与 gamemode/sh_serialization.lua 同源的 SRL 序列化/反序列化实现，
--       供地图扩展数据存储使用；带版本号守卫，避免与其他序列化模块
--       重复定义全局 Deserialize/Serialize 函数
-- ============================================================================

-- 版本守卫：若已存在更新的序列化实现（SRL_VER > 3）则跳过本文件，否则记录版本号为 3
if SRL_VER and SRL_VER > 3 then return end
SRL_VER = 3

-- 沙盒环境：反序列化时仅允许使用 Vector 和 Angle 两种特殊类型，防止执行恶意代码
local sandbox_env = {Vector = Vector, Angle = Angle}

-- ==== Deserialize - 将序列化字符串反序列化回 Lua table ====
-- @param sIn 输入的序列化字符串（"SRL={...}" 格式，缺少前缀时会自动补上）
-- @return 反序列化得到的 table，解析失败时返回空表
function Deserialize(sIn)
	-- 保存反序列化结果的表，默认空表
	local out = {}

	-- 输入为空串或结尾不是 "}" 时视为格式非法，直接返回空表
	if #sIn == 0 or string.sub(sIn, -1) ~= "}" then return out end

	-- 缺少 "SRL=" 前缀时自动补上，兼容不带前缀的输入
	if string.sub(sIn, 1, 4) ~= "SRL=" then sIn = "SRL="..sIn end

	-- 前缀后的首个字符必须是 "{"，否则格式错误返回空表
	if string.sub(sIn, 5, 5) ~= "{" then return out end

	-- 拼接 " return SRL" 构成合法的 Lua 返回语句，交给 CompileString 编译成函数
	sIn = sIn.." return SRL"
	-- CompileString 成功时返回函数，失败时返回错误信息字符串
	local func = CompileString(sIn, "deserialize", false)
	if type(func) == "string" then
		-- 编译失败：错误信息以字符串形式返回，直接打印
		print("Deserialization error: "..func)
	else
		-- 将函数放入仅含 Vector/Angle 的沙盒环境后执行，得到反序列化结果
		setfenv(func, sandbox_env)
		out = func() or out
	end

	return out
end

local allowedtypes = {}
-- 允许参与序列化的数据类型白名单（键与值都必须属于白名单才参与序列化）
allowedtypes["string"] = true
allowedtypes["number"] = true
allowedtypes["table"] = true
allowedtypes["Vector"] = true
allowedtypes["Angle"] = true
allowedtypes["boolean"] = true
-- ==== MakeTable - 将 Lua table 递归转换为可求值的字符串表示 ====
-- @param tab 要转换的 table
-- @param done 记录已处理过的嵌套 table，防止循环引用导致死循环
-- @return 序列化后的字符串（不含外层花括号）
local function MakeTable(tab, done)
	-- 累积序列化结果的字符串
	local str = ""
	-- 首次调用时初始化循环引用记录表
	done = done or {}

	-- 判断是否为顺序索引数组，决定键的生成方式
	local sequential = table.IsSequential(tab)

	-- 遍历 table 的所有键值对
	for key, value in pairs(tab) do
		local keytype = type(key)
		local valuetype = type(value)

		-- 键和值都必须属于白名单类型才参与序列化
		if allowedtypes[keytype] and allowedtypes[valuetype] then
			-- 顺序数组使用隐式索引（键留空）；否则生成 "[键]=" 形式的键
			if sequential then
				key = ""
			else
				-- 数字/布尔键直接转字符串
				if keytype == "number" or keytype == "boolean" then
					key ="["..tostring(key).."]="
				else
					-- 字符串键用 %q 转义，保证生成的代码可安全求值
					key = "["..string.format("%q", tostring(key)).."]="
				end
			end

			-- 嵌套 table：递归展开，done 表防止循环引用
			if valuetype == "table" and not done[value] then
				done[value] = true
				-- 若表自带 _serialize 方法，则优先使用自定义序列化
				if type(value._serialize) == "function" then
					-- 调用自定义 _serialize 方法生成序列化片段
					str = str..key..value:_serialize()..","
				else
					-- 否则递归序列化子表
					str = str..key.."{"..MakeTable(value, done).."},"
				end
			else
				-- 按值类型生成对应的字符串表示
				if valuetype == "string" then
					value = string.format("%q", value)
				elseif valuetype == "Vector" then
					-- Vector 序列化为构造调用 Vector(x,y,z)
					value = "Vector("..value.x..","..value.y..","..value.z..")"
				elseif valuetype == "Angle" then
					-- Angle 序列化为构造调用 Angle(pitch,yaw,roll)
					value = "Angle("..value.pitch..","..value.yaw..","..value.roll..")"
				else
					-- 其余类型（number/boolean）直接转字符串
					value = tostring(value)
				end

				-- 拼入键值对并加逗号分隔
				str = str .. key .. value .. ","
			end
		end
	end

	-- 去掉末尾多余的逗号后返回
	if string.sub(str, -1) == "," then
		return string.sub(str, 1, #str - 1)
	else
		return str
	end
end

-- ==== Serialize - 将 Lua table 序列化为可存储/传输的字符串 ====
-- @param tIn 要序列化的 table
-- @param bRaw 为 true 时输出不带 "SRL=" 前缀的原始花括号形式
-- @return 序列化后的字符串；完全空的表返回空字符串
function Serialize(tIn, bRaw)
	-- 先处理空表：直接返回空字符串
	if #tIn == 0 then
		-- 通过 pairs 探测表中是否真的没有任何键（#tIn 对非数组表不可靠）
		local empty = true
		for k in pairs(tIn) do
			-- 发现存在键，标记非空并提前退出
			empty = false
			break
		end
		-- 确实为空则返回空字符串
		if empty then
			return ""
		end
	end

	-- 原始模式：不添加 "SRL=" 前缀
	if bRaw then
		return "{"..MakeTable(tIn).."}"
	end

	-- 标准模式：添加 "SRL=" 前缀，便于 Deserialize 识别格式
	return "SRL={"..MakeTable(tIn).."}"
end