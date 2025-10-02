-- cl_init.lua (客户端)
INC_CLIENT()

ENT.NextEmit = 0

-- 客户端全局变量，用于追踪本地玩家是否处于混乱输入状态
local LocalPlayer_HasChaosInput = false
local LocalPlayer_ChaosEffectCount = 0 -- 计数器，以防多个效果同时存在

-- 变量，用于存储上一帧的视角角度，以实现平滑的鼠标反转
local previousViewAngles = nil

-- 当实体在客户端初始化时调用
function ENT:Initialize()
    self.BaseClass.Initialize(self) -- 调用基类的Initialize

    -- 如果这个实体属于本地玩家，增加混乱效果计数器
    if self:GetOwner() == LocalPlayer() then
        LocalPlayer_ChaosEffectCount = LocalPlayer_ChaosEffectCount + 1
        LocalPlayer_HasChaosInput = true -- 标记本地玩家处于混乱状态

        -- 当效果第一次激活时，初始化上一帧的角度
        if LocalPlayer_ChaosEffectCount == 1 then
            previousViewAngles = LocalPlayer():EyeAngles()
        end
    end
end

-- 当实体在客户端被移除时调用
function ENT:OnRemove()
	self.BaseClass.OnRemove(self)
    -- 如果这个实体属于本地玩家，减少混乱效果计数器
    if self:GetOwner() == LocalPlayer() then
        LocalPlayer_ChaosEffectCount = math.max(0, LocalPlayer_ChaosEffectCount - 1)
        
        -- 如果计数器归零，说明没有其他混乱效果，解除混乱状态
        if LocalPlayer_ChaosEffectCount == 0 then
            LocalPlayer_HasChaosInput = false
            -- 重置上一帧的角度变量，为下次激活做准备
            previousViewAngles = nil
        end
    end
end

-- [[ 输入反转钩子 ]]
-- 这个钩子只添加一次，在文件加载时。它的行为由 LocalPlayer_HasChaosInput 控制。
hook.Add("CreateMove", "GlobalChaos_ReverseControls", function(cmd)
    -- 如果本地玩家没有混乱效果，则直接返回，不做任何事
    if not LocalPlayer_HasChaosInput then return end
    
	-- 1. 反转键盘移动 (前进/后退/左右)
	cmd:SetForwardMove(cmd:GetForwardMove() * -1)
	cmd:SetSideMove(cmd:GetSideMove() * -1)
	-- 可选：反转向上移动（跳跃/蹲下）
	-- cmd:SetUpMove(cmd:GetUpMove() * -1)

    -- 2. 反转鼠标视角 (通过存储上一帧角度的可靠方法)

    -- 如果 previousViewAngles 尚未初始化 (例如，在效果激活的第一帧)，则进行初始化
    if not previousViewAngles then
        previousViewAngles = cmd:GetViewAngles()
        return -- 跳过第一帧的反转，以避免视角跳跃
    end

    -- 获取引擎根据本帧鼠标移动计算出的新视角
    local newAngles = cmd:GetViewAngles()

    -- 计算出由鼠标移动产生的视角变化量 (delta)
    -- 这是当前引擎计算的角度与我们上一帧存储的角度之间的差值
    local delta = newAngles - previousViewAngles

    -- 从上一帧的视角中减去这个变化量，得到反转后的新视角
    local invertedAngle = previousViewAngles - delta

    -- 将我们计算出的反转视角应用到移动指令中
    cmd:SetViewAngles(invertedAngle)

    -- **极其重要的一步**: 更新上一帧的角度为我们刚刚设置的反转角度
    -- 这样，下一帧的计算就会基于这个新的、被反转了的角度
    previousViewAngles = invertedAngle
end)


-- [[ 粒子效果绘制逻辑 ]]
function ENT:Draw()
	local owner = self:GetOwner()
	if not IsValid(owner) or (owner == LocalPlayer() and not LocalPlayer():ShouldDrawLocalPlayer()) then return end
	if owner:GetZombieClassTable() and owner:GetZombieClassTable().IgnoreTargetAssist then return end
	if owner.SpawnProtection then return end

	if CurTime() < self.NextEmit then return end
	self.NextEmit = CurTime() + 0.1

	local pos = owner:WorldSpaceCenter()
	pos.z = pos.z + 24

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(16, 24)

	for i = 1, 3 do
		local particle = emitter:Add("sprites/light_glow02_add", pos + VectorRand() * 8)
		particle:SetDieTime(math.Rand(0.6, 1.2))
		particle:SetStartAlpha(200)
		particle:SetEndAlpha(0)
		particle:SetStartSize(1)
		particle:SetEndSize(5)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-5, 5))
		particle:SetGravity(Vector(0, 0, 20))
		particle:SetAirResistance(150)
		particle:SetColor(150, 0, 255)
	end

	emitter:Finish()
end