-- ============================================================================
-- dismemberment.lua - 断肢特效（客户端）
-- 负责：等待被击杀玩家生成布娃娃后标记断肢部位，持续将断肢骨骼缩为
--       零并沿朝向喷射血液，模拟残缺肢体在喷血的表现
-- ============================================================================

-- ==== Init - 特效初始化：记录目标实体与断肢部位 ====
function EFFECT:Init(data)
	-- 被击杀的玩家实体与断肢部位掩码（DISMEMBER_* 位组合）
	self.eEnt = data:GetEntity()
	self.iScale = math.Round(data:GetScale())

	-- 默认存活 3 秒，找到布娃娃后延长到 5~7 秒
	self.DieTime = CurTime() + 3
end

-- 断肢部位列表（与 DismemberBones 按下标一一对应）
local Dismembers = {DISMEMBER_HEAD, DISMEMBER_LEFTLEG, DISMEMBER_RIGHTLEG, DISMEMBER_LEFTARM, DISMEMBER_RIGHTARM}
-- 各断肢部位对应的骨骼：ToZero = 需缩为 0 的骨骼，ToBleed = 需要喷血的骨骼
local DismemberBones = {
{ToZero = {"ValveBiped.Bip01_Head1"}, ToBleed = {["ValveBiped.Bip01_Head1"] = true}},
{ToZero = {"ValveBiped.Bip01_L_Thigh", "ValveBiped.Bip01_L_Calf", "ValveBiped.Bip01_L_Foot"}, ToBleed = {["ValveBiped.Bip01_L_Thigh"]=true}},
{ToZero = {"ValveBiped.Bip01_R_Thigh", "ValveBiped.Bip01_R_Calf", "ValveBiped.Bip01_R_Foot"}, ToBleed = {["ValveBiped.Bip01_R_Thigh"]=true}},
{ToZero = {"ValveBiped.Bip01_L_UpperArm", "ValveBiped.Bip01_L_Forearm", "ValveBiped.Bip01_L_Hand"}, ToBleed = {["ValveBiped.Bip01_L_UpperArm"]=true}},
{ToZero = {"ValveBiped.Bip01_R_UpperArm", "ValveBiped.Bip01_R_Forearm", "ValveBiped.Bip01_R_Hand"}, ToBleed = {["ValveBiped.Bip01_R_UpperArm"]=true}}
}

-- 部分僵尸模型的骨骼名映射：头部骨骼替换为其他可见骨骼（模型差异兼容）
local BoneTranslates = {}
BoneTranslates["models/zombie/classic.mdl"] = {["ValveBiped.Bip01_Head1"]="ValveBiped.Bip01_Spine2"}
BoneTranslates["models/zombie/poison.mdl"] = {["ValveBiped.Bip01_Head1"]="ValveBiped.Bip01_Spine4"}
BoneTranslates["models/zombie/fast.mdl"] = {["ValveBiped.Bip01_Head1"]="ValveBiped.HC_BodyCube"}
BoneTranslates["models/player/zombie_classic.mdl"] = {["ValveBiped.Bip01_Head1"]="ValveBiped.Bip01_Spine4"}
BoneTranslates["models/player/zombie_classic_hbfix.mdl"] = {["ValveBiped.Bip01_Head1"]="ValveBiped.Bip01_Spine4"}

-- ==== CollideCallback - 血液碰撞回调：终止粒子并留血肉印记 ====
local function CollideCallback(particle, hitpos, hitnormal)
	-- 已终止的粒子直接忽略，避免重复处理
	if particle:GetDieTime() == 0 then return end
	particle:SetDieTime(0)

	-- 1/6 概率播放血肉撞击音效，并始终在碰撞面留下血肉印记
	if math.random(6) == 1 then
		sound.Play("physics/flesh/flesh_bloody_impact_hard1.wav", hitpos, 50, math.random(95, 105))
	end

	util.Decal("Impact.Flesh", hitpos + hitnormal, hitpos - hitnormal)
end

-- ==== Think - 每帧检查：找到布娃娃后标记断肢并跟随其位置 ====
function EFFECT:Think()
	local eEnt = self.eEnt

	-- 第一次运行时尝试获取玩家布娃娃，成功后登记断肢掩码并延长存活时间
	if not self.SetDoll and eEnt:IsValid() and eEnt:IsPlayer() then
		local eRag = eEnt:GetRagdollEntity()
		if eRag and eRag:IsValid() then
			self.SetDoll = true
			self.eRagdoll = eRag
			-- 将断肢部位掩码并入布娃娃，供 Render 每帧查询
			eRag.Dismemberment = bit.bor((eRag.Dismemberment or 0), self.iScale)
			self.DieTime = CurTime() + math.Rand(5, 7)
			eRag.NextEmit = 0
			-- 扩大渲染包围盒，容纳布娃娃附近的喷血粒子
			self.Entity:SetRenderBounds(Vector(-128, -128, -128), Vector(128, 128, 128))
		end
	end

	-- 特效实体跟随布娃娃移动，保证喷血位置与尸体同步
	if self.eRagdoll and self.eRagdoll:IsValid() then
		self.Entity:SetPos(self.eRagdoll:GetPos())
	end

	return CurTime() < self.DieTime
end

-- ==== Render - 每帧渲染：缩小断肢骨骼并从断口持续喷血 ====
function EFFECT:Render()
	local eRagdoll = self.eRagdoll
	local fCurTime = CurTime()

	-- 喷血节流：每 0.05 秒发射一批粒子
	if eRagdoll and eRagdoll:IsValid() and eRagdoll.NextEmit <= fCurTime then
		eRagdoll.NextEmit = fCurTime + 0.05

		local emitter = ParticleEmitter(eRagdoll:GetPos())
		emitter:SetNearClip(20, 30)

		-- 遍历所有断肢部位，只处理掩码中已断肢的部分
		local iDismemberment = eRagdoll.Dismemberment or 0
		for index, iDismemberPart in pairs(Dismembers) do
			if bit.band(iDismemberPart, iDismemberment) == iDismemberPart then
				-- 将所有关联骨骼缩放为零，视觉上切除该肢体
				for _, sZeroBone in pairs(DismemberBones[index].ToZero) do
					local mdl = string.lower(eRagdoll:GetModel())
					if BoneTranslates[mdl] and BoneTranslates[mdl][sZeroBone] then
						sZeroBone = BoneTranslates[mdl][sZeroBone]
					end

					local iBone = eRagdoll:LookupBone(sZeroBone)
					if iBone and iBone > 0 then
						eRagdoll:ManipulateBoneScale(iBone, vector_tiny)
					end
				end

				-- 从断口骨骼位置持续喷射血液，喷射力度随剩余时间衰减
				for sZeroBone in pairs(DismemberBones[index].ToBleed) do
					local mdl = string.lower(eRagdoll:GetModel())
					if BoneTranslates[mdl] and BoneTranslates[mdl][sZeroBone] then
						sZeroBone = BoneTranslates[mdl][sZeroBone]
					end

					local iBone = eRagdoll:LookupBone(sZeroBone)
					if iBone and iBone > 0 then
						local delta = math.max(0, self.DieTime - fCurTime)
						if 0 < delta then
							local vBonePos, aBoneAng = eRagdoll:GetBonePosition(iBone)
							if vBonePos and aBoneAng then
								emitter:SetPos(vBonePos)
								local vForward = aBoneAng:Forward()
								-- 0~2 个血滴沿断口朝向喷出，附带随机散射并落地碰撞
								for i=1, math.random(0, 2) do
									local particle = emitter:Add("!sprite_bloodspray"..math.random(8), vBonePos)
									local force = math.min(1.5, delta) * math.Rand(175, 300)
									particle:SetVelocity(force * vForward + 0.2 * force * VectorRand())
									particle:SetDieTime(math.Rand(2.25, 3))
									particle:SetStartAlpha(240)
									particle:SetEndAlpha(0)
									particle:SetStartSize(math.random(1, 8))
									particle:SetEndSize(0)
									particle:SetRoll(math.Rand(0, 360))
									particle:SetRollDelta(math.Rand(-40, 40))
									particle:SetColor(255, 0, 0)
									particle:SetAirResistance(5)
									particle:SetBounce(0)
									particle:SetGravity(Vector(0, 0, -600))
									particle:SetCollide(true)
									particle:SetCollideCallback(CollideCallback)
									particle:SetLighting(true)
								end
								-- 一个跟随布娃娃速度的大血滴，模拟断口滴落的血
								local particle = emitter:Add("!sprite_bloodspray"..math.random(8), vBonePos)
								local vel = eRagdoll:GetVelocity()
								particle:SetVelocity(vel)
								particle:SetDieTime(math.Rand(0.5, 0.75))
								particle:SetStartAlpha(240)
								particle:SetEndAlpha(0)
								particle:SetStartSize(math.random(6, 12))
								particle:SetEndSize(0)
								particle:SetRoll(math.Rand(0, 360))
								local vellength = vel:Length() * 0.45
								particle:SetRollDelta(math.Rand(-vellength, vellength))
								particle:SetColor(255, 0, 0)
								particle:SetAirResistance(20)
								particle:SetLighting(true)
							end
						end
					end
				end
			end
		end

		emitter:Finish() emitter = nil collectgarbage("step", 64)
	end
end
