
-- ============================================================================
-- swep_construction_kit/shared.lua - SCK 武器构造工具包（共享）
-- 负责：SWEP 基础属性、机瞄/第三人称切换、机瞄视角插值、辅助函数
-- ============================================================================
if SERVER then
	AddCSLuaFile("shared.lua")
	AddCSLuaFile("client.lua")
	AddCSLuaFile("glon.lua")
	AddCSLuaFile("menu/tool.lua")
	AddCSLuaFile("menu/weapon.lua")
	AddCSLuaFile("menu/ironsights.lua")
	AddCSLuaFile("menu/models.lua")
	AddCSLuaFile("menu/player.lua")
	AddCSLuaFile("base_code.lua")
end

if CLIENT then

	SWEP.PrintName		= "SWEP Construction Kit"
	SWEP.Author			= "Clavus"
	SWEP.Contact		= "clavus@clavusstudios.com"
	SWEP.Purpose		= "Design SWEP ironsights and clientside models"
	SWEP.Instructions	= "http://tinyurl.com/swepkit"
	SWEP.Slot			= 5
	SWEP.SlotPos		= 10
	SWEP.ViewModelFlip	= false

	SWEP.DrawCrosshair	= true

	SWEP.ShowViewModel 	= true
	SWEP.ShowWorldModel = true

end

CreateConVar("sck_autosave", 600, FCVAR_ARCHIVE, "Seconds between each SCK autosave. 0 = disable.")

local debugging = false

function SCKDebug( msg )
	if !debugging then return end
	MsgN("[SCK] "..msg)
end

local repmsg = {}
function SCKDebugRepeat( tag, msg )
	if !debugging then return end
	if !repmsg[tag] then repmsg[tag] = { last = 0, num = 0 } end
	repmsg[tag].num = repmsg[tag].num + 1
	if (CurTime() - repmsg[tag].last >= 1) then
		MsgN("[SCK][Repeated "..repmsg[tag].num.." times in last sec] "..msg)
		repmsg[tag].num = 0
		repmsg[tag].last = CurTime()
	end
end


SWEP.HoldType = "pistol"
SWEP.HoldTypes = { "normal", "melee", "melee2", "fist",
"knife", "smg", "ar2", "pistol", "revolver", "rpg", "physgun",
"grenade", "shotgun", "crossbow", "slam", "duel", "passive",
"camera", "magic" }

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.UseHands 			= true

SWEP.ViewModel			= "models/weapons/c_pistol.mdl"
SWEP.WorldModel			= "models/weapons/w_pistol.mdl"
SWEP.CurWorldModel 		= "models/weapons/w_pistol.mdl" -- this is where shit gets hacky

SWEP.ViewModelFOV		= 70
SWEP.BobScale			= 0
SWEP.SwayScale			= 0

SWEP.Primary.Automatic	= false

SWEP.IronsightTime = 0.2

SWEP.IronSightsPos = Vector(0, 0, 0)
SWEP.IronSightsAng = Vector(0, 0, 0)

-- ==== Initialize - 初始化持枪姿势、机瞄状态与数据目录 ====
function SWEP:Initialize()
	self:SetWeaponHoldType(self.HoldType)

	self:SetIronSights( true )
	self:ResetIronSights()

	if CLIENT then
		self:CreateWeaponWorldModel()
		self:ClientInit()
		if (not file.IsDir("swep_construction_kit", "DATA")) then
			file.CreateDir("swep_construction_kit")
		end
		if (not file.IsDir("swep_construction_kit/autosaves", "DATA")) then
			file.CreateDir("swep_construction_kit/autosaves")
		end
	end

	self.Dropped = false

	sck_class = self:GetClass()
end

-- ==== Equip - 装备武器时重置丢弃标记 ====
function SWEP:Equip()
	self.Dropped = false
end

-- ==== PrimaryAttack - 左键：打开 SCK 编辑菜单 ====
function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire(CurTime() + 0.2)

	if CLIENT then
		self:OpenMenu()
	end
	if game.SinglePlayer() then
		self:GetOwner():SendLua("LocalPlayer():GetActiveWeapon():OpenMenu()")
	end

end

-- ==== SecondaryAttack - 右键：打开 SCK 编辑菜单 ====
function SWEP:SecondaryAttack()
	self:SetNextSecondaryFire(CurTime() + 0.2)

	if CLIENT then
		self:OpenMenu()
	end
	if game.SinglePlayer() then
		self:GetOwner():SendLua("LocalPlayer():GetActiveWeapon():OpenMenu()")
	end
end


-- ==== SetupDataTables - 注册机瞄与第三人称网络变量 ====
function SWEP:SetupDataTables()
	self:DTVar( "Bool", 0, "ironsights" )
	self:DTVar( "Bool", 1, "thirdperson" )
end

-- ==== ToggleIronSights - 切换机瞄开关 ====
function SWEP:ToggleIronSights()
	self.dt.ironsights = !self.dt.ironsights
end

-- ==== SetIronSights - 设置机瞄状态 ====
function SWEP:SetIronSights( b )
	self.dt.ironsights = b
end

-- ==== GetIronSights - 获取机瞄状态 ====
function SWEP:GetIronSights()
	return self.dt.ironsights
end

-- ==== ResetIronSights - 将机瞄偏移全部归零 ====
function SWEP:ResetIronSights()
	RunConsoleCommand("_sp_ironsight_x", 0)
	RunConsoleCommand("_sp_ironsight_y", 0)
	RunConsoleCommand("_sp_ironsight_z", 0)
	RunConsoleCommand("_sp_ironsight_pitch", 0)
	RunConsoleCommand("_sp_ironsight_yaw", 0)
	RunConsoleCommand("_sp_ironsight_roll", 0)
end

-- ==== ToggleThirdPerson - 切换第三人称视角 ====
function SWEP:ToggleThirdPerson()
	self:SetThirdPerson( !self.dt.thirdperson )
end

-- ==== SetThirdPerson - 设置第三人称：切换视角实体并隐藏准星 ====
function SWEP:SetThirdPerson( b )
	self.dt.thirdperson = b

	local owner = self:GetOwner()
	if (!IsValid(owner)) then owner = self.LastOwner end
	if (!IsValid(owner)) then return end

	if (self.dt.thirdperson) then
		owner:SetViewEntity(game.GetWorld())
		owner:CrosshairDisable()
	else
		owner:SetViewEntity(owner)
		owner:CrosshairEnable()
	end
end

-- ==== GetThirdPerson - 获取第三人称状态 ====
function SWEP:GetThirdPerson()
	return self.dt.thirdperson
end

-- ==== GetViewModelPosition - 计算机瞄插值后的第一人称视角位置/角度 ====
function SWEP:GetViewModelPosition(pos, ang)
	--if true then return pos, ang end
	--SCKDebugRepeat( "SWEP:VMPos", "Getting viewmodel pos" )

	local bIron = self.dt.ironsights
	local fIronTime = self.fIronTime or 0

	if self.LockViewmodel then
		if self.LockVMPos and self.LockVMAng then
			
			if self.ViewModelFlip then
				
				/*local m = Matrix()
				m:SetTranslation( self.LockVMPos )
				m:SetAngles( self.LockVMAng )
				
				local np, na = WorldToLocal( m:GetTranslation(), m:GetAngles(), pos, ang )*/
				
				local np, na = WorldToLocal( self.LockVMPos, self.LockVMAng, pos, ang )
				
				local m = Matrix()
				m:SetTranslation( np )
				m:SetAngles( na )
				
				m:SetField( 2, 1, m:GetField( 2, 1 ) * -1 )
				m:SetField( 2, 4, m:GetField( 2, 4 ) * -1 )
				
				np, na = LocalToWorld( m:GetTranslation(), m:GetAngles(), pos, ang )
				
				na.r = 0 -- temp fix

				return np, na
			end
			
			return self.LockVMPos, self.LockVMAng
		else
			self.LockVMPos = pos
			self.LockVMAng = ang	
		end
	else
		if self.LockVMPos and self.LockVMAng then
			self.LockVMPos = nil
			self.LockVMAng = nil
		end
	end

	if (not bIron and fIronTime < CurTime() - self.IronsightTime) then
		return pos, ang
	end

	self.IronSightsPos, self.IronSightsAng = self:GetIronSightCoordination()

	local Mul = 1.0

	if (fIronTime > CurTime() - self.IronsightTime) then
		Mul = math.Clamp((CurTime() - fIronTime) / self.IronsightTime, 0, 1)

		if not bIron then Mul = 1 - Mul end
	end

	local Offset = self.IronSightsPos

	if (self.IronSightsAng) then
		ang = ang * 1
		ang:RotateAroundAxis(ang:Right(), 		self.IronSightsAng.x * Mul)
		ang:RotateAroundAxis(ang:Up(), 		self.IronSightsAng.y * Mul)
		ang:RotateAroundAxis(ang:Forward(), 	self.IronSightsAng.z * Mul)
	end

	local Right 	= ang:Right()
	local Up 		= ang:Up()
	local Forward 	= ang:Forward()

	pos = pos + Offset.x * Right * Mul
	pos = pos + Offset.y * Forward * Mul
	pos = pos + Offset.z * Up * Mul

	return pos, ang
end

SWEP.ir_x = CreateConVar( "_sp_ironsight_x", 0.0 )
SWEP.ir_y = CreateConVar( "_sp_ironsight_y", 0.0 )
SWEP.ir_z = CreateConVar( "_sp_ironsight_z", 0.0 )
SWEP.ir_p = CreateConVar( "_sp_ironsight_pitch", 0.0 )
SWEP.ir_yw = CreateConVar( "_sp_ironsight_yaw", 0.0 )
SWEP.ir_r = CreateConVar( "_sp_ironsight_roll", 0.0 )

-- ==== GetIronSightCoordination - 从 ConVar 读取当前机瞄偏移量 ====
function SWEP:GetIronSightCoordination()
	local vec = Vector( self.ir_x:GetFloat(), self.ir_y:GetFloat(), self.ir_z:GetFloat() )
	local ang = Vector( self.ir_p:GetFloat(), self.ir_yw:GetFloat(), self.ir_r:GetFloat() )
	return vec, ang
end

-- ==== GetHoldTypes - 返回支持的持枪姿势列表 ====
function SWEP:GetHoldTypes()
	return self.HoldTypes
end

SWEP.LastOwner = nil
--[[**************************
	Helper functions
**************************]]
SWEP.IsSCK = true
-- ==== GetSCKSWEP - 查找玩家当前持有的 SCK 武器 ====
function GetSCKSWEP( pl, includeall )
	local wep = pl:GetActiveWeapon()
	if (IsValid(wep) and wep.IsSCK) then
		return wep
	end

	if includeall then
		for k, v in ipairs(pl:GetWeapons()) do
			if v and v.IsSCK then
				return v
			end
		end
 	end

	return NULL
end

if SERVER then
	include("server.lua")
end

if CLIENT then
	include("client.lua")
end