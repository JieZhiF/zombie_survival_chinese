    if SERVER and engine.ActiveGamemode() == "zombiesurvival" then --服务器并且模式为ZS 
        local IsValidENT = function(ent)
            if not ent then return false end
            if ent == NULL then return false end
            if ent:IsWorld() then return true end
            return ent.IsValid(ent)
        end

        --- 从实体提取身体组字符串，格式如 "0 1 0"
        --- @param ent Entity
        --- @return string bodygroupString
        local function MakeBodyGroupString(ent)
            if not IsValid(ent) then return "" end
            local parts = {}
            for i = 0, ent:GetNumBodyGroups() - 1 do
                parts[#parts + 1] = tostring(ent:GetBodygroup(i))
            end
            return table.concat(parts, "")
        end

        -- =====================================================================
        -- 防线等级系统
        -- 每个由武器生成的道具带 NailPlacerLevel（默认 1），保存时随实体写入。
        -- 服务器按"人数区间 → 等级"规则决定本局加载等级 L，
        -- 只加载 level ≤ L 的防线（高等级自动包含所有更低等级）。
        -- =====================================================================
        local MAX_LEVEL = 5

        -- =====================================================================
        -- 数据目录：全部收纳到 zs_nailplacer 下，分地图数据与配置数据
        --   地图数据：data/zs_nailplacer/maps/<地图名>.json
        --   配置数据：data/zs_nailplacer/config/*.json
        -- 旧版路径（data/zs/**）会被检测，并提醒管理员执行 zs_nailplacer_migrate 迁移
        -- =====================================================================
        local MAPDATA_DIR = "zs_nailplacer/maps/"
        local CONFIG_DIR = "zs_nailplacer/config/"
        local LEVELCFG_PATH = CONFIG_DIR .. "nail_levels.json"
        local OLD_MAPDATA_DIR = "zs/nails/"
        local OLD_LEVELCFG_PATH = "zs/nail_levels.json"
        local OLD_NAMECACHE_PATH = "zs/player_names.json"

        -- 当前地图的防线存档路径（新布局）
        local function GetMapDataPath(mapname)
            return MAPDATA_DIR .. (mapname or game.GetMap()) .. ".json"
        end

        -- 控制台日志统一走翻译键（服务端默认语言）；键缺失/翻译失败时回退英文原文，避免 @key@
        local function LogMsg(key, default, ...)
            local text
            if translate and translate.Format then
                local ok, res = pcall(translate.Format, key, ...)
                if ok and res and not res:find("@", 1, true) then
                    text = res
                end
            end
            if not text then
                text = default
                if select("#", ...) > 0 then
                    local ok, res = pcall(string.format, default, ...)
                    if ok then text = res end
                end
            end
            Msg(text .. "\n")
        end

        -- 默认规则：1 人加载全部（等级 3），2-3 人等级 2，4 人及以上等级 1
        local DEFAULT_RULES = {
            {min = 1, max = 1, level = 3},
            {min = 2, max = 3, level = 2},
            {min = 4, max = 64, level = 1},
        }

        -- 校验并修正规则表，非法输入返回 nil
        local function SanitizeRules(rules)
            if type(rules) ~= "table" or #rules == 0 then return nil end

            local out = {}
            for _, r in ipairs(rules) do
                if type(r) == "table" then
                    local mn = math.Clamp(math.floor(tonumber(r.min) or 0), 1, 64)
                    local mx = math.Clamp(math.floor(tonumber(r.max) or 0), mn, 64)
                    local lv = math.Clamp(math.floor(tonumber(r.level) or 0), 1, MAX_LEVEL)
                    table.insert(out, {min = mn, max = mx, level = lv})
                end
            end

            if #out == 0 then return nil end
            table.sort(out, function(a, b) return a.min < b.min end)
            return out
        end

        -- 加载防线等级配置：存在配置文件则解析并校验规则，否则返回默认规则
        local function LoadNailConfig()
            if file.Exists(LEVELCFG_PATH, "DATA") then
                local data = util.JSONToTable(file.Read(LEVELCFG_PATH, "DATA") or "")
                local rules = SanitizeRules(data and data.rules)
                if rules then
                    return {rules = rules, copymode = not not (data and data.copymode)}
                end
            end
            return {rules = table.Copy(DEFAULT_RULES), copymode = false}
        end

        -- 仅返回等级规则列表（供等级判定使用）
        local function LoadLevelRules()
            return LoadNailConfig().rules
        end

        -- 将等级规则与复制模式写入配置文件
        local function SaveLevelConfig(rules, copymode)
            file.CreateDir(CONFIG_DIR)
            file.Write(LEVELCFG_PATH, util.TableToJSON({rules = rules, copymode = not not copymode}, true))
        end

        -- 读取复制模式开关（true 时加载防线会复制地图素材而非挪用原实体）
        local function GetCopyMode()
            return LoadNailConfig().copymode
        end

        -- 人数 → 加载等级；无匹配区间时返回规则中的最高等级（全加载，与旧行为一致）
        local function GetLevelForPlayerCount(count, rules)
            local maxlv = 1
            for _, r in ipairs(rules) do
                if count >= r.min and count <= r.max then return r.level end
                maxlv = math.max(maxlv, r.level)
            end
            return maxlv
        end

        -- 只统计人类玩家（排除机器人），用于防线等级判定
        local function GetHumanPlayerCount()
            local count = 0
            for _, ply in ipairs(player.GetAll()) do
                if ply:IsValid() and not ply:IsBot() then
                    count = count + 1
                end
            end
            return count
        end

        -- =====================================================================
        -- 建造者名字缓存（SteamID64 → 名字）
        -- 玩家下线后 nail:GetOwner() 返回无效实体，保存时名字会丢；
        -- 这里在钉子放置瞬间（建造者必然在线）把 SteamID64 → 名字落盘，
        -- 保存时若建造者已离线，则按 nail:GetOwnerUID() 从缓存补全名字。
        -- =====================================================================
        local NAMECACHE_PATH = CONFIG_DIR .. "player_names.json"
        local NAMECACHE = {}
        local NAMECACHE_MAX = 512
        local NAMECACHE_LOADED = false
        local NAMECACHE_DIRTY = false
        local NAMECACHE_FLUSHING = false

        -- 加载建造者名字缓存（仅首次调用时从磁盘读取一次）
        local function LoadNameCache()
            if NAMECACHE_LOADED then return end
            NAMECACHE_LOADED = true
            if not file.Exists(NAMECACHE_PATH, "DATA") then return end
            local data = util.JSONToTable(file.Read(NAMECACHE_PATH, "DATA") or "")
            if type(data) ~= "table" then return end
            for uid, name in pairs(data) do
                if type(uid) == "string" and type(name) == "string" and name ~= "" then
                    NAMECACHE[uid] = name
                end
            end
        end

        -- 将名字缓存写盘（仅在标记为脏时执行）
        local function FlushNameCache()
            if not NAMECACHE_DIRTY then return end
            NAMECACHE_DIRTY = false
            file.CreateDir(CONFIG_DIR)
            file.Write(NAMECACHE_PATH, util.TableToJSON(NAMECACHE, true))
        end

        -- 记录建造者名字：超出上限时淘汰任意旧记录，10秒去抖后落盘
        local function RecordName(uid, name)
            if type(uid) ~= "string" or uid == "" then return end
            if type(name) ~= "string" or name == "" then return end
            LoadNameCache()
            if NAMECACHE[uid] == name then return end
            -- 超出上限时淘汰任意一条旧记录，保持文件体积可控
            if NAMECACHE[uid] == nil and table.Count(NAMECACHE) >= NAMECACHE_MAX then
                for k in pairs(NAMECACHE) do NAMECACHE[k] = nil break end
            end
            NAMECACHE[uid] = name
            NAMECACHE_DIRTY = true
            -- 10 秒去抖落盘，避免高频钉钉子时频繁写文件
            if not NAMECACHE_FLUSHING then
                NAMECACHE_FLUSHING = true
                timer.Simple(10, function()
                    NAMECACHE_FLUSHING = false
                    FlushNameCache()
                end)
            end
        end

        -- 取钉子建造者名字：在线直接取；离线先按 SteamID64 查缓存，
        -- 再退回读取 SetDeployer(名字) 写入的 DTString(0)（加载的钉子没有 OwnerUID，名字存在这里）。
        -- 注意：只读名字，绝不恢复引擎 owner/OwnerUID，避免加载的钉子被当成"某人的财产"而限制他人拆除。
        local function GetNailOwnerName(nail)
            local owner = nail:GetOwner()
            if IsValidENT(owner) and owner:IsPlayer() then
                local uid = owner:SteamID64()
                local name = owner:GetName()
                if uid ~= "" and name ~= "" then
                    RecordName(uid, name)
                end
                return name
            end

            local uid = nail:GetOwnerUID() or ""
            if uid ~= "" then
                LoadNameCache()
                local cached = NAMECACHE[uid]
                if cached then return cached end
            end

            -- 加载的钉子：名字存在 DTString(0)，直接读回（纯水印，无归属）
            local dtname = (nail.GetDTString and nail:GetDTString(0)) or ""
            if dtname ~= "" then return dtname end

            return ""
        end

        -- 钉子放置瞬间（建造者必然在线）记录名字，供其离线后保存时补全
        hook.Add("OnNailCreated", "ZS_NailSave_NameCache", function(_, _, nail)
            if not IsValid(nail) then return end
            local owner = nail:GetOwner()
            if IsValidENT(owner) and owner:IsPlayer() then
                RecordName(owner:SteamID64(), owner:GetName())
            end
        end)

        -- 玩家改名时同步更新缓存
        hook.Add("PlayerNameChanged", "ZS_NailSave_NameCache", function(ply, _, newName)
            if IsValidENT(ply) and type(newName) == "string" then
                RecordName(ply:SteamID64(), newName)
            end
        end)

        -- =====================================================================
        -- 旧版数据检测与迁移（data/zs/** → data/zs_nailplacer/**）
        -- 检测到旧版数据时广播提醒，管理员执行 zs_nailplacer_migrate 完成迁移
        -- =====================================================================
        local function GetOldMapFiles()
            return file.Find(OLD_MAPDATA_DIR .. "*.json", "DATA") or {}
        end

        -- 检测旧版数据（data/zs/ 下的配置或地图存档）是否存在
        local function HasOldConfig()
            if file.Exists(OLD_LEVELCFG_PATH, "DATA") then return true end
            if file.Exists(OLD_NAMECACHE_PATH, "DATA") then return true end
            return #GetOldMapFiles() > 0
        end

        local OLD_CFG_NOTIFIED = false

        -- 每张地图只广播一次；进服玩家单独提醒（见 PlayerInitialSpawn）
        local function WarnOldConfig()
            if OLD_CFG_NOTIFIED then return end
            OLD_CFG_NOTIFIED = true
            LogMsg("nailplacer_console_oldcfg", "Legacy data found in data/zs/, please notify an admin to run zs_nailplacer_migrate")
            PrintTranslatedMessage(HUD_PRINTTALK, "nailplacer_oldcfg_warn")
        end

        -- 迁移单个文件：写入新路径并确认存在后才删除旧文件
        local function MigrateFile(oldpath, newpath)
            if not file.Exists(oldpath, "DATA") then return true end

            local data = file.Read(oldpath, "DATA")
            if not data then return false end

            local dir = string.GetPathFromFilename(newpath)
            if dir ~= "" then file.CreateDir(dir) end

            file.Write(newpath, data)
            if not file.Exists(newpath, "DATA") then return false end

            file.Delete(oldpath)
            LogMsg("nailplacer_console_migrating", "Migrating %s -> %s", oldpath, newpath)
            return true
        end

        -- 管理员命令：把 data/zs/ 下的旧文件搬到 data/zs_nailplacer/
        concommand.Add("zs_nailplacer_migrate", function(ply, cmd, args, strArg)
            if IsValid(ply) and not ply:IsAdmin() then return end

            local ok = true
            ok = MigrateFile(OLD_LEVELCFG_PATH, CONFIG_DIR .. "nail_levels.json") and ok
            ok = MigrateFile(OLD_NAMECACHE_PATH, CONFIG_DIR .. "player_names.json") and ok
            for _, f in ipairs(GetOldMapFiles()) do
                ok = MigrateFile(OLD_MAPDATA_DIR .. f, MAPDATA_DIR .. f) and ok
            end

            if ok then
                LogMsg("nailplacer_console_migrate_done", "Legacy data migration complete")
                PrintTranslatedMessage(HUD_PRINTTALK, "nailplacer_migrate_done")
            else
                LogMsg("nailplacer_console_migrate_failed", "Migration failed, check DATA directory permissions")
                PrintTranslatedMessage(HUD_PRINTTALK, "nailplacer_migrate_failed")
            end
        end)

        -- =====================================================================
        -- 保存钉子（zs_savenails）
        -- =====================================================================
        concommand.Add("zs_savenails", function (ply, cmd, args, strArg)
            if IsValid(ply) then
                -- 与武器统一的权限判定（管理员或白名单）；服务器控制台（ply 无效）直接放行
                local weptbl = weapons.Get("weapon_zs_nailplacer")
                if not (weptbl and weptbl.CanUseNailPlacer and weptbl.CanUseNailPlacer(ply)) then return end
            end

            file.CreateDir(MAPDATA_DIR)
            local datapath = GetMapDataPath()

            ---@class ZS_NAILINFO
            ---@field base   string @
            ---@field attach string @
            ---@field physbone1 int @
            ---@field physbone2 int @
            ---@field ownerid64 string @
            ---@field ownername string
            ---@field pos Vector @钉子位置
            ---@field ang Angle  @钉子角度

            ---@class ZS_NAILEDENTITYINFO
            ---@field pos   Vector @实体被钉住时的位置
            ---@field ang   Angle  @实体被钉住时的角度
            ---@field skin  int    @实体皮肤
            ---@field bodygroups string @实体身体组
            ---@field model string @实体模型
            ---@field isworld boolean @实体为地图
            ---@field ismapentity boolean @实体是地图实体
            ---@field hammerid int @实体的地图ID
            ---@field isnew boolean @实体是新实体(非地图实体)
            ---@field scale number @实体缩放
            ---@field color table @实体颜色
            ---@field level int @防线等级（缺省为 1）
            local data = {enthash = {}, nails = {}} ---@type {enthash:table<string, ZS_NAILEDENTITYINFO>, nails:ZS_NAILINFO[]}
            local enthash = data.enthash
            local nails = data.nails

            ---@param ent Entity
            local function addentity(ent)
                local id = tostring(ent:EntIndex())
                local hammerid = ent:GetKeyValues()["hammerid"] or 0
                enthash[id] = enthash[id] or {
                    pos = ent:GetPos();
                    ang = ent:GetAngles();
                    skin = ent:GetSkin();
                    bodygroups = MakeBodyGroupString(ent);
                    model = ent:GetModel();
                    scale = ent:GetModelScale();

                    color = {
                        r = ent:GetColor().r;
                        g = ent:GetColor().g;
                        b = ent:GetColor().b;
                        a = ent:GetColor().a;
                    };

                    level = ent.NailPlacerLevel or 1;

                    isworld = ent:IsWorld();
                    ismapentity = hammerid > 0;
                    hammerid  = hammerid;
                    isnew = hammerid <= 0;
                }

                return id
            end

            local count = 0
            for _, nail in ipairs(ents.FindByClass("prop_nail")) do
                local baseent, attachent
                if nail:MapCreationID() > -1 then goto PASS end     -- 不重复记录地图产生的钉子
                baseent   = nail:GetBaseEntity()
                attachent = nail:GetAttachEntity()
                if IsValidENT(baseent) and IsValidENT(attachent) then
                    table.insert(nails, {base = addentity(baseent), attach = addentity(attachent), physbone1 = nail:GetParentPhysNum() or 0, physbone2 = 0, ownerid64 = nail:GetOwnerUID() or "", ownername = GetNailOwnerName(nail), pos = nail:GetPos(), ang = nail:GetAngles()})
                    count = count + 1
                end

                ::PASS::
            end

            FlushNameCache() -- 名字缓存先落盘，保证与钉子文件一起持久
            file.Write(datapath, util.TableToJSON(data, true))
            LogMsg("nailplacer_console_saved", "Saved %d nails to %s", count, datapath)
            if IsValid(ply) then
                ply:PrintTranslatedMessage(HUD_PRINTTALK, "nailplacer_saved", count)
            end
        end)

        -- =====================================================================
        -- 加载钉子（核心函数，可指定等级上限；幽灵预显与回合加载共用）
        -- =====================================================================
        local function LoadNailsFromFile(maxLevel)
            XD_ZSMAPLOADED = true
            local copymode = GetCopyMode()
            local datapath = GetMapDataPath()
            if not file.Exists(datapath, "DATA") then return 0 end

            local raw = file.Read(datapath, "DATA") or ""
            local data = util.JSONToTable(raw)
            if not (data and data.enthash and data.nails) then return 0 end

            local enthash = data.enthash    ---@type table<string, ZS_NAILEDENTITYINFO>
            local nails   = data.nails      ---@type ZS_NAILINFO[]
            local entityMap = {}
            local hammeridhash = {}

            for _, ent in ipairs(ents.GetAll()) do
                local hid = ent:GetKeyValues()["hammerid"]
                if hid then
                    hammeridhash[hid] = ent
                end
            end

            -- 解析存档中的实体条目：地图实体按复制模式决定复用/新建，新道具按等级过滤后重建
            local function resolveEntity(info)
                if not info then return nil end
                if info.isworld then return game.GetWorld() end
                if info.ismapentity then
                    local orig = hammeridhash[info.hammerid]
                    if not IsValidENT(orig) then return nil end

                    -- 复制模式开启：地图原素材不动，按存档生成一份副本作为防线；
                    -- 关闭：直接复用地图原实体（原素材会被移走组成防线）
                    if copymode then
                        local prop = ents.Create("prop_physics")
                        if not IsValidENT(prop) then return nil end
                        prop:SetModel(info.model or orig:GetModel() or "models/error.mdl")
                        prop:SetMaxHealth(1000)
                        prop:SetHealth(1000)
                        prop.NoNails = false
                        prop.NoVolumeCarryCheck = true
                        prop:Spawn()
                        prop.ExpertProtection = nil
                        prop:Activate()
                        prop.NailPlacerLevel = math.Clamp(info.level or 1, 1, MAX_LEVEL)
                        return prop
                    end

                    return orig
                end

                    if (info.level or 1) > maxLevel then return nil end

                    local prop = ents.Create("prop_physics")
                    if not IsValidENT(prop) then return nil end
                    prop:SetModel(info.model or "models/error.mdl")

                    if info.color then
                        prop:SetColor(Color(
                            info.color.r,
                            info.color.g,
                            info.color.b,
                            info.color.a
                        ))

                        if info.color.a < 255 then
                            prop:SetRenderMode(RENDERMODE_TRANSALPHA)
                        end
                    end

                    prop:SetMaxHealth(1000)
                    prop:SetHealth(1000)
                    prop.NoNails = false
                    prop.NoVolumeCarryCheck = true
                    prop:Spawn()
                    if info.color then
                        prop:SetColor(Color(
                            info.color.r,
                            info.color.g,
                            info.color.b,
                            info.color.a
                        ))
                    end
                    prop.ExpertProtection = nil
                    prop:Activate()
                    if info.scale and info.scale ~= 1 then
                        prop:SetModelScale(info.scale, 0)
                    end

                    -- 恢复等级标记，保证再次保存时等级不丢
                    prop.NailPlacerLevel = math.Clamp(info.level or 1, 1, MAX_LEVEL)
                    return prop

            end

            for key, info in pairs(enthash) do
                local ent = resolveEntity(info)
                if IsValidENT(ent) then
                    entityMap[tostring(key)] = ent

                    ent:SetPos(info.pos or vector_origin)
                    ent:SetAngles(info.ang or angle_zero)
                    ent:SetSkin(info.skin or 0)
                    ent:SetBodyGroups(info.bodygroups)

                    if info.color then
                        ent:SetColor(Color(
                            info.color.r,
                            info.color.g,
                            info.color.b,
                            info.color.a
                        ))

                        if info.color.a < 255 then
                            ent:SetRenderMode(RENDERMODE_TRANSALPHA)
                        else
                            ent:SetRenderMode(RENDERMODE_NORMAL)
                        end
                    end
                    if info.scale and info.scale ~= 1 then
                        ent:SetModelScale(info.scale, 0)
                    end
                end
            end

            local count = 0
            for _, nailInfo in ipairs(nails) do
                local baseEnt   = entityMap[tostring(nailInfo.base)]
                local attachEnt = entityMap[tostring(nailInfo.attach)]
                local nail

                if not (IsValidENT(baseEnt) and IsValidENT(attachEnt)) then goto PASS end

                -- 回填名字缓存：下次保存时即使建造者已离线，也能按 ownerid64 找到名字
                if nailInfo.ownerid64 and nailInfo.ownerid64 ~= "" and nailInfo.ownername and nailInfo.ownername ~= "" then
                    RecordName(nailInfo.ownerid64, nailInfo.ownername)
                end

                nail = ents.Create("prop_nail")
                if not IsValid(nail) then goto PASS end
                nail:SetPos(nailInfo.pos or baseEnt:GetPos())
                nail:SetAngles(nailInfo.ang or angle_zero)
                if nailInfo.ownername and nailInfo.ownername ~= "" then
                    nail:SetDeployer(nailInfo.ownername)
                end
                nail:Spawn()

                nail:AttachTo(baseEnt, attachEnt, nailInfo.physbone1 or 0, nailInfo.physbone2 or 0)
                count = count + 1
                ::PASS::
            end

            LogMsg("nailplacer_console_loaded", "Loaded %d nails from %s (level<=%d)", count, datapath, maxLevel)
            return count
        end

        -- =====================================================================
        -- 防线幽灵预显数据：服务器下发防线数据，客户端本地渲染（白色/红色线框）
        -- 这样每个玩家能按自己的 convar 独立决定显示/隐藏/颜色，
        -- 也顺带绕开了服务端 prop 的 "missing modelname" 问题
        -- =====================================================================
        local function GetGhostData()
            local datapath = GetMapDataPath()
            if not file.Exists(datapath, "DATA") then return {} end
            local data = util.JSONToTable(file.Read(datapath, "DATA") or "")
            if not (data and data.enthash) then return {} end

            local out = {}
            for _, info in pairs(data.enthash) do
                -- 只下发新生成道具，且跳过无效数据
                if info.model and info.model ~= "" and info.pos then
                    table.insert(out, info)
                end
            end
            return out
        end

        -- 下发防线幽灵预显数据（仅含新生成道具），供客户端本地渲染
        local function SendGhostData(ply)
            local ghostData = GetGhostData()
            net.Start(NET_MSG.NAILPLACER_GHOSTS)
                net.WriteUInt(#ghostData, 16)
                for _, info in ipairs(ghostData) do
                    net.WriteString(info.model)
                    net.WriteVector(info.pos)
                    net.WriteAngle(info.ang or angle_zero)
                    net.WriteFloat(info.scale or 1)
                    net.WriteString(info.bodygroups or "")
                    net.WriteUInt(info.skin or 0, 8)
                    net.WriteUInt(math.Clamp(info.level or 1, 1, 5), 8)
                end
            if ply then net.Send(ply) else net.Broadcast() end
        end

        -- 清空客户端幽灵（正式加载防线时调用）
        local function ClearGhosts(ply)
            net.Start(NET_MSG.NAILPLACER_GHOSTS)
                net.WriteUInt(0, 16)
            if ply then net.Send(ply) else net.Broadcast() end
        end

        -- =====================================================================
        -- 回合触发：每回合波次 1 开始前 1 秒（或开始的同时）按当时人数生成防线；
        -- 准备阶段只显示幽灵预显。回合重启时由 RestartRound 钩子重置标记。
        -- =====================================================================
        local nailSaveLoaded = false

        -- 按当前人数计算等级并正式加载防线（每回合只触发一次）
        local function TriggerWaveLoad()
            if nailSaveLoaded then return end
            nailSaveLoaded = true

            local level = GetLevelForPlayerCount(GetHumanPlayerCount(), LoadLevelRules())
            ClearGhosts() -- 客户端清空幽灵预显
            local count = LoadNailsFromFile(level)
            if count > 0 then
                PrintTranslatedMessage(HUD_PRINTTALK, "nailplacer_generated", count)
            end
        end

        -- 回合重启信号：重置已加载标记，使新回合波次 1 前重新加载防线。
        -- 不能用波次状态推断重置时机：wave==0 且未激活在"波次1开始前1秒"同样成立，
        -- 若在 Think 里重置会与触发条件（CurTime() >= ws - 1）重叠，
        -- 造成 加载→重置→再加载 的每帧死循环。必须挂在新回合的唯一入口 RestartRound 上。
        hook.Add("RestartRound", "ZS_NailSave_RoundReset", function()
            nailSaveLoaded = false
            timer.Simple(1, function()
                if not nailSaveLoaded then
                    SendGhostData()
                end
            end)
        end)

        hook.Add("Think", "ZS_NailSave_WaveTrigger", function()
            if not GAMEMODE then return end
            if nailSaveLoaded then return end

            -- 回合已在进行（中途进图/异常恢复）：立即加载
            if GAMEMODE:GetWaveActive() or GAMEMODE:GetWave() > 0 then
                TriggerWaveLoad()
                return
            end

            -- 波次 1 开始前 1 秒触发（每回合重启后同样适用）
            local ws = GAMEMODE:GetWaveStart()
            if ws ~= -1 and CurTime() >= ws - 1 then
                TriggerWaveLoad()
            end
        end)

        -- 地图实体就绪后准备幽灵预显数据（客户端本地渲染，替代旧的服务端 prop 幽灵）
        hook.Add("InitPostEntity", "ZS_NailSave_Init", function()
            OLD_CFG_NOTIFIED = false -- 每张地图重置，旧数据存在时重新提醒
            if HasOldConfig() then WarnOldConfig() end

            if GAMEMODE and GAMEMODE:GetWave() == 0 and not GAMEMODE:GetWaveActive() then
                SendGhostData()
            else
                TriggerWaveLoad()
            end
        end)

        -- =====================================================================
        -- 手动加载命令：管理员强制全量加载（所有等级）
        -- =====================================================================
        concommand.Add("zs_loadnails", function(ply, cmd, args, strArg)
            if IsValid(ply) then
                -- 与武器统一的权限判定（管理员或白名单）；服务器控制台（ply 无效）直接放行
                local weptbl = weapons.Get("weapon_zs_nailplacer")
                if not (weptbl and weptbl.CanUseNailPlacer and weptbl.CanUseNailPlacer(ply)) then return end
            end
            ClearGhosts()
            local count = LoadNailsFromFile(999)
            if IsValid(ply) then
                ply:PrintTranslatedMessage(HUD_PRINTTALK, "nailplacer_loaded", count)
            end
        end)

        -- =====================================================================
        -- 等级规则配置同步（菜单"等级配置"分页）
        -- mode 0 = 客户端请求规则；mode 1 = 客户端提交规则（校验后保存）
        -- 两个方向都回复当前规则（回复带 mode 标记来源）
        -- =====================================================================

        net.Receive(NET_MSG.NAILPLACER_LEVELCFG, function(len, ply)
            -- 与武器统一的权限判定（管理员或白名单）
            local weptbl = weapons.Get("weapon_zs_nailplacer")
            if not (weptbl and weptbl.CanUseNailPlacer and weptbl.CanUseNailPlacer(ply)) then return end

            local mode = net.ReadUInt(8)

            if mode == 1 then
                local data = util.JSONToTable(net.ReadString())
                local rules = SanitizeRules(data and data.rules)
                if not rules then return end
                SaveLevelConfig(rules, not not (data and data.copymode))
                SendLevelRules() -- 规则变了：广播给所有玩家刷新 HUD
            end

            net.Start(NET_MSG.NAILPLACER_LEVELCFG)
                net.WriteUInt(mode, 8)
                net.WriteString(util.TableToJSON({rules = LoadLevelRules(), copymode = GetCopyMode()}))
            net.Send(ply)
        end)

        -- =====================================================================
        -- 规则广播：所有玩家在等待阶段的 HUD 上实时看到"当前人数 → 加载等级"
        -- 规则只在进服/变更时同步，人数由客户端自己数，HUD 实时刷新
        -- =====================================================================

        function SendLevelRules(ply)
            net.Start(NET_MSG.NAILPLACER_LEVELRULES)
                net.WriteString(util.TableToJSON({
                    rules = LoadLevelRules(),
                    has = file.Exists(GetMapDataPath(), "DATA"),
                }))
            if ply then net.Send(ply) else net.Broadcast() end
        end

        hook.Add("PlayerInitialSpawn", "ZS_NailSave_LevelRules", function(ply)
            -- 稍等客户端 Lua 就绪再发
            timer.Simple(2, function()
                if IsValidENT(ply) then
                    SendLevelRules(ply)
                    SendGhostData(ply)
                    if HasOldConfig() then
                        ply:PrintTranslatedMessage(HUD_PRINTTALK, "nailplacer_oldcfg_warn")
                    end
                end
            end)
        end)
    end
