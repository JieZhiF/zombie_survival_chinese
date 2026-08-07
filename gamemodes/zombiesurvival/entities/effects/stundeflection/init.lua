-- ============================================================================
-- stundeflection/init.lua - 眩晕弹开特效（客户端）
-- 负责：被眩晕的投射物被弹开时，在弹开点生成瞬时白光、白色闪光粒子
--       与扩散光环，并点亮一个 0.4 秒的动态光源，强化弹开反馈
-- ============================================================================

-- ==== Init - 特效初始化：设置光源并喷射闪光粒子与光环 ====
function EFFECT:Init(data)
	
	--self.Position = self:GetTracerShootPos(data:GetOrigin(), self.WeaponEnt, self.Attachment)
	self.Position = data:GetOrigin()
	self.Forward = data:GetNormal()
	self.Angle = self.Forward:Angle()
	self.Right = self.Angle:Right()
	
	-- 创建 0.4 秒的白色动态光源，照亮弹开瞬间的场景
	local light = DynamicLight( 0 )
	if( light ) then	
		light.Pos = self:GetPos()
		light.Size = 100
		light.Decay = 200
		light.R = 165
		light.G = 165
		light.B = 165
		light.Brightness = 1
		light.DieTime = CurTime() + 0.4
	end
	
	local AddVel = 5 --self.WeaponEnt:GetOwner():GetVelocity()
	local emitter = ParticleEmitter(self.Position)

	
	
-- 单个大型白色光斑：从 150 快速缩小，模拟弹开瞬间的闪光
for i=1, 1 do
	if emitter ~= nil then	
		local particle = emitter:Add( "sprites/light_glow02_add_noz", self.Position, (Color(255,100,0,25)) )
		if particle ~= nil then

			particle:SetVelocity( 0 * VectorRand() + 0 * VectorRand() + 0 * VectorRand() )
			particle:SetGravity( Vector( 0, 0, -50 ) )
			particle:SetAirResistance( 90 )
			particle:SetColor( 255,255,255 )

			particle:SetDieTime( 0.3 )

			particle:SetStartSize( 150 )
			particle:SetEndSize( 1 )
		end
	
	end
end	
	
-- 26 个白色闪光粒子：向随机方向飘散，带碰撞与反弹，模拟能量碎屑
for i=0, 25 do
	if emitter ~= nil then	
		local particle = emitter:Add( "sprites/light_glow02_add_noz", self.Position, (Color(255,100,0,25)) )
		if particle ~= nil then

			particle:SetVelocity( 50 * VectorRand() + 50 * VectorRand() + 50 * VectorRand() )
			particle:SetGravity( Vector( 0, 0, -50 ) )
			particle:SetAirResistance( 90 )
			particle:SetColor( 255,255,255 )

			particle:SetDieTime( math.Rand( 0.5, 1 ) )

			particle:SetStartSize( math.random( 3, 5 ) )
			particle:SetEndSize( 1 )

			particle:SetRoll( math.Rand( 180, 480 ) )
			particle:SetRollDelta( math.Rand( -1, 1 ) )
			particle:SetBounce( 2 )
			particle:SetCollide( true )
		end
	
	end
end

		-- 2 个白色光环粒子：从 5 快速膨胀到 30，形成扩散的冲击环
		for i=0, 1 do
			local particle = emitter:Add( "particle/Particle_Ring_Wave_Additive", self.Position )
			--if (particle) then
				particle:SetDieTime( 0.25 )
				particle:SetStartAlpha( 255 )
				particle:SetEndAlpha( 0 )
				particle:SetColor( 255,255,255 )
				particle:SetStartSize( 5 )
				particle:SetEndSize( 30 )
				particle:SetRoll( math.Rand(0, 360) )
				particle:SetRollDelta( math.Rand(-1, 1) )
 				particle:SetAirResistance( 200 ) 
 				--particle:SetGravity( Vector( 100, 0, 0 ) ) 	
			--end
		
		end
emitter:Finish()
end
--end

-- ==== Think - 特效思考：一次性粒子效果，无需持续更新 ====
function EFFECT:Think()

	return false
end


-- ==== Render - 无自定义渲染，粒子由引擎粒子系统绘制 ====
function EFFECT:Render()
end