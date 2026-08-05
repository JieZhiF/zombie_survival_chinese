-- ============================================================================
-- weapon_zs_pukepus/shared.lua - 呕吐僵尸武器（共享）
-- 负责：呕吐僵尸的基础属性、呕吐间隔与呕吐弹（食肉团/毒团）发射状态
-- ============================================================================
-- 基于僵尸通用武器
SWEP.Base = "weapon_zs_zombie"

-- 显示名称
SWEP.PrintName = ""..translate.Get("weapon_zs_pukepus")

-- 呕吐攻击的间隔（秒）
SWEP.Primary.Delay = 3.5

-- 第一/第三人称模型（撬棍模型占位，实际会被隐藏）
SWEP.ViewModel = "models/weapons/v_crowbar.mdl"
SWEP.WorldModel = "models/weapons/w_crowbar.mdl"

-- 下一次呕吐弹发射时间
SWEP.NextPuke = 0
-- 剩余待发射的呕吐弹数量
SWEP.PukeLeft = 0

-- ==== Initialize - 初始化 ====
-- 隐藏原生视图/世界模型后，再走基础初始化
function SWEP:Initialize()
	self:HideViewAndWorldModel()

	self.BaseClass.Initialize(self)
end

-- ==== PrimaryAttack - 左键触发呕吐 ====
-- 按近战速度倍率计算呕吐间隔，并填充 35 发呕吐弹交给 Think 逐发发射
function SWEP:PrimaryAttack()
	if CurTime() < self:GetNextPrimaryFire() then return end
	local owner = self:GetOwner()
	local delay = owner:GetMeleeSpeedMul()
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay * delay)

	self.PukeLeft = 35

	-- 播放呕吐音效
	owner:EmitSound("npc/barnacle/barnacle_die2.wav")
	owner:EmitSound("npc/barnacle/barnacle_digesting1.wav")
	owner:EmitSound("npc/barnacle/barnacle_digesting2.wav")
end

-- ==== SecondaryAttack - 右键（空实现） ====
function SWEP:SecondaryAttack()
end

-- ==== Reload - 换弹（空实现） ====
function SWEP:Reload()
end
