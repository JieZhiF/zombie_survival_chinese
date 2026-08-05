-- ============================================================================
-- trigger_zombieclass/init.lua - 僵尸职业触发器（服务器）
-- 负责：玩家（僵尸）进入/离开触发区域时切换其职业；支持按当前职业限制、
--       一次性生效、立即变化（保持位置）与设定死亡后职业
-- ============================================================================

-- 实体类型：体积触发器（brush trigger）
ENT.Type = "brush"

-- ==== Initialize - 初始化：启用触发并补齐默认键值 ====
function ENT:Initialize()
	-- 设为触发器
	self:SetTrigger(true)

	-- 默认启用
	if self.On == nil then self.On = true end
	-- 默认立即变化（保持玩家位置与视角）
	if self.InstantChange == nil then self.InstantChange = true end
	-- 默认不限当前职业（-1 表示任意）
	if self.OnlyWhenClass == nil then
		self.OnlyWhenClass = {}
		self.OnlyWhenClass[1] = -1
	end
end

-- ==== Think - 无持续逻辑（占位实现） ====
function ENT:Think()
end

-- ==== AcceptInput - 处理输入：开关触发器与动态修改各职业参数 ====
function ENT:AcceptInput(name, caller, activator, arg)
	name = string.lower(name)
	if name == "seton" then
		-- 数字参数设定开关状态
		self.On = tonumber(arg) == 1
		return true
	elseif name == "enable" then
		self.On = true
		return true
	elseif name == "disable" then
		self.On = false
		return true
	elseif name == "settouchclass" or name == "setendtouchclass" or name == "settouchdeathclass" or name == "setendtouchdeathclass" or name == "setonetime" or name == "setinstantchange" or name == "setonlywhenclass" then
		-- 将 set 前缀输入转发为对应键值处理（去掉 "set" 前缀）
		self:KeyValue(string.sub(name, 4), arg)
	end
end

-- ==== KeyValue - 处理地图键值：启用状态、各职业参数与限制条件 ====
function ENT:KeyValue(key, value)
	key = string.lower(key)
	if key == "enabled" then
		self.On = tonumber(value) == 1
	elseif key == "touchclass" then
		-- 接触时切换的职业名
		self.TouchClass = string.lower(value)
	elseif key == "onlywhenclass" then
		-- 触发限制：仅当玩家当前职业在列表内（小写职业名，逗号分隔）
		self.OnlyWhenClass = {}
		if value == "disabled" then
			-- 关闭限制 = 任意职业可触发
			self.OnlyWhenClass[1] = -1
		else
			-- 解析职业名列表为职业索引表（-1 兜底，未命中项留空）
			self.OnlyWhenClass[1] = -1
			for i, allowed_class in pairs(string.Explode(",", string.lower(value))) do
				for k, v in ipairs(GAMEMODE.ZombieClasses) do
					if string.lower(v.Name) == allowed_class then
						self.OnlyWhenClass[i] = k
						break
					end
				end
			end
		end
	elseif key == "endtouchclass" then
		-- 离开时切换的职业名
		self.EndTouchClass = string.lower(value)
	elseif key == "touchdeathclass" then
		-- 接触时设定的死亡后职业
		self.TouchDeathClass = string.lower(value)
	elseif key == "endtouchdeathclass" then
		-- 离开时设定的死亡后职业
		self.EndTouchDeathClass = string.lower(value)
	elseif key == "onetime" then
		-- 一次性：切换后记录原职业为死亡职业，不再重复切换
		self.OneTime = tonumber(value) == 1
	elseif key == "instantchange" then
		self.InstantChange = tonumber(value) == 1
	end
end

-- ==== DoTouch - 触发核心：满足条件时将僵尸切换为目标职业 ====
function ENT:DoTouch(ent, class_name, death_class_name)
	-- 仅在启用且目标是存活僵尸时生效
	if self.On and ent:IsValidLivingZombie() then
		local prev = ent:GetZombieClass()
		-- 当前职业在允许列表内，或限制关闭（-1）时才执行
		if table.HasValue( self.OnlyWhenClass, prev ) or self.OnlyWhenClass[1] == -1 then
			-- 切换职业：目标职业名有效且不同于当前职业
			if class_name and class_name ~= string.lower(ent:GetZombieClassTable().Name) then
				for k, v in ipairs(GAMEMODE.ZombieClasses) do
					if string.lower(v.Name) == class_name then
						-- 记录位置与视角，静默杀死后重生为新职业（不占出生点）
						local prevpos = ent:GetPos()
						local prevang = ent:EyeAngles()
						ent:KillSilent()
						ent:SetZombieClass(k)
						ent.DidntSpawnOnSpawnPoint = true
						ent:UnSpectateAndSpawn()
						-- 一次性模式：将原职业记录为死亡后职业（死亡后变回原职业）
						if self.OneTime then
							ent.DeathClass = prev
						end
						-- 立即变化模式：恢复位置与视角（避免刷新位移）
						if self.InstantChange then
							ent:SetPos(prevpos)
							ent:SetEyeAngles(prevang)
						end
						break
					end
				end
			end
			-- 设定死亡后职业：目标名有效且不同于当前职业
			if death_class_name and death_class_name ~= string.lower(ent:GetZombieClassTable().Name) then
				for k, v in ipairs(GAMEMODE.ZombieClasses) do
					if string.lower(v.Name) == death_class_name then
						ent.DeathClass = k
					break
					end
				end
			end
		end
	end
end

-- ==== Touch - 接触触发：应用接触类职业参数 ====
function ENT:Touch(ent)
	self:DoTouch(ent, self.TouchClass, self.TouchDeathClass)
end
-- 开始接触与持续接触共用同一处理
ENT.StartTouch = ENT.Touch

-- ==== EndTouch - 离开触发：应用离开类职业参数 ====
function ENT:EndTouch(ent)
	self:DoTouch(ent, self.EndTouchClass, self.EndTouchDeathClass)
end
