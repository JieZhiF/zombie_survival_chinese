-- =================================================================
--                      基本定义 (Basic Definitions)
-- =================================================================
SWEP.Base					= "weapon_zs_base"
SWEP.PrintName = "'纽带' 突击步枪"
SWEP.Description = "带瞄准镜的突击步枪，射速、伤害和精度都更胜一筹。"
SWEP.Slot					= 2
SWEP.SlotPos				= 1


-- =================================================================
--                      模型和动画 (Models & Animations)
-- =================================================================
SWEP.UseHands 				= true
SWEP.ViewModel 				= "models/weapons/cstrike/c_smg_mp5.mdl"
SWEP.WorldModel				= "models/weapons/w_smg_mp5.mdl"

-- 对于SCK/VElements武器，必须设置下面这两项为false
-- 这样引擎就不会去绘制上面定义的那个基础SMG模型
SWEP.ShowViewModel          = false
SWEP.ShowWorldModel         = false

SWEP.ViewModelFlip 			= false
SWEP.HoldType				= "ar2"
SWEP.Tier = 5
-- =================================================================
--                      主要攻击属性 (Primary Fire)
-- =================================================================
SWEP.Primary.Damage			= 30
SWEP.Primary.NumShots		= 1
SWEP.Primary.Sound			= Sound("weapons/nexus_fire.wav")
SWEP.Primary.ClipSize		= 30
SWEP.Primary.Delay			= 0.09 -- 1/(666/60)
SWEP.Primary.DefaultClip = 90
SWEP.Primary.Ammo			= "ar2"
SWEP.Primary.Automatic 		= true

-- =================================================================
--                      开镜设置 (Iron Sights)
-- =================================================================
SWEP.IronSightsPos          = Vector(0,0,0)--Vector(-7.32, -8.78, 0.08)
SWEP.IronSightsAng          = Vector(0, 0, 0)
SWEP.IronsightsMultiplier   = 0.25

-- =================================================================
--                      SCK 元素定义 (VElements & WElements)
-- =================================================================
SWEP.VElements = {
	["base"] = { type = "Model", model = "models/props_combine/CombineTrain01a.mdl", bone = "v_weapon.MP5_Parent", rel = "", pos = Vector(0, -2.874, -11.497), angle = Angle(-90, 0, -90), size = Vector(0.045, 0.012, 0.01), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["bolt"] = { type = "Model", model = "models/Items/CrossbowRounds.mdl", bone = "v_weapon.MP5_Bolt", rel = "", pos = Vector(-0.8, 0, 0), angle = Angle(0, 0, 0), size = Vector(0.1, 0.1, 0.1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/gibs/metalgibs/metal_gibs", skin = 0, bodygroup = {} },
	["bolt2"] = { type = "Model", model = "models/Items/combine_rifle_ammo01.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "bolt", pos = Vector(-0.5, 0, 0), angle = Angle(90, 0, 0), size = Vector(0.08, 0.08, 0.08), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["grip"] = { type = "Model", model = "models/weapons/w_pist_glock18.mdl", bone = "v_weapon.MP5_Parent", rel = "base", pos = Vector(-11.634, 0.039, -4.312), angle = Angle(0, 0, 0), size = Vector(0.8, 0.8, 0.8), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["mag"] = { type = "Model", model = "models/props_combine/combine_train02a.mdl", bone = "v_weapon.MP5_Clip", rel = "", pos = Vector(0, 1, 0), angle = Angle(0, 0, 17.246), size = Vector(0.01, 0.01, 0.01), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["scope"] = { type = "Model", model = "models/maxofs2d/lamp_flashlight.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "scopehold", pos = Vector(0, -1.6, 1.58), angle = Angle(0, 90, 0), size = Vector(0.17, 0.17, 0.17), color = Color(144, 144, 144, 255), surpresslightning = false, material = "phoenix_storms/pro_gear_side", skin = 0, bodygroup = {} },
	["scope+"] = { type = "Model", model = "models/maxofs2d/lamp_flashlight.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "scope", pos = Vector(-2.874, 0, 0), angle = Angle(0, 180, 0), size = Vector(0.17, 0.17, 0.17), color = Color(144, 144, 144, 255), surpresslightning = false, material = "phoenix_storms/pro_gear_side", skin = 0, bodygroup = {} },
	["scopehold"] = { type = "Model", model = "models/props_phx/gears/rack9.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "base", pos = Vector(-7.9, 0, 2.2), angle = Angle(0, 90, 0), size = Vector(0.15, 0.1, 0.15), color = Color(116, 116, 116, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["scopelens"] = { type = "Model", model = "models/hunter/tubes/circle2x2.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "scope", pos = Vector(1.474, 0, 0), angle = Angle(-90, 0, 0), size = Vector(0.017, 0.017, 0.017), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/XQM/BoxFull_diffuse", skin = 0, bodygroup = {} },
	["scoperod"] = { type = "Model", model = "models/mechanics/robotics/g1.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "scopehold", pos = Vector(-0.078, 0.026, 0.575), angle = Angle(0, 90, 90), size = Vector(0.088, 0.088, 0.088), color = Color(125, 125, 125, 255), surpresslightning = false, material = "phoenix_storms/pro_gear_side", skin = 0, bodygroup = {} }
}
SWEP.WElements = {
	["base"] = { type = "Model", model = "models/props_combine/CombineTrain01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(14.76, 1.151, -4.046), angle = Angle(-170.299, 180, 0), size = Vector(0.04, 0.012, 0.01), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["bolt"] = { type = "Model", model = "models/Items/CrossbowRounds.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(14.998, 2.146, -6.43), angle = Angle(-4.311, 90, 0), size = Vector(0.1, 0.1, 0.1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/gibs/metalgibs/metal_gibs", skin = 0, bodygroup = {} },
	["bolt2"] = { type = "Model", model = "models/Items/combine_rifle_ammo01.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "bolt", pos = Vector(-0.5, 0, 0), angle = Angle(90, 0, 0), size = Vector(0.08, 0.08, 0.08), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["grip"] = { type = "Model", model = "models/weapons/w_pist_glock18.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(-11.301, 0.159, -3.844), angle = Angle(0, 0, 0), size = Vector(0.8, 0.8, 0.8), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["mag"] = { type = "Model", model = "models/props_combine/combine_train02a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(11.622, 1.01, -1.46), angle = Angle(0, 90, -73.293), size = Vector(0.01, 0.01, 0.01), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["scope"] = { type = "Model", model = "models/maxofs2d/lamp_flashlight.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "scopehold", pos = Vector(0, -1.6, 1.58), angle = Angle(0, 90, 0), size = Vector(0.17, 0.17, 0.17), color = Color(144, 144, 144, 255), surpresslightning = false, material = "phoenix_storms/pro_gear_side", skin = 0, bodygroup = {} },
	["scope+"] = { type = "Model", model = "models/maxofs2d/lamp_flashlight.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "scope", pos = Vector(-2.874, 0, 0), angle = Angle(0, 180, 0), size = Vector(0.17, 0.17, 0.17), color = Color(144, 144, 144, 255), surpresslightning = false, material = "phoenix_storms/pro_gear_side", skin = 0, bodygroup = {} },
	["scopehold"] = { type = "Model", model = "models/props_phx/gears/rack9.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(-7.9, 0, 2.2), angle = Angle(0, 90, 0), size = Vector(0.15, 0.1, 0.15), color = Color(116, 116, 116, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["scopelens"] = { type = "Model", model = "models/hunter/tubes/circle2x2.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "scope", pos = Vector(1.474, 0, 0), angle = Angle(-90, 0, 0), size = Vector(0.017, 0.017, 0.017), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/XQM/BoxFull_diffuse", skin = 0, bodygroup = {} },
	["scopelens+"] = { type = "Model", model = "models/hunter/tubes/circle2x2.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "scope", pos = Vector(-4.349, 0, 0), angle = Angle(-90, 0, 0), size = Vector(0.017, 0.017, 0.017), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/XQM/BoxFull_diffuse", skin = 0, bodygroup = {} },
	["scoperod"] = { type = "Model", model = "models/mechanics/robotics/g1.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "scopehold", pos = Vector(-0.078, 0.026, 0.575), angle = Angle(0, 90, 90), size = Vector(0.088, 0.088, 0.088), color = Color(125, 125, 125, 255), surpresslightning = false, material = "phoenix_storms/pro_gear_side", skin = 0, bodygroup = {} }
}
SWEP.ViewModelBoneMods = {
	["ValveBiped.Bip01_R_Finger1"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0.55, 0), angle = Angle(0, -38.802, 8.623) },
	["ValveBiped.Bip01_R_Finger2"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(0, -25.868, 0) },
	["ValveBiped.Bip01_R_Finger21"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(0, -2.156, 0) },
	["ValveBiped.Bip01_R_Finger22"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(-8.623, 34.491, 0) },
	["ValveBiped.Bip01_R_Finger3"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(0, -15.09, 8.623) },
	["ValveBiped.Bip01_R_Finger32"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(0, 8.623, 0) },
	["ValveBiped.Bip01_R_Finger4"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(0, -21.557, 8.623) },
	["ValveBiped.Bip01_R_Forearm"] = { scale = Vector(1, 1, 1), pos = Vector(-1.078, 0.719, -1.437), angle = Angle(0, 0, 0) },
	["v_weapon.MP5_Parent"] = { scale = Vector(1,1,1), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) }
}
SWEP.HUD3DBone = "v_weapon.MP5_Parent"
SWEP.HUD3DPos = Vector(-1.15, -4.4, -4)
SWEP.HUD3DAng = Angle(0, 0, -18)
SWEP.HUD3DScale = 0.015


-- 判断是否处于“完全开镜”状态的函数 (开镜动画结束后)
function SWEP:IsScoped()
	return self:GetIronsights() and self.fIronTime and self.fIronTime + 0.25 <= CurTime()
end

-- 客户端代码 (只在客户端运行)
if CLIENT then
	local texScope = surface.GetTextureID("zombiesurvival/scope")
	
	-- 绘制瞄准镜UI的函数
	function SWEP:DrawHUDBackground()
		if GAMEMODE.DisableScopes then return end
		if not self:IsScoped() then return end

		local scrw, scrh = ScrW(), ScrH()
		local size = math.min(scrw, scrh)

		local hw = scrw * 0.5
		local hh = scrh * 0.5

		surface.SetDrawColor(19, 17, 17, 180)
		surface.DrawLine(0, hh, scrw, hh)
		surface.DrawLine(hw, 0, hw, scrh)
		for i=1, 10 do
			surface.DrawLine(hw, hh + i * 7, hw + (50 - i * 5), hh + i * 7)
		end

		surface.SetTexture(texScope)
		surface.SetDrawColor(255, 255, 255, 255)
		surface.DrawTexturedRect((scrw - size) * 0.5, (scrh - size) * 0.5, size, size)
		surface.SetDrawColor(0, 0, 0, 255)
		if scrw > size then
			local extra = (scrw - size) * 0.5
			surface.DrawRect(0, 0, extra, scrh)
			surface.DrawRect(scrw - extra, 0, extra, scrh)
		end
		if scrh > size then
			local extra = (scrh - size) * 0.5
			surface.DrawRect(0, 0, scrw, extra)
			surface.DrawRect(0, scrh - extra, scrw, extra)
		end
	end
end