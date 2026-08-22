-- ============================================================================
-- weapon_zs_buffgun.lua - 管理员Buff枪
-- 负责：管理员专属状态效果枪械：
--       右键 打开 buff 选择面板（状态 + 时长）
--       左键 发射子弹（不分敌我），命中玩家给予所选 buff
--       R 键 对自己施加所选 buff
-- ============================================================================
AddCSLuaFile()

-- 继承基础枪械母本
SWEP.Base = "weapon_zs_base"

-- 武器显示名称与描述（本地化）
SWEP.PrintName = ""..translate.Get("weapon_zs_buffgun")
SWEP.Description = ""..translate.Get("weapon_zs_buffgun_description")

-- 管理工具枪：不参与品质/改装系统
SWEP.AllowQualityWeapons = false

if CLIENT then
	-- 武器槽位：手枪槽
	SWEP.Slot = GAMEMODE:GetWeaponSlot("WeaponSelectSlotPistols")
	SWEP.SlotPos = 9
	SWEP.SlotGroup = WEPSELECT_PISTOL
	SWEP.WeaponType = "pistol"

	-- HUD 3D 展示参数
	SWEP.HUD3DBone = "v_weapon.Glock_Slide"
	SWEP.HUD3DPos = Vector(5, 0.25, -0.8)
	SWEP.HUD3DAng = Angle(90, 0, 0)
end

-- 手持姿势与模型（使用 Glock18 外观）
SWEP.HoldType = "pistol"
SWEP.ViewModel = "models/weapons/cstrike/c_pist_glock18.mdl"
SWEP.WorldModel = "models/weapons/w_pist_glock18.mdl"
SWEP.UseHands = true
SWEP.ViewModelFlip = false
-- 射击参数：0 伤害，纯 buff 弹
SWEP.Primary.Sound = Sound("Weapon_Glock.Single")
SWEP.Primary.Damage = 0
SWEP.Primary.NumShots = 1
SWEP.Primary.Delay = 0.3
SWEP.Primary.ClipSize = 1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = ""

-- 命中扩散与曳光效果
SWEP.ConeMin = 0.4
SWEP.ConeMax = 0.4
SWEP.TracerName = "tooltracer"

-- 可选状态列表（status_ 实体名 -> 菜单显示名），数组保证菜单顺序
SWEP.BuffList = {
	{ status = "freeze", label = translate.Get("Status_Frozen") },
	{ status = "frost", label = translate.Get("Status_Frost") },
	{ status = "slow", label = translate.Get("Status_Slow") },
	{ status = "burn", label = translate.Get("Status_Burning") },
	{ status = "poison", label = translate.Get("Status_Poison") },
	{ status = "bleed", label = translate.Get("Status_Bleed") },
	{ status = "stun", label = translate.Get("Status_Stun") },
	{ status = "knockdown", label = translate.Get("Status_KnockDown") },
	{ status = "sickness", label = translate.Get("Status_Sickness") },
	{ status = "enfeeble", label = translate.Get("Status_Enfeeble") },
	{ status = "frightened", label = translate.Get("Status_Tremor") },
	{ status = "dimvision", label = translate.Get("Status_DimVision") },
	{ status = "reaper", label = translate.Get("Status_Reaper") },
	{ status = "strengthdartboost", label = translate.Get("Status_Strength") },
	{ status = "adrenalineamp", label = translate.Get("Status_Adrenaline") },
	{ status = "healdartboost", label = translate.Get("Status_Speed") },
	{ status = "medrifledefboost", label = translate.Get("Status_Defence") },
	{ status = "fastreload", label = translate.Get("Status_FastReload") },
	{ status = "fastshoot", label = translate.Get("Status_FastShoot") },
	{ status = "zombie_regen", label = translate.Get("Status_ZombieRegen") },
}

-- 可选时长（秒），-1 表示永久
SWEP.BuffDurations = { 5, 10, 20, 30, 60, -1 }

-- 状态名 -> 显示名 查找表（服务端校验 + 命中消息用）
SWEP.BuffLookup = {}
for _, entry in ipairs(SWEP.BuffList) do
	SWEP.BuffLookup[entry.status] = entry.label
end

-- ==== 服务端工具函数 ====
-- 判断玩家当前是否已拥有该状态（burn 走实体火焰系统，其余走状态实体）
local function HasBuffStatus(pl, status)
	if status == "burn" then
		return pl:GetNWFloat("FireDieTime", 0) > CurTime()
	end

	local cur = pl:GetStatus(status)
	return cur ~= nil and cur:IsValid()
end

-- 施加 buff：burn/poison/bleed 有各自的施加接口，其余统一走 GiveStatus
local function ApplyBuff(target, status, duration, attacker)
	if status == "burn" then
		target:Ignite(duration)
	elseif status == "poison" then
		target:AddPoisonDamage(duration * 5, attacker)
	elseif status == "bleed" then
		target:AddBleedDamage(duration * 5, attacker)
	else
		target:GiveStatus(status, duration)
	end
end

-- ==== 服务端：接收客户端的选择请求 ====
if SERVER then
	net.Receive(NET_MSG.BUFFGUN_SELECT, function(len, pl)
		local wep = net.ReadEntity()
		local status = net.ReadString()
		local duration = net.ReadInt(8)

		if not IsValid(wep) or wep:GetClass() ~= "weapon_zs_buffgun" or wep:GetOwner() ~= pl then return end
		if not gamemode.Call("PlayerIsAdmin", pl) then return end
		if not wep.BuffLookup[status] then return end

		local valid
		for _, dur in ipairs(wep.BuffDurations) do
			if dur == duration then
				valid = true
				break
			end
		end
		if not valid then return end

		-- 保存选择（服务端权威），并同步到客户端用于面板勾选显示
		wep.BuffStatus = status
		wep.BuffDuration = duration
		wep:SetDTString(1, status)
		wep:SetDTFloat(1, duration)
	end)
end

-- ==== PrimaryAttack - 左键射击（不分敌我） ====
function SWEP:PrimaryAttack()
	local owner = self:GetOwner()

	if SERVER then
		if not gamemode.Call("PlayerIsAdmin", owner) then return end
		if not self.BuffStatus then
			owner:PrintMessage(HUD_PRINTTALK, translate.Get("buffgun_no_selection"))
			return
		end
	end

	if self:GetNextPrimaryFire() > CurTime() then return end
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

	self:ShootBullets(self.Primary.Damage, self.Primary.NumShots, self.ConeMin)
end

-- ==== BulletCallback - 子弹命中回调：对命中的玩家施加所选 buff ====
SWEP.BulletCallback = function(attacker, tr, dmginfo)
	if not SERVER then return end

	local target = tr.Entity
	if not IsValid(target) or not target:IsPlayer() or not target:Alive() then return end

	local wep = attacker:GetActiveWeapon()
	if not IsValid(wep) or not wep.BuffLookup or not wep.BuffStatus then return end
	if not gamemode.Call("PlayerIsAdmin", attacker) then return end

	ApplyBuff(target, wep.BuffStatus, wep.BuffDuration, attacker)

	-- 命中提示节流：最多每秒一条，避免按住左键刷屏
	if CurTime() >= (wep.NextHitMsg or 0) then
		wep.NextHitMsg = CurTime() + 1
		local durationText = wep.BuffDuration == -1 and translate.Get("buffgun_perm") or string.format(translate.Get("buffgun_duration_sec"), wep.BuffDuration)
		attacker:PrintMessage(HUD_PRINTTALK, translate.Format("buffgun_hit", wep.BuffLookup[wep.BuffStatus] or wep.BuffStatus, target:Name(), durationText))
	end
end

-- ==== Reload - R 键对自己施加所选 buff ====
function SWEP:Reload()
	if not SERVER then return end

	local owner = self:GetOwner()
	if not gamemode.Call("PlayerIsAdmin", owner) then return end
	if not self.BuffStatus then
		owner:PrintMessage(HUD_PRINTTALK, translate.Get("buffgun_no_selection"))
		return
	end

	-- 已拥有该状态时不重复施加，避免按住 R 键反复弹提示
	if HasBuffStatus(owner, self.BuffStatus) then return end
	if CurTime() < (self.NextSelfBuff or 0) then return end
	self.NextSelfBuff = CurTime() + 1

	ApplyBuff(owner, self.BuffStatus, self.BuffDuration, owner)
	owner:PrintMessage(HUD_PRINTTALK, translate.Get("buffgun_self_applied"))
end

-- ==== SecondaryAttack - 右键打开 buff 选择面板（服务端空实现，避免触发机瞄） ====
function SWEP:SecondaryAttack()
	if not CLIENT then return end

	self:OpenBuffMenu()
end

-- ============================================================================
-- 客户端 buff 选择面板（ZSBuffGunMenu）
-- ============================================================================
-- 区域地图（VGUI 四字段）
-- [区域] 主窗口
-- [位置] SecondaryAttack() / PANEL:Init()
-- [作用] 创建屏幕居中的圆角窗口，持有武器引用并管理关闭
-- [常改] 窗口尺寸、背景、边框、标题
--
-- [区域] 状态列表
-- [位置] PANEL:Init() / PANEL:SelectStatus()
-- [作用] 展示全部可选状态，点击选中并高亮当前项
-- [常改] 行高、颜色、字号、滚动列表宽高
--
-- [区域] 时长按钮
-- [位置] PANEL:Init() / PANEL:ApplyDuration()
-- [作用] 为选中状态选择时长（含永久），点击后发送给服务端
-- [常改] 按钮尺寸、时长列表、点击后是否关闭
--
-- [区域] 当前选择
-- [位置] PANEL:RefreshHighlight()
-- [作用] 底部显示已选状态与时长，随选择实时更新
-- [常改] 文案格式、字体、位置
-- ============================================================================
if CLIENT then
	local BuffMenuPanel

	local PANEL = {}

	-- ==== Init - 构建面板控件 ====
	function PANEL:Init()
		self:SetTitle(translate.Get("weapon_zs_buffgun"))
		self.lblTitle:SetFont("BarrierFont")
		self:SetSize(560, 560)

		-- 屏幕居中
		self:SetPos((ScrW() - self:GetWide()) / 2, (ScrH() - self:GetTall()) / 2)

		-- 状态列表（左侧，可滚动）
		self.StatusList = vgui.Create("DScrollPanel", self)
		self.StatusList:SetPos(10, 44)
		self.StatusList:SetSize(300, 440)

		-- 时长面板（右侧）
		self.DurationPanel = vgui.Create("DPanel", self)
		self.DurationPanel:SetPos(320, 44)
		self.DurationPanel:SetSize(230, 440)
		self.DurationPanel.Paint = function() end

		local title = vgui.Create("DLabel", self.DurationPanel)
		title:SetFont("zs_wortharsenal")
		title:SetText(translate.Get("buffgun_duration_title"))
		title:SetPos(10, 4)
		title:SizeToContents()

		-- 当前选择显示（底部）
		self.SelectionLabel = vgui.Create("DLabel", self)
		self.SelectionLabel:SetFont("zs_wortharsenal")
		self.SelectionLabel:SetPos(10, 500)
		self.SelectionLabel:SetSize(540, 40)
	end

	-- ==== SetWeapon - 绑定武器并构建状态/时长按钮 ====
	function PANEL:SetWeapon(wep)
		self.Weapon = wep
		self.SelectedStatus = ""
		self.SelectedDuration = 0

		self.StatusButtons = {}
		local y = 0
		for _, entry in ipairs(wep.BuffList) do
			local btn = vgui.Create("DButton", self.StatusList)
			btn:SetText("")
			btn:SetSize(290, 32)
			btn:SetPos(5, y)
			btn.Entry = entry
			btn.DoClick = function(me)
				self:SelectStatus(me.Entry.status)
			end
			btn.Paint = function(me, w, h)
				local col = Color(45, 50, 62, 230)
				if me:IsHovered() then
					col = Color(70, 90, 130, 240)
				end
				if me.Selected then
					col = Color(0, 110, 200, 240)
				end
				draw.RoundedBox(4, 0, 0, w, h, col)
				draw.SimpleText(me.Entry.label, "zs_wortharsenal", 14, h / 2, Color(240, 240, 240), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			end
			table.insert(self.StatusButtons, btn)
			y = y + 37
		end

		self.DurationButtons = {}
		local dy = 36
		for _, dur in ipairs(wep.BuffDurations) do
			local dtext = dur == -1 and translate.Get("buffgun_perm") or string.format(translate.Get("buffgun_duration_sec"), dur)
			local btn = vgui.Create("DButton", self.DurationPanel)
			btn:SetText("")
			btn:SetSize(210, 38)
			btn:SetPos(10, dy)
			btn.Duration = dur
			btn.DoClick = function(me)
				self:ApplyDuration(me.Duration)
			end
			btn.Paint = function(me, w, h)
				local col = Color(45, 50, 62, 230)
				if me:IsHovered() then
					col = Color(70, 90, 130, 240)
				end
				if me.Selected then
					col = Color(0, 160, 90, 240)
				end
				draw.RoundedBox(4, 0, 0, w, h, col)
				draw.SimpleText(dtext, "zs_wortharsenal", w / 2, h / 2, Color(240, 240, 240), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
			table.insert(self.DurationButtons, btn)
			dy = dy + 46
		end

		-- 从服务端同步的选择初始化勾选
		self:SelectStatus(wep:GetDTString(1), true)
		if self.SelectedStatus ~= "" then
			self.SelectedDuration = wep:GetDTFloat(1)
		end
		self:RefreshHighlight()
	end

	-- ==== SelectStatus - 选中状态并刷新高亮 ====
	function PANEL:SelectStatus(status, silent)
		self.SelectedStatus = status
		if not silent then
			self.SelectedDuration = 0
		end
		self:RefreshHighlight()
	end

	-- ==== ApplyDuration - 选中时长并发送给服务端 ====
	function PANEL:ApplyDuration(duration)
		if self.SelectedStatus == "" then return end

		self.SelectedDuration = duration
		self:RefreshHighlight()

		net.Start(NET_MSG.BUFFGUN_SELECT)
			net.WriteEntity(self.Weapon)
			net.WriteString(self.SelectedStatus)
			net.WriteInt(duration, 8)
		net.SendToServer()

		self:Close()
	end

	-- ==== RefreshHighlight - 刷新状态/时长按钮高亮与底部文字 ====
	function PANEL:RefreshHighlight()
		local wep = self.Weapon
		for _, btn in ipairs(self.StatusButtons) do
			btn.Selected = btn.Entry.status == self.SelectedStatus
		end
		for _, btn in ipairs(self.DurationButtons) do
			btn.Selected = btn.Duration == self.SelectedDuration
		end

		local text = translate.Get("buffgun_none")
		if self.SelectedStatus ~= "" and wep and wep.BuffLookup then
			local dtext = self.SelectedDuration == -1 and translate.Get("buffgun_perm") or (self.SelectedDuration > 0 and string.format(translate.Get("buffgun_duration_sec"), self.SelectedDuration) or translate.Get("buffgun_pick_duration"))
			text = translate.Format("buffgun_current", wep.BuffLookup[self.SelectedStatus] or self.SelectedStatus, dtext)
		end
		self.SelectionLabel:SetText(text)
	end

	-- ==== OnClose - 关闭时清理实例引用 ====
	function PANEL:OnClose()
		BuffMenuPanel = nil
		self:Remove()
	end

	-- ==== Paint - 背景与边框 ====
	function PANEL:Paint(w, h)
		draw.RoundedBoxEx(8, 0, 0, w, h, Color(12, 16, 26, 235), true, true, true, true)
		surface.SetDrawColor(0, 150, 255, 130)
		surface.DrawOutlinedRect(1, 1, w - 2, h - 2)
	end

	vgui.Register("ZSBuffGunMenu", PANEL, "DEXRoundedFrame")

	-- ==== OpenBuffMenu - 创建/复用 buff 选择面板 ====
	function SWEP:OpenBuffMenu()
		if not gamemode.Call("PlayerIsAdmin", LocalPlayer()) then return end

		if BuffMenuPanel and BuffMenuPanel:IsValid() then
			BuffMenuPanel:Remove()
		end
		BuffMenuPanel = vgui.Create("ZSBuffGunMenu")
		BuffMenuPanel:MakePopup()
		BuffMenuPanel:SetWeapon(self)
	end
end
