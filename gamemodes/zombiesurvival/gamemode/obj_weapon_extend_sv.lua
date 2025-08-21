-- 本文件主要负责扩展Garry's Mod中"Weapon"（武器）对象在服务器端的功能，提供了弹药管理和模型显示控制的方法。

-- EmptyAll 将武器弹夹中的子弹全部退还给玩家，并清空弹夹。
-- HideWorldModel 隐藏武器的世界模型（对其他玩家可见的模型），主要是通过禁用其阴影实现。
-- HideViewModel 一个空的占位函数，因为隐藏视图模型（玩家第一人称视角看到的模型）是客户端操作。
local meta = FindMetaTable("Weapon")

function meta:EmptyAll(nodefaultclip)
	if self.Primary and string.lower(self.Primary.Ammo or "") ~= "none" then
		local owner = self:GetOwner()
		if owner:IsValid() then
			if self:Clip1() >= 1 then

				owner:GiveAmmo(self:Clip1(), self.Primary.Ammo, true)
			end
			if not nodefaultclip then
				owner:RemoveAmmo(self.Primary.DefaultClip, self.Primary.Ammo)
			end
		end
		self:SetClip1(0)
	end
	if self.Secondary and string.lower(self.Secondary.Ammo or "") ~= "none" then
		local owner = self:GetOwner()
		if owner:IsValid() then
			if self:Clip2() >= 1 then

				owner:GiveAmmo(self:Clip2(), self.Secondary.Ammo, true)
			end
			if not nodefaultclip then
				owner:RemoveAmmo(self.Secondary.DefaultClip, self.Secondary.Ammo)
			end
		end
		self:SetClip2(0)
	end
end

function meta:HideWorldModel()
	self:DrawShadow(false)
end

function meta:HideViewModel()
end
