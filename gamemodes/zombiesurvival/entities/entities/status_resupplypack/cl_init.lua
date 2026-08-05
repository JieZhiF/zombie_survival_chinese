-- ============================================================================
-- status_resupplypack/cl_init.lua - 补给包状态实体（客户端）
-- 负责：将补给包模型绑定到持有者背部、播放冷却提示音与 3D2D 使用提示
-- ============================================================================

INC_CLIENT()

-- ==== Initialize - 初始化 ====
-- 关闭阴影并设置渲染包围盒
function ENT:Initialize()
	self:DrawShadow(false)
	self:SetModelScale(0.35, 0)

	self:SetRenderBounds(Vector(-26, -26, -26), Vector(26, 26, 45))
end

-- ==== Think - 每帧逻辑 ====
-- 本地玩家为人类时，在补给冷却结束时播放提示音
function ENT:Think()
	if MySelf:IsValid() and MySelf:Team() == TEAM_HUMAN then
		local nextuse = MySelf.NextUse or 0
		-- 冷却期间重置标记，冷却结束的瞬间播放一次提示音
		if self.Dinged then
			if CurTime() < nextuse then
				self.Dinged = false
			end
		elseif CurTime() >= nextuse then
			self.Dinged = true

			self:EmitSound("zombiesurvival/ding.ogg")
		end
	end

	self:NextThink(CurTime() + 0.5)
	return true
end

-- ==== Draw - 绘制 ====
-- 把补给包吸附到持有者背部骨骼，并根据持有者状态绘制隐藏或 3D2D 提示
function ENT:Draw()
	local owner = self:GetOwner()
	-- 持有者无效或本地玩家不可见时跳过绘制
	if not owner:IsValid() or owner == MySelf and not owner:ShouldDrawLocalPlayer() then return end

	-- 持有者正手持补给包武器时不绘制（避免重复显示）
	local wep = owner:GetActiveWeapon()
	if wep:IsValid() and wep:GetClass() == "weapon_zs_t_resupplypack" then return end

	-- 获取背部骨骼位置与朝向
	local boneid = owner:LookupBone("ValveBiped.Bip01_Spine2")
	if not boneid or boneid <= 0 then return end

	-- 将补给包放置于背部骨骼并调整朝向（贴合背部）
	local bonepos, boneang = owner:GetBonePositionMatrixed(boneid)

	self:SetPos(bonepos + boneang:Forward() + boneang:Right() * 6)
	boneang:RotateAroundAxis(boneang:Right(), 270)
	boneang:RotateAroundAxis(boneang:Forward(), 90)
	self:SetAngles(boneang)

	-- 持有者为影子玩家（影分身）时按设置隐藏补给包
	local shadowman = owner.ShadowMan
	local hidepacks = not GAMEMODE.HidePacks

	if hidepacks and shadowman then
		render.SetBlend(0)
	end

	self:DrawModel()

	if hidepacks and shadowman then
		render.SetBlend(1)
	end

	-- 非隐藏状态下绘制 3D2D 补给提示牌（显示是否可用）
	if not hidepacks or not shadowman then
		local w, h = 420, 200
		cam.Start3D2D(self:LocalToWorld(Vector(0, 0, self:OBBMaxs().z)), self:GetAngles(), 0.025)
			-- 半透明黑色圆角底牌 + 补给文字（冷却中红色，可用绿色）
			draw.RoundedBox(64, w * -0.5, h * -0.5, w, h, color_black_alpha120)
			draw.SimpleText(translate.Get("resupply_box"), "ZS3D2DFont2", 0, 0, (MySelf.NextUse or 0) <= CurTime() and COLOR_GREEN or COLOR_DARKRED, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		cam.End3D2D()
	end
end
