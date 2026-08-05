-- ============================================================================
-- point_worldhint - 世界提示点实体（共享端）
-- 负责：声明实体类型与网络同步属性（观看者队伍/提示文字/显示范围），并提供提示文字的本地化读取
-- ============================================================================

-- 实体类型：动画实体
ENT.Type = "anim"

-- 可见队伍编号：0 表示所有队伍可见，非 0 时仅对应队伍的玩家可见
AccessorFuncDT(ENT, "Viewable", "Int", 0)
-- 提示文字内容（原始文本或翻译键）
AccessorFuncDT(ENT, "Hint", "String", 0)
-- 显示范围（英寸），0 表示不限制距离
AccessorFuncDT(ENT, "Range", "Float", 0)
-- 提示文字是否为翻译键：true 时通过 translate.Get 本地化
AccessorFuncDT(ENT, "Translated", "Bool", 0)

-- ==== GetHint - 获取提示文字，标记为翻译键时返回本地化结果 ====
function ENT:GetHint()
	local hint = self:GetDTString(0)

	-- 需要翻译时返回本地化文本，否则原样返回
	if self:GetTranslated() then return translate.Get(hint) end

	return hint
end
