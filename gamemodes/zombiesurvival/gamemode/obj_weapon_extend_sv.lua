-- ============================================================
-- 文件: obj_weapon_extend_sv.lua
-- 作用: 服务端脚本
-- 功能: 扩展武器(Weapon)对象的服务端功能
--       提供弹药清空退还及模型显示控制方法
-- ============================================================

-- 以下是本文件所有扩展函数的简要说明：
-- EmptyAll —— 将武器弹夹中的子弹全部退还给玩家，并清空弹夹
-- HideWorldModel —— 隐藏武器世界模型（禁用阴影渲染）
-- HideViewModel —— 空函数占位（视图模型隐藏是客户端操作，服务端无需处理）

-- 获取武器对象的 Lua 元表
local meta = FindMetaTable("Weapon")

-- ============================================================
-- 清空弹夹并退还子弹
-- 将弹夹内的子弹归还给玩家作为备弹，同时可选移除默认弹夹容量对应的备弹
-- nodefaultclip: 若为 true，则不扣除默认弹夹对应的备弹
-- ============================================================
function meta:EmptyAll(nodefaultclip)
	-- 处理主弹药：检查主弹药类型是否有效
	if self.Primary and string.lower(self.Primary.Ammo or "") ~= "none" then
		-- 获取武器持有者
		local owner = self:GetOwner()
		-- 验证持有者有效
		if owner:IsValid() then
			-- 如果弹夹内至少有一颗子弹，则将其退还为备弹
			if self:Clip1() >= 1 then
				owner:GiveAmmo(self:Clip1(), self.Primary.Ammo, true)
			end
			-- 如果不是 "无默认弹夹" 模式，则从备弹中扣除默认弹夹容量
			if not nodefaultclip then
				owner:RemoveAmmo(self.Primary.DefaultClip, self.Primary.Ammo)
			end
		end
		-- 将弹夹清空
		self:SetClip1(0)
	end
	-- 处理副弹药：检查副弹药类型是否有效
	if self.Secondary and string.lower(self.Secondary.Ammo or "") ~= "none" then
		-- 获取武器持有者
		local owner = self:GetOwner()
		-- 验证持有者有效
		if owner:IsValid() then
			-- 如果弹夹内至少有一颗子弹，则将其退还为备弹
			if self:Clip2() >= 1 then
				owner:GiveAmmo(self:Clip2(), self.Secondary.Ammo, true)
			end
			-- 如果不是 "无默认弹夹" 模式，则从备弹中扣除默认弹夹容量
			if not nodefaultclip then
				owner:RemoveAmmo(self.Secondary.DefaultClip, self.Secondary.Ammo)
			end
		end
		-- 将弹夹清空
		self:SetClip2(0)
	end
end

-- ============================================================
-- 隐藏武器世界模型（服务端版本）
-- 通过禁用阴影来减少世界模型的可见性影响
-- 客户端的完整隐藏请参见 obj_weapon_extend_cl.lua
-- ============================================================
function meta:HideWorldModel()
	-- 禁用武器的阴影渲染
	self:DrawShadow(false)
end

-- ============================================================
-- 隐藏武器视图模型（服务端占位）
-- 视图模型的隐藏是纯客户端操作，服务端无需实现
-- 此处为空函数，仅为保证方法存在以避免调用错误
-- 实际隐藏逻辑在 obj_weapon_extend_cl.lua 中
-- ============================================================
function meta:HideViewModel()
end
