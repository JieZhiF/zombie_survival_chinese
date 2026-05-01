AddCSLuaFile()

SWEP.PrintName = ""..translate.Get("weapon_zs_gunturretcontrol")
--SWEP.Description = "R: 切换显示模式 | 左键: 切换目标 | 右键: 手动控制"
SWEP.Description = ""..translate.Get("weapon_zs_gunturretcontrol_description") -- 炮塔控制器描述
-- 定义显示模式常量
local MODE_SELECTED = 0
local MODE_ALL = 1
local MODE_OFF = 2

if CLIENT then
	SWEP.Slot = GAMEMODE:GetWeaponSlot("WeaponSelectSlotDeployables")
	SWEP.SlotGroup = WEPSELECT_DEPLOYABLES
	SWEP.ViewModelFOV = 50
    SWEP.BobScale = 0.5
	SWEP.SwayScale = 0.5
end

SWEP.ViewModel = "models/weapons/c_slam.mdl"
SWEP.WorldModel = "models/weapons/w_slam.mdl"
SWEP.UseHands = true

SWEP.Primary.Delay = 0
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.NoDeploySpeedChange = true
SWEP.NoTransfer = true
SWEP.AutoSwitchFrom	= false

SWEP.WalkSpeed = SPEED_FAST

SWEP.NoMagazine = true
SWEP.Undroppable = true
SWEP.NoPickupNotification = true

SWEP.HoldType = "slam"
-- DT 说明:
-- DTBool(0): 是否正在手动控制
-- DTInt(0):  当前的显示模式 (0: 选定, 1: 全部, 2: 关闭)
-- DTEntity(0): 当前选中的炮塔

function SWEP:Initialize()
	self:SetWeaponHoldType(self.HoldType)
	self:SetDeploySpeed(10)
    if SERVER then
        self:SetDTInt(0, MODE_SELECTED) -- 默认显示选定
    end
end
-- 获取冷却时间
function SWEP:GetNextActionTime() return self:GetDTFloat(0) end
function SWEP:SetNextActionTime(time) self:SetDTFloat(0, time) end

-- 获取玩家拥有的所有炮塔列表
function SWEP:GetOwnedTurrets()
    local owner = self:GetOwner()
    local turrets = {}
    for _, ent in pairs(ents.FindByClass("prop_gunturret*")) do
        if ent:IsValid() and ent:GetObjectOwner() == owner then
            table.insert(turrets, ent)
        end
    end
    return turrets
end

function SWEP:Think()
	if self.IdleAnimation and self.IdleAnimation <= CurTime() then
		self.IdleAnimation = nil
		self:SendWeaponAnim(ACT_VM_IDLE)
	end

	if SERVER then
        local current = self:GetTurret()
        -- 如果当前没选中炮塔，或者选中的炮塔失效了，自动找一个
        if not current:IsValid() or current:GetObjectOwner() ~= self:GetOwner() then
            local turrets = self:GetOwnedTurrets()
            if #turrets > 0 then
                self:SetTurret(turrets[1])
            else
                -- 一个炮塔都没有，删除控制器
                self:GetOwner():StripWeapon(self:GetClass())
            end
        end
	end
end

function SWEP:PrimaryAttack()
    -- 1. 增加预测检查，防止逻辑在同一次点击中运行两次（客户端一次，服务器一次）
    if not IsFirstTimePredicted() then return end

    -- 2. 严格的冷却检查
    if CurTime() < self:GetNextActionTime() then return end
    
    -- 3. 手动控制时不许切换
    if self:GetDTBool(0) then return end

    local turrets = self:GetOwnedTurrets()
    if #turrets <= 1 then return end

    local current = self:GetTurret()
    local nextIndex = 1
    for i, ent in ipairs(turrets) do
        if ent == current then
            nextIndex = i + 1
            break
        end
    end

    if nextIndex > #turrets then nextIndex = 1 end
    
    -- 执行切换
    self:SetTurret(turrets[nextIndex])
    
    -- 4. 设置冷却时间（0.5秒足够防止误触，也不会觉得卡顿）
    self:SetNextActionTime(CurTime() + 0.25)

    -- 5. 播放切换音效
    if CLIENT then
        self:GetOwner():EmitSound("buttons/lightswitch2.wav", 60, 150)
    end
end


function SWEP:SecondaryAttack()
	if IsFirstTimePredicted() then
		self:SetDTBool(0, not self:GetDTBool(0))
		if CLIENT then
			MySelf:EmitSound(self:GetDTBool(0) and "buttons/button17.wav" or "buttons/button19.wav", 0)
		end
	end
end

-- R键：切换显示模式
function SWEP:Reload()
    -- 增加时间检查，防止按住R时快速闪烁
    if CurTime() < self:GetNextActionTime() then return end
    
    if IsFirstTimePredicted() then
        local mode = self:GetDTInt(0)
        mode = mode + 1
        if mode > MODE_OFF then mode = MODE_SELECTED end
        self:SetDTInt(0, mode)

        -- 设置 0.5 秒操作冷却
        self:SetNextActionTime(CurTime() + 0.5)

        if CLIENT then
            MySelf:EmitSound("buttons/combine_button7.wav", 60, 100)
        end
    end
end
-- 获取补给弹药类型 (用于弹药箱)
function SWEP:GetResupplyAmmoType()
	local turret = self:GetTurret()
	if IsValid(turret) then
		return turret.AmmoType
	end
	return "smg1"
end
function SWEP:Deploy()
	gamemode.Call("WeaponDeployed", self:GetOwner(), self)

	self.IdleAnimation = CurTime() + self:SequenceDuration()

	return true
end

function SWEP:Holster()
	return true
end
function SWEP:GetTurret() return self:GetDTEntity(0) end
function SWEP:SetTurret(ent) self:SetDTEntity(0, ent) end

-----------------------------------------------------------
-- 客户端渲染逻辑
-----------------------------------------------------------
if CLIENT then
    function SWEP:DrawWeaponSelection(x, y, w, h, alpha)
        self:BaseDrawWeaponSelection(x, y, w, h, alpha)
    end
    local matBeam = Material("trails/laser")
    local matGlow = Material("sprites/glow04_noz")

-- 绘制扫描范围的辅助函数（适配天赋版）
    local function DrawTurretVisuals(turret, isSelected, showFill)
        if not IsValid(turret) then return end
        
        local range = turret.SearchDistance or 768
        local dotLimit = turret.MinimumAimDot or 0.5
        
        -- --- 核心：适配天赋 ---
        -- 获取炮塔实体上存储的扫描角度乘数（由玩家天赋决定，如 0.1 或 1.5）
        local scanMul = turret:GetScanMaxAngle() or 1
        
        local shootPos = turret:ShootPos()
        local forward = turret:GetForward()
        
        -- 计算基础张角 (Dot 0.5 = 60度)
        local baseAngle = math.deg(math.acos(math.Clamp(dotLimit, -1, 1)))
        
        -- 最终显示的张角 = 基础角度 * 天赋乘数
        -- 如果玩家有点出“锁定”技能，这里计算出来的角度会变得非常窄
        local angleLimit = baseAngle * scanMul
        
        -- 颜色设定
        local color = isSelected and Color(0, 255, 0, 230) or Color(0, 200, 255, 180)
        local thickness = isSelected and 3 or 1.5

        -- 绘制 3D 边框线
        render.SetMaterial(matBeam)
        local segments = 12
        local baseAng = forward:Angle()
        local lastArcPos = nil
        local arcPoints = {}

        for i = 0, segments do
            local deg = (i / segments) * (angleLimit * 2) - angleLimit
            local ang = Angle(baseAng.p, baseAng.y, baseAng.r)
            ang:RotateAroundAxis(ang:Up(), -deg)
            local targetPos = shootPos + ang:Forward() * range
            table.insert(arcPoints, targetPos)

            if i == 0 or i == segments then
                render.DrawBeam(shootPos, targetPos, thickness, 0, 1, color)
            end
            if lastArcPos then
                render.DrawBeam(lastArcPos, targetPos, thickness, 0, 1, color)
            end
            lastArcPos = targetPos
        end

        -- 绘制地面填充
        if showFill then
            local tr = util.TraceLine({
                start = turret:GetPos() + Vector(0,0,10),
                endpos = turret:GetPos() - Vector(0,0,100),
                filter = {turret, turret:GetTurretHitbox()}
            })
            if tr.Hit then
                cam.Start3D2D(tr.HitPos + tr.HitNormal * 1, tr.HitNormal:Angle() + Angle(90, 0, 0), 1)
                    local poly = {{x = 0, y = 0}}
                    local rot = math.atan2(forward.y, forward.x)
                    for i = 0, segments do
                        -- 这里同样应用计算后的弧度
                        local d = math.rad((i / segments) * (angleLimit * 2) - angleLimit)
                        local finalAng = rot - d
                        table.insert(poly, {x = math.cos(finalAng) * range, y = -math.sin(finalAng) * range})
                    end
                    draw.NoTexture()
                    surface.SetDrawColor(color.r, color.g, color.b, isSelected and 45 or 25)
                    surface.DrawPoly(poly)
                cam.End3D2D()
            end
        end
    end
    -- 范围显示逻辑
    hook.Add("PostDrawTranslucentRenderables", "TurretControlSystem", function()
        local lp = LocalPlayer()
        if not IsValid(lp) or lp:Team() ~= TEAM_HUMAN then return end
        
        local wep = lp:GetActiveWeapon()
        if not IsValid(wep) or wep:GetClass() ~= "weapon_zs_gunturretcontrol" then return end
        
        -- 新增：如果正在手动控制，则不显示任何扫描范围
        if wep:GetDTBool(0) then return end

        local mode = wep:GetDTInt(0)
        if mode == MODE_OFF then return end

        local selectedTurret = wep:GetTurret()

        if mode == MODE_SELECTED then
            DrawTurretVisuals(selectedTurret, true, true)
        elseif mode == MODE_ALL then
            for _, ent in pairs(ents.FindByClass("prop_gunturret*")) do
                if ent:IsValid() and ent:GetObjectOwner() == lp then
                    DrawTurretVisuals(ent, ent == selectedTurret, true)
                end
            end
        end
    end)

    -- HUD 文字逻辑
    function SWEP:DrawHUD()
        -- 新增：如果正在手动控制，隐藏所有 HUD 文字
        if self:GetDTBool(0) then return end
        local turret = self:GetTurret()
        local name = GAMEMODE.AmmoNames[turret and turret.AmmoType or ""] or "未知"
        local mode = self:GetDTInt(0)
        local modeName = "选定"
        if mode == 1 then modeName = "全部" elseif mode == 2 then modeName = "关闭" end
        
        local turret = self:GetTurret()
        local turretName = IsValid(turret) and "编号: "..turret:EntIndex() or "无"
        
        draw.SimpleText("扫描显示模式: "..modeName.." (按R切换)", "ZSHUDFontSmallest", ScrW() * 0.85, ScrH() * 0.85, COLOR_WHITE, TEXT_ALIGN_CENTER)
        draw.SimpleText("控制目标: "..turretName.." (左键切换)".."弹药类型：" .. name, "ZSHUDFontSmallest", ScrW() * 0.85, ScrH() * 0.88, COLOR_WHITE, TEXT_ALIGN_CENTER)
 
        -- 提示右键可以进入手动模式
        draw.SimpleText("右键进入手动控制", "ZSHUDFontSmallest", ScrW() * 0.85, ScrH() * 0.91, Color(100, 255, 100, 255), TEXT_ALIGN_CENTER)
    end
end