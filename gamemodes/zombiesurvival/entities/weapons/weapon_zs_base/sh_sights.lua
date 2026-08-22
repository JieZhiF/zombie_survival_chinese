-- sh_sights.lua
-- 机械瞄准（ADS）核心：ARC9 风格平滑过渡状态机 + 输入处理 + FOV/灵敏度

-- [切换模式] 双端一致的复制变量：1=右键按一下切换开关，0=长按瞄准
local CVAR_TOGGLE_ADS = CreateConVar("zs_toggleads", "0", bit.bor(FCVAR_REPLICATED, FCVAR_ARCHIVE), "切换式机械瞄准（1=按一下切换，0=长按）")

function SWEP:IsToggleADS()
	return CVAR_TOGGLE_ADS:GetBool()
end

--[[ 平滑过渡说明：
	GetIronsightDelta（CLIENT）采用持续逼近式进度：从当前值向目标滑动，
	中途反打收/开镜时从当前位置继续，不产生跳变。
	self.fIronTime 仅保留给狙击系武器的 IsScoped() 做完全瞄准时序判断。 ]]

function SWEP:SecondaryAttack()
	-- 切换模式下由 Think 的按键沿检测接管，这里直接让行避免双重翻转
	if self:IsToggleADS() then return end
	-- 武器可显式禁用机瞄（如霰弹枪基座）
	if self.IronEnable == false then return end

	if self:GetNextSecondaryFire() <= CurTime() and not self:GetOwner():IsHolding() and self:GetReloadFinish() == 0 then
		self:SetIronsights(true)
	end
end

function SWEP:SetIronsights(b)
	b = b and true or false
	-- 状态未变化直接跳过：否则 Deploy 强制收镜等重复调用会重盖时间戳，制造一次假的退出过渡（表现为切枪瞬间放大）
	if self:GetDTBool(0) == b then return end

	self:SetDTBool(0, b)
	self.fIronTime = CurTime() -- 记录状态翻转时间戳，驱动 GetIronsightDelta 平滑过渡
	self.m_bLastIronNet = b -- 同步缓存，供 Think 检测网络侧翻转
	local hold = b and self.IronSightsHoldType or self.HoldType
	if hold then self:SetWeaponHoldType(hold) end

	if GAMEMODE then
		gamemode.Call("WeaponDeployed", self:GetOwner(), self)
	end
end

function SWEP:GetIronsights()
	return self:GetDTBool(0)
end

function SWEP:GetWalkSpeed()
	if self:GetIronsights() then
		return math.min(self.WalkSpeed, math.max(90, self.WalkSpeed * (self:GetOwner().Wooism and 0.75 or 0.5)))
	end
	return self.WalkSpeed
end

if CLIENT then
	-- [过渡进度] 持续逼近式 0~1：按真实耗时推进，与调用频率无关；单次上限 0.1 秒防卡顿瞬移
	function SWEP:GetIronsightDelta()
		if GAMEMODE.NoIronsights then return 0 end

		local st = SysTime()
		local dt = math.min(st - (self.m_fIronLastSysT or st), 0.1)
		self.m_fIronLastSysT = st

		local target = self:GetIronsights() and 1 or 0
		self.m_nIronDelta = math.Approach(self.m_nIronDelta or 0, target, dt / (self.AimDownSightsTime or 0.25))

		return self.m_nIronDelta
	end

	local OverrideIronSights = {}
	function SWEP:CheckCustomIronSights()
		local class = self:GetClass()
		if OverrideIronSights[class] then
			if type(OverrideIronSights[class]) == "table" then
				self.IronSightsPos = OverrideIronSights[class].Pos
				self.IronSightsAng = OverrideIronSights[class].Ang
			end
			return
		end

		local filename = "ironsights/" .. class .. ".txt"
		if file.Exists(filename, "MOD") then
			local content = file.Read(filename, "MOD")
			local tab = string.Explode(" ", content)
			local pos = Vector(tonumber(tab[1]) or 0, tonumber(tab[2]) or 0, tonumber(tab[3]) or 0)
			local ang = Angle(tonumber(tab[4]) or 0, tonumber(tab[5]) or 0, tonumber(tab[6]) or 0)
			OverrideIronSights[class] = {Pos = pos, Ang = ang}
			self.IronSightsPos, self.IronSightsAng = pos, ang
		else
			OverrideIronSights[class] = true
		end
	end

	-- [FOV 缩放] 基于平滑过渡进度的每武器倍率（全游戏唯一的机瞄 FOV 缩放实现）
	function SWEP:GetAimFOVMultiplier()
		local delta = self:GetIronsightDelta()
		if delta <= 0 then return 1 end

		local eased = math.ease.OutQuart(delta)
		local target
		if self.IsScoped and not GAMEMODE.DisableScopes then
			target = self.IronsightsMultiplier or 0.25
		else
			local zoom = GAMEMODE.IronsightZoomScale or 1
			target = 1 - (1 - (self.IronsightsMultiplier or 0.6)) * zoom
		end

		return Lerp(eased, 1, target)
	end

	function SWEP:TranslateFOV(fov)
		return self:GetAimFOVMultiplier() * fov
	end

	function SWEP:AdjustMouseSensitivity()
		-- 过渡期间灵敏度随 FOV 倍率同步缩放；未瞄准时返回 nil 使用引擎默认值
		if self:GetIronsightDelta() > 0 then
			return self:GetAimFOVMultiplier()
		end
	end
end

function SWEP:OnRestore()
	self:SetIronsights(false)
end
