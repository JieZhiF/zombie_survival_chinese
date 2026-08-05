-- ============================================================================
-- status_ghost_detpack - 遥控炸药包（Detpack）幽灵放置状态实体（单文件）
-- 负责：继承幽灵放置基类，配置炸药包的放置预览，并限制其只能放置在火车/线性移动轨道类实体上
-- ============================================================================

-- 客户端与服务器同时加载本文件
AddCSLuaFile()

-- 实体类型：动画实体
ENT.Type = "anim"
-- 基础实体：status_ghost_base（通用放置幽灵基类）
ENT.Base = "status_ghost_base"

-- 幽灵预览模型（已安装的 C4 模型）
ENT.GhostModel = Model("models/weapons/w_c4_planted.mdl")
-- 幽灵模型的旋转角度
ENT.GhostRotation = Angle(270, 0, 0)
-- 确认放置时实际生成的目标实体
ENT.GhostEntity = "prop_detpack"
-- 与目标实体对应的放置武器
ENT.GhostWeapon = "weapon_zs_detpack"
-- 不要求放置面为平地（允许斜面/其他朝向）
ENT.GhostFlatGround = false
-- 允许放置的最大距离（英寸）
ENT.GhostDistance = 8

-- ==== CustomValidate - 自定义放置校验：仅允许放置在 func_tracktrain/func_movelinear 移动实体上 ====
function ENT:CustomValidate(tr)
	local hitent = tr.Entity
	if hitent and hitent:IsValid() and hitent:GetClass() ~= "func_tracktrain" and hitent:GetClass() ~= "func_movelinear" then
		return false
	end

	return true
end
