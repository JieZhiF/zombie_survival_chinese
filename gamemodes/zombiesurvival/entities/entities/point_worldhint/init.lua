-- ============================================================================
-- point_worldhint - 世界提示点实体（服务端）
-- 负责：初始化无碰撞的隐形悬浮实体，处理 Hammer 输入的 setviewer/sethint/setrange 与键值解析，并始终向客户端传输
-- ============================================================================
INC_SERVER()

-- ==== Initialize - 初始化实体：关闭阴影、无移动、无碰撞体 ====
function ENT:Initialize()
	self:DrawShadow(false)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_NONE)
	self:SetCollisionGroup(COLLISION_GROUP_WORLD)
end

-- ==== AcceptInput - 接收地图实体输入，转换为对应的键值设置 ====
function ENT:AcceptInput(name, activator, caller, args)
	if name == "setviewer" then
		self:SetKeyValue("viewer", args)
		return true
	elseif name == "sethint" then
		self:SetKeyValue("hint", args)
		return true
	elseif name == "setrange" then
		self:SetKeyValue("range", args)
		return true
	end
end

-- ==== KeyValue - 解析 Hammer 键值并写入对应的网络属性 ====
function ENT:KeyValue(key, value)
	key = string.lower(key)
	if key == "viewer" then
		self:SetViewable(tonumber(value) or 0)
	elseif key == "hint" then
		self:SetHint(value)
	elseif key == "range" then
		self:SetRange(tonumber(value) or 0)
	end
end

-- ==== UpdateTransmitState - 强制本实体始终传输给所有客户端 ====
function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end
