-- ============================================================================
-- logic_stripweapons - 武器剥夺逻辑实体（点实体）
-- 负责：按输入剥夺激活者（仅存活人类）的武器，支持保留拳头与动态键值配置
-- ============================================================================

-- 实体类型：点实体
ENT.Type = "point"

-- ==== Initialize - 补全 KeepFists 键值默认值（默认保留拳头） ====
function ENT:Initialize()
	self.KeepFists = self.KeepFists or 1
end

-- ==== AcceptInput - 处理 stripweapon/stripallweapons/setkeepfists 输入，仅对存活人类玩家生效 ====
function ENT:AcceptInput(name, activator, caller, args)
	name = string.lower(name)
	if name == "stripweapon" then
		if activator:IsPlayer() and activator:Alive() and activator:Team() == TEAM_HUMAN then
				-- 剥离指定类别的单件武器
				activator:StripWeapon(args)
		end
	elseif name == "stripallweapons" then
		if activator:IsPlayer() and activator:Alive() and activator:Team() == TEAM_HUMAN then
			-- 保留拳头模式：逐个剥离除拳头外的全部武器
			if tonumber(self.KeepFists) == 1 then
				local weps = activator:GetWeapons()
				for k, v in pairs(weps) do
					local weaponclass = v:GetClass()
					if weaponclass ~= "weapon_zs_fists" then activator:StripWeapon(weaponclass) end
				end
			else
				-- 未开启保留拳头时直接全部剥离
				activator:StripWeapons(args)
			end
		end
	elseif name == "setkeepfists" then
		self.KeepFists = tonumber(args)
	end
end

-- ==== KeyValue - 解析 Hammer 键值：keepfists（是否保留拳头武器） ====
function ENT:KeyValue(key, value)
	key = string.lower(key)
	if key == "keepfists" then
		self.KeepFists = tonumber(value)
	end
end
		