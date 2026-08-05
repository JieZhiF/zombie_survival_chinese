-- ============================================================================
-- weapon_zs_detpackremote.lua - 炸药包引爆器武器
-- 负责：引爆玩家放置的炸药包（prop_detpack）；若场上已无自己的炸药包，
--       该武器会自动从玩家身上移除
-- ============================================================================
AddCSLuaFile() -- 将该文件同时发送到客户端

-- 武器显示名称（本地化）
SWEP.PrintName = ""..translate.Get("weapon_zs_detpackremote")
-- 武器描述（本地化）
SWEP.Description = ""..translate.Get("weapon_zs_detpackremote_description")


if CLIENT then -- 客户端专属设置
	-- 武器栏位：放入"可部署物品"分类
	SWEP.Slot = GAMEMODE:GetWeaponSlot("WeaponSelectSlotDeployables")
	-- 栏位组：可部署物品栏
	SWEP.SlotGroup = WEPSELECT_DEPLOYABLES
	SWEP.ViewModelFOV = 50 -- 第一人称视野大小
	SWEP.BobScale = 0.5 -- 走路时的模型摆动幅度
	SWEP.SwayScale = 0.5 -- 移动鼠标时的模型晃动幅度
end

SWEP.ViewModel = "models/weapons/c_slam.mdl" -- 第一人称模型（SLAM 遥控器）
SWEP.WorldModel = "models/weapons/w_slam.mdl" -- 世界模型
SWEP.UseHands = true -- 使用玩家手臂模型握持

-- 无限弹匣（引爆器不消耗弹药）
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

-- 副攻击同样不使用弹药
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.WalkSpeed = SPEED_NORMAL -- 手持时正常移动速度

SWEP.NoMagazine = true -- 没有弹匣（不显示弹药信息）
SWEP.Undroppable = true -- 禁止丢弃
SWEP.NoPickupNotification = true -- 捡起时不显示提示

SWEP.HoldType = "slam" -- 手持姿势：SLAM 安放姿势

-- 展开/收起时不改变移动速度
SWEP.NoDeploySpeedChange = true

-- ==== Initialize - 武器初始化 ====
-- 应用手持姿势
function SWEP:Initialize()
	self:SetWeaponHoldType(self.HoldType)
end

if SERVER then -- 服务器专属逻辑
-- ==== Think - 服务器思考帧：检查炸药包是否还在 ====
-- 若场上已经找不到属于该玩家的炸药包，则直接移除引爆器
function SWEP:Think()
	-- 遍历场上所有炸药包，只要还有自己的就保留引爆器
	for _, ent in pairs(ents.FindByClass("prop_detpack")) do
		if ent:GetOwner() == self:GetOwner() then
			return
		end
	end

	-- 没有自己的炸药包了，从玩家身上移除该武器
	self:GetOwner():StripWeapon(self:GetClass())
end
end

-- ==== PrimaryAttack - 左键：引爆所有自己的炸药包 ====
function SWEP:PrimaryAttack()
	self:SendWeaponAnim(ACT_SLAM_DETONATOR_DETONATE) -- 播放引爆动画

	if CLIENT then return end -- 客户端只播放动画，逻辑在服务器执行

	-- 遍历所有炸药包，引爆还没有设定爆炸时间的（避免重复引爆）
	for _, ent in pairs(ents.FindByClass("prop_detpack")) do
		if ent:GetOwner() == self:GetOwner() and ent:GetExplodeTime() == 0 then
			ent:SetExplodeTime(CurTime() + ent.ExplosionDelay)
		end
	end
end

-- ==== SecondaryAttack - 右键（空实现） ====
function SWEP:SecondaryAttack()
end

-- ==== Reload - 换弹（禁止） ====
function SWEP:Reload()
	return false
end

-- ==== Deploy - 武器展开时 ====
function SWEP:Deploy()
	gamemode.Call("WeaponDeployed", self:GetOwner(), self)

	self:SendWeaponAnim(ACT_SLAM_DETONATOR_IDLE) -- 播放待机动画

	return true
end

-- ==== Holster - 武器收起时 ====
function SWEP:Holster()
	return true
end

if not CLIENT then return end -- 以下仅客户端执行

-- ==== DrawWeaponSelection - 武器选择界面图标 ====
-- 使用基础武器母本的默认绘制
function SWEP:DrawWeaponSelection(x, y, w, h, alpha)
	self:BaseDrawWeaponSelection(x, y, w, h, alpha)
end

-- ==== Think - 客户端思考帧（空实现） ====
function SWEP:Think()
end
