-- ============================================================================
-- status_feigndeath/cl_init.lua - 装死状态（客户端）
-- 负责：锁定视角朝向并禁止跳跃；进入/退出时切换无碰撞状态；
--       绘制"按冲刺键起身"提示文字（随阶段渐显/渐隐）
-- ============================================================================
INC_CLIENT()

-- 渲染组：半透明实体（提示文字绘制用）
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

-- ==== OnInitialize - 初始化：注册输入/绘制 hook，锁定视角并切换无碰撞 ====
function ENT:OnInitialize()
	hook.Add("Move", self, self.Move)
	hook.Add("CreateMove", self, self.CreateMove)
	hook.Add("ShouldDrawLocalPlayer", self, self.ShouldDrawLocalPlayer)

	-- 扩大渲染包围盒以容纳 3D2D 提示文字
	self:SetRenderBounds(Vector(-40, -40, -18), Vector(40, 40, 80))

	local owner = self:GetOwner()
	if owner:IsValid() then
		-- 登记装死引用，并强制开启完全无碰撞（含与环境道具）
		owner.FeignDeath = self
		owner.NoCollideAll = true
		owner:CollisionRulesChanged()

		-- 记录进入装死时的视角朝向，装死期间锁定
		self.CommandYaw = owner:GetAngles().yaw

		-- 通知武器与僵尸类进入倒地状态（播放倒地动画等）
		owner:CallWeaponFunction("KnockedDown", self, false)
		owner:CallZombieFunction("KnockedDown", self, false)
	end
end

-- ==== CreateMove - 输入修正：锁定视角朝向并屏蔽跳跃键 ====
function ENT:CreateMove(cmd)
	-- 只处理本状态携带者的输入
	if MySelf ~= self:GetOwner() then return end

	-- 将视角锁定为装死开始时的朝向，防止倒地后镜头乱转
	local ang = cmd:GetViewAngles()
	ang.yaw = self.CommandYaw or ang.yaw
	cmd:SetViewAngles(ang)

	-- 屏蔽跳跃键，装死期间不允许起跳
	if bit.band(cmd:GetButtons(), IN_JUMP) ~= 0 then
		cmd:SetButtons(cmd:GetButtons() - IN_JUMP)
	end
end

-- ==== ShouldDrawLocalPlayer - 装死时允许渲染本地玩家第三人称模型 ====
function ENT:ShouldDrawLocalPlayer(pl)
	if pl ~= self:GetOwner() then return end

	return true
end

-- ==== OnRemove - 状态结束时恢复碰撞规则与视角控制 ====
function ENT:OnRemove()
	local owner = self:GetOwner()
	if owner:IsValid() then
		owner.FeignDeath = nil
		-- 恢复无碰撞标记为僵尸类默认值（仅亡灵且该类自带时保持）
		owner.NoCollideAll = owner:Team() == TEAM_UNDEAD and owner:GetZombieClassTable().NoCollideAll
		owner:CollisionRulesChanged()
	end
end

-- ==== DrawTranslucent - 绘制"按冲刺键起身"提示文字（带渐显/渐隐） ====
function ENT:DrawTranslucent()
	local owner = self:GetOwner()
	-- 只在本地玩家身上显示
	if MySelf ~= owner then return end

	-- 提示文字位于玩家右侧 32 单位处，透明度按剩余时间渐变：
	-- 可起身阶段（状态 1）剩余时间越多越清晰；装死阶段则逐渐淡出
	local pos = owner:GetPos() + EyeAngles():Right() * 32
	local col = table.Copy(COLOR_GRAY)
	if self:GetState() == 1 then
		col.a = math.max(self:GetStateEndTime() - CurTime(), 0) * 80
	else
		col.a = (1 - math.max(self:GetStateEndTime() - CurTime(), 0)) * 80
	end
	local ang = owner:GetAngles()
	ang.pitch = 0
	ang.roll = 0

	-- 3D2D 绘制提示文字，忽略深度测试保证始终可见
	cam.IgnoreZ(true)
	cam.Start3D2D(pos, ang, 0.1)
		draw.SimpleTextBlur(translate.Get("press_sprint_to_get_up"), "ZS3D2DFont2Small", 0, 0, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	cam.End3D2D()
	cam.IgnoreZ(false)
end
