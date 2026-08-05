-- ============================================================================
-- init.lua - 溺水状态（服务器）：水下检测与溺水伤害
-- 负责：判定玩家是否全身入水/处于无空气区域，溺水进度满时周期性造成伤害
-- ============================================================================
AddCSLuaFile("shared.lua")

include("shared.lua")

-- ==== Think - 周期更新水下标记，并对溺水玩家造成伤害 ====
function ENT:Think()
	local owner = self:GetOwner()
	-- 拥有者无效或已死亡：不做处理
	if not owner:IsValid() or not owner:Alive() then return end

	-- 非人类阵营时移除状态（仅人类会溺水）
	if owner:Team() ~= TEAM_HUMAN then self:Remove() return end

	-- 根据水位与无空气区域标记切换水下状态
	if self:IsUnderwater() then
		-- 已出水且不在无空气区域：标记为上岸
		if owner:WaterLevel() < 3 and not (owner.NoAirBrush and owner.NoAirBrush:IsValid()) then
			self:SetUnderwater(false)
		end
	-- 全身入水（水位≥3）或位于无空气区域：标记为入水
	elseif owner:WaterLevel() >= 3 or owner.NoAirBrush and owner.NoAirBrush:IsValid() then
		self:SetUnderwater(true)
	end

	-- 溺水进度满：每秒造成一次溺水伤害
	if self:IsDrowning() then
		owner:TakeSpecialDamage(10, DMG_DROWN, game.GetWorld())

		self:NextThink(CurTime() + 1)
		return true
	-- 已完全恢复且不在水中：溺水状态结束，移除自身
	elseif not self:IsUnderwater() and self:GetDrown() == 0 then
		self:Remove()
	end
end
