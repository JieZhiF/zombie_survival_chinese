-- 视角模型（第一人称看到的武器模型）
SWEP.ViewModel = "models/weapons/v_axe/v_axe.mdl"
-- 世界模型（其他玩家/地上看到的武器模型）
SWEP.WorldModel = "models/weapons/w_axe.mdl"

-- ====== Primary fire（主攻击） 基本设置 ======
SWEP.Primary.ClipSize = -1         -- 子弹槽（近战通常 -1 表示无限或不使用弹匣）
SWEP.Primary.DefaultClip = -1     -- 初始弹药（-1 表示不适用）
SWEP.Primary.Automatic = true     -- 是否按住左键持续触发（对近战通常允许按住）
SWEP.Primary.Ammo = "none"        -- 使用的弹药类型（"none" 表示不消耗弹药）
SWEP.Primary.Delay = 1            -- 主攻击间隔（秒），和 owner:GetMeleeSpeedMul() 会一起影响实际速度

-- ====== 近战专用属性 ======
SWEP.MeleeDamage = 30             -- 每次近战造成的基础伤害（会乘以各种倍率）
SWEP.MeleeRange = 65              -- 近战的射线/检测距离（单位：源引擎单位）
SWEP.MeleeSize = 1.5              -- 近战检测的半径（相当于 trace 半径 / 宽度）
SWEP.MeleeKnockBack = 0           -- 造成的击退强度（用于玩家或实体的抛掷/推开）

-- ====== Secondary（次攻击）示例设置（这里被用作格挡或占位） ======
SWEP.Secondary.ClipSize = 1
SWEP.Secondary.DefaultClip = 1
SWEP.Secondary.Ammo = "dummy"
SWEP.Secondary.Automatic = true

-- 玩家携带时的移动速度（由 gamemode 使用）
SWEP.WalkSpeed = SPEED_FAST

-- 标记这是近战武器（供其他代码分支检测）
SWEP.IsMelee = true
SWEP.MeleeFlagged = false         -- 用于 PostHitUtil 中标记是否将 IsMelee 暂时打开

-- 动作/持枪类型 —— 影响玩家动作动画（后面会映射到 ActIndex）
SWEP.HoldType = "melee"         -- 武器默认持握类型（站立/行走/攻击等的动画组）
SWEP.SwingHoldType = "melee2"   -- 挥舞时使用的持握类型（用于切换不同挥动画）

-- 伤害类型（源引擎常量）
SWEP.DamageType = DMG_SLASH

-- 命中表现（命中血肉/地面不同的贴花）
SWEP.BloodDecal = "Blood"
SWEP.HitDecal = "Impact.Concrete"

-- 动画常量（视角手臂动画）
SWEP.HitAnim = ACT_VM_HITCENTER
SWEP.MissAnim = ACT_VM_MISSCENTER

-- 挥舞动画 / 偏移（用于 StartSwinging / 动画展示）
SWEP.SwingTime = 0                      -- 挥舞持续时间（如果为 0 则直接调用 MeleeSwing）
SWEP.SwingRotation = Angle(0, 0, 0)     -- 挥舞时的旋转偏移（视图模型）
SWEP.SwingOffset = Vector(0, 0, 0)      -- 挥舞时的位置偏移（视图模型）

-- 格挡（block / parry）相关
SWEP.MeleeDelay = 0
SWEP.BlockHoldType = "melee2"          -- 格挡时使用的持握类型（影响动画）
SWEP.BlockPos = Vector(0, 0, 0)        -- 格挡视图位置偏移
SWEP.BlockAng = Angle(0, 0, 0)         -- 格挡视图角度偏移

SWEP.DefendingDamageBlockedDefault = 1.5 -- 默认的“被格挡时减少伤害”基值（>1 表示某种减伤系数）
SWEP.DefendingDamageBlocked = 1.5        -- 当前格挡减伤值（会在 Think 里动态改变，对于完美格挡/蓄力有作用）
SWEP.NextBlock = 2                       -- 格挡冷却（时间戳或秒数初始值用于限制连续格挡）

SWEP.BlockSound = "weapons/rpg/shotdown.wav" -- 格挡触发音效
SWEP.BlockSoundPitch = 90                    -- 格挡音效音高（pitch）
SWEP.ParryStartTime = 1                      -- 用来记录格挡开始时间（注意：初始化为1可能导致逻辑上的细微问题，建议初始为0）

SWEP.AllowQualityWeapons = false
SWEP.Weight = 4

-- 常量别名：材质类型判断（用于区分是否为肉身）
local MAT_FLESH = MAT_FLESH
local MAT_BLOODYFLESH = MAT_BLOODYFLESH
local MAT_ANTLION = MAT_ANTLION
local MAT_ALIENFLESH = MAT_ALIENFLESH

-- 初始化：设置部署速度、持枪类型、挥舞持枪类型；客户端做动画初始化
function SWEP:Initialize()
    GAMEMODE:DoChangeDeploySpeed(self)        -- 通知 gamemode 调整部署速度（gamemode 定义）
    self:SetWeaponHoldType(self.HoldType)     -- 初始化 ActivityTranslate（普通持枪）
    self:SetWeaponSwingHoldType(self.SwingHoldType) -- 初始化挥舞时的 ActivityTranslateSwing

    if CLIENT then
        self:Anim_Initialize() -- 客户端专用的动画初始化（如果定义）
    end
end

-- 网络变量（DataTables）用于同步变量到客户端/服务器
function SWEP:SetupDataTables()
    self:NetworkVar("Int", 0, "PowerCombo") -- 定义一个整型 NetworkVar：GetPowerCombo / SetPowerCombo
end

-- 设置挥舞时的持枪类型：把当前 ActivityTranslate（普通）保留到 old，把新类型设置到 ActivityTranslateSwing
function SWEP:SetWeaponSwingHoldType(t)
    local old = self.ActivityTranslate
    self:SetWeaponHoldType(t)           -- 这会修改 self.ActivityTranslate
    local new = self.ActivityTranslate
    self.ActivityTranslate = old        -- 恢复普通的 ActivityTranslate（保留之前的）
    self.ActivityTranslateSwing = new  -- 保存挥舞时的 Activity 表为 ActivityTranslateSwing
end

-- 部署武器（切换到武器时调用）
function SWEP:Deploy()
    gamemode.Call("WeaponDeployed", self:GetOwner(), self) -- 通知 gamemode（如果需要）
    self.IdleAnimation = CurTime() + self:SequenceDuration() -- 在武器序列时间后播放空闲
    return true
end

-- Think 在每帧（或较短间隔）被调用：处理格挡衰减、完美格挡时间、挥舞结束触发等
function SWEP:Think()
    -- 如果在格挡但又同时挥舞，或者玩家没有按下 IN_RELOAD（这里逻辑可能写反？）则取消格挡
    if self:IsBlocking() and self:IsSwinging() or not self.Owner:KeyDown(IN_RELOAD) then
        self:SetBlocking(false)
    end

    if self:IsBlocking() and self.Owner:KeyDown(IN_RELOAD) then
        -- 格挡时逐渐降低 DefendingDamageBlocked，意图是奖励“长时间格挡后”的某种变化（比如完美格挡窗口）
        self.DefendingDamageBlocked = math.max(1.5, self.DefendingDamageBlocked - 0.010)

        -- 当格挡刚开始，记录开始时间（用于计算 Parry/完美格挡）
        if self.ParryStartTime == 0 then
            self.ParryStartTime = CurTime()
        end
    else
        -- 取消格挡时，逐步恢复 DefendingDamageBlocked 到默认值
        self.DefendingDamageBlocked = math.min(self.DefendingDamageBlockedDefault, self.DefendingDamageBlocked + 0.005)
        self.ParryStartTime = 0  -- 重置完美格挡计时
    end

    if self:IsBlocking() and CLIENT then
        self.BlockAnim = CurTime() + 1 -- 在客户端播放 Block 动画时间戳
    end

    -- 空闲动画播放控制
    if self.IdleAnimation and self.IdleAnimation <= CurTime() then
        self.IdleAnimation = nil
        self:SendWeaponAnim(ACT_VM_IDLE)
    end

    -- 如果正在挥舞并且挥舞时间结束，则停止挥舞并执行 MeleeSwing（真正的检测/命中逻辑）
    if self:IsSwinging() and self:GetSwingEnd() <= CurTime() then
        self:StopSwinging()
        self:MeleeSwing()
    end
end

-- SecondaryAttack 被覆盖为空（次攻击用于格挡），如果当前正在格挡则直接返回
function SWEP:SecondaryAttack()
    if self:IsBlocking() then return end
end

-- Reload 用作格挡触发（按 R 开始格挡）
function SWEP:Reload()
    if self:IsSwinging() then return end
    if self.NextBlock and self.NextBlock >= CurTime() then return end -- NextBlock 用于限制格挡频率
    if self:IsBlocking() then return end

    if not self:IsSwinging() and GetConVar("zsw_enable_block"):GetInt() == 1 then
        self:SetBlocking(true) -- 开始格挡（网络同步）
        self.ParryStartTime = CurTime() -- 记录格挡开始时间（用于完美格挡）
        self.Owner:EmitSound("physics/metal/weapon_impact_soft"..math.random(1,2)..".wav")
    end

    if GetConVar("zsw_enable_block"):GetInt() == 1 then
        self.NextBlock = CurTime() + 0.5 -- 格挡冷却（0.5s）
    end

    return false
end

--[[ 说明：GetBlockDamageMultiplier 为格挡计算伤害倍率的示例函数（服务器端） ]]
function SWEP:GetBlockDamageMultiplier(pl)
    -- 如果被攻击的玩家处于 Defending（格挡）状态
    if pl:IsDefending() then
        -- 获取玩家自身的防御值（此函数属于 Player）
        local defenseValue = pl:GetBlockDefense()

        if defenseValue and self.MeleePower > defenseValue then
            -- 当攻击方力量大于防御方防御值时，计算穿透伤害比例
            local multiplier = (self.MeleePower - defenseValue) / 100
            return math.max(0, multiplier)
        else
            -- 攻击力不足以穿透防御 => 完全格挡
            return 0
        end
    end

    -- 未格挡则正常伤害
    return 1
end

-- 判断是否可以进行主攻击（不能在挥舞、不能拿着某些东西、不能在建筑 ghost 模式等）
function SWEP:CanPrimaryAttack()
    if self:GetOwner():IsHolding() or self:GetOwner():GetBarricadeGhosting() then return false end
    return self:GetNextPrimaryFire() <= CurTime() and not self:IsSwinging()
end

-- 播放挥砍音效
function SWEP:PlaySwingSound()
    self:EmitSound("weapons/iceaxe/iceaxe_swing1.wav")
end
function SWEP:PlayStartSwingSound()
    -- 保留位置，若需要可实现挥砍起手声音
end
function SWEP:PlayHitSound()
    self:EmitSound("physics/flesh/flesh_impact_bullet" .. math.random( 3, 5 ) .. ".wav")
end
function SWEP:PlayHitFleshSound()
    self:EmitSound("physics/flesh/flesh_impact_bullet" .. math.random( 3, 5 ) .. ".wav")
end

-- 主攻击入口：检查能否攻击、是否处于格挡、设置下次攻击时间，并选择立即 MeleeSwing 或 StartSwinging
function SWEP:PrimaryAttack()
    if not self:CanPrimaryAttack() then return end
    if self:IsBlocking() then return end
    self:SetNextAttack()

    if self.SwingTime == 0 then
        self:MeleeSwing() -- 直接进行一次即时近战检测并造成伤害
    else
        self:StartSwinging() -- 有挥舞时间时先进入挥舞状态，等到设置的 SwingEnd 再真正处理命中
    end
end

-- 设置下一次主攻击的冷却（考虑玩家攻速乘数）
function SWEP:SetNextAttack()
    local owner = self:GetOwner()
    local armdelay = owner:GetMeleeSpeedMul() -- 玩家可能有攻速增益（hook/角色属性）
    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay * armdelay)
end

-- 放下武器（holster）时，如果正在挥舞且挥舞未结束则不能切换
function SWEP:Holster()
    if CurTime() >= self:GetSwingEnd() then
        if CLIENT then
            self:Anim_Holster()
        end
        return true
    end
    return false
end

-- 开始“挥舞”阶段（用于有前摇的武器）
function SWEP:StartSwinging()
    local owner = self:GetOwner()

    if self.StartSwingAnimation then
        self:SendWeaponAnim(self.StartSwingAnimation)
        self.IdleAnimation = CurTime() + self:SequenceDuration()
    end
    self:PlayStartSwingSound()

    local armdelay = owner:GetMeleeSpeedMul()
    -- 设置 SwingEnd（挥舞结束时间），这里考虑了玩家的 MeleeSwingDelayMul（可选属性）
    self:SetSwingEnd(CurTime() + self.SwingTime * (owner.MeleeSwingDelayMul or 1) * armdelay)
end

-- 播放玩家攻击动作（服务器端玩家动画事件）
function SWEP:DoMeleeAttackAnim()
    self:GetOwner():DoAttackEvent()
end

-- 真正做近战检测/命中逻辑（检测 trace、播放命中/未命中动画、音效、调用后续命中处理）
function SWEP:MeleeSwing()
    local owner = self:GetOwner()

    self:DoMeleeAttackAnim()

    -- 使用玩家的 CompensatedMeleeTrace（通常是带补偿的 trace，考虑 Ping / 预测）
    local tr = owner:CompensatedMeleeTrace(self.MeleeRange * (owner.MeleeRangeMul or 1), self.MeleeSize)

    -- 未命中分支
    if not tr.Hit then
        if self.MissAnim then
            self:SendWeaponAnim(self.MissAnim)
        end
        self.IdleAnimation = CurTime() + self:SequenceDuration()
        self:PlaySwingSound()

        -- 如果玩家有 PowerAttackMul（连击相关），则重置连击计数
        if owner.MeleePowerAttackMul and owner.MeleePowerAttackMul > 1 then
            self:SetPowerCombo(0)
        end

        if self.PostOnMeleeMiss then self:PostOnMeleeMiss(tr) end

        return
    end

    -- 命中后：基于玩家状态调整伤害倍率（例：人类职业加成，技能 LastStand）
    local damagemultiplier = owner:Team() == TEAM_HUMAN and owner.MeleeDamageMultiplier or 1
    if owner:IsSkillActive(SKILL_LASTSTAND) then
        if owner:Health() <= owner:GetMaxHealth() * 0.25 then
            damagemultiplier = damagemultiplier * 2
        else
            damagemultiplier = damagemultiplier * 0.85
        end
    end

    local hitent = tr.Entity
    local hitflesh = tr.MatType == MAT_FLESH or tr.MatType == MAT_BLOODYFLESH or tr.MatType == MAT_ANTLION or tr.MatType == MAT_ALIENFLESH

    -- 播放命中动画
    if self.HitAnim then
        self:SendWeaponAnim(self.HitAnim)
    end
    self.IdleAnimation = CurTime() + self:SequenceDuration()

    if hitflesh then
        -- 在肉体上画血迹、播放肉体命中音效、服务器端触发额外效果
        util.Decal(self.BloodDecal, tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal)
        self:PlayHitFleshSound()

        if SERVER then
            self:ServerHitFleshEffects(hitent, tr, damagemultiplier)
        end

        if not self.NoHitSoundFlesh then
            self:PlayHitSound()
        end
    else
        -- 非肉体命中分支（地面/金属等）
        -- util.Decal(self.HitDecal, tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal)
        self:PlayHitSound()
    end

    -- 如果存在用户扩展的 OnMeleeHit 并且返回 true，则认为已处理完毕
    if self.OnMeleeHit and self:OnMeleeHit(hitent, hitflesh, tr) then
        return
    end

    if SERVER then
        self:ServerMeleeHitEntity(tr, hitent, damagemultiplier)
    end

    -- 执行本地的命中处理（会创建 DamageInfo 并最终调用 PostHitUtil）
    self:MeleeHitEntity(tr, hitent, damagemultiplier)

    if self.PostOnMeleeHit then self.PostOnMeleeHit(hitent, hitflesh, tr) end

    if SERVER then
        self:ServerMeleePostHitEntity(tr, hitent, damagemultiplier)
    end
end

-- 玩家命中实用处理（连击系统、视角震动、对某些生物额外伤害等）
function SWEP:PlayerHitUtil(owner, damage, hitent, dmginfo)
    -- 连击系统：累积 PowerCombo，提高伤害并触发音效
    if owner.MeleePowerAttackMul and owner.MeleePowerAttackMul > 1 then
        self:SetPowerCombo(self:GetPowerCombo() + 1)

        damage = damage + damage * (owner.MeleePowerAttackMul - 1) * (self:GetPowerCombo()/4)
        dmginfo:SetDamage(damage)

        if self:GetPowerCombo() >= 4 then
            self:SetPowerCombo(0)
            if SERVER then
                local pitch = math.Clamp(math.random(90, 110) + 15 * (1 - damage/45), 50 , 200)
                owner:EmitSound("npc/strider/strider_skewer1.wav", 75, pitch)
            end
        end
    end

    -- 视角冲击（屏幕抖动）
    hitent:MeleeViewPunch(damage * (self.MeleeViewPunchScale or 1))
    -- 对 Headcrab 双倍伤害处理示例
    if hitent:IsHeadcrab() then
        damage = damage * 2
        dmginfo:SetDamage(damage)
    end
end

-- 命中后额外处理（伤害派发、击退、碎片效果、impact等）
function SWEP:PostHitUtil(owner, hitent, dmginfo, tr, vel)
    if self.PointsMultiplier then
        POINTSMULTIPLIER = self.PointsMultiplier
    end
    -- 发起 trace attack（把 dmginfo 通过 trace 发送到目标）
    hitent:DispatchTraceAttack(dmginfo, tr, owner:GetAimVector())
    if self.PointsMultiplier then
        POINTSMULTIPLIER = nil
    end

    if vel then
        hitent:SetLocalVelocity(vel)
    end

    -- 对玩家做自己的击退逻辑
    if hitent:IsPlayer() then
        local knockback = self.MeleeKnockBack * (owner.MeleeKnockbackMultiplier or 1)
        if knockback > 0 then
            hitent:ThrowFromPositionSetZ(tr.StartPos, knockback, nil, true)
        end

        if owner.MeleeLegDamageAdd and owner.MeleeLegDamageAdd > 0 then
            hitent:AddLegDamage(owner.MeleeLegDamageAdd)
        end
    end

    -- 创建 ragdoll impact 特效
    local effectdata = EffectData()
    effectdata:SetOrigin(tr.HitPos)
    effectdata:SetStart(tr.StartPos)
    effectdata:SetNormal(tr.HitNormal)
    util.Effect("RagdollImpact", effectdata)
    if not tr.HitSky then
        effectdata:SetSurfaceProp(tr.SurfaceProps)
        effectdata:SetDamageType(self.DamageType)
        effectdata:SetHitBox(tr.HitBox)
        effectdata:SetEntity(hitent)
        util.Effect("Impact", effectdata)
    end

    if self.MeleeFlagged then self.IsMelee = nil end
end

-- 具体创建 DamageInfo 并对实体/玩家进行最终处理
function SWEP:MeleeHitEntity(tr, hitent, damagemultiplier)
    if not IsFirstTimePredicted() then return end -- 预测保护，防止客户端/服务器重复执行

    if self.MeleeFlagged then self.IsMelee = true end

    local owner = self:GetOwner()

    -- Glass weapons 特殊处理（技能作用）
    if SERVER and hitent:IsPlayer() and not self.NoGlassWeapons and owner:IsSkillActive(SKILL_GLASSWEAPONS) then
        damagemultiplier = damagemultiplier * 3.5
        owner.GlassWeaponShouldBreak = not owner.GlassWeaponShouldBreak
    end

    local damage = self.MeleeDamage * damagemultiplier

    local dmginfo = DamageInfo()
    dmginfo:SetDamagePosition(tr.HitPos)
    dmginfo:SetAttacker(owner)
    dmginfo:SetInflictor(self)
    dmginfo:SetDamageType(self.DamageType)
    dmginfo:SetDamage(damage)
    dmginfo:SetDamageForce(math.min(self.MeleeDamage, 50) * 50 * owner:GetAimVector())

    local vel
    if hitent:IsPlayer() then
        self:PlayerHitUtil(owner, damage, hitent, dmginfo)

        if SERVER then
            hitent:SetLastHitGroup(tr.HitGroup)
            if tr.HitGroup == HITGROUP_HEAD then
                hitent:SetWasHitInHead()
            end

            if hitent:WouldDieFrom(damage, tr.HitPos) then
                dmginfo:SetDamageForce(math.min(self.MeleeDamage, 50) * 400 * owner:GetAimVector())
            end
        end

        vel = hitent:GetVelocity()
    else
        if owner.MeleePowerAttackMul and owner.MeleePowerAttackMul > 1 then
            self:SetPowerCombo(0)
        end
    end

    self:PostHitUtil(owner, hitent, dmginfo, tr, vel)
end

-- 挥舞状态的控制（记录/获取/停止）
function SWEP:StopSwinging()
    self:SetSwingEnd(0)
end
function SWEP:IsSwinging()
    return self:GetSwingEnd() > 0
end
function SWEP:SetSwingEnd(swingend)
    self:SetDTFloat(0, swingend) -- DTFloat 网络变量（索引0）
end
function SWEP:GetSwingEnd()
    return self:GetDTFloat(0)
end

-- 设置/查询格挡状态（DTBool 索引 0）
function SWEP:SetBlocking(b)
    self:SetDTBool(0, b)
    -- 如果停止格挡，重置完美格挡计时
    if not b then
        self.ParryStartTime = 0
    end
end
function SWEP:IsBlocking()
    return self:GetDTBool(0)
end

-- Parry（完美格挡）时间管理（DTFloat 索引 4）
function SWEP:SetParryTime(time)
    self:SetDTFloat(4, time)
end
function SWEP:GetParryTime()
    return self:GetDTFloat(4)
end
function SWEP:IsParrying()
    return self:GetParryTime() > CurTime()
end
function SWEP:ResetParryTime()
    self:SetParryTime(0)
end

-- BlockActivityTranslate：当处于格挡时，不同动作映射到物理枪的动画（用于 TranslateActivity）
local BlockActivityTranslate = {}
BlockActivityTranslate[ACT_MP_STAND_IDLE] = ACT_HL2MP_IDLE_PHYSGUN
BlockActivityTranslate[ACT_MP_WALK] = ACT_HL2MP_WALK_PHYSGUN
BlockActivityTranslate[ACT_MP_RUN] = ACT_HL2MP_RUN_PHYSGUN
BlockActivityTranslate[ACT_MP_CROUCH_IDLE] = ACT_HL2MP_CROUCH_IDLE_PHYSGUN
BlockActivityTranslate[ACT_MP_CROUCHWALK] = ACT_HL2MP_WALK_CROUCH_PHYSGUN
BlockActivityTranslate[ACT_MP_ATTACK_STAND_PRIMARYFIRE] = ACT_HL2MP_GESTURE_RANGE_ATTACK_PHYSGUN
BlockActivityTranslate[ACT_MP_ATTACK_CROUCH_PRIMARYFIRE] = ACT_HL2MP_GESTURE_RANGE_ATTACK_PHYSGUN
BlockActivityTranslate[ACT_MP_RELOAD_STAND] = ACT_HL2MP_GESTURE_RELOAD_PHYSGUN
BlockActivityTranslate[ACT_MP_RELOAD_CROUCH] = ACT_HL2MP_GESTURE_RELOAD_PHYSGUN
BlockActivityTranslate[ACT_MP_JUMP] = ACT_HL2MP_JUMP_PHYSGUN
BlockActivityTranslate[ACT_RANGE_ATTACK1] = ACT_HL2MP_GESTURE_RANGE_ATTACK_PHYSGUN

-- ActIndex：把字符串持握类型映射到 HL2MP 的动画起始索引
local ActIndex = {
    [ "pistol" ]         = ACT_HL2MP_IDLE_PISTOL,
    [ "smg" ]            = ACT_HL2MP_IDLE_SMG1,
    [ "grenade" ]        = ACT_HL2MP_IDLE_GRENADE,
    [ "ar2" ]            = ACT_HL2MP_IDLE_AR2,
    [ "shotgun" ]        = ACT_HL2MP_IDLE_SHOTGUN,
    [ "rpg" ]            = ACT_HL2MP_IDLE_RPG,
    [ "physgun" ]        = ACT_HL2MP_IDLE_PHYSGUN,
    [ "crossbow" ]       = ACT_HL2MP_IDLE_CROSSBOW,
    [ "melee" ]          = ACT_HL2MP_IDLE_MELEE,
    [ "slam" ]           = ACT_HL2MP_IDLE_SLAM,
    [ "normal" ]         = ACT_HL2MP_IDLE,
    [ "fist" ]           = ACT_HL2MP_IDLE_FIST,
    [ "melee2" ]         = ACT_HL2MP_IDLE_MELEE2,
    [ "passive" ]        = ACT_HL2MP_IDLE_PASSIVE,
    [ "knife" ]          = ACT_HL2MP_IDLE_KNIFE,
    [ "duel" ]           = ACT_HL2MP_IDLE_DUEL,
    [ "revolver" ]       = ACT_HL2MP_IDLE_REVOLVER,
    [ "camera" ]         = ACT_HL2MP_IDLE_CAMERA
}

-- 根据持枪类型填充 ActivityTranslate 表（把 HL2MP 动画索引按顺序映射到 ACT_MP_xxx）
function SWEP:SetWeaponHoldType(t)
    t = string.lower(t)
    local index = ActIndex[t]

    if (index == nil) then
        Msg("SWEP:SetWeaponHoldType - ActIndex[ \""..t.."\" ] isn't set! (defaulting to normal)\n")
        t = "normal"
        index = ActIndex[t]
    end

    self.ActivityTranslate = {}
    self.ActivityTranslate[ACT_MP_STAND_IDLE]                 = index
    self.ActivityTranslate[ACT_MP_WALK]                       = index+1
    self.ActivityTranslate[ACT_MP_RUN]                        = index+2
    self.ActivityTranslate[ACT_MP_CROUCH_IDLE]                = index+3
    self.ActivityTranslate[ACT_MP_CROUCHWALK]                 = index+4
    self.ActivityTranslate[ACT_MP_ATTACK_STAND_PRIMARYFIRE]   = index+5
    self.ActivityTranslate[ACT_MP_ATTACK_CROUCH_PRIMARYFIRE]  = index+5
    self.ActivityTranslate[ACT_MP_RELOAD_STAND]               = index+6
    self.ActivityTranslate[ACT_MP_RELOAD_CROUCH]              = index+6
    self.ActivityTranslate[ACT_MP_JUMP]                       = index+7
    self.ActivityTranslate[ACT_RANGE_ATTACK1]                 = index+8
    self.ActivityTranslate[ACT_MP_SWIM_IDLE]                  = index+8
    self.ActivityTranslate[ACT_MP_SWIM]                       = index+9

    -- "normal" 的跳跃动画特殊处理
    if t == "normal" then
        self.ActivityTranslate[ACT_MP_JUMP] = ACT_HL2MP_JUMP_SLAM
    end

    -- "knife" 或 "melee2" 在 ACTs 中缺少下蹲空闲动画，用 nil 规避
    if t == "knife" or t == "melee2" then
        self.ActivityTranslate[ACT_MP_CROUCH_IDLE] = nil
    end
end

-- 默认设置成 melee（这会调用上面的 SetWeaponHoldType）
SWEP:SetWeaponHoldType("melee")

-- 根据当前状态（挥舞/格挡/普通）返回应当使用的动画（TranslateActivity 用于玩家第三人称动作）
function SWEP:TranslateActivity(act)
    if self:GetSwingEnd() ~= 0 and self.ActivityTranslateSwing[act] then
        return self.ActivityTranslateSwing[act] or -1
    end

    if self:IsBlocking() and BlockActivityTranslate[act] ~= nil and self.BlockHoldType ~= "melee2" then
        return BlockActivityTranslate[act]
    end

    return self.ActivityTranslate and self.ActivityTranslate[act] or -1
end
