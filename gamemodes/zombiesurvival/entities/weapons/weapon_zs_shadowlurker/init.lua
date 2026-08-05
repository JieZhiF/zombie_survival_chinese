-- ============================================================================
-- weapon_zs_shadowlurker/init.lua - 暗影潜行者（服务器端定义）
-- 负责：爪击命中时附加暗视负面状态
-- ============================================================================
-- 服务器端专用（GMod 武器文件的标准服务器入口标记）
INC_SERVER()

-- ==== ApplyMeleeDamage - 近战命中附加效果 ====
function SWEP:ApplyMeleeDamage(ent, trace, damage)
	-- 命中玩家时给予 5 秒暗视状态（削弱视野）
	if ent:IsPlayer() then
		ent:GiveStatus("dimvision", 5)
	end

	-- 继续执行基础近战伤害逻辑
	self.BaseClass.ApplyMeleeDamage(self, ent, trace, damage)
end
