-- ============================================================================
-- weapon_zs_spinfusor/shared.lua - 旋转掷弹枪（Spinfusor，共享）
-- 负责：定义脉冲榴弹发射器的伤害/弹药/换弹参数、开火音效注册与预缓存，
--       以及武器槽位与模型设置
-- ============================================================================
-- 武器显示名称与描述（本地化）
SWEP.PrintName = ""..translate.Get("weapon_zs_spinfusor")
SWEP.Description = ""..translate.Get("weapon_zs_spinfusor_description")


-- 武器栏位中的位置
SWEP.SlotPos = 0

-- 隐藏视模型与世界模型（纯特效武器，无可见模型）
SWEP.ShowViewModel = false
SWEP.ShowWorldModel = false

-- 注册开火音效（自定义音效表，高音调随机变奏）
sound.Add(
{
	name = "Weapon_Slayer.Single",
	channel = CHAN_AUTO,
	volume = 1,
	soundlevel = 100,
	pitch = {125, 135},
	sound = {"weapons/physcannon/superphys_launch2.wav", "weapons/physcannon/superphys_launch3.wav"}
})

-- 继承通用投掷物武器基底（提供榴弹发射逻辑）
SWEP.Base = "weapon_zs_baseproj"

-- 持枪姿势：弩
SWEP.HoldType = "crossbow"

-- 视/世界模型（被隐藏，仅作占位），使用玩家手臂
SWEP.ViewModel = "models/weapons/c_crossbow.mdl"
SWEP.WorldModel = "models/weapons/w_crossbow.mdl"
SWEP.UseHands = true

-- 不绘制 CS 样式枪口闪光
SWEP.CSMuzzleFlashes = false

-- 主攻击：单发伤害与射击间隔，单发模式，消耗脉冲弹药
SWEP.Primary.Damage = 86
SWEP.Primary.Delay = 1.2
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "pulse"
-- 武器类别：脉冲
SWEP.WeaponType = "pulse"
-- 开火音效
SWEP.Primary.Sound = Sound("Weapon_Slayer.Single")

-- 弹匣容量与初始弹药（备用弹 30 发）
SWEP.Primary.ClipSize = 7
SWEP.Primary.DefaultClip = 30
-- 换弹所需的满匣发数
SWEP.RequiredClip = 7

-- 换弹速度倍率
SWEP.ReloadSpeed = 0.9

-- 后坐力
SWEP.Recoil = 3

-- 持枪移动速度（较慢档位）
SWEP.WalkSpeed = SPEED_SLOWER

-- 无扩散（0 扩散 = 精准直射）
SWEP.ConeMax = 0
SWEP.ConeMin = 0

-- 武器等级与商店最大库存
SWEP.Tier = 5
SWEP.MaxStock = 2

-- 开火动画速度倍率
SWEP.FireAnimSpeed = 0.65

-- 附加 10% 换弹速度修改器
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_RELOAD_SPEED, 0.1)

-- ==== EmitReloadSound - 播放换弹音效（双音轨叠加，仅首次预测时播放） ====
function SWEP:EmitReloadSound()
	if IsFirstTimePredicted() then
		self:EmitSound("weapons/ar2/ar2_reload.wav", 75, 100, 1, CHAN_WEAPON + 21)
		self:EmitSound("weapons/smg1/smg1_reload.wav", 75, 100, 1, CHAN_WEAPON + 22)
	end
end

-- 预缓存换弹音效（避免首次播放卡顿）
util.PrecacheSound("weapons/ar2/ar2_reload.wav")
util.PrecacheSound("weapons/smg1/smg1_reload.wav")
