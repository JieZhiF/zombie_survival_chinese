-- 确保客户端能够下载此文件。这是所有武器脚本的必需品。
AddCSLuaFile()

-- [[ 武器基础信息定义 ]] --

-- 仅在客户端设置的信息
if CLIENT then
   SWEP.PrintName = "'青峰'电子加速器" -- 武器在菜单中显示的名称
   
    SWEP.Slot = GAMEMODE:GetWeaponSlot("WeaponSelectSlotAssaultRifles")
SWEP.WeaponType = "rifle"
    SWEP.SlotGroup = WEPSELECT_ASSAULT_RIFLE
end
SWEP.Description = "瞄准状态下，E键可以特殊射击子弹" -- 武器的描述

-- 由于这是一个完全由多个模型（Elements）组成的自定义视图模型，我们不需要渲染原始的视图模型或世界模型。
SWEP.ShowViewModel = false
SWEP.ShowWorldModel = false


SWEP.Base = "weapon_zs_base" -- 继承自 'weapon_zs_base' 基础武器，会获得其所有功能

-- [[ 自定义模型组件 (VElements & WElements) ]] --
-- VElements: 定义了第一人称视角下看到的武器模型组件。
-- 每个组件都是一个独立的模型，通过骨骼（bone）和相对位置（rel, pos, angle）组合在一起。
SWEP.VElements = {
	["b1"] = { type = "Model", model = "models/combine_turrets/ground_turret.mdl", bone = "ValveBiped.base", rel = "base", pos = Vector(0, -2.52, -5.335), angle = Angle(90, -90, 0), size = Vector(0.5, 0.107, 0.131), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["top1"] = { type = "Model", model = "models/props_combine/tprotato1.mdl", bone = "ValveBiped.base", rel = "base", pos = Vector(0, -1.754, -7.974), angle = Angle(6.631, 90, -180), size = Vector(0.07, 0.028, 0.15), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["top2"] = { type = "Model", model = "models/combine_room/combine_monitor002.mdl", bone = "ValveBiped.base", rel = "base", pos = Vector(0, -2.698, -7.529), angle = Angle(0, -90, 180), size = Vector(0.039, 0.018, 0.059), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["b3"] = { type = "Model", model = "models/props_combine/combine_booth_med01a.mdl", bone = "ValveBiped.base", rel = "base", pos = Vector(-0.075, -0.306, -23.323), angle = Angle(0, 45, 0), size = Vector(0.027, 0.025, 0.129), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["barrel"] = { type = "Model", model = "models/props_combine/combinethumper001a.mdl", bone = "ValveBiped.base", rel = "base", pos = Vector(0, -1.719, -18.504), angle = Angle(0, 0, 0), size = Vector(0.029, 0.019, 0.09), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["base"] = { type = "Model", model = "", bone = "ValveBiped.base", rel = "", pos = Vector(0.174, 0.643, 1.771), angle = Angle(0, 0, 0), size = Vector(0.5, 0.5, 0.5), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["prong"] = { type = "Model", model = "models/props_combine/tprotato1_chunk01.mdl", bone = "ValveBiped.base", rel = "base", pos = Vector(-0.576, 0.312, 20.052), angle = Angle(0, 0, 0), size = Vector(0.05, 0.056, 0.279), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["vent"] = { type = "Model", model = "models/props_combine/combine_barricade_med01a.mdl", bone = "ValveBiped.base", rel = "base", pos = Vector(0, -0.245, -10.36), angle = Angle(0, -4.711, 0), size = Vector(0.05, 0.029, 0.079), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["b2"] = { type = "Model", model = "models/props_combine/tprotato1_chunk04.mdl", bone = "ValveBiped.base", rel = "base", pos = Vector(0, 0.016, 0), angle = Angle(5.502, -90, 180), size = Vector(0.187, 0.114, 0.259), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["grip+"] = { type = "Model", model = "models/props_combine/combinetrain01a.mdl", bone = "ValveBiped.base", rel = "base", pos = Vector(0, 1.858, -3.029), angle = Angle(0, 90, 180), size = Vector(0.009, 0.009, 0.009), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["grip"] = { type = "Model", model = "models/props_combine/combinetrain01a.mdl", bone = "ValveBiped.base", rel = "base", pos = Vector(0, 2.757, 6.798), angle = Angle(0, 90, 180), size = Vector(0.009, 0.009, 0.009), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	-- 全息瞄准镜的渲染平面
	["reflexfront"] = { type = "Quad", bone = "ValveBiped.base", rel = "top2", pos = Vector(-2.661, -0.276, 2.413), angle = Angle(0, 90, 0), size = 0.0025, draw_func = nil},
	["reflexback"] = { type = "Quad", bone = "ValveBiped.base", rel = "top2", pos = Vector(-2.661, -0.276, -2.633), angle = Angle(0, 90, 0), size = 0.0025, draw_func = nil},
}

-- WElements: 定义了第三人称视角下（其他玩家看到的）的武器模型组件。
SWEP.WElements = {
	["top2"] = { type = "Model", model = "models/combine_room/combine_monitor002.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(0, -2.698, -7.529), angle = Angle(0, -73.056, 180), size = Vector(0.039, 0.018, 0.059), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["b3"] = { type = "Model", model = "models/props_combine/combine_booth_med01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "barrel", pos = Vector(0.118, 0.34, 3.437), angle = Angle(0, 45, 0), size = Vector(0.027, 0.025, 0.079), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["barrel"] = { type = "Model", model = "models/props_combine/combinethumper001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(0, -1.719, -18.504), angle = Angle(0, 0, 0), size = Vector(0.029, 0.019, 0.09), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["b1"] = { type = "Model", model = "models/combine_turrets/ground_turret.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(0, -2.52, -5.335), angle = Angle(90, -90, 0), size = Vector(0.5, 0.107, 0.131), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["base"] = { type = "Model", model = "", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(9.164, 1.751, -5.377), angle = Angle(0, -90, -101.689), size = Vector(0.009, 0.009, 0.009), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["prong"] = { type = "Model", model = "models/props_combine/tprotato1_chunk01.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(-0.576, 0.312, 20.052), angle = Angle(0, 0, 0), size = Vector(0.05, 0.056, 0.279), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["top1"] = { type = "Model", model = "models/props_combine/tprotato1.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(0, -1.754, -7.974), angle = Angle(6.631, 90, -180), size = Vector(0.07, 0.028, 0.15), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["b2"] = { type = "Model", model = "models/props_combine/tprotato1_chunk04.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(0, 0.016, 0), angle = Angle(5.502, -90, 180), size = Vector(0.187, 0.114, 0.259), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}

-- [[ 武器属性与参数 ]] --

-- 用于在3D HUD中显示武器图标的设置
SWEP.HUD3DScale = 0.022
SWEP.HUD3DBone = "ValveBiped.base"
SWEP.HUD3DPos = Vector(2.3,0.2,1)
SWEP.HUD3DAng = Angle(180, 0, -20)

SWEP.RPM = 650 -- 理论射速（每分钟发数），实际射速由 Primary.Delay 控制

-- 自定义旋转效果参数
SWEP.RotSpeed = 3
SWEP.Mult = 0.25
SWEP.Spin = 0 -- 当前旋转速度/强度
SWEP.Tier = 5
SWEP.MaxStock = 2

-- 主要攻击（左键）设置
SWEP.Primary.Recoil	= 0.1 -- 基础后坐力数值
SWEP.Primary.Damage = 27 -- 每颗子弹的伤害
SWEP.Primary.KnockbackScale = 1 -- 击退效果的乘数
SWEP.Primary.NumShots = 1 -- 每次攻击发射的子弹数量
SWEP.Primary.ClipSize = 40 -- 弹匣容量
SWEP.Primary.Delay = 0.092 -- 射击间隔（秒），决定了实际射速 (60 / 0.092 ≈ 652 RPM)
SWEP.Primary.Cone = 0.018 -- 基础精准度（圆锥扩散范围）
SWEP.Primary.Automatic = true -- 是否为全自动
SWEP.Primary.DefaultClip = 240 -- 默认备弹量
SWEP.Primary.Ammo = "pulse"
SWEP.WeaponType = "pulse" -- 使用的弹药类型

-- 次要攻击（右键/特殊攻击）设置
SWEP.Secondary.ClipSize = 1 -- 设置为-1以使用主弹药
SWEP.Secondary.DefaultClip = 1 -- 由于使用主弹药，此项无实际作用
SWEP.Secondary.Ammo = "ar2" -- 特殊攻击消耗的弹药类型（这里可能是一个占位符或特殊设计）
SWEP.Secondary.Delay = 1.25 -- 特殊攻击的冷却时间
SWEP.Secondary.Automatic = true -- 是否可以按住不放

-- 视图模型和世界模型（即使不显示，也最好指定以防出错）
SWEP.UseHands = true -- 是否显示玩家的手部模型
SWEP.ViewModelFlip = false -- 是否翻转视图模型
SWEP.ViewModelFOV = 75 -- 视图模型的视野范围
SWEP.ViewModel  = "models/weapons/c_smg1.mdl" -- 基础视图模型
SWEP.WorldModel = "models/weapons/w_smg1.mdl" -- 基础世界模型

-- 玩家持枪动作
SWEP.HoldType = "ar2" -- 第三人称正常持枪姿势
SWEP.IronSightsHoldType = "ar2" -- 第三人称开镜持枪姿势
SWEP.WalkSpeed = SPEED_NORMAL -- 手持该武器时的移动速度

-- 瞄准（机瞄）相关设置
SWEP.IronSpeed = 8.5
SWEP.IronSightPos = Vector(0, -6.75, -1) -- 机瞄时的摄像机位置偏移（此脚本未使用默认机瞄，故此项无效）
SWEP.IronSightAng = Angle(0, 0, 0) -- 机瞄时的摄像机角度偏移（此脚本未使用默认机瞄，故此项无效）

-- 游戏模式相关
SWEP.PointsMultiplier = GAMEMODE.PulsePointsMultiplier -- 击杀获取的点数乘数

-- 准星扩散设置
SWEP.ConeMax = 3.2 -- 最大准星扩散
SWEP.ConeMin = 1.6 -- 最小准星扩散
SWEP.ConeRamp = 2 -- 准星扩散速度

-- 检视动画（当前未定义）
SWEP.Inspect = {
	{pos = Vector(0,0,0), ang = Angle(0,0,0), time = -1},
}
SWEP.InspectSpeed = 1 -- 检视动画速度

-- 武器自定义状态变量
SWEP.Sighting = false -- 是否处于瞄准状态
SWEP.Full = true -- 弹匣是否为满（用于播放首次空仓的声音）
SWEP.acc = 1 -- 精准度修正值（瞄准时为2，用于减少后坐力）

-- 动画和视觉效果平滑过渡变量
SWEP.reloadoffset = 0 -- 换弹动画位移变量
SWEP.targetoffset = 0 -- 换弹动画位移目标值
SWEP.reloadoffset2 = 0
SWEP.targetoffset2 = 0
SWEP.SightOffset = 0 -- 瞄准动画位移变量
SWEP.SightOffset2 = 0
SWEP.RSO1 = 0 -- 实际应用的瞄准位移
SWEP.RSO2 = 0
SWEP.punch = 0 -- 屏幕震动强度

-- 动画和音效控制变量
SWEP.FN = 0 -- Finish Next: 下一个动作（如开火、换弹）可以执行的最早时间戳
SWEP.VO = 0 -- Viewmodel Offset: 视图模型位移（垂直）
SWEP.VX = 0 -- Viewmodel Offset: 视图模型位移（前后）
SWEP.A = 0 -- Alpha/Animation value: 用于某种动画效果的强度值
SWEP.LastFire = 0 -- 上次开火的时间戳，用于计算后坐力重置

-- 后坐力控制
SWEP.REC = 0 -- 当前后坐力累积值
SWEP.Iterator = 0
-- 默认后坐力范围
SWEP.defupmax = -0.07 -- 默认垂直后坐力最大值
SWEP.deflmax = 0.05  -- 默认水平后坐力最大值
SWEP.deflmin = -0.02 -- 默认水平后坐力最小值
-- 动态后坐力范围
SWEP.upmax = -0.1
SWEP.lmax = 0.04
SWEP.lmin = -0.01

-- 杂项
SWEP.TracerName = "dmr4" -- 弹道曳光效果名称
SWEP.IdleActivity = ACT_IDLE -- 闲置时的武器动画


--
-- 函数: SWEP:Reload()
-- 描述: 处理武器的换弹逻辑。
--
function SWEP:Reload()
    local owner = self:GetOwner() -- 获取武器持有者
    if not self:CanReload() then return end -- 检查是否可以换弹
	if owner:IsHolding() then return end -- 如果玩家正在进行拾取等操作，则不允许换弹
	
	-- 检查冷却时间是否结束，且弹匣未满
	if self.FN < CurTime() and self:Clip1() < self.Primary.ClipSize then
        self.A = 0
        self:EmitSound(Sound("weapons/plasma/laserChargeNew.wav"), 50, 100) -- 播放换弹开始音效
        self.FN = CurTime() + 2.1 -- 设置换弹动作的冷却时间为2.1秒
		
		-- 使用 timer.Simple 创建一系列的视觉动画效果（屏幕震动和模型位移）
        timer.Simple(0.1, function()
            if not IsValid(self) then return end
            self.targetoffset = -5
            if IsValid(self.Owner) then self.Owner:ViewPunch(Angle(1, 0, 0)) end
        end)
        timer.Simple(0.2, function()
            if not IsValid(self) then return end
            self.targetoffset2 = -5
            if IsValid(self.Owner) then self.Owner:ViewPunch(Angle(-1, -2, 0)) end
        end)
        timer.Simple(0.9, function()
            if not IsValid(self) then return end
            self.targetoffset2 = 0
            if IsValid(self.Owner) then self.Owner:ViewPunch(Angle(0.5, 0.5, 0)) end
        end)
        timer.Simple(1.1, function()
            if not IsValid(self) then return end
            self.targetoffset = 0
            if IsValid(self.Owner) then self.Owner:ViewPunch(Angle(-1, 0, 0)) end
        end)
		
        self.Spin = self.Spin / 2 -- 减半旋转效果
        if IsValid(self.Owner) then self.Owner:SetFOV(0, 0.1) end -- 重置FOV
        self.REC = 0 -- 重置后坐力累积
		
        self.Weapon:DefaultReload(ACT_VM_RELOAD) -- 调用基础武器的换弹函数，处理弹药和动画计时
    end
end

--
-- 函数: SWEP:ShootEffects()
-- 描述: 处理开火时的视觉效果，如模型动画和玩家动作。
--
function SWEP:ShootEffects()
	self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK) -- 播放第一人称开火动画
	self.Owner:SetAnimation(PLAYER_ATTACK1) -- 设置第三人称玩家攻击动画
end

--
-- 函数: SWEP:Think()
-- 描述: 每帧都会执行的函数，用于处理持续性的逻辑，如动画平滑、状态更新等。
--
function SWEP:Think()
	-- 随时间减少旋转效果
	if self.Spin > 0 then
		self.Spin = self.Spin - 0.009
	end

	-- 检测是否按下右键（攻击2）来进行瞄准
	if self.Owner:KeyDown(IN_ATTACK2) then
		self.acc = 2 -- 提高精准度（减少后坐力）
		self.Owner:SetFOV(60, 0.1) -- 缩小FOV，实现缩放效果
	else
		self.acc = 1 -- 恢复默认精准度
		self.Owner:SetFOV(0, 0.1) -- 恢复默认FOV
	end
	-- 在松开左键时播放射击结束音效
	if self.Owner:KeyReleased(IN_ATTACK) and self:Clip1() > 0 then
		self:EmitSound(Sound("weapons/laserrifle/end2.wav"), 85, 100)
	end
	
	-- 弹药打空时播放一次射击结束音效
	if self:Clip1() > 0 then 
		self.Full = true 
	end
	if self.Full == true and self:Clip1() == 0 then 
		self:EmitSound(Sound("weapons/laserrifle/end2.wav"), 85, 100)
		self.Full = false 
	end

	-- 动态更新模型材质（如果 GetMaterial() 返回的是动态材质）
	local mat = self:GetMaterial()
	self.VElements["barrel"].material = mat
	self.VElements["b3"].material = mat
	self.WElements["barrel"].material = mat
	self.WElements["b3"].material = mat

	-- 更新模型组件的位置，以实现开火时的后退动画
	self.VElements["vent"].pos = Vector(0, -0.245, -10.36 - self.VO)
	self.VElements["prong"].pos = Vector(-0.576, 0.312, 20.052 - self.VX)

	-- 随时间平滑地恢复动画变量到初始值
	if self.A > 0 then self.A = self.A - 20 end
	if self.VO > 0 then self.VO = self.VO - 2.1 end
	if self.VX > 0 then self.VX = self.VX - 0.13 end
	
	-- 平滑处理屏幕震动效果
	if CLIENT then
		self:DoAnims()
		self.punch = Lerp(RealFrameTime() * 2, self.punch, self.REC * 10)
	end

	-- 如果停止开火一段时间，则重置后坐力
	if CurTime() > (self.LastFire + 0.3) then
		self.REC = 0
		self.Iterator = 0
		self.upmax = self.defupmax
		self.lmax = self.deflmax
		self.lmin = self.deflmin
	end
end

--
-- 函数: SWEP:SecondaryAttack()
-- 描述: 处理特殊攻击（默认是E键触发）。
--
function SWEP:SecondaryAttack()
    -- 检查是否能进行次要攻击，并且玩家是否按下了E键（IN_USE）
	if not self:CanSecondaryAttack() or not self.Owner:KeyDown(IN_USE) then return end
	-- 检查弹药是否足够
	if self:Clip1() < 6 then return end

	self:TakePrimaryAmmo(6) -- 一次消耗6发子弹
	self:ShootEffects() -- 播放开火动画

	-- 计算一个随机的后坐力角度
	local ang = Angle(math.Rand(-0.2, -0.2) * (1), math.Rand(-0.1, 0.1), math.Rand(-0.5, 0.5))
	
	self:EmitSound(Sound("weapons/teshu_fire1.wav"), 88, math.Rand(110, 120)) -- 播放特殊音效

	-- 发射伤害更高（乘以9）的子弹
	self:ShootBullets(self.Primary.Damage * 9, self.Primary.NumShots, self:GetCone())
	
	self.Owner:ViewPunch(ang * 6.65) -- 施加一个强烈的屏幕震动
	
	-- 设置开火冷却
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)
	self.Owner:MuzzleFlash()

	-- 触发一系列视觉动画效果
	if self.Spin < 2 then
		self.Spin = self.Spin + 0.55
	end
	self.A = 240
	self.VO = 7
	self.VX = 9
	self.punch = 30
end

--
-- 函数: SWEP:EmitFireSound()
-- 描述: 播放主攻击的开火音效。
--
function SWEP:EmitFireSound()
	self:EmitSound(Sound("weapons/laserrifle/fire2.wav"), 85, 100)  
end

--
-- 函数: SWEP:PrimaryAttack()
-- 描述: 处理主攻击（左键开火）的逻辑。
--
function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end -- 检查是否可以开火
	if self.FN > CurTime() then return end -- 检查是否处于换弹等动作的冷却中

	-- 根据是否瞄准（acc=2）来计算后坐力角度
	local ang = Angle(math.Rand(-0.2, -0.2) * (self.Primary.Recoil / self.acc), math.Rand(-0.1, 0.1) / self.acc, math.Rand(-0.5, 0.5) / self.acc)
	
	self:EmitFireSound() -- 播放开火声音
	
	self:ShootBullets(self.Primary.Damage, self.Primary.NumShots, self:GetCone()) -- 发射子弹

	-- 播放开火动画效果
	if not self.Owner:KeyDown(IN_ATTACK2) then
		self:ShootEffects()
	else
		self.offset = -1 -- 如果在瞄准状态，可能用于触发不同的动画效果
	end
    
	-- 根据玩家是否蹲下，应用不同的后坐力屏幕震动强度
    if self.Owner:Crouching() then 
        self.Owner:ViewPunch(ang * 0.55) 
    else
        self.Owner:ViewPunch(ang * 0.68) 
    end
    
    -- 消耗一发子弹。此操作会在客户端和服务端同步执行。
	self:TakePrimaryAmmo(1)

	-- 设置下次可以开火的时间
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self.Owner:MuzzleFlash() -- 显示枪口火焰

	-- 增加旋转效果
	if self.Spin < 2 then
		self.Spin = self.Spin + 0.55
	end
	
	-- 触发视觉动画效果
	self.A = 240
	self.VO = 7
	self.LastFire = CurTime() -- 记录本次开火时间
	self.punch = 1 + self.REC * 2 -- 计算屏幕震动强度

	-- 累加后坐力，用于实现连续射击时的后坐力递增
	if IsFirstTimePredicted() then
		self.Iterator = self.Iterator + 1
		self.REC = self.REC + 0.5
	end
end

--
-- 函数: SWEP:ShootBullets(dmg, numbul, cone)
-- 描述: 封装了实际的子弹发射逻辑，处理伤害、数量、扩散、击退和曳光等。
--
function SWEP:ShootBullets(dmg, numbul, cone)
	local owner = self:GetOwner()
	owner:DoAttackEvent()

	-- 如果设置了点数乘数，则临时应用
	if self.PointsMultiplier then
		POINTSMULTIPLIER = self.PointsMultiplier
	end

	owner:LagCompensation(true) -- 开启延迟补偿
	-- 调用Lua版本的子弹发射函数
	owner:FireBulletsLua(owner:GetShootPos(), owner:GetAimVector(), cone, numbul, dmg, nil, self.Primary.KnockbackScale, self.TracerName, self.BulletCallback, self.Primary.HullSize, nil, self.Primary.MaxDistance, nil, self)
	owner:LagCompensation(false) -- 关闭延迟补偿

	-- 恢复默认点数乘数
	if self.PointsMultiplier then
		POINTSMULTIPLIER = nil
	end
end

--
-- 函数: SWEP:FireAnimationEvent(...)
-- 描述: 覆盖基础武器的动画事件，用于禁用不需要的默认效果（如默认的枪口火焰）。
--
function SWEP:FireAnimationEvent(pos, ang, event, options)
	if (event == 21 or event == 20) then return true end -- 禁用动画 muzzle event
	if (event == 5001 or event == 5003 or event == 5011 or event == 5021 or event == 5031 or event == 6001) then return true end -- 禁用第三人称 muzzle flash
	return false
end

--
-- 函数: SWEP:DrawHUD()
-- 描述: 在客户端每帧绘制HUD元素，包括自定义的全息瞄准镜。
--

function SWEP:DrawHUD()
	self.BaseClass.DrawHUD(self) -- 调用父类的DrawHUD
	
	-- [[ 瞄准状态切换逻辑 ]] --
	-- 当按下右键且当前不处于瞄准状态时，进入瞄准状态
	if not self.Sighting and self.Owner:KeyDown(IN_ATTACK2) then
		self.Sighting = true
		self.Owner:EmitSound(Sound("weapons/player_archer_ads_up.wav"), 60, 100)
		-- 使用timer创建平滑的瞄准动画
		timer.Simple(0.13, function() if IsValid(self) then self.SightOffset = -0.6 end end)
		timer.Simple(0.32, function() if IsValid(self) then self.SightOffset2 = -9 end end)
	end
	-- 当松开右键且当前处于瞄准状态时，退出瞄准状态
	if self.Sighting and not self.Owner:KeyDown(IN_ATTACK2) then
		self.Sighting = false
		self.Owner:EmitSound(Sound("weapons/player_archer_ads_down.wav"), 60, 100)
		timer.Simple(0.256, function() if IsValid(self) then self.SightOffset = 0 end end)
		timer.Simple(0.1, function() if IsValid(self) then self.SightOffset2 = 0 end end)
	end

	-- [[ 动画平滑处理 ]] --
	-- 使用 Lerp (线性插值) 平滑地更新换弹和瞄准的位移值
	self.reloadoffset = Lerp(RealFrameTime() * 15, self.reloadoffset, self.targetoffset)
	self.reloadoffset2 = Lerp(RealFrameTime() * 15, self.reloadoffset2, self.targetoffset2)
	self.RSO1 = Lerp(RealFrameTime() * 20, self.RSO1, self.SightOffset)
	self.RSO2 = Lerp(RealFrameTime() * 20, self.RSO2, self.SightOffset2)
	
	-- 根据计算出的位移值，实时更新各模型组件的位置，形成动画效果
	self.VElements["barrel"].pos = Vector(0, -1.719, -18.504) + Vector(0, self.reloadoffset / 4, self.reloadoffset2 * 2)
	self.VElements["top2"].pos = Vector(0, -2.698, -7.529) + Vector(0, self.reloadoffset / 4, self.reloadoffset2 * -2) + Vector(0, self.RSO1, self.RSO2)
	self.VElements["vent"].pos = Vector(0, -0.245, -10.36) + Vector(0, 0, self.reloadoffset)
	self.VElements["b1"].pos = Vector(0, -2.52, -5.335) + Vector(0, self.reloadoffset * -0.2, 0)
	self.VElements["b3"].pos = Vector(-0.075, -0.306, -23.323) + Vector(0, 0, self.reloadoffset2)
	
	-- [[ 全息瞄准镜绘制 ]] --
	-- 绘制函数会被 VFire 基础自动调用
	-- 前镜片绘制
	self.VElements["reflexfront"].draw_func = function(weapon)
		-- 计算玩家视线与瞄准镜平面的交点，以确定准星在屏幕上的位置
		local accusight = util.IntersectRayWithPlane(EyePos(), EyeAngles():Forward(), weapon.VElements["reflexfront"].info.pos, EyeAngles():Forward() * -1)
		-- 将世界坐标转换为相对于镜片中心的局部2D坐标
		accusight = WorldToLocal(accusight, Angle(0,0,0), weapon.VElements["reflexfront"].info.pos, EyeAngles())

		-- 将3D偏移转换为2D屏幕坐标
		local x = math.Clamp(accusight.y * -400, 0, 90)
		local z = math.Clamp(accusight.z * -400, 0, 180)

		-- 绘制瞄准镜UI元素
		draw.RoundedBox(0, x - 140, z - 90, 280, 180, Color(10, 10, 10, 70)) -- 背景板
		draw.RoundedBox(0, x - 140, z - 90, 80, 35, Color(10, 10, 10, 140)) -- 弹药信息背景
		draw.DrawText("弹容: "..weapon:Clip1(), "DermaDefault", x - 130, z - 80, Color(200, 200, 200, 220)) -- 弹药文本
		
		-- 绘制多层圆环，形成发光效果的准星
		surface.DrawCircle(x, z, 30, Color(0, 255, 0, 200))
		surface.DrawCircle(x, z, 31, Color(0, 255, 0, 200))
		surface.DrawCircle(x, z, 32, Color(0, 255, 0, 200))
		surface.DrawCircle(x, z, 40, Color(0, 255, 0, 100))
		surface.DrawCircle(x, z, 41, Color(0, 255, 0, 100))
		surface.DrawCircle(x, z, 42, Color(0, 255, 0, 100))
		surface.DrawCircle(x, z, 50, Color(0, 255, 0, 30))
		surface.DrawCircle(x, z, 51, Color(0, 255, 0, 30))
		surface.DrawCircle(x, z, 52, Color(0, 255, 0, 30))
	end
	
	-- 后镜片绘制
	self.VElements["reflexback"].draw_func = function(weapon)
		-- 计算逻辑同上
		local accusight = util.IntersectRayWithPlane(EyePos(), EyeAngles():Forward(), weapon.VElements["reflexback"].info.pos, EyeAngles():Forward() * -1)
		accusight = WorldToLocal(accusight, Angle(0,0,0), weapon.VElements["reflexback"].info.pos, EyeAngles())
		
		local x = math.Clamp(accusight.y * -400, 0, 120)
		local z = math.Clamp(accusight.z * -400, -120, 120)
		
		-- 绘制简单的绿色光点作为后准星
		draw.RoundedBox(0, x - 90, z - 90, 180, 180, Color(50, 150, 50, 10))
		surface.DrawCircle(x, z, 14, Color(50, 255, 50, 130))
		surface.DrawCircle(x, z, 15, Color(50, 255, 50, 130))
		surface.DrawCircle(x, z, 16, Color(50, 255, 50, 130))
	end

	self:DoAnims()
	self.offset = Lerp(RealFrameTime() * 10, self.offset, 0)
	
	-- 如果需要，可以在非瞄准状态下绘制一个传统的准星

end
function SWEP:CalcViewModelView()
end