-- ============================================================================
-- sck/cl_util.lua - SCK（SWEP 构造工具包）文件保存工具（客户端）
-- 负责：生成合法的存档文件名（过滤非法字符），并将当前 SWEP 的全部
--       自定义外观数据（模型、骨骼修改、持枪姿势等）编码为 GLON 文件
--       写入 DATA 目录（swep_construction_kit/），支持自动重命名避免覆盖。
-- ============================================================================

-- 文件名中不允许出现的非法字符表（对应 Windows 文件系统限制）
local badsymbols = {"/", "\\", "?", ":", "*", "\"", "|", "<", ">"}

-- ==== sanitize_filename - 将文件名中的非法字符替换为下划线 ====
-- @param text string - 原始文件名
-- @return string - 净化后的合法文件名
local function sanitize_filename(text)
	for _, symb in ipairs(badsymbols) do
		text = string.Replace(text, symb, "_")
	end

	return text
end

-- ==== GetDesiredFilename - 获取用户输入并经净化处理的目标文件名 ====
-- @param satext DTextEntry|nil - 文件名输入框控件
-- @return string|nil - 净化后的文件名（控件为空或内容为空时返回 nil）
function GetDesiredFilename(satext)
	if not satext then return end

	-- 读取输入框内容并去除首尾空白
	local txt = satext:GetValue()

	txt = string.Trim(txt)

	-- 过滤非法字符后返回
	txt = sanitize_filename(txt)
	return txt
end

-- ==== SaveAsSCKFile - 将当前武器外观配置保存为 GLON 存档文件 ====
-- @param overridetext string|nil - 指定文件名（优先级高于输入框内容）
-- @param wep Weapon|nil - 目标武器，缺省时取本地玩家当前的 SCK SWEP
-- @param satext DTextEntry|nil - 文件名输入框控件
-- @param force boolean|nil - 为 true 时允许覆盖同名文件
function SaveAsSCKFile(overridetext, wep, satext, force)
	wep = wep or GetSCKSWEP(LocalPlayer(), true)
	if not IsValid(wep) then return end

	-- 确定保存文件名：优先外部指定，其次取输入框净化后的内容
	local text = overridetext or GetDesiredFilename(satext) or ""
	if (text == "") then return end

	local save_data = wep.save_data

	-- collect all save data
	-- 收集武器全部自定义外观数据（深拷贝，避免后续修改污染原始表）
	save_data.v_models = table.Copy(wep.v_models)
	save_data.w_models = table.Copy(wep.w_models)
	save_data.v_bonemods = table.Copy(wep.v_bonemods)
	-- remove caches
	-- 清除运行时生成的模型/精灵缓存字段（这些对象无法序列化）
	for k, v in pairs(save_data.v_models) do
		v.createdModel = nil
		v.createdSprite = nil
	end
	for k, v in pairs(save_data.w_models) do
		v.createdModel = nil
		v.createdSprite = nil
	end
	-- 保存视图模型相关的普通配置项
	save_data.ViewModelFlip = wep.ViewModelFlip
	save_data.UseHands = wep.UseHands
	save_data.ViewModel = wep.ViewModel
	save_data.CurWorldModel = wep.CurWorldModel
	save_data.ViewModelFOV = wep.ViewModelFOV
	save_data.HoldType = wep.HoldType
	save_data.IronSightsEnabled = wep:GetIronSights()
	save_data.IronSightsPos, save_data.IronSightsAng = wep:GetIronSightCoordination()
	save_data.ShowViewModel = wep.ShowViewModel
	save_data.ShowWorldModel = wep.ShowWorldModel

	-- 用 GLON 编码整个存档表（pcall 保护，编码失败不崩溃）
	local succ, val = pcall(glon.encode, save_data)

	-- 构造 DATA 目录下的存档文件路径
	local filename = "swep_construction_kit/"..text..".txt"

	-- 非强制模式下若文件名已存在，自动追加数字后缀直到不冲突（需要重命名时）
	if not force and file.Exists(filename, "DATA") then --we need to rename
		for i = 1, 9999 do
			local attempt = "swep_construction_kit/"..text..i..".txt"

			if not file.Exists(attempt, "DATA") then
				filename = attempt
				text = text..i
				break
			end
		end
	end

	-- 编码失败时提示玩家并中止保存
	if not succ then LocalPlayer():ChatPrint("Failed to encode settings!") return end

	-- 写入存档文件并反馈保存结果
	file.Write(filename, val)
	LocalPlayer():ChatPrint("Saved file \""..text.."\"!")
end