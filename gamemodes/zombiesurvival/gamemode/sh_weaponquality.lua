-- ============================================================================
-- 文件: sh_weaponquality.lua (共享 - 客户端与服务器端共用)
-- 用途: 定义和管理武器的品质/升级系统 (Remantle/Quality 系统)
-- 核心机制: 通过创建基础武器的品质变体, 修改武器属性来提升性能
-- 涉及概念: 品质等级 (Sturdy/Honed/Perfected), 属性修饰器 (Modifiers),
--          升级分支 (Branches), 废料 (Scrap) 经济系统
-- ============================================================================

-- ============================================================================
-- 全局数据表: weapon quality modifiers (属性修饰器注册表)
-- 存储所有已注册的武器属性修饰器定义
-- 键: 修饰器 ID (WEAPON_MODIFIER_* 常量)
-- 值: {Name = 名称, DisplayRaw = 是否显示原始数值, VarTable = 影响的武器变量表}
-- ============================================================================
GM.WeaponQualityModifiers = {}

-- ============================================================================
-- 全局数组: weapon qualities (品质等级定义)
-- 定义三个品质等级: 坚固 (Sturdy), 磨练 (Honed), 完美 (Perfected)
-- 每个条目: {品质名称, 基础伤害乘数, 分支品质修饰词}
-- 索引 1 = 1级 (Sturdy), 索引 2 = 2级 (Honed), 索引 3 = 3级 (Perfected)
-- ============================================================================
GM.WeaponQualities = {
    -- 品质等级1: 坚固 - 1.09x 基础伤害, 修饰词为"调校"
    {translate.Get("weapon_quality_sturdy"), 1.09, translate.Get("weapon_quality_tuned")},
    -- 品质等级2: 磨练 - 1.19x 基础伤害, 修饰词为"改装"
    {translate.Get("weapon_quality_honed"), 1.19, translate.Get("weapon_quality_modified")},
    -- 品质等级3: 完美 - 1.35x 基础伤害, 修饰词为"改造"
    {translate.Get("weapon_quality_perfected"), 1.35, translate.Get("weapon_quality_reformed")}
}

-- ============================================================================
-- 全局数组: weapon quality colors (品质颜色定义)
-- 用于品质武器的 UI 显示和击杀图标着色
-- 每个条目: {主颜色(用于UI), 击杀图标颜色}
-- 索引对应品质等级 1, 2, 3
-- ============================================================================
GM.WeaponQualityColors = {
    -- 品质1: 淡黄色 / 黄绿色
    {Color(235, 235, 115), Color(172, 219, 105)},
    -- 品质2: 深蓝色 / 青蓝色
    {Color(50, 90, 175), Color(35, 110, 145)},
    -- 品质3: 紫色 / 红色
    {Color(160, 95, 235), Color(252, 100, 100)}
}

-- ============================================================================
-- 修饰器 ID 常量
-- 每个常量对应一种可被品质系统修改的武器属性
-- 用作 GM.WeaponQualityModifiers 表的键
-- ============================================================================
WEAPON_MODIFIER_MIN_SPREAD = 1            -- 最小散布 (腰射精度)
WEAPON_MODIFIER_MAX_SPREAD = 2            -- 最大散布 (连射精度)
WEAPON_MODIFIER_FIRE_DELAY = 3            -- 射击间隔/射速 (基于 tick 率向上取整)
WEAPON_MODIFIER_RELOAD_SPEED = 4          -- 换弹速度
WEAPON_MODIFIER_CLIP_SIZE = 5             -- 弹匣容量
WEAPON_MODIFIER_MELEE_RANGE = 6           -- 近战攻击距离
WEAPON_MODIFIER_MELEE_SIZE = 7            -- 近战攻击范围/体积
WEAPON_MODIFIER_MELEE_IMPACT_DELAY = 8    -- 近战攻击命中延迟 (挥舞速度)
WEAPON_MODIFIER_PROJECTILE_VELOCITY = 9   -- 弹丸/投射物速度
WEAPON_MODIFIER_SHORT_TEAM_HEAT = 10      -- 团队热量积累 (短时)
WEAPON_MODIFIER_SHOT_COUNT = 11           -- 每次射击弹丸数量 (霰弹)
WEAPON_MODIFIER_BULLET_PIERCES = 12       -- 子弹穿透次数
WEAPON_MODIFIER_MAXIMUM_MINES = 13        -- 最大地雷/陷阱放置数
WEAPON_MODIFIER_MAX_DISTANCE = 14         -- 最大作用距离
WEAPON_MODIFIER_AURA_RADIUS = 15          -- 光环半径
WEAPON_MODIFIER_RECOIL = 16               -- 后坐力
WEAPON_MODIFIER_DAMAGE = 17               -- 直接伤害加成
WEAPON_MODIFIER_HEALRANGE = 18            -- 治疗范围
WEAPON_MODIFIER_HEALCOOLDOWN = 19         -- 治疗冷却时间
WEAPON_MODIFIER_BUFF_DURATION = 20        -- 增益效果持续时间
WEAPON_MODIFIER_LEG_DAMAGE = 21           -- 腿部伤害
WEAPON_MODIFIER_REPAIR = 22               -- 修理能力
WEAPON_MODIFIER_TURRET_SPREAD = 23        -- 炮塔散布
WEAPON_MODIFIER_HEALING = 24              -- 治疗量
WEAPON_MODIFIER_HEADSHOT_MULTI = 25       -- 爆头倍率
WEAPON_MODIFIER_MELEE_KNOCK = 26          -- 近战击退力

-- 内部索引计数器: 用于注册修饰器 (但实际不再使用, 因为所有修饰器都通过常量 ID 注册)
local index = 1

-- ============================================================================
-- GM:AddWeaponQualityModifier(id, name, displayraw, vartable)
-- 功能: 注册一个新的武器属性修饰器
-- 参数:
--   id        - 修饰器唯一 ID (对应 WEAPON_MODIFIER_* 常量)
--   name      - 修饰器显示名称 (已翻译的字符串)
--   displayraw - boolean, 是否直接显示原始数值变化 (true=显示具体数字, false=显示百分比)
--   vartable  - 表 {变量名 = 是否为主要属性}, 定义此修饰器影响的武器变量
--               true 表示写 wept.Primary.变量, false 表示写 wept.变量
-- 返回值: 创建的修饰器数据表
-- ============================================================================
function GM:AddWeaponQualityModifier(id, name, displayraw, vartable)
    -- 构建修饰器数据结构
    local datatab = {Name = name, DisplayRaw = displayraw, VarTable = vartable}
    -- 按 ID 存入注册表
    self.WeaponQualityModifiers[id] = datatab

    -- 递增索引计数器 (历史遗留, 用于旧式注册方式)
    index = index + 1

    return datatab
end

-- ============================================================================
-- GM:SetPrimaryWeaponModifier(swep, modifier, amount)
-- 功能: 为武器设置主要品质修饰器 (替代默认的伤害倍率加成)
-- 参数:
--   swep     - 武器 SWEP 表
--   modifier - 修饰器 ID (WEAPON_MODIFIER_*)
--   amount   - 修饰器数值 (每级品质的增量)
-- 说明: 如果武器没有通过此函数设置主要修饰器, 则使用默认的伤害乘数系统
-- ============================================================================
function GM:SetPrimaryWeaponModifier(swep, modifier, amount)
    -- 存储主要修饰器信息到武器的 PrimaryRemantleModifier 字段
    swep.PrimaryRemantleModifier = {Modifier = modifier, Amount = amount}
end

-- ============================================================================
-- GM:AttachWeaponModifier(swep, modifier, amount, qualitystart)
-- 功能: 为武器附加一个次要属性修饰器 (在主要修饰器之外额外增加属性变化)
-- 参数:
--   swep         - 武器 SWEP 表
--   modifier     - 修饰器 ID (WEAPON_MODIFIER_*)
--   amount       - 修饰器数值 (每级品质的增量)
--   qualitystart - 可选, 修饰器开始生效的品质等级 (默认 2, 即从 Honed 开始)
-- ============================================================================
function GM:AttachWeaponModifier(swep, modifier, amount, qualitystart)
    -- 初始化 AltRemantleModifiers 表 (如果还不存在)
    if not swep.AltRemantleModifiers then swep.AltRemantleModifiers = {} end

    -- 构建修饰器数据: 数值和起始等级
    local datatab = {Amount = amount, QualityStart = qualitystart or 2}
    -- 以修饰器 ID 为键存入
    swep.AltRemantleModifiers[modifier] = datatab
end

-- ============================================================================
-- GM:AddNewRemantleBranch(swep, no, printname, desc, branchfunc)
-- 功能: 为武器定义一个新的品质升级分支 (武器可以根据分支获得不同的属性加成)
-- 参数:
--   swep       - 武器 SWEP 表
--   no         - 分支编号 (正整数, 用于唯一标识)
--   printname  - 分支显示名称
--   desc       - 分支描述文本 (显示在品质描述中)
--   branchfunc - 函数, 接收武器表作为参数, 用于应用分支特有的属性修改
-- 返回值: 创建的分支数据表
-- ============================================================================
function GM:AddNewRemantleBranch(swep, no, printname, desc, branchfunc)
    -- 初始化 Branches 表 (如果还不存在)
    if not swep.Branches then swep.Branches = {} end

    -- 构建分支数据结构
    local datatab = {PrintName = printname, Desc = desc, BranchFunc = branchfunc}
    -- 以分支编号为键存入
    swep.Branches[no] = datatab

    return datatab
end

-- ============================================================================
-- 注册所有可用的武器属性修饰器
-- 每个 GM:AddWeaponQualityModifier 调用注册一个修饰器
-- 参数格式: (ID, 译名, 是否显示原始值, {变量名=是否为主要属性})
-- 主要属性(true) 修改 wept.Primary.变量, 次要属性(false) 修改 wept.变量
-- 某些修饰器后面附加了 .ReqClip = true 表示显示时需要除以 RequiredClip
-- ============================================================================

-- 注册修饰器: 最小散布 (腰射精度提升)
GM:AddWeaponQualityModifier(WEAPON_MODIFIER_MIN_SPREAD, translate.Get("weapon_quality_modifier_min_spread"), false, {ConeMin = false})

-- 注册修饰器: 最大散布 (连射精度提升)
GM:AddWeaponQualityModifier(WEAPON_MODIFIER_MAX_SPREAD, translate.Get("weapon_quality_modifier_max_spread"), false, {ConeMax = false})

-- 注册修饰器: 射击间隔 (射速提升)
GM:AddWeaponQualityModifier(WEAPON_MODIFIER_FIRE_DELAY, translate.Get("weapon_quality_modifier_fire_delay"), false, {Delay = true})

-- 注册修饰器: 换弹速度
GM:AddWeaponQualityModifier(WEAPON_MODIFIER_RELOAD_SPEED, translate.Get("weapon_quality_modifier_reload_speed"), false, {ReloadSpeed = false})

-- 注册修饰器: 弹匣容量 (显示原始数值, 需要 RequiredClip 除数)
GM:AddWeaponQualityModifier(WEAPON_MODIFIER_CLIP_SIZE, translate.Get("weapon_quality_modifier_clip_size"), true, {ClipSize = true}).ReqClip = true

-- 注册修饰器: 近战攻击距离
GM:AddWeaponQualityModifier(WEAPON_MODIFIER_MELEE_RANGE, translate.Get("weapon_quality_modifier_melee_range"), false, {MeleeRange = false})

-- 注册修饰器: 近战攻击范围/体积
GM:AddWeaponQualityModifier(WEAPON_MODIFIER_MELEE_SIZE, translate.Get("weapon_quality_modifier_melee_size"), false, {MeleeSize = false})

-- 注册修饰器: 近战攻击命中延迟 (挥舞速度)
GM:AddWeaponQualityModifier(WEAPON_MODIFIER_MELEE_IMPACT_DELAY, translate.Get("weapon_quality_modifier_melee_impact_delay"), false, {SwingTime = false})

-- 注册修饰器: 投射物速度 (弹丸飞行速度)
GM:AddWeaponQualityModifier(WEAPON_MODIFIER_PROJECTILE_VELOCITY, translate.Get("weapon_quality_modifier_projectile_velocity"), false, {ProjVelocity = true})

-- 注册修饰器: 团队短时热量 (短时间内的热量积累速率)
GM:AddWeaponQualityModifier(WEAPON_MODIFIER_SHORT_TEAM_HEAT, translate.Get("weapon_quality_modifier_short_team_heat"), false, {HeatBuildShort = false})

-- 注册修饰器: 弹丸数量 (每次射击的弹片/弹丸数, 如霰弹枪)
GM:AddWeaponQualityModifier(WEAPON_MODIFIER_SHOT_COUNT, translate.Get("weapon_quality_modifier_shot_count"), true, {NumShots = true})

-- 注册修饰器: 子弹穿透次数
GM:AddWeaponQualityModifier(WEAPON_MODIFIER_BULLET_PIERCES, translate.Get("weapon_quality_modifier_bullet_pierces"), true, {Pierces = false})

-- 注册修饰器: 最大地雷数 (可同时放置的地雷上限)
GM:AddWeaponQualityModifier(WEAPON_MODIFIER_MAXIMUM_MINES, translate.Get("weapon_quality_modifier_maximum_mines"), true, {MaxMines = false})

-- 注册修饰器: 最大距离 (武器/技能的最远作用距离)
GM:AddWeaponQualityModifier(WEAPON_MODIFIER_MAX_DISTANCE, translate.Get("weapon_quality_modifier_max_distance"), false, {MaxDistance = false})

-- 注册修饰器: 光环半径 (光环类效果的影响范围)
GM:AddWeaponQualityModifier(WEAPON_MODIFIER_AURA_RADIUS, translate.Get("weapon_quality_modifier_aura_radius"), false, {AuraRange = false})

-- 注册修饰器: 后坐力
GM:AddWeaponQualityModifier(WEAPON_MODIFIER_RECOIL, translate.Get("weapon_quality_modifier_recoil"), false, {Recoil = false})

-- 注册修饰器: 伤害 (同时影响 Primary.Damage 和 MeleeDamage)
GM:AddWeaponQualityModifier(WEAPON_MODIFIER_DAMAGE, translate.Get("weapon_quality_modifier_damage"), false, {Damage = true, MeleeDamage = false})

-- 注册修饰器: 治疗范围
GM:AddWeaponQualityModifier(WEAPON_MODIFIER_HEALRANGE, translate.Get("weapon_quality_modifier_healrange"), false, {HealRange = false})

-- 注册修饰器: 治疗冷却时间
GM:AddWeaponQualityModifier(WEAPON_MODIFIER_HEALCOOLDOWN, translate.Get("weapon_quality_modifier_healcooldown"), false, {Delay = true})

-- 注册修饰器: 增益持续时间 (Buff 效果的持续时间)
GM:AddWeaponQualityModifier(WEAPON_MODIFIER_BUFF_DURATION, translate.Get("weapon_quality_modifier_buff_duration"), false, {BuffDuration = false})

-- 注册修饰器: 腿部伤害 (对腿部造成的伤害值)
GM:AddWeaponQualityModifier(WEAPON_MODIFIER_LEG_DAMAGE, translate.Get("weapon_quality_modifier_leg_damage"), false, {LegDamage = false})

-- 注册修饰器: 修理能力 (修理物品或建筑的速度/效率)
GM:AddWeaponQualityModifier(WEAPON_MODIFIER_REPAIR, translate.Get("weapon_quality_modifier_repair"), false, {Repair = false})

-- 注册修饰器: 炮塔散布 (炮塔类武器的射击精度)
GM:AddWeaponQualityModifier(WEAPON_MODIFIER_TURRET_SPREAD, translate.Get("weapon_quality_modifier_turret_spread"), false, {TurretSpread = false})

-- 注册修饰器: 治疗量 (每次治疗恢复的生命值)
GM:AddWeaponQualityModifier(WEAPON_MODIFIER_HEALING, translate.Get("weapon_quality_modifier_healing"), false, {Heal = false})

-- 注册修饰器: 爆头倍率 (爆头伤害倍率)
GM:AddWeaponQualityModifier(WEAPON_MODIFIER_HEADSHOT_MULTI, translate.Get("weapon_quality_modifier_headshot_multi"), false, {HeadshotMulti = false})

-- 注册修饰器: 近战击退 (近战攻击击退敌人的力度)
GM:AddWeaponQualityModifier(WEAPON_MODIFIER_MELEE_KNOCK, translate.Get("weapon_quality_modifier_melee_knock"), false, {MeleeKnockBack = false})


-- ============================================================================
-- 内部函数: ApplyWeaponModifier(modinfo, wept, datatab, remantledescs, i)
-- 功能: 将一个属性修饰器应用到武器的对应属性上
-- 参数:
--   modinfo        - 修饰器定义 (从 GM.WeaponQualityModifiers 获取)
--   wept           - 武器 SWEP 表 (将被修改)
--   datatab        - {Amount = 每级增量, QualityStart = 起始等级}
--   remantledescs  - 数组, 用于收集品质属性描述文本 (显示给玩家)
--   i              - 当前品质等级 (1=Sturdy, 2=Honed, 3=Perfected)
-- 流程: 遍历修饰器影响的所有变量, 计算每级增量并应用到武器属性上,
--       同时生成可读的描述文本追加到 remantledescs 中
-- ============================================================================
local function ApplyWeaponModifier(modinfo, wept, datatab, remantledescs, i)
    -- 标记当前修饰器是否已经生成了描述文本 (防止同一修饰器生成多次)
    local displayed = false
    -- mtbl: 目标属性表 (Primary 主属性表 或 wept 武器表)
    -- basestat: 修改前的原始值
    -- newstat: 修改后的新值
    -- qfactor: 品质等级因子 (基于起始等级的偏移量)
    local mtbl, basestat, newstat, qfactor

    -- 遍历此修饰器影响的所有武器变量
    for var, isprimary in pairs(modinfo.VarTable) do
        -- isprimary=true 表示变量在 wept.Primary 中, 否则直接在 wept 中
        mtbl = isprimary and wept.Primary or wept
        -- 只修改变量已存在的武器 (跳过未定义该变量的武器)
        if mtbl[var] then
            -- 计算品质等级因子: 当前等级相对于起始等级的偏移
            -- 如果 QualityStart=2, i=1, 则 qfactor=0 (等级1不生效)
            -- 如果 QualityStart=2, i=2, 则 qfactor=1 (等级2开始生效)
            qfactor = i - (datatab.QualityStart - 1)
            basestat = mtbl[var]
            newstat = basestat + datatab.Amount * qfactor

            -- 应用新值到武器属性
            mtbl[var] = newstat

            -- 生成描述文本: 只有在 qfactor>0 (修饰器实际生效) 且尚未生成过描述时才生成
            if not displayed and qfactor > 0 then
                -- 决定数值前是否加 "+" 号 (正值用 "+", 负值默认已有 "-")
                local ispos = datatab.Amount > 0 and "+" or ""
                -- 生成数值变化描述:
                -- 如果不是原始值显示模式 (DisplayRaw=false), 显示百分比变化
                -- 如果是原始值显示模式 (DisplayRaw=true), 显示具体数值变化
                --   ReqClip 标记存在时除以 RequiredClip (用于弹匣容量等)
                local statincdesc = not modinfo.DisplayRaw and (((math.Round(newstat/basestat, 2)-1) * 100).. "% ")
                    or ((datatab.Amount * qfactor / (modinfo.ReqClip and wept.RequiredClip or 1)).. " ")

                -- 将属性变化描述插入到品质描述列表
                table.insert(remantledescs, ispos .. statincdesc .. modinfo.Name)
                displayed = true
            end
        end
    end
end

-- ============================================================================
-- 内部函数: CreateQualityKillicon(oldc, newc, i, b, cols)
-- 功能: 为品质武器创建带有颜色的击杀图标
-- 参数:
--   oldc  - 原始武器类名 (用于获取原始击杀图标信息)
--   newc  - 新品质武器类名 (将注册为此类名的击杀图标)
--   i     - 品质等级 (1-3, 用于选择颜色)
--   b     - 分支编号 (可选, 用于分支特有的颜色偏移)
--   cols  - 分支自定义颜色表 (可选, 如果分支定义了自定义颜色则使用)
-- 说明: 复制原始击杀图标的注册信息, 替换颜色为对应品质颜色
-- ============================================================================
local function CreateQualityKillicon(oldc, newc, i, b, cols)
    -- 获取原始武器的击杀图标注册信息
    local kitbl = killicon.Get(oldc)
    if kitbl then
        -- 判断图标类型: 如果图标表有2个元素, 使用 killicon.Add (材质图标);
        -- 否则使用 killicon.AddFont (字体图标)
        local kifunc = #kitbl == 2 and killicon.Add or killicon.AddFont
        -- 复制原始图标表
        local nkitbl = table.Copy(kitbl)
        -- 替换颜色为品质等级对应的颜色:
        -- 优先使用分支自定义颜色 cols, 否则使用全局 GM.WeaponQualityColors
        -- 分支颜色索引: b 存在时使用 b+1, 否则使用 1 (主颜色)
        nkitbl[#kitbl] = cols and cols[i] or GAMEMODE.WeaponQualityColors[i][b and b+1 or 1]
        -- 用新颜色注册品质武器的击杀图标
        kifunc(newc, unpack(nkitbl))
    end
end

-- ============================================================================
-- GM:CreateWeaponOfQuality(i, orig, quality, classname, branch)
-- 功能: 创建一个指定品质等级和分支的武器变体
-- 参数:
--   i         - 品质等级索引 (1/2/3)
--   orig      - 原始武器的储存表 (weapons.GetStored 获取)
--   quality   - 品质数据表 (来自 GM.WeaponQualities[i])
--   classname - 基础武器的类名字符串
--   branch    - 分支数据表 (可选, 如果传入则创建分支变体)
-- 流程:
--   1. 复制基础武器属性
--   2. 应用主要修饰器 (或默认伤害乘数)
--   3. 应用附加修饰器
--   4. 应用分支函数和描述
--   5. 生成唯一类名
--   6. 在客户端注册彩色击杀图标
--   7. 处理部署类 (DeployClass) 的连带品质化
--   8. 处理幽灵/预览状态 (GhostStatus) 的连带品质化
--   9. 注册新武器到武器系统
-- ============================================================================
function GM:CreateWeaponOfQuality(i, orig, quality, classname, branch)
    -- 初始化品质描述列表 (使用空表占位)
    orig.RemantleDescs[branch and branch.No or 0][i] = {}
    -- 完整的武器副本用于避免带瞄准镜武器出现崩溃问题
    -- TODO: 一旦所有 self.BaseClass 调用被移除, 重构为不使用完整的武器类

    -- 获取基础武器的完整副本
    local wept = weapons.Get(classname)
    -- 获取品质描述列表的引用 (用于填充属性变化文本)
    local remantledescs = orig.RemantleDescs[branch and branch.No or 0][i]

    -- 设置品质武器的基础类名 (原始武器类)
    wept.BaseQuality = classname
    -- 设置品质等级
    wept.QualityTier = i
    -- 设置分支编号 (如果有分支)
    wept.Branch = branch and branch.No

    -- 修改武器显示名称: 前缀为品质名 + 分支名 + 原始武器名
    if wept.PrintName then
        wept.PrintName = (branch and branch.NewNames and branch.NewNames[i] or branch and quality[3] or quality[1]).." "..(branch and branch.PrintName or wept.PrintName)
    end

    -- ================================================================
    -- 应用主要品质修饰器 (PrimaryRemantleModifier)
    -- ================================================================
    if wept.PrimaryRemantleModifier then
        -- 武器定义了自定义的主要修饰器, 使用修饰器系统替代默认伤害倍率
        local primod = wept.PrimaryRemantleModifier
        -- 调用内部函数应用修饰器 (从等级1开始生效)
        ApplyWeaponModifier(self.WeaponQualityModifiers[primod.Modifier], wept, {Amount = primod.Amount, QualityStart = 1}, remantledescs, i)
    else
        -- 武器没有自定义主要修饰器, 使用默认的伤害乘数系统
        -- 应用品质伤害乘数到 Primary.Damage
        if wept.Primary and wept.Primary.Damage then
            wept.Primary.Damage = wept.Primary.Damage * quality[2]
        end
        -- 应用品质伤害乘数到 MeleeDamage (近战伤害)
        if wept.MeleeDamage then
            wept.MeleeDamage = wept.MeleeDamage * quality[2]
        end

        -- 生成伤害加成的描述文本
        table.insert(remantledescs, "+" .. ((quality[2]-1) * 100) .. "% " .. "Damage")
    end

    -- ================================================================
    -- 应用附加品质修饰器 (AltRemantleModifiers)
    -- ================================================================
    if wept.AltRemantleModifiers then
        -- 遍历所有附加修饰器
        for modifier, datatab in pairs(wept.AltRemantleModifiers) do
            -- 跳过 "BaseClass" 特殊键 (原因不明, 可能是防错)
            if modifier == "BaseClass" then continue end

            -- 调用内部函数应用修饰器 (按修饰器定义的起始等级生效)
            ApplyWeaponModifier(self.WeaponQualityModifiers[modifier], wept, datatab, remantledescs, i)
        end
    end

    -- ================================================================
    -- 应用分支特有逻辑
    -- ================================================================
    if branch and branch.BranchFunc then
        -- 在描述列表最前面插入分支描述
        table.insert(remantledescs, 1, branch.Desc)
        -- 执行分支函数, 对武器进行自定义修改
        branch.BranchFunc(wept)
    end

    -- 生成品质武器的唯一类名
    local newclass = self:GetWeaponClassOfQuality(classname, i, branch and branch.No)

    -- ================================================================
    -- 客户端: 注册品质击杀图标
    -- ================================================================
    if CLIENT then
        -- 创建带颜色的击杀图标: 分支自定义图标或使用基础武器图标
        CreateQualityKillicon(branch and branch.Killicon or classname, newclass, i, branch and branch.No, branch and branch.Colors)
    end

    -- ================================================================
    -- 内部辅助函数: regscriptent (注册脚本实体)
    -- 功能: 为品质武器注册关联的脚本实体 (如部署类/状态类)
    -- 参数:
    --   class  - 原始类名
    --   cbk    - 回调函数 (可选, 用于对复制的实体进行额外处理)
    --   prefix - 注册前缀 (可选, 如 "status_")
    -- 返回值: 新类名字符串
    -- ================================================================
    local regscriptent = function(class, cbk, prefix)
        -- 生成品质版本的类名
        local newent = self:GetWeaponClassOfQuality(class, i)
        -- 获取原始脚本实体
        local afent = scripted_ents.Get((prefix or "") .. class)
        -- 如果提供了回调, 调用它进行额外处理
        if cbk then cbk(afent, newent) end

        -- 清除原始类名 (重新注册时需要)
        afent.ClassName = nil
        -- 以新名称注册脚本实体
        scripted_ents.Register(afent, (prefix or "") .. newent)
        return newent
    end

    -- ================================================================
    -- 处理部署类 (DeployClass): 可部署武器的品质化
    -- 例如: 地雷、炮塔等需要放置的武器
    -- ================================================================
    if wept.DeployClass then
        -- 为部署物创建品质版本, 并更新武器的 DeployClass 指向品质版本
        wept.DeployClass = regscriptent(wept.DeployClass, function(ent, newcl)
            -- 客户端: 为部署物品质版本注册击杀图标
            if CLIENT then
                CreateQualityKillicon(wept.DeployClass, newcl, i)
            end

            -- 如果部署物在 DeployableInfo 表中有记录, 添加品质版本的信息
            if self.DeployableInfo[wept.DeployClass] then
                self:AddDeployableInfo(newcl, quality[1].." "..self.DeployableInfo[wept.DeployClass].Name, "")
            end
        end)

        -- 处理弹药类型: 为品质武器创建独特的弹药类型
        if wept.AmmoIfHas then
            -- 生成品质版本的弹药类名
            local newammo = self:GetWeaponClassOfQuality(wept.Primary.Ammo, i)
            -- 注册新的弹药类型
            game.AddAmmoType({name = newammo})
            -- 更新武器的弹药类型指向品质版本
            wept.Primary.Ammo = newammo
        end

        -- 处理频道/通道注册: 如果武器属于某个频道, 将品质版部署类加入频道列表
        if wept.Channel then
            table.insert(self.ChannelsToClass[wept.Channel], wept.DeployClass)
        end
    end

    -- ================================================================
    -- 处理幽灵状态 (GhostStatus): 武器预览/幽灵实体的品质化
    -- 用于在放置前预览可部署武器的位置
    -- ================================================================
    if wept.GhostStatus then
        wept.GhostStatus = regscriptent(wept.GhostStatus, function(ent)
            -- 如果幽灵实体有通配符设置, 备份原始实体名
            if ent.GhostEntityWildCard then
                ent.GhostEntityWildCard = ent.GhostEntity
            end

            -- 为幽灵实体的关联实体创建品质版本
            local ghostent = self:GetWeaponClassOfQuality(ent.GhostEntity, i)
            ent.GhostEntity = ghostent
            -- 更新幽灵武器的关联
            ent.GhostWeapon = newclass
        end, "status_")
    end

    -- 清除武器类名 (重新注册时需要)
    wept.ClassName = nil
    -- 将品质武器注册到武器系统中
    weapons.Register(wept, newclass)
end

-- ============================================================================
-- GM:CreateWeaponQualities()
-- 功能: 在游戏启动时遍历所有已注册武器, 为每个允许品质的武器创建
--       所有品质等级和分支的变体
-- 参数: 无
-- 返回值: 无
-- 流程:
--   1. 获取所有已注册武器列表
--   2. 跳过基础武器模板 (weapon_zs_base 开头的)
--   3. 只处理 AllowQualityWeapons 为 true 的武器
--   4. 初始化原始武器的品质描述表结构
--   5. 为每个品质等级 (1/2/3) 创建品质变体
--   6. 如果武器有分支, 为每个分支也创建品质变体
-- ============================================================================
function GM:CreateWeaponQualities()
    -- 获取所有已注册的武器列表
    local allweapons = weapons.GetList()
    local classname

    -- 遍历所有武器
    for _, t in ipairs(allweapons) do
        classname = t.ClassName

        -- 跳过基础武器模板类 (以 weapon_zs_base 开头的)
        if string.sub(classname, 1, 14) == "weapon_zs_base" then
            continue
        end

        -- 获取武器的完整 SWEP 表
        local wept = weapons.Get(classname)
        -- 只处理允许品质武器的条目
        if wept and wept.AllowQualityWeapons then
            -- 获取武器的原始储存表 (用于持久化数据)
            local orig = weapons.GetStored(classname)
            -- 初始化品质描述表: 0 表示无分支 (默认分支)
            orig.RemantleDescs = {}
            orig.RemantleDescs[0] = {}

            -- 如果武器有自定义分支, 为每个分支初始化描述表
            if orig.Branches then
                for no, _ in pairs(orig.Branches) do
                    orig.RemantleDescs[no] = {}
                end
            end

            -- 为每个品质等级 (1/2/3) 创建武器变体
            for i, quality in ipairs(self.WeaponQualities) do
                -- 创建无分支的默认品质变体
                self:CreateWeaponOfQuality(i, orig, quality, classname)

                -- 如果武器有自定义分支, 为每个分支创建品质变体
                if orig.Branches then
                    for no, tbl in pairs(orig.Branches) do
                        -- 复制分支数据表并设置编号
                        local ntbl = table.Copy(tbl)
                        ntbl.No = no

                        -- 创建带分支的品质变体
                        self:CreateWeaponOfQuality(i, orig, quality, classname, ntbl)
                    end
                end
            end
        end
    end
end

-- ============================================================================
-- GM:GetWeaponClassOfQuality(classname, quality, branch)
-- 功能: 根据基础类名、品质等级和分支编号生成唯一的品质武器类名
-- 参数:
--   classname - 基础武器类名字符串
--   quality   - 品质等级 (1/2/3)
--   branch    - 分支编号 (可选, 0 或 nil 表示无分支)
-- 返回值: 品质武器的完整类名字符串
-- 示例: weapon_zs_rifle_q1 (无分支, 品质1)
--       weapon_zs_rifle_a2 (分支1, 品质2)
-- 说明: 分支编号通过 string.char(113 + branch) 转换为字母
--       0 -> 'q', 1 -> 'r', 2 -> 's', 3 -> 't', 以此类推
-- ============================================================================
function GM:GetWeaponClassOfQuality(classname, quality, branch)
    -- 格式: 基础类名_字母(branch或0对应q)+品质等级
    return classname.."_"..string.char(113 + (branch or 0))..quality
end

-- ============================================================================
-- GM:GetDismantleScrap(wtbl, invitem)
-- 功能: 计算拆解/分解一件品质武器时返还的废料 (Scrap) 数量
-- 参数:
--   wtbl    - 武器数据表 (包含 Tier 和 QualityTier 等字段)
--   invitem - boolean, 是否为背包/库存中的物品 (影响除数)
-- 返回值: 整数, 拆解后获得的废料数量 (向下取整)
-- 计算逻辑:
--   基础值 = 废料基础值表 (ScrapVals/ScrapValsTrinkets) 根据 Tier 索引
--   品质乘数 = DismantleMultipliers[品质等级+1]
--   近战武器惩罚 = * 0.75
--   物品区分: 库存物品除数2, 普通武器除数1 (或 DismantleDiv)
-- ============================================================================
function GM:GetDismantleScrap(wtbl, invitem)
    -- 武器的基础 Tier (层级/稀有度)
    local itier = wtbl.Tier
    -- 武器的品质等级 (QualityTier: 1/2/3, 无品质则为 nil)
    local quatier = wtbl.QualityTier

    -- 库存物品拆解只返还一半 (除数2), 普通武器全返
    local dismantlediv = invitem and 2 or 1
    -- 基础废料值: 库存物品使用 ScrapValsTrinkets, 普通武器使用 ScrapVals
    local baseval = invitem and GAMEMODE.ScrapValsTrinkets[itier or 1] or GAMEMODE.ScrapVals[itier or 1]

    -- 品质等级偏移: QualityTier 为 nil 或 0 时, qu = 1 (基础品质)
    -- 否则品质等级+1 作为索引
    local qu = (quatier or 0) + 1
    -- 基础值 * 品质拆解乘数 - 品质修正 (无品质时减去1点)
    local basicvalue = baseval * GAMEMODE.DismantleMultipliers[qu] - ((quatier or itier) and 0 or 1)

    -- 最终结果: 基础值 * 近战惩罚 * 物品除数, 向下取整
    return math.floor((basicvalue * (wtbl.IsMelee and 0.75 or 1)) / (wtbl.DismantleDiv or dismantlediv))
end

-- ============================================================================
-- GM:GetUpgradeScrap(wtbl, qualitychoice)
-- 功能: 计算将武器升级到指定品质等级所需的废料 (Scrap) 数量
-- 参数:
--   wtbl           - 武器数据表 (包含 Tier 字段)
--   qualitychoice  - 目标品质等级系数 (与品质等级直接相关)
-- 返回值: 整数, 升级所需的废料数量 (向上取整)
-- 计算逻辑:
--   基础废料值 = ScrapVals[Tier]
--   * qualitychoice (品质等级系数)
--   * 近战武器折扣 (0.85)
-- ============================================================================
function GM:GetUpgradeScrap(wtbl, qualitychoice)
    -- 武器的基础 Tier
    local itier = wtbl.Tier

    -- 基础值 * 品质系数 * 近战武器折扣 (近战升级更便宜), 向上取整
    return math.ceil(self.ScrapVals[itier or 1] * qualitychoice * (wtbl.IsMelee and 0.85 or 1))
end

-- ============================================================================
-- GM:PointsToScrap(points)
-- 功能: 将游戏点数 (Points) 转换为等值的废料 (Scrap) 数量
-- 参数:
--   points - 要转换的点数
-- 返回值: 转换后的废料数量
-- 转换率: 70 点数 = 32 废料, 即每点 = 32/70 废料
-- ============================================================================
function GM:PointsToScrap(points)
    -- 点数 / (70/32) 等价于点数 * 32/70
    return points / (70 / 32)
end
