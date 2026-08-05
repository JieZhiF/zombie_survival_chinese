-- ============================================================================
-- weapon_zs_arsenalcrate/cl_init.lua - 军械箱部署武器（客户端部分）
-- 负责：栏位与准星设置；右键/换弹键旋转放置预览方向，并控制旋转音效
-- ============================================================================
INC_CLIENT() -- 客户端专用文件标记

SWEP.DrawCrosshair = false -- 不绘制准星（用屏幕中心点代替）


-- 武器栏位：放入"可部署物品"分类
SWEP.Slot = GAMEMODE:GetWeaponSlot("WeaponSelectSlotDeployables")
-- 栏位组：可部署物品栏
SWEP.SlotGroup = WEPSELECT_DEPLOYABLES
-- 武器在栏位中的位置序号
SWEP.SlotPos = 0

-- ==== DrawHUD - 绘制 HUD 准星 ====
-- 仅当玩家开启了准星设置时，绘制屏幕中心的放置落点指示点
function SWEP:DrawHUD()
	if GetConVar("crosshair"):GetInt() ~= 1 then return end
	self:DrawCrosshairDot()
end

-- ==== PrimaryAttack - 左键（空实现） ====
-- 放置逻辑由服务器端处理
function SWEP:PrimaryAttack()
end

-- ==== DrawWeaponSelection - 武器选择界面图标 ====
-- 使用基础武器母本的默认绘制
function SWEP:DrawWeaponSelection(x, y, w, h, alpha)
	self:BaseDrawWeaponSelection(x, y, w, h, alpha)
end

-- ==== Think - 思考帧：旋转放置预览方向 ====
-- 按住右键顺时针旋转预览，按住换弹键逆时针旋转
function SWEP:Think()
	if self:GetOwner():KeyDown(IN_ATTACK2) then
		self:RotateGhost(FrameTime() * 60) -- 顺时针旋转
	end
	if self:GetOwner():KeyDown(IN_RELOAD) then
		self:RotateGhost(FrameTime() * -60) -- 逆时针旋转
	end
end

-- ==== Deploy - 武器展开时 ====
-- 通知游戏模式部署事件
function SWEP:Deploy()
	gamemode.Call("WeaponDeployed", self:GetOwner(), self)

	return true
end

local nextclick = 0 -- 旋转音效的节流计时
-- ==== RotateGhost - 旋转放置预览并播放音效 ====
-- 通过控制台命令把新的旋转角度发给服务器，旋转时播放提示音
function SWEP:RotateGhost(amount)
	-- 音效节流：每 0.3 秒最多播放一次
	if nextclick <= RealTime() then
		surface.PlaySound("npc/headcrab_poison/ph_step4.wav")
		nextclick = RealTime() + 0.3
	end

	-- 累加旋转角度并归一化后发送给服务器
	RunConsoleCommand("_zs_ghostrotation", math.NormalizeAngle(GetConVar("_zs_ghostrotation"):GetFloat() + amount))
end
