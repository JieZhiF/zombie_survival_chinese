-- ============================================================================
-- info_sigilnode - 印记生成节点（点实体）
-- 负责：由地图作者放置，标记印记（sigil）可生成的位置；
--       支持 KeyValue（ForceSpawn）强制该节点必定生成印记
-- ============================================================================

-- 实体类型：点实体（纯逻辑标记，无渲染）
ENT.Type = "point"

-- ==== Initialize - 节点初始化 ====
function ENT:Initialize()
	-- 默认不强制生成（由印记生成系统按概率/规则选择节点）
	if self.ForceSpawn == nil then self.ForceSpawn = false end
end

-- ==== KeyValue - 读取 Hammer 实体属性 ====
function ENT:KeyValue(key, value)
	key = string.lower(key)
	-- forcespawn：按数值（1/0）设置强制生成标记
	if key == "forcespawn" then
		self.ForceSpawn = tonumber(value) == 1
	end
end
