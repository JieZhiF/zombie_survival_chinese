-- ============================================================================
-- cl_init.lua - 地图武器基类（客户端）
-- 负责：隐藏武器栏/HUD 信息，掉落时绘制发光指示精灵
-- ============================================================================
include('shared.lua')

SWEP.Slot = -1 -- 不占武器栏
SWEP.SlotPos = -1 -- 无槽位
SWEP.DrawAmmo = false -- 不显示弹药 HUD
SWEP.DrawCrosshair = true -- 绘制准星
SWEP.DrawWeaponInfoBox = false -- 不显示武器信息框

local glowmat = Material("sprites/glow04_noz") -- 发光指示材质
-- ==== DrawWorldModel - 绘制掉落地上的武器发光精灵（吸引玩家注意） ====
function SWEP:DrawWorldModel()
	local owner = self:GetOwner()
	if owner:IsValid() then return end

	local pos = self:GetPos()
	local col = self:GetClass() == "weapon_knife" and Color(0, 255, 0, 200) or Color(255, 125, 63, 200)

	-- 随时间脉动的发光精灵
	render.SetMaterial(glowmat)
	render.DrawSprite(pos, math.abs(30 + 15 * math.sin(RealTime() * 7 + 1.5)), math.abs(30 + 15 * math.sin(RealTime() * 7)), col)
end

SWEP.DrawWorldModelTranslucent = SWEP.DrawWorldModel -- 半透明绘制复用同一函数
