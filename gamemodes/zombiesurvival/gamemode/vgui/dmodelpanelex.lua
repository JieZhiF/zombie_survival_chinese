local PANEL = {}
//描述：可能是用来显示模型的，不清楚哪里有用到
//注释状态
function PANEL:SetModel(strModelName)//设置模型
	if IsValid(self.Entity) then//如果实体有效
		self.Entity:Remove()
		self.Entity = nil
	end

	if not ClientsideModel then return end//如果没有客户端模型则返回

	self.Entity = ClientsideModel(strModelName, RENDER_GROUP_OPAQUE_ENTITY)//创建客户端模型,并设置渲染组
	if not IsValid(self.Entity) then return end//如果实体无效则返回

	self.Entity:SetNoDraw(true)//设置实体不绘制

	local iSeq = self.Entity:LookupSequence("walk")//获取实体的动作序列
	if iSeq <= 0 then iSeq = self.Entity:LookupSequence("Run1") end//如果动作序列无效则尝试获取Run1动作序列
	if iSeq <= 0 then iSeq = self.Entity:LookupSequence("walk_all") end//如果动作序列无效则尝试获取walk_all动作序列
	if iSeq <= 0 then iSeq = self.Entity:LookupSequence("WalkUnarmed_all") end//如果动作序列无效则尝试获取WalkUnarmed_all动作序列
	if iSeq <= 0 then iSeq = self.Entity:LookupSequence("walk_all_moderate") end//如果动作序列无效则尝试获取walk_all_moderate动作序列
	if iSeq > 0 then self.Entity:ResetSequence(iSeq) end//如果动作序列有效则重置动作序列
end

function PANEL:AutoCam()//这是原始AutoCam功能的修改版本，它被修改为与新的DModelPanelEx一起工作
	if IsValid(self.Entity) then//如果实体有效
		local mins, maxs = self.Entity:GetRenderBounds()//获取实体的渲染范围
		self:SetCamPos(mins:Distance(maxs) * Vector(0.75, 0.75, 0.5))//设置相机位置
		self:SetLookAt((mins + maxs) / 2)//设置相机看向的位置
	end
end

vgui.Register("DModelPanelEx", PANEL, "DModelPanel")
