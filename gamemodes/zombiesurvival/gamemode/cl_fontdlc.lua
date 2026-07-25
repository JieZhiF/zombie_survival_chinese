-- ============================================================
-- 字体DLC系统
-- 允许玩家自定义游戏字体（通过创建字体配置并保存到文件）
-- 支持从存档读取配置，提供动态字体切换功能
-- ============================================================

-- 全局表，存储字体DLC所有方法
ZSFontDLC = ZSFontDLC or {}

-- 定义字体配置表：包含 内部ID、中文用途名称、默认参数
-- 在这里把你的 "Weapon Name" 等用途和实际代码里的 FontName 对应起来
ZSFontDLC.FontDefinitions = {
    -- 武器/物品名字（3D显示）
    ["weapon_name_ssp"] = { --SSP = Source Sans Pro
        name = "武器/物品名字 (3D显示)", 
        default = { font = "Source Sans Pro", size = 40, weight = 500, extended = true, antialias = true } 
    },
    -- 物品属性说明（小号字体）
    ["weapon_name_ssp_small"] = { 
        name = "物品属性说明 (小号)", 
        default = { font = "Source Sans Pro", size = 36, weight = 500, extended = true, antialias = true } 
    },
    -- 屏幕HUD主要字体
    ["DAWD12"] = { 
        name = "屏幕HUD主要字体--无效", 
        default = { font = "HarmonyOS Sans SC", size = 32, weight = 500, extended = true, antialias = true } 
    },
    -- 屏幕HUD次要/小字体
    ["12411DFAGTH"] = { 
        name = "屏幕HUD次要/小字体--无效", 
        default = { font = "HarmonyOS Sans SC", size = 22, weight = 500, extended = true, antialias = true } 
    },
    ["BarrierFont"] = { 
        name = "防线显示字体", 
        default = { font = "HarmonyOS Sans SC", size = 36, weight = 500, extended = true, antialias = true } 
    },
    -- 你可以在这里继续添加你在 cl_init.lua 里 CreateFonts 创建的所有字体
}

-- 获取当前配置（合并默认值和玩家存档）
function ZSFontDLC.GetConfig()
    local config = {}
    
    -- 先填入默认值
    for id, data in pairs(ZSFontDLC.FontDefinitions) do
        config[id] = table.Copy(data.default)
    end

    -- 读取玩家存档覆盖默认值
    if file.Exists("zs_fonts/config.json", "DATA") then
        local saved = util.JSONToTable(file.Read("zs_fonts/config.json", "DATA"))
        if saved then
            table.Merge(config, saved)
        end
    end
    
    return config
end

-- 保存配置到文件
function ZSFontDLC.SaveConfig(fullConfig)
    if not file.Exists("zs_fonts", "DATA") then file.CreateDir("zs_fonts") end
    file.Write("zs_fonts/config.json", util.TableToJSON(fullConfig, true))
end

-- 初始化/应用所有字体
function ZSFontDLC.Initialize()
    local config = ZSFontDLC.GetConfig()
    
    for id, params in pairs(config) do
        surface.CreateFont(id, params)
    end
    print("[ZSFontDLC] 所有自定义字体已应用")
end

-- 游戏启动时加载一次
hook.Add("Initialize", "ZSFontDLC_Init", function()
    ZSFontDLC.Initialize()
end)

-- 提供一个控制台命令供调试（重新加载字体）
concommand.Add("zs_reload_fonts", function() ZSFontDLC.Initialize() end)
