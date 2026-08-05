-- ============================================================================
-- weapon_zs_cameracontrol/shared.lua - 监控摄像头遥控器（共享端定义）
-- 负责：切换/查看已部署摄像头的核心逻辑、待机动画与 hook 生命周期
-- ============================================================================
-- 注册为共享文件（客户端与服务端都加载）
AddCSLuaFile()

-- 继承基础武器
SWEP.Base = "weapon_zs_base"

-- 武器名称（本地化）
SWEP.PrintName = ""..translate.Get("weapon_zs_cameracontrol")

-- 武器栏中的位置
SWEP.SlotPos = 0

-- 第一人称 / 第三人称模型
SWEP.ViewModel = "models/weapons/c_slam.mdl"
SWEP.WorldModel = "models/weapons/w_slam.mdl"
-- 使用玩家自己的手臂模型
SWEP.UseHands = true

-- 主攻击（切换摄像头）：无延迟、无限弹药、无弹药类型
SWEP.Primary.Delay = 0
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

-- 副攻击相关参数（预留属性，当前代码中未使用）
SWEP.Secondary.Delay = 20
SWEP.Secondary.Heal = 10

-- 副弹药：无限、无弹药类型
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

-- 持枪移动速度（快速）
SWEP.WalkSpeed = SPEED_FAST

-- 无弹匣显示 / 不可丢弃 / 不可拆除 / 不允许强化 / 捡起无提示
SWEP.NoMagazine = true
SWEP.Undroppable = true
SWEP.NoDismantle = true
SWEP.AllowQualityWeapons = false
SWEP.NoPickupNotification = true

-- 持枪姿势（摄像机姿势）
SWEP.HoldType = "camera"

-- 部署时不改变移动速度 / 不可转移给他人 / 拾取时不会自动切换过来
SWEP.NoDeploySpeedChange = true
SWEP.NoTransfer = true
SWEP.AutoSwitchFrom	= false

-- 待机动作动画（SLAM 投掷姿势）
SWEP.IdleActivity = ACT_SLAM_THROW_DETONATE

-- 网络同步访问器：当前选中的摄像头实体
AccessorFuncDT(SWEP, "Camera", "Entity", 0)

-- ==== PrimaryAttack - 左键切换到下一个摄像头 ====
function SWEP:PrimaryAttack(reverse)
	if IsFirstTimePredicted() then
		-- 播放安装动画并安排回到待机动画的时间
		self:SendWeaponAnim(ACT_SLAM_TRIPMINE_ATTACH)
		self.IdleAnimation = CurTime() + 0.33

		if SERVER then
			-- 服务器端执行摄像头切换
			self:CycleCamera(reverse)
		end

		if CLIENT then
			-- 客户端播放切换音效
			MySelf:EmitSound("buttons/button17.wav", 0)
		end
	end
end

-- ==== SecondaryAttack - 右键切换到上一个摄像头 ====
function SWEP:SecondaryAttack(reverse)
	self:PrimaryAttack(true)
end

-- ==== Reload - 禁用换弹功能 ====
function SWEP:Reload()
	return false
end

-- ==== Think - 每帧检查待机动画与摄像头状态 ====
function SWEP:Think()
	-- 动画时间到后恢复待机姿势
	if self.IdleAnimation and self.IdleAnimation <= CurTime() then
		self.IdleAnimation = nil
		self:SendWeaponAnim(self.IdleActivity)
	end

	if SERVER then
		-- 当前摄像头失效时自动切换到其他摄像头
		if not self:GetCamera():IsValid() then
			self:CycleCamera()
		end

		-- 场上已没有属于自己的摄像头时移除该武器
		for _, ent in pairs(ents.FindByClass("prop_camera")) do
			if ent:GetObjectOwner() == self:GetOwner() then
				return
			end
		end

		self:GetOwner():StripWeapon(self:GetClass())
	end
end

-- ==== Deploy - 切换出武器时挂载视野/渲染 hook ====
function SWEP:Deploy()
	self.BaseClass.Deploy(self)

	-- 通知游戏模式武器已切换出
	gamemode.Call("WeaponDeployed", self:GetOwner(), self)

	-- 保持待机动画
	self.IdleAnimation = math.huge
	self:SendWeaponAnim(self.IdleActivity)

	if SERVER then
		-- 服务器端：把摄像头位置加入玩家视野
		hook.Add("SetupPlayerVisibility", self, self.SetupPlayerVisibility)
	end

	if CLIENT then
		-- 客户端：渲染摄像头视角
		hook.Add("RenderScene", self, self.RenderScene)
	end

	return true
end

-- ==== Holster - 收起武器时移除 hook ====
function SWEP:Holster()
	self.BaseClass.Holster(self)

	if SERVER then
		hook.Remove("SetupPlayerVisibility", self)
	end

	if CLIENT then
		hook.Remove("RenderScene", self)
	end

	return true
end
