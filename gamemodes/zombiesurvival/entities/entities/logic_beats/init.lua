-- ============================================================================
-- logic_beats/init.lua - 节拍开关逻辑实体（服务器）
-- 负责：通过 Enable/Disable 输入与 enabled 键值控制全局节拍效果开关
--       （全局布尔 beatsdisabled：true 时禁用节拍相关的视觉/听觉反馈）
-- ============================================================================

-- 实体类型：点实体（仅存在于 Hammer 地图中，无物理模型）
ENT.Type = "point"

-- ==== AcceptInput - 处理 Enable/Disable 输入，切换全局节拍开关 ====
function ENT:AcceptInput(name, activator, caller, args)
	name = string.lower(name)
	if name == "enable" then
		-- 启用节拍效果
		SetGlobalBool("beatsdisabled", false)
	elseif name == "disable" then
		-- 禁用节拍效果
		SetGlobalBool("beatsdisabled", true)
	end
end

-- ==== KeyValue - 处理地图键值 enabled：设定初始节拍开关状态 ====
function ENT:KeyValue(key, value)
	key = string.lower(key)
	if key == "enabled" then
		-- enabled 值为 "0" 时表示初始禁用（与全局布尔取反对应）
		SetGlobalBool("beatsdisabled", value == "0")
	end
end
