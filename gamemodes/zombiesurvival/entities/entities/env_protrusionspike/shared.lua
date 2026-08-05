-- ============================================================================
-- env_protrusionspike/shared.lua - 突起尖刺环境实体（共享部分）
-- 负责：定义环境机关"突起尖刺"（由脚本/地图事件触发生成），
--       设置半透明渲染、不可被子弹/近战/射线攻击的特性，
--       并预缓存模型与玻璃破碎音效
-- ============================================================================

-- 实体类型：动画实体
ENT.Type = "anim"

-- 半透明渲染组（尖刺半透明显示）
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
-- 忽略子弹（不可被射击破坏）
ENT.IgnoreBullets = true
-- 忽略近战攻击
ENT.IgnoreMelee = true
-- 忽略玩家视线射线（可被透视）
ENT.IgnoreTraces = true

-- 预缓存尖刺模型与触发音效，避免运行时卡顿
util.PrecacheModel("models/props_wasteland/rockcliff06d.mdl")
util.PrecacheSound("physics/glass/glass_largesheet_break1.wav")
util.PrecacheSound("physics/glass/glass_largesheet_break2.wav")
util.PrecacheSound("physics/glass/glass_largesheet_break3.wav")
