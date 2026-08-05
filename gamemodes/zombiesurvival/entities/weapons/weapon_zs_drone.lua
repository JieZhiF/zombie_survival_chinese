-- ============================================================================
-- weapon_zs_drone.lua - 无人机部署器（投掷式无人机）
-- 负责：部署攻击无人机的完整流程、弹药转移、3D 剩余数量 HUD
-- ============================================================================
-- 注册为共享文件（客户端与服务端都加载）
AddCSLuaFile()

-- 武器名称 / 描述（本地化）
SWEP.PrintName = ""..translate.Get("weapon_zs_drone")
SWEP.Description = ""..translate.Get("weapon_zs_drone_description")

if CLIENT then
	-- 客户端专属：第一人称模型设置（不翻转、视野 50、只显示第一人称模型）
	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 50
	SWEP.ShowViewModel = true
	SWEP.ShowWorldModel = false

	-- 缩小原始手持模型的骨骼（隐藏原模型体积）
	SWEP.ViewModelBoneMods = {
		["ValveBiped.cube1"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
		["ValveBiped.cube2"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
		["ValveBiped.cube3"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
		["ValveBiped.cube"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) }
	}
	-- 第一人称附加模型：右手托着的无人机
	SWEP.VElements = {
		["base"] = { type = "Model", model = "models/combine_scanner.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(5, 4, 0), angle = Angle(-54.206, 58.294, -50.114), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}

	-- 第三人称附加模型：右手托着的无人机
	SWEP.WElements = {
		["base"] = { type = "Model", model = "models/combine_scanner.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(5, 5, 0), angle = Angle(-43.978, 27.614, 0), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}
end

-- 继承近战武器基础（部署器本体无直接攻击能力）
SWEP.Base = "weapon_zs_basemelee"

-- 第一人称 / 第三人称模型
SWEP.ViewModel = "models/weapons/c_bugbait.mdl"
SWEP.WorldModel = "models/combine_scanner.mdl"
-- 使用玩家自己的手臂模型
SWEP.UseHands = true

-- 持枪姿势（手雷姿势）
SWEP.HoldType = "grenade"

-- 持武器移动速度（快速）
SWEP.WalkSpeed = SPEED_FAST

-- 拥有弹药时才显示 HUD
SWEP.AmmoIfHas = true

-- 主弹药：无人机数量（每次部署消耗 1 台）
SWEP.Primary.ClipSize = 1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "drone"
SWEP.Primary.Delay = 1
SWEP.Primary.DefaultClip = 1

-- 副弹药：占位（不使用）
SWEP.Secondary.ClipSize = 1
SWEP.Secondary.DefaultClip = 1
SWEP.Secondary.Ammo = "dummy"

-- 部署时向无人机充入的弹药类型
SWEP.ResupplyAmmoType = "smg1"

-- 持武器移动速度（快速）
SWEP.WalkSpeed = SPEED_FAST

-- 携带上限（背包可存数量）
SWEP.MaxStock = 6

-- 部署出的无人机实体 / 充入无人机的弹药类型
SWEP.DeployClass = "prop_drone"
SWEP.DeployAmmoType = "smg1"

-- ==== Initialize - 武器初始化 ====
function SWEP:Initialize()
	-- 使用手雷持枪姿势
	self:SetWeaponHoldType("grenade")
	-- 按游戏模式规则调整切换速度
	GAMEMODE:DoChangeDeploySpeed(self)

	if CLIENT then
		-- 客户端初始化附加模型动画
		self:Anim_Initialize()
	end
end

-- ==== CanPrimaryAttack - 判断是否允许部署无人机 ====
function SWEP:CanPrimaryAttack()
	-- 正在搬运/放置路障时禁止
	if self:GetOwner():IsHolding() or self:GetOwner():GetBarricadeGhosting() then return false end

	-- 场上已有自己的无人机时禁止重复部署
	for _, ent in pairs(ents.FindByClass(self.DeployClass)) do
		if ent:GetObjectOwner() == self:GetOwner() then return false end
	end

	-- 没有无人机库存时禁止（并设置冷却）
	if self:GetPrimaryAmmoCount() <= 0 then
		self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
		return false
	end

	return true
end

-- ==== PrimaryAttack - 左键部署无人机（核心逻辑） ====
function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

	local owner = self:GetOwner()
	-- 播放投掷动画与攻击动作
	self:SendWeaponAnim(ACT_VM_THROW)
	owner:DoAttackEvent()

	-- 消耗一台无人机库存，并记录下次换弹/收起的动作时间
	self:TakePrimaryAmmo(1)
	self.NextDeploy = CurTime() + 0.75
	owner.DroneControlAmmo = self.DeployAmmoType

	if SERVER then
		-- 生成无人机实体
		local ent = ents.Create(self.DeployClass)
		if ent:IsValid() then
			-- 在玩家枪口位置生成并归属玩家
			ent:SetPos(owner:GetShootPos())
			ent:Spawn()
			ent:SetObjectOwner(owner)
			ent:SetupPlayerSkills()

			-- 若背包中有回收的同类型无人机，恢复其耐久
			local stored = owner:PopPackedItem(ent:GetClass())
			if stored then
				ent:SetObjectHealth(stored[1])
			end

			-- 播放投掷音效，并沿瞄准方向抛出无人机
			ent:EmitSound("WeaponFrag.Throw")
			local phys = ent:GetPhysicsObject()
			if phys:IsValid() then
				phys:Wake()
				phys:SetVelocityInstantaneous(self:GetOwner():GetAimVector() * 200)
			end

			-- 把携带的 SMG 弹药充入无人机（上限由无人机实体决定）
			local ammotype = self.DeployAmmoType
			if ammotype then
				local ammo = math.min(owner:GetAmmoCount(ammotype), ent.MaxAmmo)
				ent:SetAmmo(ammo)
				owner:RemoveAmmo(ammo, ammotype)
			end

			-- 自动切换出无人机遥控器（没有则先给予）
			if not owner:HasWeapon("weapon_zs_dronecontrol") then
				owner:Give("weapon_zs_dronecontrol")
			end
			owner:SelectWeapon("weapon_zs_dronecontrol")

			-- 库存耗尽后自动移除该武器
			if self:GetPrimaryAmmoCount() <= 0 then
				owner:StripWeapon(self:GetClass())
			end
		end
	end
end

-- ==== SecondaryAttack - 禁用右键功能 ====
function SWEP:SecondaryAttack()
end

-- ==== CanSecondaryAttack - 禁止右键 ====
function SWEP:CanSecondaryAttack()
	return false
end

-- ==== Reload - 禁用换弹功能 ====
function SWEP:Reload()
	return false
end

-- ==== Deploy - 切换出武器 ====
function SWEP:Deploy()
	GAMEMODE:WeaponDeployed(self:GetOwner(), self)

	-- 没有库存时播放空投掷动画
	if self:GetPrimaryAmmoCount() <= 0 then
		self:SendWeaponAnim(ACT_VM_THROW)
	end

	return true
end

-- ==== Holster - 收起武器 ====
function SWEP:Holster()
	self.NextDeploy = nil

	if CLIENT then
		-- 客户端收起附加模型动画
		self:Anim_Holster()
	end

	return true
end

-- ==== Think - 每帧处理投掷后的换弹/移除时机 ====
function SWEP:Think()
	-- 投掷动作完成后根据库存播放换弹动画或移除武器
	if self.NextDeploy and self.NextDeploy <= CurTime() then
		self.NextDeploy = nil

		if 0 < self:GetPrimaryAmmoCount() then
			self:SendWeaponAnim(ACT_VM_DRAW)
		else
			self:SendWeaponAnim(ACT_VM_THROW)
			if SERVER then
				-- 库存为 0 时移除武器实体
				self:Remove()
			end
		end
	end
end

-- 3D HUD 配色：背景半透明黑 / 数字白
local colBG = Color(16, 16, 16, 90)
local colWhite = Color(220, 220, 220, 230)

-- 3D HUD 相对手部的位置偏移
SWEP.HUD3DPos = Vector(5, 2, 0)

-- ==== PostDrawViewModel - 在无人机模型上绘制 3D 剩余数量 HUD ====
function SWEP:PostDrawViewModel(vm)
	if not self.HUD3DPos or not GAMEMODE:ShouldDraw3DWeaponHUD() then return end

	-- 定位右手骨骼作为 HUD 绘制位置
	local bone = vm:LookupBone("ValveBiped.Bip01_R_Hand")
	if not bone then return end

	local m = vm:GetBoneMatrix(bone)
	if not m then return end

	local pos, ang = m:GetTranslation(), m:GetAngles()

	local offset = self.HUD3DPos

	-- 把偏移应用到骨骼位置
	pos = pos + ang:Forward() * offset.x + ang:Right() * offset.y + ang:Up() * offset.z

	-- 让 HUD 持续摆动与旋转（漂浮动画）
	ang:RotateAroundAxis(ang:Up(), math.sin(CurTime() * math.pi) * 20)
	ang:RotateAroundAxis(ang:Right(), CurTime() * 180)

	pos = pos + ang:Forward() * 7

	-- 翻转角度让 HUD 正对玩家
	ang:RotateAroundAxis(ang:Right(), 270)
	ang:RotateAroundAxis(ang:Up(), 180)

	-- 绘制圆角背景与剩余无人机数量
	local wid, hei = 144, 144
	local x, y = wid * -0.5, hei * -0.5
	local clip = self:GetPrimaryAmmoCount()

	cam.Start3D2D(pos, ang, 0.0125)
		draw.RoundedBox(32, x, y, wid, hei, colBG)
		draw.SimpleText(clip, "ZS3D2DFontBig", x + wid * 0.5, y + hei * 0.5, colWhite, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	cam.End3D2D()
end
