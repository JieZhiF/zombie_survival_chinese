-- ============================================================================
-- weapon_zs_special_wow/shared.lua - 特殊僵尸"Wow"自爆武器
-- 负责：定义无弹药消耗的自爆攻击（溶解爆炸），带扫描机器人音效与粒子特效
-- ============================================================================
-- 武器显示名称（从翻译表读取）
SWEP.PrintName = ""..translate.Get("weapon_zs_special_wow")

-- 主射击无需弹药（无限使用）
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"

-- 副射击无需弹药
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"

-- 仅限僵尸使用
SWEP.ZombieOnly = true
-- 近战类武器（不显示弹药）
SWEP.IsMelee = true

-- 视图模型与世界模型文件（匕首）
SWEP.ViewModel = "models/weapons/v_knife_t.mdl"
SWEP.WorldModel = "models/weapons/w_knife_t.mdl"

-- 预缓存扫描机器人的接近/对话音效
util.PrecacheSound("npc/scanner/scanner_nearmiss1.wav")
util.PrecacheSound("npc/scanner/scanner_nearmiss2.wav")
util.PrecacheSound("npc/scanner/scanner_talk1.wav")
util.PrecacheSound("npc/scanner/scanner_talk2.wav")

-- 下一次环境音效触发时间
SWEP.NextAmbientSound = 0

-- ==== Initialize - 初始化：隐藏视图与世界模型 ====
function SWEP:Initialize()
	self:HideViewAndWorldModel()
end

-- ==== Think - 每帧逻辑（空实现） ====
function SWEP:Think()
end

-- ==== PrimaryAttack - 自爆攻击：短暂无敌并造成溶解爆炸伤害 ====
function SWEP:PrimaryAttack()
	-- 攻击冷却（4 秒）
	if CurTime() < self:GetNextPrimaryAttack() then return end
	self:SetNextPrimaryAttack(CurTime() + 4)

	local owner = self:GetOwner()

	-- 记录本次远程攻击时间
	owner.LastRangedAttack = CurTime()

	if SERVER then
		-- 爆炸期间短暂开启无敌，防止自伤
		owner:GodEnable()
		util.BlastDamageEx(self, owner, owner:GetShootPos(), 64, 5, DMG_DISSOLVE)
		owner:GodDisable()
	end

	-- 首次预测时播放爆炸粒子特效
	if IsFirstTimePredicted() then
		local effectdata = EffectData()
			effectdata:SetOrigin(owner:GetShootPos())
			effectdata:SetNormal(owner:GetAimVector())
		util.Effect("explosion_wispball", effectdata)
	end
end

-- ==== SecondaryAttack - 右键（空实现，无副攻击） ====
function SWEP:SecondaryAttack()
end

-- ==== Reload - 播放扫描机器人的随机对话音效（冷却 5 秒） ====
function SWEP:Reload()
	if CurTime() >= self:GetNextSecondaryAttack() then
		self:SetNextSecondaryAttack(CurTime() + 5)
		self:EmitSound("npc/scanner/scanner_talk2.wav")
	end
end
