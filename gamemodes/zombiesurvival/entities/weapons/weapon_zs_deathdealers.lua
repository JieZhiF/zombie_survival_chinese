-- ============================================================================
-- weapon_zs_deathdealers.lua - 双持霰弹手枪（死亡使者）
-- 负责：双持精英手枪外观的霰弹武器：8 粒弹丸、左右枪交替开火动画、
--       换弹时向两侧抛出假武器模型、左右枪交替的曳光弹发射点
-- ============================================================================
AddCSLuaFile() -- 将该文件同时发送到客户端

-- 武器显示名称（本地化）
SWEP.PrintName = ""..translate.Get("weapon_zs_deathdealers")
-- 武器描述（本地化）
SWEP.Description = ""..translate.Get("weapon_zs_deathdealers_description")


-- 武器在栏位中的位置序号
SWEP.SlotPos = 0

if CLIENT then -- 客户端专属设置
	-- 武器栏位：放入"霰弹枪"分类
	SWEP.Slot = GAMEMODE:GetWeaponSlot("WeaponSelectSlotShotguns")
	-- 栏位组：霰弹枪栏
	SWEP.SlotGroup = WEPSELECT_SHOTGUN
	SWEP.ViewModelFlip = false -- 不翻转第一人称模型
	SWEP.ViewModelFOV = 62 -- 第一人称视野大小
	SWEP.ShowViewModel = false -- 隐藏原始第一人称模型（用自定义元素）
	SWEP.ShowWorldModel = false -- 隐藏世界模型

	-- HUD 3D 武器展示图：绑定骨骼与位置/缩放
	SWEP.HUD3DBone = "v_weapon.slide_right"
	SWEP.HUD3DPos = Vector(0, -3, -3.5)
	SWEP.HUD3DScale = 0.015

	-- 第一人称手持元素：用零件拼装左右两支枪（握把、枪管、底部等）
	SWEP.VElements = {
		["handle+"] = { type = "Model", model = "models/weapons/w_pist_elite_single.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "barrel++", pos = Vector(-0.308, 20.618, -2.906), angle = Angle(-60.416, 89, 0), size = Vector(0.685, 1.394, 1.488), color = Color(105, 105, 105, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["handle"] = { type = "Model", model = "models/weapons/w_pist_elite_single.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "barrel", pos = Vector(-0.308, 20.618, -2.906), angle = Angle(-60.416, 89, 0), size = Vector(0.685, 1.394, 1.488), color = Color(105, 105, 105, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["barrel+"] = { type = "Model", model = "models/props_combine/combine_train02a.mdl", bone = "v_weapon.elite_right", rel = "barrel", pos = Vector(0, 11.961, 0), angle = Angle(0, 0, 0), size = Vector(0.035, 0.004, 0.029), color = Color(105, 105, 105, 255), surpresslightning = false, material = "models/props_pipes/destroyedpipes01a", skin = 0, bodygroup = {} },
		["barrel+++"] = { type = "Model", model = "models/props_combine/combine_train02a.mdl", bone = "v_weapon.elite_right", rel = "barrel++", pos = Vector(0, 11.961, 0), angle = Angle(0, 0, 0), size = Vector(0.035, 0.004, 0.029), color = Color(105, 105, 105, 255), surpresslightning = false, material = "models/props_pipes/destroyedpipes01a", skin = 0, bodygroup = {} },
		["bottom2"] = { type = "Model", model = "models/props_wasteland/laundry_washer003.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "barrel", pos = Vector(0, -5.393, -3.069), angle = Angle(180, 90, 0), size = Vector(0.143, 0.07, 0.057), color = Color(105, 105, 105, 255), surpresslightning = false, material = "models/props_pipes/destroyedpipes01a", skin = 0, bodygroup = {} },
		["barrel"] = { type = "Model", model = "models/props_combine/combine_train02a.mdl", bone = "v_weapon.elite_right", rel = "", pos = Vector(0.028, -2.34, 17.02), angle = Angle(180, 0, -90), size = Vector(0.034, 0.045, 0.029), color = Color(165, 165, 155, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["BARREL2+"] = { type = "Model", model = "models/props_combine/combinebutton.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "barrel++", pos = Vector(-0.138, -14.155, -0.889), angle = Angle(180, -90, -90), size = Vector(0.352, 0.356, 0.18), color = Color(105, 105, 105, 255), surpresslightning = false, material = "models/props_pipes/destroyedpipes01a", skin = 0, bodygroup = {} },
		["bottom2+"] = { type = "Model", model = "models/props_wasteland/laundry_washer003.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "barrel++", pos = Vector(0, -5.393, -3.069), angle = Angle(180, 90, 0), size = Vector(0.143, 0.07, 0.057), color = Color(105, 105, 105, 255), surpresslightning = false, material = "models/props_pipes/destroyedpipes01a", skin = 0, bodygroup = {} },
		["barrel++"] = { type = "Model", model = "models/props_combine/combine_train02a.mdl", bone = "v_weapon.elite_left", rel = "", pos = Vector(-0.213, -2.34, 17.02), angle = Angle(180, 0, -90), size = Vector(0.034, 0.045, 0.029), color = Color(165, 165, 155, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["BARREL2"] = { type = "Model", model = "models/props_combine/combinebutton.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "barrel", pos = Vector(-0.138, -14.155, -0.889), angle = Angle(180, -90, -90), size = Vector(0.352, 0.356, 0.18), color = Color(105, 105, 105, 255), surpresslightning = false, material = "models/props_pipes/destroyedpipes01a", skin = 0, bodygroup = {} }
	}

	-- 第三人称世界元素：同样的零件拼装，绑在玩家手部骨骼上
	SWEP.WElements = {
		["handle+"] = { type = "Model", model = "models/weapons/w_pist_elite_single.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "barrel++", pos = Vector(-0.308, 20.618, -2.906), angle = Angle(-60.416, 89, 0), size = Vector(0.685, 1.394, 1.488), color = Color(105, 105, 105, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["handle"] = { type = "Model", model = "models/weapons/w_pist_elite_single.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "barrel", pos = Vector(-0.308, 20.618, -2.906), angle = Angle(-60.416, 89, 0), size = Vector(0.685, 1.394, 1.488), color = Color(105, 105, 105, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["barrel+"] = { type = "Model", model = "models/props_combine/combine_train02a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "barrel", pos = Vector(0, 11.961, 0), angle = Angle(0, 0, 0), size = Vector(0.035, 0.004, 0.029), color = Color(105, 105, 105, 255), surpresslightning = false, material = "models/props_pipes/destroyedpipes01a", skin = 0, bodygroup = {} },
		["BARREL2+"] = { type = "Model", model = "models/props_combine/combinebutton.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "barrel++", pos = Vector(-0.138, -14.155, -0.889), angle = Angle(180, -90, -90), size = Vector(0.352, 0.356, 0.18), color = Color(105, 105, 105, 255), surpresslightning = false, material = "models/props_pipes/destroyedpipes01a", skin = 0, bodygroup = {} },
		["bottom2+"] = { type = "Model", model = "models/props_wasteland/laundry_washer003.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "barrel++", pos = Vector(0, -5.393, -3.069), angle = Angle(180, 90, 0), size = Vector(0.143, 0.07, 0.057), color = Color(105, 105, 105, 255), surpresslightning = false, material = "models/props_pipes/destroyedpipes01a", skin = 0, bodygroup = {} },
		["barrel"] = { type = "Model", model = "models/props_combine/combine_train02a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(20.041, 2.372, -3.764), angle = Angle(180, -95, 8), size = Vector(0.034, 0.045, 0.029), color = Color(165, 165, 155, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["BARREL2"] = { type = "Model", model = "models/props_combine/combinebutton.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "barrel", pos = Vector(-0.138, -14.155, -0.889), angle = Angle(180, -90, -90), size = Vector(0.352, 0.356, 0.18), color = Color(105, 105, 105, 255), surpresslightning = false, material = "models/props_pipes/destroyedpipes01a", skin = 0, bodygroup = {} },
		["bottom2"] = { type = "Model", model = "models/props_wasteland/laundry_washer003.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "barrel", pos = Vector(0, -5.393, -3.069), angle = Angle(180, 90, 0), size = Vector(0.143, 0.07, 0.057), color = Color(105, 105, 105, 255), surpresslightning = false, material = "models/props_pipes/destroyedpipes01a", skin = 0, bodygroup = {} },
		["barrel++"] = { type = "Model", model = "models/props_combine/combine_train02a.mdl", bone = "ValveBiped.Bip01_L_Hand", rel = "", pos = Vector(19.978, 2.829, 4.127), angle = Angle(0, -95, 8), size = Vector(0.034, 0.045, 0.029), color = Color(165, 165, 155, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["barrel+++"] = { type = "Model", model = "models/props_combine/combine_train02a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "barrel++", pos = Vector(0, 11.961, 0), angle = Angle(0, 0, 0), size = Vector(0.035, 0.004, 0.029), color = Color(105, 105, 105, 255), surpresslightning = false, material = "models/props_pipes/destroyedpipes01a", skin = 0, bodygroup = {} }
	}

	-- 第一人称骨骼变形：调整左右手枪骨骼与手臂姿态
	SWEP.ViewModelBoneMods = {
		["v_weapon.elite_right"] = { scale = Vector(1, 1, 1), pos = Vector(0, -0.19, -4.318), angle = Angle(0, 0, -3) },
		["ValveBiped.Bip01_Spine4"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(0, 4.721, 0) },
		["ValveBiped.Bip01_L_Hand"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(7, 0, 0) },
		["v_weapon.elite_left"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0.126, -3.794), angle = Angle(0, 0, -3) },
		["ValveBiped.Bip01_R_Hand"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(-7, 0, 0) }
	}
end

-- 继承武器母本
SWEP.Base = "weapon_zs_base"

-- 手持姿势：双持姿势
SWEP.HoldType = "duel"

-- 第一人称模型（双持精英手枪骨架）
SWEP.ViewModel = "models/weapons/cstrike/c_pist_elite.mdl"
-- 世界模型
SWEP.WorldModel = "models/weapons/w_pist_elite.mdl"
-- 掉落在地上的假世界模型（霰弹枪外观）
SWEP.FakeWorldModel = "models/weapons/w_shotgun.mdl"
SWEP.UseHands = true -- 使用玩家手臂模型握持

SWEP.Primary.Damage = 15.75 -- 单粒弹丸伤害
SWEP.Primary.NumShots = 8 -- 一次射击 8 粒弹丸
SWEP.Primary.Delay = 0.6 -- 射击间隔

SWEP.Primary.ClipSize = 8 -- 弹匣容量（两枪各 4 发）
SWEP.Primary.Automatic = true -- 全自动
SWEP.Primary.Ammo = "buckshot" -- 弹药类型：鹿弹
GAMEMODE:SetupDefaultClip(SWEP.Primary) -- 按游戏模式规则设置默认备弹

SWEP.ConeMax = 6 -- 最大扩散
SWEP.ConeMin = 4 -- 最小扩散

-- 附加武器修正：降低最大/最小扩散（更精准）
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_MAX_SPREAD, -0.75)
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_MIN_SPREAD, -0.5)

SWEP.Tier = 5 -- 武器等级（5 级高级武器）
SWEP.MaxStock = 2 -- 商店最大库存量

-- ==== SendReloadAnimation - 播放换弹动画 ====
-- 换弹时播放拔出动画（双枪重新上膛的表现）
function SWEP:SendReloadAnimation()
	self:SendWeaponAnim(ACT_VM_DRAW)
end

-- ==== SecondaryAttack - 右键（空实现） ====
function SWEP:SecondaryAttack()
end

-- ==== Reload - 换弹：抛出左右两把假枪 ====
-- 换弹开始时向身体两侧抛出两个假武器模型，模拟把枪扔出去换新枪
function SWEP:Reload()
	local owner = self:GetOwner()
	if owner:IsHolding() or not self:CanReload() then return end -- 持握物品或不可换弹时取消

	if SERVER then -- 仅服务器生成实体
		for i=1,2 do -- 左右各抛一把
			local ent = ents.Create("prop_fakeweapon")
			if ent:IsValid() then
				ent:SetOwner(owner) -- 假武器属于该玩家
				ent:SetWeaponType(self:GetClass()) -- 记录对应的武器类型
				-- 生成在玩家眼前偏左/偏右的位置
				local pos = owner:EyePos() + owner:EyeAngles():Right() * (i == 1 and 8 or -8)
				ent:SetPos(pos)
				ent:SetAngles(VectorRand():Angle()) -- 随机旋转
				ent:Spawn()
				local phys = ent:GetPhysicsObject()
				if phys:IsValid() then
					-- 随机翻滚角速度 + 沿视线方向抛出
					phys:AddAngleVelocity(Vector(math.Rand(-420, 420), math.Rand(-420, 420), math.Rand(-420, 420)))
					phys:ApplyForceCenter(phys:GetMass() * owner:GetAimVector() * math.random(64, 128))
				end
			end
		end
	end

	self.BaseClass.Reload(self) -- 继续执行母本换弹逻辑
end

-- ==== SendWeaponAnimation - 左右枪交替开火动画 ====
-- 根据剩余弹药奇偶决定播放左枪还是右枪的开火动画
function SWEP:SendWeaponAnimation()
	self:SendWeaponAnim(self:Clip1() % 2 == 0 and ACT_VM_PRIMARYATTACK or ACT_VM_SECONDARYATTACK)
end

-- ==== EmitFireSound - 播放开火音效 ====
-- 双管霰弹枪开火声，带随机音调
function SWEP:EmitFireSound()
	self:EmitSound("weapons/shotgun/shotgun_dbl_fire.wav", 75, math.random(125, 130))
end

if not CLIENT then return end -- 以下仅客户端执行

-- ==== GetTracerOrigin - 获取曳光弹发射点 ====
-- 根据剩余弹药奇偶，返回当前开火那支枪的枪口附件位置
function SWEP:GetTracerOrigin()
	local owner = self:GetOwner()
	if owner:IsValid() then
		local vm = owner:GetViewModel()
		if vm and vm:IsValid() then
			-- 附件 3/4 对应左右枪口
			local attachment = vm:GetAttachment(self:Clip1() % 2 + 3)
			if attachment then
				return attachment.Pos
			end
		end
	end
end
