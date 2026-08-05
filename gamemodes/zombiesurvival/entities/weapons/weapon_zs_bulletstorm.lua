-- ============================================================================
-- weapon_zs_bulletstorm.lua - 弹幕冲锋枪（P90 改装）
-- 负责：定义高射速冲锋枪属性、机瞄"弹幕模式"（双弹丸低伤害）与机瞄音效
-- ============================================================================

-- 注册为共享文件（客户端也需加载）
AddCSLuaFile()
-- 定义母本类引用（供 BaseClass 调用）
DEFINE_BASECLASS("weapon_zs_base")

-- 武器显示名称
SWEP.PrintName = ""..translate.Get("weapon_zs_bulletstorm")
-- 武器描述
SWEP.Description = ""..translate.Get("weapon_zs_bulletstorm_description")

-- 武器选择槽内位置 0
SWEP.SlotPos = 0

if CLIENT then
	-- 武器槽位：冲锋枪类
	SWEP.Slot = GAMEMODE:GetWeaponSlot("WeaponSelectSlotSMGs")
	-- 武器选择分组：冲锋枪
	SWEP.SlotGroup = WEPSELECT_SMG
	-- 不翻转第一人称模型
	SWEP.ViewModelFlip = false
	-- 第一人称镜头视野
	SWEP.ViewModelFOV = 50

	-- HUD 3D 模型挂点：枪机骨骼
	SWEP.HUD3DBone = "v_weapon.p90_Release"
	-- HUD 3D 模型偏移位置
	SWEP.HUD3DPos = Vector(-1.35, -0.5, -6.5)
	-- HUD 3D 模型旋转角度
	SWEP.HUD3DAng = Angle(0, 0, 0)
end

-- 母本：基础武器
SWEP.Base = "weapon_zs_base"

-- 持枪姿势：冲锋枪
SWEP.HoldType = "smg"

-- 第一人称模型（P90）
SWEP.ViewModel = "models/weapons/cstrike/c_smg_p90.mdl"
-- 世界模型
SWEP.WorldModel = "models/weapons/w_smg_p90.mdl"
-- 使用玩家手臂模型
SWEP.UseHands = true

-- 开火音效（P90 单发音）
SWEP.Primary.Sound = Sound("Weapon_p90.Single")
-- 单发伤害
SWEP.Primary.Damage = 17.5
-- 每次开火射出 1 发（机瞄时 2 发，见 PrimaryAttack）
SWEP.Primary.NumShots = 1
-- 射击间隔 0.07 秒（极高射速）
SWEP.Primary.Delay = 0.07

-- 弹匣容量 50 发
SWEP.Primary.ClipSize = 50
-- 自动开火
SWEP.Primary.Automatic = true
-- 消耗冲锋枪弹药
SWEP.Primary.Ammo = "smg1"
-- 按游戏模式规则设置默认弹匣
GAMEMODE:SetupDefaultClip(SWEP.Primary)

-- 最大扩散
SWEP.ConeMax = 5.5
-- 最小扩散
SWEP.ConeMin = 3

-- 开火时的玩家手势
SWEP.Primary.Gesture = ACT_HL2MP_GESTURE_RANGE_ATTACK_SMG1
-- 换弹时的玩家手势
SWEP.ReloadGesture = ACT_HL2MP_GESTURE_RELOAD_SMG1

-- 移动速度：慢
SWEP.WalkSpeed = SPEED_SLOW

-- 武器等级 4
SWEP.Tier = 4
-- 商店最大库存 3 个
SWEP.MaxStock = 3

-- 机瞄位置偏移
SWEP.IronSightsPos = Vector(-2, 6, 3)
-- 机瞄旋转角度
SWEP.IronSightsAng = Vector(0, 2, 0)

-- 附加武器强化修改器：换弹速度 +0.1
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_RELOAD_SPEED, 0.1)

-- ==== PrimaryAttack - 开火（机瞄时为"弹幕模式"） ====
function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end
	-- 是否处于机瞄状态
	local ironsights = self:GetIronsights()

	-- 机瞄时射速降低 25%（延迟 x1.3333），换取双倍弹丸
	self:SetNextPrimaryFire(CurTime() + self:GetFireDelay() * (ironsights and 1.3333 or 1))

	-- 播放开火音效并消耗弹药
	self:EmitFireSound()
	self:TakeAmmo()
	-- 机瞄时：单发伤害降至 2/3、弹丸数翻倍（弹幕扫射）
	self:ShootBullets(self.Primary.Damage * (ironsights and 0.6666 or 1), self.Primary.NumShots * (ironsights and 2 or 1), self:GetCone())
	-- 记录开火动画时长，到时播放待机动画
	self.IdleAnimation = CurTime() + self:SequenceDuration()
end

-- ==== SetIronsights - 切换机瞄（带音效反馈） ====
function SWEP:SetIronsights(b)
	-- 状态变化时播放开/关扫描音
	if self:GetIronsights() ~= b then
		if b then
			self:EmitSound("npc/scanner/scanner_scan4.wav", 40)
		else
			self:EmitSound("npc/scanner/scanner_scan2.wav", 40)
		end
	end

	BaseClass.SetIronsights(self, b)
end

-- ==== SecondaryAttack - 右键进入机瞄 ====
function SWEP:SecondaryAttack()
	-- 冷却结束、未手持物品且不在换弹时才可进入机瞄
	if self:GetNextSecondaryFire() <= CurTime() and not self:GetOwner():IsHolding() and self:GetReloadFinish() == 0 then
		self:SetIronsights(true)
	end
end

-- 预缓存机瞄开关音效
util.PrecacheSound("npc/scanner/scanner_scan4.wav")
util.PrecacheSound("npc/scanner/scanner_scan2.wav")
