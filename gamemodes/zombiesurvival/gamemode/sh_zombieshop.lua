-- ============================================================================
-- 商店分类定义 (Shop Categories Definition)
-- ============================================================================
-- 目前依此为 攻击突变、防御突变、实用突变、僵尸升级、迷你BOSS
GM.ZombieShopCategories = {
    ["OffensiveMutations"] = {
        Name = ""..translate.Get("zshop_category_offensive").."",
        Icon = "icon16/heart.png",
        Order = 1 -- 攻击排第 1
    },
    ["DefenseMutations"] = {
        Name = ""..translate.Get("zshop_category_defensive").."",
        Icon = "icon16/shield.png",
        Order = 2 -- 防御排第 2
    },
    ["UtilityMutations"] = {
        Name = ""..translate.Get("zshop_category_utility").."",
        Icon = "icon16/wrench.png",
        Order = 3 -- 使用排第 3
    },
    ["ZombieUpgrades"] = {
        Name = ""..translate.Get("zshop_category_zombieupgrades").."",
        Icon = "icon16/arrow_up.png",
        Order = 4 -- 升级僵尸排第 4
    },
    ["MiniBoss"] = {
        Name = ""..translate.Get("zshop_category_miniboss").."",
        Icon = "icon16/user_red.png",
        Order = 5 -- 迷你BOSS排第 5
    },
}
-- ============================================================================
-- 变异数据管理 (Mutation Data Management)
-- ============================================================================
GM.Mutations = GM.Mutations or {}

--[[
    添加一个新的变异项到商店。
    @param signature    (string)    变异的唯一标识符
    @param name         (string)    显示的名称
    @param desc         (string)    详细描述
    @param category     (table)     所属的分类 (来自 GM.ZombieShopCategories)
    @param price        (number)    价格
    @param icon         (string)    图标路径 (可选)
    @param callback     (function)  购买后执行的回调函数
]]
function GM:AddMutation(signature, name, desc, category, price, icon, callback)
    local tab = {
        Signature = signature,
        Name = name,
        Description = desc,
        Category = category,
        Price = price,
        Icon = icon,
        Callback = callback
    }
    self.Mutations[#self.Mutations + 1] = tab
    return tab
end

-- 为了兼容旧称呼，保留此函数
function GM:AddMutationItem(signature, name, desc, category, price, icon, callback)
    return self:AddMutation(signature, name, desc, category, price, icon, callback)
end
-- 图标示例：加_add是带箭头的
-- icon16/arrow_up.png 上箭头
-- icon16/heart.png 心脏
-- icon16/shield.png 盾牌
-- 示例：添加一个变异项
-- 攻击突变设置
GM:AddMutationItem(
    "m_zombie_damage_1",
    ""..translate.Get("zshop_mutation_damage_1").."",
    ""..translate.Get("zshop_mutation_increase_damage_1").."",
    GM.ZombieShopCategories["OffensiveMutations"],
    100,
    "icon16/arrow_up.png",
    function(pl) pl.m_Zombie_Damage1 = true print("Buy mutations") end
)

GM:AddMutationItem(
    "m_shade_damage",
    ""..translate.Get("zshop_bossphysicshazard").."", 
    ""..translate.Get("zshop_bossphysicshazard2").."", 
    GM.ZombieShopCategories["BossMutations"], 
    550, 
    "icon16/arrow_up.png", 
    function(pl) pl.m_Shade_Force = true end
)

-- 防御突变设置
GM:AddMutationItem(
    "m_zombie_health_1",
    ""..translate.Get("zshop_alphazomb").."",
    ""..translate.Get("zshop_alphazomb2").."",
    GM.ZombieShopCategories["DefenseMutations"],
    150,
    "icon16/heart.png",
    function(pl) pl.m_Zombie_Health1 = true end
)

-- 实用突变设置
GM:AddMutationItem(
    "m_zombie_moan",
    ""..translate.Get("zshop_zombsprint").."",
    ""..translate.Get("zshop_zombsprint2").."",
    GM.ZombieShopCategories["UtilityMutations"], 
    15, 
    "icon16/arrow_up.png", 
    function(pl) pl.m_Zombie_Moan = true end
)


GM:AddMutationItem(
    "m_zombie_moanguard",
    ""..translate.Get("zshop_zombguard").."", 
    ""..translate.Get("zshop_zombguard2").."", 
    GM.ZombieShopCategories["UtilityMutations"], 
    80, 
    "icon16/arrow_up.png", 
    function(pl) pl.m_Zombie_MoanGuard = true end
)

