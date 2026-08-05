-- GMod 全局环境声明 (供 luacheck 静态分析)
std = "none"
max_line_length = false

globals = {
	"_G", "print", "pairs", "ipairs", "next", "type", "tostring", "tonumber",
	"select", "unpack", "require", "error", "assert", "pcall", "xpcall",
	"string", "table", "math", "bit", "os", "io", "coroutine", "debug", "rawset", "rawget",
	"GM", "GAMEMODE", "CLIENT", "SERVER", "SHARED", "MySelf", "LocalPlayer",
	"Vector", "Angle", "Color", "Entity", "Player", "Weapon", "EffectData",
	"net", "hook", "util", "ents", "player", "team", "timer", "cvars", "weapons",
	"game", "engine", "surface", "cam", "render", "draw", "vgui", "language",
	"CreateClientConVar", "CreateConVar", "AddCSLuaFile", "include", "include_library",
	"Msg", "MsgC", "MsgN", "ErrorNoHalt", "CompileString", "CompileFile", "LoadString",
	"CurTime", "RealTime", "FrameTime", "SysTime", "FrameNumber",
	"EyePos", "EyeAngles", "WorldVisible", "BetterScreenScale", "translate",
	"TEAM_HUMAN", "TEAM_UNDEAD", "TEAM_SPECTATOR", "TEAM_UNASSIGNED",
	"FCVAR_ARCHIVE", "FCVAR_NOTIFY", "FCVAR_REPLICATED", "FCVAR_SERVER_CAN_EXECUTE", "FCVAR_CLIENTCMD_CAN_EXECUTE",
	"DMG_GENERIC", "DMG_CRUSH", "DMG_BULLET", "DMG_SLASH", "DMG_BURN", "DMG_CLUB", "DMG_SLOWBURN",
	"DMG_ALWAYSGIB", "DMG_ACID", "DMG_TAKE_BLEED", "DMG_BUCKSHOT", "DMG_BLAST",
	"CONTENTS_WATER", "CONTENTS_SLIME", "MASK_SOLID", "MASK_SOLID_BRUSHONLY", "MASK_SHOT",
	"COLLISION_GROUP_WORLD", "COLLISION_GROUP_NONE", "COLLISION_GROUP_DEBRIS",
	"IN_SPEED", "IN_RELOAD", "IN_USE", "IN_ATTACK", "IN_ATTACK2",
	"SIMPLE_USE", "SOLID_VPHYSICS", "OBS_MODE_NONE",
	"NET_MSG", "POINTSMULTIPLIER", "INFDAMAGEFLOATER", "LASTHUMAN", "ROUNDWINNER",
	"SKILL_BLOODLUST", "SKILL_D_FRAIL", "SKILL_REGENERATOR", "SKILL_BLOODARMOR", "SKILL_CARDIOTONIC",
	"SKILL_BLOODLETTER", "SKILL_D_LATEBUYER", "SKILL_STOWAGE", "SKILL_STOCKPILE", "SKILL_INSIGHT",
	"SKILL_ACUITY", "SKILL_VISION", "SKILL_BACKPEDDLER", "STATTRACK_TYPE_ZOMBIECLASS", "STATTRACK_TYPE_WEAPON",
	"FM_NONE", "SLOWTYPE_COLD", "CLASS", "ENT", "SWEP", "EFFECT", "ZombieClasses",
}
