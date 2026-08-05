-- ============================================================================
-- decal_scorch.lua - 焦痕贴图特效（客户端）
-- 负责：在命中位置沿表面法线方向投射一个烧焦痕迹贴图，
--       用于表现火焰/爆炸攻击留下的灼烧痕迹
-- ============================================================================

-- ==== Init - 特效初始化：在命中面投射焦痕贴图 ====
function EFFECT:Init(data)
	-- 命中位置与表面法线
	local pos = data:GetOrigin()
	local normal = data:GetNormal()

	-- 以命中点为原点沿法线方向投射焦痕贴图（Start 与 End 确定贴图朝向）
	util.Decal("Scorch", pos + normal, pos - normal)
end

-- ==== Think - 特效思考：一次性贴图效果，无需持续更新 ====
function EFFECT:Think()
	return false
end

-- ==== Render - 无自定义渲染，贴图由引擎贴图系统绘制 ====
function EFFECT:Render()
end
