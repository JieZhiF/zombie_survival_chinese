-- ============================================================================
-- weapon_zs_manhack.lua - 猎头无人机（部署型投掷武器）
-- 负责：定义投掷猎头无人机的行为（部署实体、给予遥控器、弹药耗尽自动移除）
--       以及客户端 HUD 上旋转的无人机图标显示
-- ============================================================================

-- 客户端共享加载声明（本文件双端加载）
AddCSLuaFile()

-- 武器显示名称（本地化）
SWEP.PrintName = ""..translate.Get("weapon_zs_manhack")
-- 武器商店中的描述文本（本地化）
SWEP.Description = ""..translate.Get("weapon_zs_manhack_description")

-- 客户端专用属性：视角模型与附加模型配置
if CLIENT then
	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 50
	SWEP.ShowViewModel = true
	SWEP.ShowWorldModel = false

	-- 将视角模型原始方块骨骼缩小为不可见（隐藏原 bugbait 模型部件）
	SWEP.ViewModelBoneMods = {
		["ValveBiped.cube1"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
		["ValveBiped.cube2"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
		["ValveBiped.cube3"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
		["ValveBiped.cube"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) }
	}
	-- 第一人称附加模型：手持一架小型猎头无人机
	SWEP.VElements = {
		["base"] = { type = "Model", model = "models/manhack.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(5, 4, 0), angle = Angle(-54.206, 58.294, -50.114), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}

	-- 第三人称附加模型：供他人视角显示手持无人机
	SWEP.WElements = {
		["base"] = { type = "Model", model = "models/manhack.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(5, 5, 0), angle = Angle(-43.978, 27.614, 0), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}
end

-- 继承近战武器基类
SWEP.Base = "weapon_zs_basemelee"

-- 第一人称视角模型（借用的 bugbait 模型，实际显示由附加模型完成）
SWEP.ViewModel = "models/weapons/c_bugbait.mdl"
-- 第三人称世界模型
SWEP.WorldModel = "models/manhack.mdl"
-- 使用玩家手臂模型握持
SWEP.UseHands = true

-- 部署时生成的实体类型：猎头无人机
SWEP.DeployClass = "prop_manhack"
-- 部署后自动切换到的遥控武器
SWEP.ControlWeapon = "weapon_zs_manhackcontrol"

-- 持握姿势：手雷（投掷动作）
SWEP.HoldType = "grenade"

-- 手持移动速度（快速）
SWEP.WalkSpeed = SPEED_FAST

-- 有对应弹药时才能使用
SWEP.AmmoIfHas = true

-- 左键：一次携带量 1，手动投掷，消耗 manhack 弹药
SWEP.Primary.ClipSize = 1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "manhack"
SWEP.Primary.Delay = 1
SWEP.Primary.DefaultClip = 1

-- 右键：占位弹匣（不使用）
SWEP.Secondary.ClipSize = 1
SWEP.Secondary.DefaultClip = 1
SWEP.Secondary.Ammo = "dummy"

-- 可同时持有的最大库存数量
SWEP.MaxStock = 10

-- 手持移动速度（快速，重复声明覆盖）
SWEP.WalkSpeed = SPEED_FAST

-- ==== Initialize - 初始化武器 ====
function SWEP:Initialize()
	-- 强制持握姿势为手雷
	self:SetWeaponHoldType("grenade")
	-- 应用部署速度修正
	GAMEMODE:DoChangeDeploySpeed(self)

	if CLIENT then
		-- 客户端初始化附加模型动画
		self:Anim_Initialize()
	end
end

-- ==== CanPrimaryAttack - 检查能否投掷 ====
function SWEP:CanPrimaryAttack()
	-- 搬运物品或放置路障预览时禁止投掷
	if self:GetOwner():IsHolding() or self:GetOwner():GetBarricadeGhosting() then return false end

	-- 场上已有属于本玩家的无人机时禁止再投
	for _, ent in pairs(ents.FindByClass("prop_manhack*")) do
		if ent:GetObjectOwner() == self:GetOwner() then return false end
	end

	-- 没有携带弹药则进入冷却并禁止投掷
	if self:GetPrimaryAmmoCount() <= 0 then
		self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
		return false
	end

	return true
end

-- ==== PrimaryAttack - 投掷无人机 ====
function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

	local owner = self:GetOwner()
	-- 播放投掷动画与攻击动作
	self:SendWeaponAnim(ACT_VM_THROW)
	owner:DoAttackEvent()

	-- 消耗一发携带弹药，并安排 0.75 秒后的收尾逻辑
	self:TakePrimaryAmmo(1)
	self.NextDeploy = CurTime() + 0.75

	if SERVER then
		-- 在玩家视角位置生成无人机实体
		local ent = ents.Create(self.DeployClass)
		if ent:IsValid() then
			ent:SetPos(owner:GetShootPos())
			ent:Spawn()
			ent:SetObjectOwner(owner)
			-- 应用玩家的技能加成
			ent:SetupPlayerSkills()

			-- 若此前保存过该实体数据（如耐久），则恢复
			local stored = owner:PopPackedItem(ent:GetClass())
			if stored then
				ent:SetObjectHealth(stored[1])
			end

			-- 播放投掷音效并沿准星方向推出无人机
			ent:EmitSound("WeaponFrag.Throw")
			local phys = ent:GetPhysicsObject()
			if phys:IsValid() then
				phys:Wake()
				phys:SetVelocityInstantaneous(self:GetOwner():GetAimVector() * 200)
			end

			-- 给予并切换到遥控武器
			if not owner:HasWeapon(self.ControlWeapon) then
				owner:Give(self.ControlWeapon)
			end
			owner:SelectWeapon(self.ControlWeapon)

			-- 弹药耗尽后移除本武器
			if self:GetPrimaryAmmoCount() <= 0 then
				owner:StripWeapon(self:GetClass())
			end
		end
	end
end

-- ==== SecondaryAttack - 右键无动作 ====
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

-- ==== Deploy - 切出武器 ====
function SWEP:Deploy()
	-- 通知游戏模式武器已部署
	GAMEMODE:WeaponDeployed(self:GetOwner(), self)

	-- 没有携带弹药时直接播放空手投掷动画
	if self:GetPrimaryAmmoCount() <= 0 then
		self:SendWeaponAnim(ACT_VM_THROW)
	end

	return true
end

-- ==== Holster - 收起武器 ====
function SWEP:Holster()
	-- 取消未完成的收尾计时器
	self.NextDeploy = nil

	if CLIENT then
		self:Anim_Holster()
	end

	return true
end

-- ==== Think - 每帧逻辑（处理投掷后的收尾） ====
function SWEP:Think()
	-- 投掷后 0.75 秒：恢复待机动画，弹药耗尽则移除武器
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

-- HUD 绘制颜色：背景半透明黑、文字亮白
local colBG = Color(16, 16, 16, 90)
local colWhite = Color(220, 220, 220, 230)

-- HUD 3D 图标相对手部的偏移
SWEP.HUD3DPos = Vector(5, 2, 0)

-- ==== PostDrawViewModel - 绘制旋转的无人机弹药 HUD ====
function SWEP:PostDrawViewModel(vm)
	-- 未启用 3D 武器 HUD 时跳过
	if not self.HUD3DPos or not GAMEMODE:ShouldDraw3DWeaponHUD() then return end

	-- 取右手骨骼矩阵作为锚点
	local bone = vm:LookupBone("ValveBiped.Bip01_R_Hand")
	if not bone then return end

	local m = vm:GetBoneMatrix(bone)
	if not m then return end

	local pos, ang = m:GetTranslation(), m:GetAngles()

	local offset = self.HUD3DPos

	-- 按偏移移动位置
	pos = pos + ang:Forward() * offset.x + ang:Right() * offset.y + ang:Up() * offset.z

	-- 让图标左右摆动并绕自身旋转，模拟无人机悬浮效果
	ang:RotateAroundAxis(ang:Up(), math.sin(CurTime() * math.pi) * 20)
	ang:RotateAroundAxis(ang:Right(), CurTime() * 180)

	pos = pos + ang:Forward() * 7

	ang:RotateAroundAxis(ang:Right(), 270)
	ang:RotateAroundAxis(ang:Up(), 180)

	-- 绘制圆角面板与剩余携带数量
	local wid, hei = 144, 144
	local x, y = wid * -0.5, hei * -0.5
	local clip = self:GetPrimaryAmmoCount()

	cam.Start3D2D(pos, ang, 0.0125)
		draw.RoundedBox(32, x, y, wid, hei, colBG)
		draw.SimpleText(clip, "ZS3D2DFontBig", x + wid * 0.5, y + hei * 0.5, colWhite, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	cam.End3D2D()
end
