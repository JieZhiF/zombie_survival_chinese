-- ============================================================================
-- weapon_zs_crow/shared.lua - 乌鸦僵尸的啄击利爪武器
-- 负责：定义乌鸦僵尸的近战属性、隐藏模型及啄击动画状态追踪
-- ============================================================================
-- 仅限僵尸使用，属于近战武器（乌鸦专属标记）
SWEP.ZombieOnly = true
SWEP.IsMelee = true
SWEP.IsCrow = true

-- 第一人称与第三人称模型（小刀模型代替利爪）
SWEP.ViewModel = "models/weapons/v_knife_t.mdl"
SWEP.WorldModel = "models/weapons/w_knife_t.mdl"

-- 主攻击：无限弹药、全自动、不消耗任何弹药，间隔 2 秒
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Primary.Delay = 2

-- 副攻击：同样为无限弹药的全自动攻击
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo	= "none"

-- ==== Initialize - 隐藏视图模型与世界模型（乌鸦攻击由动画体现） ====
function SWEP:Initialize()
	self:HideViewAndWorldModel()
end

-- ==== OnRemove - 移除武器时停止主人的扇翅膀音效并清除状态 ====
function SWEP:OnRemove()
	local owner = self:GetOwner()
	if owner and owner:IsValid() then
		if owner.Flapping then
			owner:StopSound("NPC_Crow.Flap")
		end
		owner.Flapping = nil
	end
end
-- 收起武器时同样停止扇翅膀音效
SWEP.Holster = SWEP.OnRemove

-- ==== SetPeckEndTime - 记录啄击动画结束时间（DT 浮点字段 0） ====
function SWEP:SetPeckEndTime(time)
	self:SetDTFloat(0, time)
end

-- ==== GetPeckEndTime - 读取啄击动画结束时间 ====
function SWEP:GetPeckEndTime()
	return self:GetDTFloat(0)
end

-- ==== IsPecking - 判定是否正处于啄击动画中 ====
function SWEP:IsPecking()
	return CurTime() < self:GetPeckEndTime()
end
