-- ============================================================================
-- weapon_zs_coolwisp/shared.lua - 寒冰幽灵武器（共享）
-- 负责：寒冰幽灵的冰冻吐息：对周围敌人附加冰霜状态并造成腿部减速，
--       以及换弹键的风声音效
-- ============================================================================
-- 显示名称
SWEP.PrintName = ""..translate.Get("weapon_zs_coolwisp")

-- 无限弹药（无弹匣概念）
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"

-- 右键同样无限弹药
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"

-- 仅僵尸可用
SWEP.ZombieOnly = true
-- 属于近战武器（走近战机制）
SWEP.IsMelee = true

-- 模型（匕首占位，实际会被隐藏）
SWEP.ViewModel = "models/weapons/v_knife_t.mdl"
SWEP.WorldModel = "models/weapons/w_knife_t.mdl"

-- 缓存全局函数（性能优化）
local math_random = math.random
local string_format = string.format

-- ==== Initialize - 初始化 ====
-- 隐藏原生视图/世界模型
function SWEP:Initialize()
	self:HideViewAndWorldModel()
end

-- ==== Think - 每帧逻辑（空实现） ====
function SWEP:Think()
end

-- ==== PrimaryAttack - 冰冻吐息 ====
-- 半径 57 内的敌人附加 4 秒冰霜状态并叠加腿部伤害；吐息期间自身无敌防误伤
function SWEP:PrimaryAttack()
	if CurTime() < self:GetNextPrimaryAttack() then return end
	self:SetNextPrimaryAttack(CurTime() + 3)

	local owner = self:GetOwner()

	owner.LastRangedAttack = CurTime()

	if SERVER then
		-- 遍历范围内敌人：附加冰霜状态 + 腿部伤害
		for _, ent in pairs(util.BlastAlloc(self, owner, owner:GetPos(), 57)) do
			if ent:IsValidLivingPlayer() and gamemode.Call("PlayerShouldTakeDamage", ent, owner) and ent ~= owner then
				ent:GiveStatus("frost", 4)
				ent:AddLegDamageExt(10, owner, self, SLOWTYPE_COLD)
			end
		end

		-- 吐息期间自身无敌，避免炸到自己
		owner:GodEnable()
		util.BlastDamageEx(self, owner, owner:GetShootPos(), 57, 5, DMG_DROWN)
		owner:GodDisable()
	end

	-- 客户端预测：播放冰爆特效
	if IsFirstTimePredicted() then
		local effectdata = EffectData()
			effectdata:SetOrigin(owner:GetShootPos())
			effectdata:SetNormal(owner:GetAimVector())
		util.Effect("explosion_cold", effectdata)
	end
end

-- ==== SecondaryAttack - 右键（空实现） ====
function SWEP:SecondaryAttack()
end

-- ==== Reload - 换弹键播放风声 ====
-- 冷却 5 秒，随机播放风声呻吟音效
function SWEP:Reload()
	if CurTime() >= self:GetNextSecondaryAttack() then
		self:SetNextSecondaryAttack(CurTime() + 5)
		self:EmitSound(string_format("ambient/wind/wind_moan%d.wav", math_random(2)))
	end
end
