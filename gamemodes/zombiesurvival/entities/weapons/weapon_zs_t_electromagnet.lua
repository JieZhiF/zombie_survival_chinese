-- ============================================================================
-- weapon_zs_t_electromagnet.lua - 电磁铁武器
-- 负责：基于磁铁武器母本定义电磁铁的显示名称
-- ============================================================================
AddCSLuaFile()

-- 基于磁铁武器母本
SWEP.Base = "weapon_zs_t_magnet"
-- 武器名称（从翻译表读取）
SWEP.PrintName = ""..translate.Get("weapon_zs_t_electromagnet")
