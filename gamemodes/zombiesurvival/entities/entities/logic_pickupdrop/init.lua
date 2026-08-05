-- ============================================================================
-- init.lua - 拾取/丢弃控制逻辑实体（地图专用）
-- 负责：按目标实体名批量禁用/启用拾取，或强制持有者放下指定道具，并透传 On 输出
-- ============================================================================
-- 点实体类型（无模型无物理）
ENT.Type = "point"

-- ==== Initialize - 初始化目标实体名 ====
-- 未设置 EntityToWatch 时使用占位名（不会匹配到任何实体）
function ENT:Initialize()
	self.EntityToWatch = self.EntityToWatch or "_____"
end

-- ==== Think - 思考 ====
-- 无持续逻辑，空实现
function ENT:Think()
end

-- ==== AcceptInput - 处理逻辑输入 ====
-- On 前缀输入直接透传输出；其余按 enablepickup/disablepickup/forcedrop 批量操作目标实体
function ENT:AcceptInput(name, activator, caller, args)
	name = string.lower(name)
	-- On 开头输入：直接触发同名输出（转给其它逻辑实体）
	if string.sub(name, 1, 2) == "on" then
		self:FireOutput(name, activator, caller, args)
		return true
	elseif name == "disablepickup" then
		-- 禁止拾取所有同名目标实体
		for _, ent in pairs(ents.FindByName(self.EntityToWatch)) do
			ent.m_NoPickup = true
		end
		return true
	elseif name == "enablepickup" then
		-- 恢复拾取所有同名目标实体
		for _, ent in pairs(ents.FindByName(self.EntityToWatch)) do
			ent.m_NoPickup = nil
		end
		return true
	elseif name	== "forcedrop" then
		-- 遍历所有「人类持有」状态，强制放下匹配的目标道具
		for _, ent in pairs(ents.FindByClass("status_human_holding")) do
			local object = ent:GetObject()
			if object:IsValid() and object:GetName() == self.EntityToWatch then
				ent:Remove()
			end
		end
		return true
	end
end

-- ==== KeyValue - 解析键值 ====
-- 记录目标实体名；On 前缀键值注册为输出（供逻辑连线使用）
function ENT:KeyValue(key, value)
	key = string.lower(key)
	if key == "entitytowatch" then
		self.EntityToWatch = value or self.EntityToWatch
	elseif string.sub(key, 1, 2) == "on" then
		self:AddOnOutput(key, value)
	end
end
