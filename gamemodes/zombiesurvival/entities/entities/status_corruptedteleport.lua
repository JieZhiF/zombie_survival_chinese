-- ============================================================================
-- status_corruptedteleport.lua - 腐化传送状态（共享）
-- 负责：继承法阵传送状态，但将传送粒子染成腐化绿色调
-- ============================================================================
-- 客户端与服务端均加载本文件
AddCSLuaFile()

-- 动画实体类型
ENT.Type = "anim"
-- 继承法阵传送状态基类，复用传送逻辑与粒子系统
ENT.Base = "status_sigilteleport"

-- 传送阵使用的烟雾粒子材质
ENT.ParticleMaterial = "particle/smokesprites_0001"

-- ==== SetParticleColor - 将传送粒子染成腐化绿色（38, 255, 102） ====
function ENT:SetParticleColor(particle)
	particle:SetColor(38, 255, 102)
end
