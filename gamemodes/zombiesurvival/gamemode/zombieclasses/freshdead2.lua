-- ============================================================================
-- 近期死者 (Recent Dead) — 僵尸职业（已禁用）
-- 继承自：freshdead
-- 特点：Fresh Dead的变体、已禁用状态
-- ============================================================================

-- 基础职业为"新鲜死者"
CLASS.Base = "freshdead"

-- 职业显示名称
CLASS.Name = "Recent Dead"
-- 翻译键名
CLASS.TranslationName = "class_recent_dead"
-- 描述文本键名
CLASS.Description = "description_fresh_dead"
-- 控制帮助文本键名
CLASS.Help = "controls_fresh_dead"

-- 初始可用/隐藏/已禁用
CLASS.Wave = 0
-- 隐藏（不直接可选）
CLASS.Hidden = true
-- 禁用（不参与游戏）
CLASS.Disabled = true
-- 解锁（但被禁用）
CLASS.Unlocked = true

-- 生命值
CLASS.Health = 130
-- 击杀得分
CLASS.Points = CLASS.Health/GM.HumanoidZombiePointRatio

-- 使用玩家模型
CLASS.UsePlayerModel = true
-- 不使用之前的模型
CLASS.UsePreviousModel = false

-- 服务端：被击杀时不做特殊处理
if SERVER then
	function CLASS:OnKilled() end
end

-- 客户端在此处结束
if not CLIENT then return end

-- 击杀图标
CLASS.Icon = "zombiesurvival/killicons/fresh_dead"
