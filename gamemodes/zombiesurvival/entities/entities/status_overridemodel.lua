-- ============================================================================
-- status_overridemodel.lua - 覆盖模型状态（共享）
-- 负责：为拥有者附加一个替代模型实体（如僵尸变身的外观），隐藏玩家本体模型；
--       出生保护期间模型闪烁蓝色提示；某些僵尸类可保留本体模型（NoHideMainModel）
-- ============================================================================
AddCSLuaFile()

-- 实体类型为动画实体，继承 status__base 状态基类
ENT.Type = "anim"
ENT.Base = "status__base"
-- 半透明渲染组，保证闪烁/透明效果正确排序
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

-- ==== Initialize - 初始化：附加为拥有者的骨骼合并模型并隐藏其本体 ====
function ENT:Initialize()
	-- 无碰撞、不移动，纯粹作为外观附加物
	self:SetSolid(SOLID_NONE)
	self:SetMoveType(MOVETYPE_NONE)
	-- 骨骼合并 + 快速剔除 + 跟随父级动画，使模型跟随玩家动作
	self:AddEffects(bit.bor(EF_BONEMERGE, EF_BONEMERGE_FASTCULL, EF_PARENT_ANIMATES))
	self:SetRenderMode(RENDERMODE_TRANSALPHA)

	local pPlayer = self:GetOwner()
	if pPlayer:IsValid() then
		-- 记录到玩家字段，供外观切换逻辑引用
		pPlayer.status_overridemodel = self
		-- 非僵尸阵营或僵尸类未禁用本体隐藏时，隐藏玩家本体模型
		if SERVER and pPlayer:Team() ~= TEAM_UNDEAD or not pPlayer:GetZombieClassTable().NoHideMainModel then
			pPlayer:SetRenderMode(RENDERMODE_NONE)
		end
	end
end

-- ==== PlayerSet - 附加到玩家：同样隐藏玩家本体模型 ====
function ENT:PlayerSet(pPlayer, bExists)
	if SERVER and pPlayer:Team() ~= TEAM_UNDEAD or not pPlayer:GetZombieClassTable().NoHideMainModel then
		pPlayer:SetRenderMode(RENDERMODE_NONE)
	end
end

-- ==== OnRemove - 移除：恢复玩家本体模型可见 ====
function ENT:OnRemove()
	local pPlayer = self:GetOwner()
	if SERVER and pPlayer:IsValid() then
		pPlayer:SetRenderMode(RENDERMODE_NORMAL)
	end
end

-- ==== Think - 无每帧逻辑（占位） ====
function ENT:Think()
end

if CLIENT then
	-- ==== Draw - 渲染：绘制覆盖模型；出生保护期间以蓝色闪烁提示 ====
	function ENT:Draw()
		local owner = self:GetOwner()
		if owner:IsValid() and (not owner:IsPlayer() or owner:Alive()) then
			local pcolor = owner:GetColor()
			-- 出生保护：强制蓝色并高频闪烁（全屏自发光）
			if owner.SpawnProtection then
				pcolor.a = (0.02 + (CurTime() + self:EntIndex() * 0.2) % 0.05) * 255
				pcolor.r = 0
				pcolor.b = 0
				pcolor.g = 255
				render.SuppressEngineLighting(true)
			end
			self:SetColor(pcolor)

			-- 出生保护且僵尸类保留本体时不绘制覆盖模型
			if not (owner.SpawnProtection and owner:GetZombieClassTable().NoHideMainModel) then
				-- 僵尸类可拦截绘制流程（Pre/Post 回调）
				if not owner:CallZombieFunction1("PrePlayerDrawOverrideModel", self) then
					self:DrawModel()

					owner:CallZombieFunction1("PostPlayerDrawOverrideModel", self)
				end
			end

			-- 结束自发光状态
			if owner.SpawnProtection then
				render.SuppressEngineLighting(false)
			end
		end
	end
	-- 半透明渲染通道复用同一绘制函数
	ENT.DrawTranslucent = ENT.Draw
end
