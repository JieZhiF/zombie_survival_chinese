-- ============================================================================
-- status_ghost_messagebeacon - 讯息信标放置幽灵预览状态实体（共享端）
-- 负责：每帧沿准星射线计算放置点，校验放置合法性（贴地/不嵌入实体/不与其他信标重叠）并同步位置朝向
-- ============================================================================

-- 实体类型：动画实体
ENT.Type = "anim"
-- 母类：通用状态实体基类
ENT.Base = "status__base"

-- 幽灵预览模型：讯息信标地雷模型
ENT.Model = Model("models/props_combine/combine_mine01.mdl")

-- ==== Initialize - 关闭阴影并设为线框材质，设置碰撞边界后立即校验放置合法性 ====
function ENT:Initialize()
	self:DrawShadow(false)
	self:SetMaterial("models/wireframe")
	self:SetModel(self.Model)
	self:SetCollisionBounds(Vector(-8.29, -8.29, 0), Vector(8.29, 8.29, 10.13))

	self:RecalculateValidity()
end

-- ==== IsInsideProp - 检测幽灵当前位置是否嵌入了任何物理实体（嵌入则不可放置） ====
function ENT:IsInsideProp()
	for _, ent in pairs(ents.FindInBox(self:WorldSpaceAABB())) do
		if ent and ent ~= self and ent:IsValid() and ent:GetMoveType() == MOVETYPE_VPHYSICS and ent:GetSolid() > 0 then return true end
	end

	return false
end

-- ==== RecalculateValidity - 沿准星射线计算放置点：校验贴地、无重叠、不阻挡出生点，并同步幽灵位置/朝向 ====
function ENT:RecalculateValidity()
	local owner = self:GetOwner()
	if not owner:IsValid() then return end

	local eyeangles = owner:EyeAngles()
	local shootpos = owner:GetShootPos()
	local tr = util.TraceLine({start = shootpos, endpos = shootpos + owner:GetAimVector() * 48, mask = MASK_SOLID, filter = owner})

	-- 命中世界且非天空，且命中面法线朝上（贴地）时视为有效表面
	if tr.HitWorld and not tr.HitSky and tr.HitNormal.z >= 0 then
		-- 将幽灵朝向调整为贴合地面的角度（绕右轴旋转 270 度）
		eyeangles = tr.HitNormal:Angle()
		eyeangles:RotateAroundAxis(eyeangles:Right(), 270)

		local valid = true
		-- 嵌入其他物理实体，或 48 单位内已存在其他信标时判定为无效
		if self:IsInsideProp() then
			valid = false
		else
			for _, ent in pairs(ents.FindInSphere(tr.HitPos, 48)) do
				if ent and ent:IsValid() and ent:GetClass() == "prop_messagebeacon" then
					valid = false
					break
				end
			end
		end

		-- 服务端额外校验：放置点不得阻挡玩家出生点
		if valid and SERVER and GAMEMODE:EntityWouldBlockSpawn(self) then
			valid = false
		end

		self:SetValidPlacement(valid)
	else
		self:SetValidPlacement(false)
	end

	-- 同步幽灵到射线命中点并应用贴地朝向
	local pos, ang = tr.HitPos, eyeangles
	self:SetPos(pos)
	self:SetAngles(ang)

	return pos, ang
end

-- ==== GetValidPlacement - 读取网络同步的放置合法性状态 ====
function ENT:GetValidPlacement()
	return self:GetDTBool(0)
end

-- ==== SetValidPlacement - 网络同步设置放置合法性状态 ====
function ENT:SetValidPlacement(onoff)
	self:SetDTBool(0, onoff)
end
