-- ============================================================================
-- shadow_gore_child/shared.lua - 暗影血娃 (Shadow Child) 共享定义
-- 负责：职业属性（继承血娃）、隐藏标记、低血量高移速、骷髅覆写模型
-- ============================================================================

-- 继承血娃 (Gore Child) 的基础属性
CLASS.Base = "gore_child"

-- 隐藏职业（不在常规职业列表中显示，由特殊机制生成）
CLASS.Hidden = true

-- 职业显示名称
CLASS.Name = "Shadow Child"
-- 翻译键名
CLASS.TranslationName = "class_shadow_gore_child"
-- 描述文本键名
CLASS.Description = "description_shadow_gore_child"
-- 控制帮助文本键名
CLASS.Help = "controls_shadow_gore_child"

-- 生命值（极低，脆弱的暗影小怪）
CLASS.Health = 15
-- 移动速度
CLASS.Speed = 155

-- 击杀得分
CLASS.Points = 0.5

-- 绑定的武器
CLASS.SWEP = "weapon_zs_shadowgorechild"

-- 覆写模型（骷髅模型）
CLASS.OverrideModel = Model("models/player/skeleton.mdl")

-- 不隐藏主模型（覆写模型与主模型叠加显示）
CLASS.NoHideMainModel = true
