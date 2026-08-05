-- ============================================================================
-- 商店分类定义 (Shop Categories Definition)
-- ============================================================================
-- 目前依此为 攻击突变、防御突变、实用突变、僵尸升级、迷你BOSS
GM.ZombieShopCategories = {
	-- 攻击突变分类
    ["OffensiveMutations"] = {
        Name = ""..translate.Get("zshop_category_offensive").."",
        Icon = "icon16/heart.png",
        Order = 1 -- 攻击排第 1
    },
	-- 防御突变分类
    ["DefenseMutations"] = {
        Name = ""..translate.Get("zshop_category_defensive").."",
        Icon = "icon16/shield.png",
        Order = 2 -- 防御排第 2
    },
	-- 实用突变分类
    ["UtilityMutations"] = {
        Name = ""..translate.Get("zshop_category_utility").."",
        Icon = "icon16/wrench.png",
        Order = 3 -- 使用排第 3
    },
	-- 僵尸升级分类
    ["ZombieUpgrades"] = {
        Name = ""..translate.Get("zshop_category_zombieupgrades").."",
        Icon = "icon16/arrow_up.png",
        Order = 4 -- 升级僵尸排第 4
    },
	-- 迷你BOSS分类
    ["MiniBoss"] = {
        Name = ""..translate.Get("zshop_category_miniboss").."",
        Icon = "icon16/user_red.png",
        Order = 5 -- 迷你BOSS排第 5
    },
}
-- ============================================================================
-- 变异数据管理 (Mutation Data Management)
-- ============================================================================
-- 存储所有变异项的全局表，如果尚未初始化则创建空表
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
	-- 构建变异项的完整数据表
    local tab = {
        Signature = signature,
        Name = name,
        Description = desc,
        Category = category,
        Price = price,
        Icon = icon,
        Callback = callback
    }
	-- 将变异项追加到 Mutations 列表中
    self.Mutations[#self.Mutations + 1] = tab
    return tab
end

-- 为了兼容旧称呼，保留此函数（AddMutationItem 是 AddMutation 的别名）
function GM:AddMutationItem(signature, name, desc, category, price, icon, callback)
    return self:AddMutation(signature, name, desc, category, price, icon, callback)
end
-- 图标示例：加_add是带箭头的
-- icon16/arrow_up.png 上箭头
-- icon16/heart.png 心脏
-- icon16/shield.png 盾牌

-- 示例：添加一个变异项
-- 攻击突变设置：增加僵尸伤害（等级1）
GM:AddMutationItem(
    "m_zombie_damage_1",
    ""..translate.Get("zshop_mutation_damage_1").."",
    ""..translate.Get("zshop_mutation_increase_damage_1").."",
    GM.ZombieShopCategories["OffensiveMutations"],
    100,
    "icon16/arrow_up.png",
    function(pl) pl.m_Zombie_Damage1 = true end
)

-- 攻击突变设置：阴影之力（物理危害）
GM:AddMutationItem(
    "m_shade_damage",
    ""..translate.Get("zshop_bossphysicshazard").."", 
    ""..translate.Get("zshop_bossphysicshazard2").."", 
    GM.ZombieShopCategories["ZombieUpgrades"], 
    550, 
    "icon16/arrow_up.png", 
    function(pl) pl.m_Shade_Force = true end
)

-- 防御突变设置：阿尔法僵尸（增加生命值等级1）
GM:AddMutationItem(
    "m_zombie_health_1",
    ""..translate.Get("zshop_alphazomb").."",
    ""..translate.Get("zshop_alphazomb2").."",
    GM.ZombieShopCategories["DefenseMutations"],
    150,
    "icon16/heart.png",
    function(pl) pl.m_Zombie_Health1 = true end
)

-- 实用突变设置：僵尸嚎叫加速
GM:AddMutationItem(
    "m_zombie_moan",
    ""..translate.Get("zshop_zombsprint").."",
    ""..translate.Get("zshop_zombsprint2").."",
    GM.ZombieShopCategories["UtilityMutations"], 
    15, 
    "icon16/arrow_up.png", 
    function(pl) pl.m_Zombie_Moan = true end
)

-- 实用突变设置：僵尸嚎叫守卫
GM:AddMutationItem(
    "m_zombie_moanguard",
    ""..translate.Get("zshop_zombguard").."", 
    ""..translate.Get("zshop_zombguard2").."", 
    GM.ZombieShopCategories["UtilityMutations"], 
    80, 
    "icon16/arrow_up.png", 
    function(pl) pl.m_Zombie_MoanGuard = true end
)

-- ============================================================================
-- 迷你BOSS购买项（Mini Boss Purchases）
-- 通过 BTokens 在僵尸商店"迷你BOSS"分类下购买，购买后立即变身为对应迷你BOSS。
-- 与普通变异不同：迷你BOSS变身是一次性的，死亡后恢复原职业，因此
-- Repeatable = true 标记使其可重复购买（不记入 UsedMutations，界面不显示"已拥有"）。
-- 服务器端 GM:SpawnMiniBoss 负责实际变身流程（init.lua）。
-- ============================================================================
local function AddMiniBossPurchase(signature, classname, translationnamekey, price)
    local tab = GM:AddMutationItem(
        signature,
        ""..translate.Get(translationnamekey).."",
        ""..translate.Get("zshop_miniboss_purchase_desc").."",
        GM.ZombieShopCategories["MiniBoss"],
        price,
        "icon16/user_red.png",
        function(pl)
            local ct = GAMEMODE.ZombieClasses[classname]
            if ct and ct.MiniBoss then
                GAMEMODE:SpawnMiniBoss(pl, classname)
            end
        end
    )
    -- 可重复购买标记：购买后不记入 UsedMutations，界面不显示"已拥有"
    tab.Repeatable = true
    tab.MiniBossClass = classname
end

AddMiniBossPurchase("m_miniboss_asskicker", "Ass Kicker", "class_asskicker", 1000)
AddMiniBossPurchase("m_miniboss_shitslapper", "Shit Slapper", "class_shitslapper", 1500)
AddMiniBossPurchase("m_miniboss_gigagorechild", "Giga Gore Child", "class_giga_gore_child", 1000)
AddMiniBossPurchase("m_miniboss_gigashadowchild", "Giga Shadow Child", "class_giga_shadow_child", 900)
AddMiniBossPurchase("m_miniboss_nightbutcher", "噩梦屠夫", "class_butcher_night", 1200)
AddMiniBossPurchase("m_miniboss_humantraitor", "humantraitor", "class_humantraitor", 600)
