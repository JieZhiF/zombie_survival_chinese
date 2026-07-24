-- ============================================================
-- 僵尸逃跑模式客户端逻辑
-- 包括冻结倒计时提示等HUD元素
-- ============================================================

-- 引入共享的僵尸逃跑模式配置
include("sh_zombieescape.lua")

-- 如果当前不是僵尸逃跑模式，则不加载后续逻辑
if not GM.ZombieEscape then return end

-- 在HUD上绘制冻结状态提示
hook.Add("HUDPaint", "zombieescape", function()
	if not MySelf:IsValid() then return end

	-- 当波次为0、波次未激活、并且玩家是僵尸阵营或仍在冻结时间内时，显示冻结提示
	if GAMEMODE:GetWave() == 0 and not GAMEMODE:GetWaveActive() and (MySelf:Team() == TEAM_UNDEAD or CurTime() < GAMEMODE:GetWaveStart() - GAMEMODE.ZE_FreezeTime) then
		draw.SimpleTextBlur(translate.Format("ze_humans_are_frozen_until_x", GAMEMODE.ZE_FreezeTime), "ZSHUDFontSmall", ScrW() / 2, ScrH() / 2, COLOR_DARKRED, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end)
