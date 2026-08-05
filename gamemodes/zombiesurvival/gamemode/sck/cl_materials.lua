-- ============================================================================
-- sck/cl_materials.lua - SCK（SWEP 构造工具包）材质转换与收藏管理（客户端）
-- 负责：将 SCK 使用的地图世界材质（lightmappedgeneric 等着色器）转换为
--       可应用于武器模型的 VertexLitGeneric 动态材质（sck_ 前缀），
--       并维护材质收藏列表（内置默认收藏 + 用户自定义，持久化到 DATA）。
-- ============================================================================
--Made this local since this file is now mirrored in the public SCK addon, where GM isn't guarunteed to exist in the load order

-- 已转换材质路径 -> "!sck_xxx" 动态材质名的缓存映射（避免重复创建）
SCKMaterials = {}
-- 材质收藏表：key 为材质路径，value 为 1（内置默认收藏）或 2（用户收藏）
SCKMaterialFavs = {}
-- 旧版 "!sck_xxx" 名称到新版材质路径的兼容映射（用于加载旧版存档）
SCKMaterialCompat = {
	["!sck_snow"] = "ground/snow01",
}

-- 需要转换的着色器类型表：地图世界材质无法直接用于模型，需转为 VertexLitGeneric
local conv_mat = {
	["lightmappedgeneric"] = true,
	["lightmappedgeneric_hdr_dx9"] = true,
	["lightmappedgeneric_dx9"] = true,
	["lightmappedgeneric_dx8"] = true,
	["lightmappedgeneric_dx6"] = true,

	["worldtwotextureblend"] = true,
	["worldtwotextureblend_dx8"] = true,
	["worldtwotextureblend_dx6"] = true,

	["worldvertextransition"] = true,
	["worldvertextransition_dx9"] = true,
	["worldvertextransition_dx8"] = true,
	["worldvertextransition_dx6"] = true,
}

-- ==== ConvertSCKMaterial - 将世界材质转换为武器可用的 sck_ 动态材质 ====
-- @param basetex string - 基础材质路径
-- @return string - 转换后的动态材质名（"!sck_xxx"），非世界材质时原样返回
function ConvertSCKMaterial(basetex)
	local mat = Material(basetex)

	-- 获取材质着色器名并转小写以便匹配
	local shader = mat:GetShader()

	shader = string.lower(shader)

	-- 非世界着色器无需转换，直接返回原材质
	if not conv_mat[shader] then return basetex end

	-- 以原材质文件名生成新材质名（sck_ 前缀，向后兼容旧存档引用）
	local matfilename = string.GetFileFromFilename(basetex)
	local newname = "sck_"..matfilename --can create issues, but good for backwards compat
	-- 读取原材质属性，在新材质中复现相同表现
	local sp = mat:GetString("$surfaceprop") or "metal"
	local trans = mat:GetInt("$translucent") or 0
	local at = mat:GetInt("$alphatest") or 0

	local vta = mat:GetInt("$vertexalpha") or 0
	local vtc = mat:GetInt("$vertexcolor") or 0

	-- 基于同一基础贴图创建 VertexLitGeneric 动态材质
	CreateMaterial(newname, "VertexLitGeneric",  {
		["$basetexture"] = basetex,
		["$surfaceprop"] = sp,
		["$translucent"] = trans,
		["$alphatest"] = at,
		["$vertexalpha"] = vta,
		["$vertexcolor"] = vtc,
	})

	-- 缓存转换结果并返回 "!" 前缀的动态材质名（! 表示运行时生成的材质）
	SCKMaterials[basetex] = "!"..newname

	return SCKMaterials[basetex]
end

-- ==== AddMaterialFavorite - 将材质加入收藏列表（可标记为内置默认收藏） ====
-- @param basetex string - 材质路径
-- @param default boolean|nil - 是否为内置默认收藏（true 时登记兼容名）
function AddMaterialFavorite(basetex, default)
	-- 默认收藏需登记旧式兼容名，使旧版 SCK 的 "!sck_xxx" 引用可被解析
	if default then --so we need to keep track of the defaults on new system, so old SCK that use !sck_ can be loaded
		local name = string.GetFileFromFilename(basetex)
		SCKMaterialCompat["!sck_"..name] = basetex
	end

	-- 已是默认收藏则直接返回，避免每次加载重复登记并覆盖用户修改
	if default and SCKMaterialFavs[basetex] ~= nil then return end --Hack, maybe people don't like the defaults, don't readd every time
	-- 收藏标记：1=内置默认收藏，2=用户自定义收藏
	SCKMaterialFavs[basetex] = default and 1 or 2

	-- 用户自定义收藏变更时立即持久化到磁盘
	if not default then
		SaveMaterialData()
	end
end

-- ==== RemoveMaterialFavorite - 从收藏列表移除材质并持久化 ====
-- @param basetex string - 要移除的材质路径
function RemoveMaterialFavorite(basetex)
	local cur = SCKMaterialFavs[basetex]

	-- 内置默认收藏用 false 标记"已移除"（便于逻辑区分），用户收藏直接删除条目
	if cur == 1 then --not the cleanest way, helps logic above work
		SCKMaterialFavs[basetex] = false
	else
		SCKMaterialFavs[basetex] = nil
	end

	SaveMaterialData()
end

-- ==== SaveMaterialData - 将收藏表以 JSON 形式写入 DATA 目录 ====
function SaveMaterialData()
	file.Write("sck_materialfavs.dat", util.TableToJSON(SCKMaterialFavs, true))
end

-- ==== LoadMaterialData - 启动时从 DATA 目录读取收藏表 ====
function LoadMaterialData()
	if file.Exists("sck_materialfavs.dat", "DATA") then
		local info = file.Read("sck_materialfavs.dat", "DATA")

		SCKMaterialFavs = util.JSONToTable(info)
	end
end

-- 初始化时加载已保存的收藏数据
LoadMaterialData()

--[[#############################
	#		SCK MATERIALS		#
	#############################]]

-- 内置默认收藏材质列表（按材质类别分组，供 SCK 材质选择器直接使用）：
-- 砖块类
AddMaterialFavorite("brick/brickfloor001a", true)
AddMaterialFavorite("brick/brickwall001a", true)

-- 混凝土类
AddMaterialFavorite("concrete/concreteceiling001a", true)
AddMaterialFavorite("concrete/concretefloor001a", true)
AddMaterialFavorite("concrete/milwall002", true)

-- 金属类
AddMaterialFavorite("metal/metalfloor001a", true)
AddMaterialFavorite("metal/metalceiling005a", true)
AddMaterialFavorite("models/gibs/metalgibs/metal_gibs", true)
AddMaterialFavorite("phoenix_storms/dome", true)
AddMaterialFavorite("phoenix_storms/grey_steel", true)

-- 石膏类
AddMaterialFavorite("plaster/plasterceiling003a", true)
AddMaterialFavorite("plaster/plasterwall003a", true)
AddMaterialFavorite("plaster/plasterwall008a", true)

-- 石材类
AddMaterialFavorite("stone/stonefloor011a", true)
AddMaterialFavorite("stone/stonewall036a", true)

-- 木料类
AddMaterialFavorite("wood/woodfloor001a", true)
AddMaterialFavorite("wood/woodwall003a", true)
AddMaterialFavorite("wood/woodstair002c", true)
AddMaterialFavorite("wood/woodshelf001a", true)
AddMaterialFavorite("wood/woodshelf008a", true)

-- 自然/雪地类
AddMaterialFavorite("nature/snowfloor002a", true)
AddMaterialFavorite("ground/snow01", true)

--##############################
