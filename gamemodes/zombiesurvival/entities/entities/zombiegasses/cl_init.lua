-- ============================================================================
-- cl_init.lua - 僵尸毒气区域（客户端）：咳嗽音效与绿色毒气粒子渲染
-- 负责：本地人类玩家身处毒气时播放咳嗽声，并按频率生成随机上升的绿色烟雾粒子
-- ============================================================================
INC_CLIENT()

-- 下次允许生成粒子的时间（限制粒子频率）
ENT.NextGas = 0
-- 下次允许播放咳嗽音效的时间（4~6 秒间隔）
ENT.NextSound = 0

-- ==== Think - 客户端每帧逻辑：为圈内的人类玩家播放咳嗽音效 ====
function ENT:Think()
	-- 僵尸逃跑模式下不播放音效
	if GAMEMODE.ZombieEscape then return end

	-- 按 4~6 秒的随机间隔检查是否播放咳嗽声
	if self.NextSound <= CurTime() then
		self.NextSound = CurTime() + math.Rand(4, 6)

		-- 仅对本地人类玩家，且在波次进行中、玩家位于毒气范围内且可见时播放
		if 0 < GAMEMODE:GetWave() and MySelf:IsValid() and MySelf:Team() == TEAM_HUMAN and MySelf:Alive() then
			local mypos = self:GetPos()
			local eyepos = MySelf:NearestPoint(mypos)
			local radius = self:GetRadius()
			-- 半径判定额外扩大 72 单位（5184 = 72^2），并校验视线无遮挡
			if eyepos:DistToSqr(mypos) <= radius * radius + 5184 and WorldVisible(eyepos, mypos) then
				MySelf:EmitSound("ambient/voices/cough"..math.random(4)..".wav")
			end
		end
	end
end

-- 毒气粒子外观参数表：不同材质的烟雾精灵与配色，随机抽取一种生成
local particleTable = {
	[ 1 ] = { particle = "particle/smokesprites_0001", sizeStart = 0, sizeEnd = 96, airRecis = 90, startAlpha = 180, endAlpha = 0, randXY = 76, randZMin = 34, randZMax = 72, color = Color( 0, 80, 0 ), rotRate = 0.9, lifeTimeMin = 1.8, lifeTimeMax = 2.9 },
	[ 2 ] = { particle = "particle/smokesprites_0002", sizeStart = 0, sizeEnd = 90, airRecis = 76, startAlpha = 110, endAlpha = 0, randXY = 54, randZMin = 24, randZMax = 62, color = Color( 0, 120, 0 ), rotRate = 0.6, lifeTimeMin = 1.6, lifeTimeMax = 2.2 },
	[ 3 ] = { particle = "particle/smokesprites_0003", sizeStart = 0, sizeEnd = 140, airRecis = 49, startAlpha = 130, endAlpha = 0,randXY = 66, randZMin = 39, randZMax = 42, color = Color( 0, 90, 0 ), rotRate = 0.6, lifeTimeMin = 1.8, lifeTimeMax = 2.4 },
	[ 4 ] = { particle = "particle/smokesprites_0004", sizeStart = 0, sizeEnd = 100, airRecis = 59, startAlpha = 160, endAlpha = 0,randXY = 72, randZMin = 31, randZMax = 68, color = Color( 0, 60, 0 ), rotRate = 0.2, lifeTimeMin = 1.6, lifeTimeMax = 2.9 },
	[ 5 ] = { particle = "particle/smokesprites_0007", sizeStart = 0, sizeEnd = 160, airRecis = 79, startAlpha = 180, endAlpha = 0,randXY = 76, randZMin = 16, randZMax = 56, color = Color( 0, 70, 0 ), rotRate = 1.4, lifeTimeMin = 1.6, lifeTimeMax = 2.2 },
	[ 6 ] = { particle = "particle/smokesprites_0008", sizeStart = 0, sizeEnd = 60, airRecis = 46, startAlpha = 190, endAlpha = 0,randXY = 79, randZMin = 12, randZMax = 48, color = Color( 0, 90, 0 ), rotRate = 1, lifeTimeMin = 1.7, lifeTimeMax = 2.4 },
	[ 7 ] = { particle = "particle/particle_glow_03", sizeStart = 0, sizeEnd = 4, airRecis = 4, startAlpha = 255, endAlpha = 0,randXY = 59, randZMin = 16, randZMax = 64, color = Color( 0, 255, 0 ), rotRate = 0, lifeTimeMin = 1.5, lifeTimeMax = 2.8 },
}

-- ==== Draw - 实体绘制：按随机间隔生成一枚上升的毒气烟雾粒子 ====
function ENT:Draw()
	-- 僵尸逃跑模式或无时间配额时跳过本帧
	if GAMEMODE.ZombieEscape or CurTime() < self.NextGas then return end
	-- 每 0.05~0.25 秒生成一枚粒子
	self.NextGas = CurTime() + math.Rand( 0.05, 0.25 )

	local pos = self:GetPos()
	-- 生成随机的出生偏移：水平 20~40 单位、垂直 10~60 单位
	local vecRan = VectorRand()
	vecRan:Normalize()
	local particledata = particleTable[math.random(7)]
	vecRan = vecRan * math.Rand( 20, 40 )
	vecRan.z = math.Rand( 10, 60 )

	local emitter = ParticleEmitter( pos )
	emitter:SetNearClip( 48, 64 )

	-- 粒子散布范围随毒气半径缩放
	local radiusmul = self:GetRadius() / 170

	local particle = emitter:Add( particledata.particle, pos + vecRan )
	particle:SetVelocity( Vector( math.Rand(-particledata.randXY, particledata.randXY) * radiusmul * 2, math.Rand(-particledata.randXY, particledata.randXY) * radiusmul * 2, math.Rand(particledata.randZMin, particledata.randZMax) * radiusmul ))
	particle:SetColor( particledata.color.r, particledata.color.g, particledata.color.b )
	particle:SetAirResistance( particledata.airRecis )
	particle:SetCollide( true )
	particle:SetDieTime( math.Rand( particledata.lifeTimeMin , particledata.lifeTimeMax ) )
	particle:SetStartAlpha( particledata.startAlpha )
	particle:SetEndAlpha( particledata.endAlpha )
	particle:SetStartSize( particledata.sizeStart )
	particle:SetEndSize( particledata.sizeEnd )
	particle:SetRollDelta( math.Rand( -particledata.rotRate, particledata.rotRate ) )

	-- 提交粒子发射器并释放内存（周期调用下避免累积）
	emitter:Finish() emitter = nil collectgarbage("step", 64)
end
