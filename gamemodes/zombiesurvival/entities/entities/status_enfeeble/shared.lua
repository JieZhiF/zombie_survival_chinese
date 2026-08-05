-- ============================================================================
-- status_enfeeble/shared.lua - 虚弱状态（共享）
-- 负责：被施加者在受僵尸攻击时承伤放大（1.4 倍），并显示红色旋转的
--       内脏模型特效与受伤者红色泛光；记录施加者与持续时间
-- ============================================================================
AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "status__base"

-- 承伤倍率：被虚弱者受到僵尸伤害放大 1.4 倍
ENT.DamageScale = 1.4

-- 特效模型：旋转的红色内脏模型
ENT.Model = Model("models/gibs/HGIBS.mdl")

-- 临时状态：结束后不保留
ENT.Ephemeral = true

-- DT 访问器：状态持续时间与开始时间（同步至客户端）
AccessorFuncDT(ENT, "Duration", "Float", 0)
AccessorFuncDT(ENT, "StartTime", "Float", 4)

-- ==== Initialize - 初始化基础状态、设置特效模型并注册各端钩子 ====
function ENT:Initialize()
	self.BaseClass.Initialize(self)

	-- 特效模型设置：不投射阴影
	self:SetModel(self.Model)
	self:DrawShadow(false)

	if SERVER then
		-- 服务器：监听伤害/玩家受伤事件用于承伤放大与伤害归属
		hook.Add("EntityTakeDamage", self, self.EntityTakeDamage)
		hook.Add("PlayerHurt", self, self.PlayerHurt)

		-- 施加时播放虚弱音效
		self:EmitSound("beams/beamstart5.wav", 65, 140)
	end

	if CLIENT then
		-- 客户端：玩家模型红色泛光与屏幕特效
		hook.Add("PrePlayerDraw", self, self.PrePlayerDraw)
		hook.Add("PostPlayerDraw", self, self.PostPlayerDraw)
		hook.Add("RenderScreenspaceEffects", self, self.RenderScreenspaceEffects)
	end
end

-- ==== PlayerSet - 附加到玩家时记录状态开始时间 ====
function ENT:PlayerSet()
	self:SetStartTime(CurTime())
end
