-- ============================================================================
-- weapon_zs_rollermine.lua - 滚筒雷部署器
-- 负责：部署可操控的滚筒雷（prop_rollermine），含弹药管理、库存数量
--       显示与部署后处理
-- ============================================================================
AddCSLuaFile()

-- 显示名称与描述
SWEP.PrintName = ""..translate.Get("weapon_zs_rollermine")
SWEP.Description = ""..translate.Get("weapon_zs_rollermine_description")

if CLIENT then
	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 50
	SWEP.ShowViewModel = true
	SWEP.ShowWorldModel = false

	-- 缩放隐藏视图模型骨骼
	SWEP.ViewModelBoneMods = {
		["ValveBiped.cube1"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
		["ValveBiped.cube2"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
		["ValveBiped.cube3"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
		["ValveBiped.cube"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) }
	}
	-- 第一人称滚筒雷模型
	SWEP.VElements = {
		["base"] = { type = "Model", model = "models/roller.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(5, 4, 0), angle = Angle(-54.206, 58.294, -50.114), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}

	-- 第三人称滚筒雷模型
	SWEP.WElements = {
		["base"] = { type = "Model", model = "models/roller.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(5, 5, 0), angle = Angle(-43.978, 27.614, 0), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}
end

SWEP.Base = "weapon_zs_basemelee"

-- 模型与手臂（虫饵模型占位）
SWEP.ViewModel = "models/weapons/c_bugbait.mdl"
SWEP.WorldModel = "models/roller.mdl"
SWEP.UseHands = true

-- 部署的实体类与配套遥控武器
SWEP.DeployClass = "prop_rollermine"
SWEP.ControlWeapon = "weapon_zs_rollerminecontrol"

-- 持枪姿势
SWEP.HoldType = "grenade"

-- 移动速度（快速）
SWEP.WalkSpeed = SPEED_FAST

-- 弹药耗尽时自动移除武器
SWEP.AmmoIfHas = true

-- 弹药设置：一次携带 1 枚
SWEP.Primary.ClipSize = 1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "rollermine"
SWEP.Primary.Delay = 1
SWEP.Primary.DefaultClip = 1

-- 右键假弹药（占位，无实际用途）
SWEP.Secondary.ClipSize = 1
SWEP.Secondary.DefaultClip = 1
SWEP.Secondary.Ammo = "dummy"

-- 库存上限
SWEP.MaxStock = 10

SWEP.WalkSpeed = SPEED_FAST

-- ==== Initialize - 初始化 ====
-- 设置持枪姿势并调用部署速度调整；客户端初始化动画
function SWEP:Initialize()
	self:SetWeaponHoldType("grenade")
	GAMEMODE:DoChangeDeploySpeed(self)

	if CLIENT then
		self:Anim_Initialize()
	end
end

-- ==== CanPrimaryAttack - 是否能部署 ====
-- 持有者正在搬运/架设路障、场上已有自己的滚筒雷或弹药耗尽时禁止部署
function SWEP:CanPrimaryAttack()
	if self:GetOwner():IsHolding() or self:GetOwner():GetBarricadeGhosting() then return false end

	for _, ent in pairs(ents.FindByClass("prop_rollermine*")) do
		if ent:GetObjectOwner() == self:GetOwner() then return false end
	end

	if self:GetPrimaryAmmoCount() <= 0 then
		self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
		return false
	end

	return true
end

-- ==== PrimaryAttack - 左键部署滚筒雷 ====
-- 消耗 1 发弹药生成滚筒雷，0.75 秒后切到遥控武器
function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

	local owner = self:GetOwner()
	self:SendWeaponAnim(ACT_VM_THROW)
	owner:DoAttackEvent()

	self:TakePrimaryAmmo(1)
	-- 0.75 秒后执行投掷后处理
	self.NextDeploy = CurTime() + 0.75

	if SERVER then
		local ent = ents.Create(self.DeployClass)
		if ent:IsValid() then
			ent:SetPos(owner:GetShootPos())
			ent:Spawn()
			ent:SetObjectOwner(owner)
			ent:SetupPlayerSkills()

			-- 恢复此前打包储存的滚筒雷血量
			local stored = owner:PopPackedItem(ent:GetClass())
			if stored then
				ent:SetObjectHealth(stored[1])
			end

			ent:EmitSound("WeaponFrag.Throw")
			-- 以 200 速度向前抛出
			local phys = ent:GetPhysicsObject()
			if phys:IsValid() then
				phys:Wake()
				phys:SetVelocityInstantaneous(self:GetOwner():GetAimVector() * 200)
			end

			-- 发放并切换到遥控武器；弹药耗尽则移除本武器
			if not owner:HasWeapon(self.ControlWeapon) then
				owner:Give(self.ControlWeapon)
			end
			owner:SelectWeapon(self.ControlWeapon)

			if self:GetPrimaryAmmoCount() <= 0 then
				owner:StripWeapon(self:GetClass())
			end
		end
	end
end

-- ==== SecondaryAttack - 右键（空实现） ====
function SWEP:SecondaryAttack()
end

-- ==== CanSecondaryAttack - 禁止右键 ====
function SWEP:CanSecondaryAttack()
	return false
end

-- ==== Reload - 禁止换弹 ====
function SWEP:Reload()
	return false
end

-- ==== Deploy - 拔出武器时 ====
-- 通知游戏模式武器已部署；弹药耗尽时播放投掷动画
function SWEP:Deploy()
	GAMEMODE:WeaponDeployed(self:GetOwner(), self)

	if self:GetPrimaryAmmoCount() <= 0 then
		self:SendWeaponAnim(ACT_VM_THROW)
	end

	return true
end

-- ==== Holster - 收起武器时 ====
function SWEP:Holster()
	self.NextDeploy = nil

	if CLIENT then
		self:Anim_Holster()
	end

	return true
end

-- ==== Think - 投掷后处理 ====
-- 部署后 0.75 秒：有弹药则切回待机动画，无弹药则直接移除武器
function SWEP:Think()
	if self.NextDeploy and self.NextDeploy <= CurTime() then
		self.NextDeploy = nil

		if 0 < self:GetPrimaryAmmoCount() then
			self:SendWeaponAnim(ACT_VM_DRAW)
		else
			self:SendWeaponAnim(ACT_VM_THROW)
			if SERVER then
				self:Remove()
			end
		end
	end
end

-- 3D HUD 配色（背景与文字）
local colBG = Color(16, 16, 16, 90)
local colWhite = Color(220, 220, 220, 230)

-- 3D HUD 显示位置偏移
SWEP.HUD3DPos = Vector(5, 2, 0)

-- ==== PostDrawViewModel - 绘制弹药 3D HUD ====
-- 在手持位置绘制一个悬浮旋转的圆角框，显示剩余滚筒雷数量
function SWEP:PostDrawViewModel(vm)
	if not self.HUD3DPos or not GAMEMODE:ShouldDraw3DWeaponHUD() then return end

	-- 找到右手骨骼矩阵作为锚点
	local bone = vm:LookupBone("ValveBiped.Bip01_R_Hand")
	if not bone then return end

	local m = vm:GetBoneMatrix(bone)
	if not m then return end

	local pos, ang = m:GetTranslation(), m:GetAngles()

	local offset = self.HUD3DPos

	pos = pos + ang:Forward() * offset.x + ang:Right() * offset.y + ang:Up() * offset.z

	-- 让 HUD 悬浮摆动并持续旋转
	ang:RotateAroundAxis(ang:Up(), math.sin(CurTime() * math.pi) * 20)
	ang:RotateAroundAxis(ang:Right(), CurTime() * 180)

	pos = pos + ang:Forward() * 7

	ang:RotateAroundAxis(ang:Right(), 270)
	ang:RotateAroundAxis(ang:Up(), 180)

	-- 绘制 144×144 的圆角面板与剩余数量文字
	local wid, hei = 144, 144
	local x, y = wid * -0.5, hei * -0.5
	local clip = self:GetPrimaryAmmoCount()

	cam.Start3D2D(pos, ang, 0.0125)
		draw.RoundedBox(32, x, y, wid, hei, colBG)
		draw.SimpleText(clip, "ZS3D2DFontBig", x + wid * 0.5, y + hei * 0.5, colWhite, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	cam.End3D2D()
end
