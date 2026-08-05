-- ============================================================================
-- init.lua - 拾取限制逻辑实体（服务端）：配置拾取上限规则
-- 负责：通过地图实体键值/输入动态调整武器、弹药、手电筒拾取上限
-- ============================================================================
-- 点实体类型（无模型、无物理，纯逻辑触发器）
ENT.Type = "point"

-- ==== Initialize - 初始化占位（无初始化逻辑） ====
function ENT:Initialize()
end

-- ==== Think - 每帧占位（纯配置实体，无需周期逻辑） ====
function ENT:Think()
end

-- ==== AcceptInput - 处理地图输入：转发为对应的键值配置 ====
function ENT:AcceptInput(name, activator, caller, args)
	name = string.lower(name)
	if name == "setmaxweaponpickups" then
		self:SetKeyValue("maxweaponpickups", args)
	elseif name == "setmaxammopickups" then
		self:SetKeyValue("maxammopickups", args)
	elseif name == "setmaxflashlightpickups" then
		self:SetKeyValue("maxflashlightpickups", args)
	elseif name == "setweaponrequiredforammo" then
		self:SetKeyValue("weaponrequiredforammo", args)
	end
end

-- ==== KeyValue - 解析键值：写入全局拾取上限（-1 表示无限制） ====
function ENT:KeyValue(key, value)
	key = string.lower(key)
	if key == "maxweaponpickups" then
		value = tonumber(value) or -1
		-- -1 清除限制，否则设置每人武器拾取上限
		if value == -1 then
			GAMEMODE.MaxWeaponPickups = nil
		else
			GAMEMODE.MaxWeaponPickups = value
		end
	elseif key == "maxammopickups" then
		value = tonumber(value) or -1
		-- -1 清除限制，否则设置每人弹药拾取上限
		if value == -1 then
			GAMEMODE.MaxAmmoPickups = nil
		else
			GAMEMODE.MaxAmmoPickups = value
		end
	elseif key == "maxflashlightpickups" then
		value = tonumber(value) or -1
		-- -1 清除限制，否则设置每人手电筒拾取上限
		if value == -1 then
			GAMEMODE.MaxFlashlightPickups = nil
		else
			GAMEMODE.MaxFlashlightPickups = value
		end
	elseif key == "weaponrequiredforammo" then
		-- 值为 1 时要求持有对应武器才能拾取弹药
		GAMEMODE.WeaponRequiredForAmmo = tonumber(value) == 1
	end
end
