-- ============================================================================
-- weapon_zs_t_extinctionorgan.lua - 灭绝器官饰品武器
-- 负责：继承末日器官（weapon_zs_t_doomorgan），仅覆盖名称和描述，
--       使用逻辑与末日器官完全相同（清除负面状态）
-- ============================================================================
AddCSLuaFile()

-- 继承末日器官饰品武器
SWEP.Base = "weapon_zs_t_doomorgan"

-- 武器显示名称与描述（本地化键）
SWEP.PrintName = ""..translate.Get("weapon_zs_t_extinctionorgan")
SWEP.Description = ""..translate.Get("weapon_zs_t_extinctionorgan_description")
