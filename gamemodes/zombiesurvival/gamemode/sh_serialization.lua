-- 本文件提供了将Lua table（表）序列化为字符串以及从字符串反序列化回table的功能，主要用于数据存储或网络传输。

-- Deserialize 将一个序列化后的字符串转换回Lua table
-- Serialize 将一个Lua table转换为序列化字符串

-- 沙盒环境，限制反序列化时只能使用 Vector 和 Angle 两种特殊类型，防止恶意代码执行
local sandbox_env = {Vector = Vector, Angle = Angle}

-- 反序列化函数：将序列化字符串转换回 Lua table
-- @param sIn 输入的序列化字符串
-- @return 反序列化后得到的 table
function Deserialize(sIn)
	local out = {}

	-- 如果输入字符串为空或结尾不是 "}"，则返回空表
	if #sIn == 0 or string.sub(sIn, -1) ~= "}" then return out end

	-- 如果字符串开头不是 "SRL="，则手动补上该前缀
	if string.sub(sIn, 1, 4) ~= "SRL=" then sIn = "SRL="..sIn end

	-- 如果前缀后的第一个字符不是 "{"，说明格式错误，返回空表
	if string.sub(sIn, 5, 5) ~= "{" then return out end

	-- 拼接 " return SRL" 以构成合法的 Lua 返回语句，用于 CompileString 编译执行
	sIn = sIn.." return SRL"
	local func = CompileString(sIn, "deserialize", false)
	-- 如果编译返回的是字符串（错误信息），则打印错误
	if type(func) == "string" then
		print("Deserialization error: "..func)
	else
		-- 设置函数的沙盒环境，然后执行获取数据
		setfenv(func, sandbox_env)
		out = func() or out
	end

	return out
end

-- 定义允许进行序列化的数据类型表
local allowedtypes = {}
allowedtypes["string"] = true
allowedtypes["number"] = true
allowedtypes["table"] = true
allowedtypes["Vector"] = true
allowedtypes["Angle"] = true
allowedtypes["boolean"] = true

-- 内部递归函数：将 Lua table 转换为可求值的字符串表示
-- @param tab 要转换的 table
-- @param done 已处理过的 table 记录，用于防止循环引用
-- @return 序列化后的字符串
local function MakeTable(tab, done)
	local str = ""
	local done = done or {}

	-- 检查 table 是否为顺序索引（数组）
	local sequential = table.IsSequential(tab)

	-- 遍历 table 中的所有键值对
	for key, value in pairs(tab) do
		local keytype = type(key)
		local valuetype = type(value)

		-- 仅序列化允许的数据类型
		if allowedtypes[keytype] and allowedtypes[valuetype] then
			-- 如果是顺序数组，键使用空字符串（隐式索引）；否则生成键的字符串表示
			if sequential then
				key = ""
			else
				if keytype == "number" or keytype == "boolean" then 
					key ="["..tostring(key).."]="
				else
					key = "["..string.format("%q", tostring(key)).."]="
				end
			end

			-- 递归处理嵌套 table，并检测循环引用
			if valuetype == "table" and not done[value] then
				done[value] = true
				-- 如果 table 有自定义的 _serialize 方法，则使用该方法
				if type(value._serialize) == "function" then
					str = str..key..value:_serialize()..","
				else
					str = str..key.."{"..MakeTable(value, done).."},"
				end
			else
				-- 根据值类型生成对应的字符串表示
				if valuetype == "string" then 
					value = string.format("%q", value)
				elseif valuetype == "Vector" then
					value = "Vector("..value.x..","..value.y..","..value.z..")"
				elseif valuetype == "Angle" then
					value = "Angle("..value.pitch..","..value.yaw..","..value.roll..")"
				else
					value = tostring(value)
				end

				str = str .. key .. value .. ","
			end
		end
	end

	-- 去掉末尾多余的逗号
	if string.sub(str, -1) == "," then
		return string.sub(str, 1, #str - 1)
	else
		return str
	end
end

-- 序列化函数：将 Lua table 转换为可存储或传输的字符串
-- @param tIn 要序列化的 table
-- @param bRaw 是否以原始格式输出（不加 "SRL=" 前缀）
-- @return 序列化后的字符串
function Serialize(tIn, bRaw)
	-- 检查 table 是否完全为空
	if #tIn == 0 then
		local empty = true
		for k in pairs(tIn) do
			empty = false
			break
		end
		if empty then
			return ""
		end
	end

	-- 原始模式：不添加 "SRL=" 前缀，只返回花括号包裹的内容
	if bRaw then
		return "{"..MakeTable(tIn).."}"
	end

	-- 标准模式：添加 "SRL={" 前缀以便反序列化时识别
	return "SRL={"..MakeTable(tIn).."}"
end
