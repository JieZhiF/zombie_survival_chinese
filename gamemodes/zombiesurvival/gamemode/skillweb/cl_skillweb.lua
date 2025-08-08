local draw_SimpleText = draw.SimpleText
local render_SetBlend = render.SetBlend
local render_DrawBeam = render.DrawBeam
local render_ModelMaterialOverride = render.ModelMaterialOverride
local render_SetColorModulation = render.SetColorModulation
local render_SuppressEngineLighting = render.SuppressEngineLighting 

net.Receive("zs_skills_notify", function(length)
	if GAMEMODE.SkillWeb then
		GAMEMODE.SkillWeb:DisplayMessage(net.ReadString(), net.ReadBool() and COLOR_RED or COLOR_GREEN)
	end
end)

net.Receive("zs_skill_is_desired", function(length)
	local skillid = net.ReadUInt(16)
	local yesno = net.ReadBool()
	
	if MySelf:IsValid() then
		MySelf:SetSkillDesired(skillid, yesno)
		
		if GAMEMODE.SkillWeb and GAMEMODE.SkillWeb:IsValid() then
			surface.PlaySound("zombiesurvival/ui/misc" .. (yesno and 2 or 1) .. ".ogg")
			GAMEMODE.SkillWeb:UpdateQuickStats()
		end
	end
end)

net.Receive("zs_skill_is_unlocked", function(length)
	local skillid = net.ReadUInt(16)
	local yesno = net.ReadBool()
	
	if MySelf:IsValid() then
		MySelf:SetSkillUnlocked(skillid, yesno)
	end
end)

net.Receive("zs_skills_active", function(length)
	local t = {}
	
	for skillid in pairs(GAMEMODE.Skills) do
		if net.ReadBool() then
			t[skillid] = true
		end
	end
	
	if MySelf:IsValid() then
		MySelf:ApplySkills(t)
	end
end)

net.Receive("zs_skills_init", function(length)
	GAMEMODE.ReceivedInitialSkills = true
	
	local unlocked = {}
	local desired = {}
	local active = {}
	
	for skillid in pairs(GAMEMODE.Skills) do
		if net.ReadBool() then
			unlocked[skillid] = true
		end
	end
	
	for skillid in pairs(GAMEMODE.Skills) do
		if net.ReadBool() then
			desired[skillid] = true
		end
	end
	
	if net.ReadBool() then
		for skillid in pairs(GAMEMODE.Skills) do
			if net.ReadBool() then
				active[skillid] = true
			end
		end
	end
	
	if MySelf:IsValid() then
		MySelf:SetUnlockedSkills(unlocked)
		MySelf:SetDesiredActiveSkills(desired)
		MySelf:ApplySkills(active)
	end
end)

net.Receive("zs_skills_desired", function(length)
	local t = {}
	
	for skillid in pairs(GAMEMODE.Skills) do
		if net.ReadBool() then
			t[#t + 1] = skillid
		end
	end
	
	if MySelf:IsValid() then
		MySelf:SetDesiredActiveSkills(t)
	end
	
	if GAMEMODE.SkillWeb and GAMEMODE.SkillWeb:IsValid() then
		GAMEMODE.SkillWeb:UpdateQuickStats()
	end
end)

net.Receive("zs_skills_unlocked", function(length)
	local t = {}
	
	for skillid in pairs(GAMEMODE.Skills) do
		if net.ReadBool() then
			t[#t + 1] = skillid
		end
	end
	
	if MySelf:IsValid() then
		MySelf:SetUnlockedSkills(t)
	end
end)


net.Receive("zs_skills_nextreset", function(length)
    GAMEMODE.NextSkillReset = net.ReadUInt(32)

    if GAMEMODE.SkillWeb and GAMEMODE.SkillWeb:IsValid() then
        local days = math.floor(GAMEMODE.NextSkillReset / 3600)
        local btn = GAMEMODE.SkillWeb.Reset

        local buttonText = GAMEMODE.NextSkillReset <= 0 and ""..translate.Get("Skill_ui_reset") or (""..translate.Get("Skill_ui_reset_daysleft").." "..days)
        btn:SetText(buttonText)
        btn:SetDisabled(GAMEMODE.NextSkillReset > 0)
    end
end)

GM.SavedSkillLoadouts = {}

hook.Add("Initialize", "LoadSkillLoadouts", function()
	if file.Exists(GAMEMODE.SkillLoadoutsFile, "DATA") then
		GAMEMODE.SavedSkillLoadouts = Deserialize(file.Read(GAMEMODE.SkillLoadoutsFile)) or {}
	end
end)

local function UpdateDropDown(dropdown)  
	dropdown:Clear()
	for i, cart in ipairs(GAMEMODE.SavedSkillLoadouts) do
		dropdown:AddChoice(cart[1])
	end
end

local function SaveSkillLoadout(name)
	for i, cart in ipairs(GAMEMODE.SavedSkillLoadouts) do
		if string.lower(cart[1]) == string.lower(name) then
			cart[1] = name
			cart[2] = MySelf:GetDesiredActiveSkills()

			file.Write(GAMEMODE.SkillLoadoutsFile, Serialize(GAMEMODE.SavedSkillLoadouts))
			return
		end
	end

	GAMEMODE.SavedSkillLoadouts[#GAMEMODE.SavedSkillLoadouts + 1] = {name, MySelf:GetDesiredActiveSkills()}
	file.Write(GAMEMODE.SkillLoadoutsFile, Serialize(GAMEMODE.SavedSkillLoadouts))
end


function GM:GenerateFromSkillWebGrid()
	local mat = Material("zombiesurvival/skillwebgrid.png")
	local w, h = mat:Width(), mat:Height()
	local prelines = {}
	local lines = {}
	local col
	
	for y = 1, h do
		for x = 1, w do
			col = mat:GetColor(x - 1, y - 1)
			
			if col.r ~= 255 or col.g ~= 255 or col.b ~= 255 then
				local id = col.r + col.g * 255 + col.b * 65052
				local lx, ly = math.ceil(x - w / 2), math.floor(y - h / 2)
				
				if lines[id] then
					print(string.format("-- WARNING: Skill ID %d already exists (pixel %d, %d)", id, x, y))
				end
				
				prelines[id] = string.format("SKILL_%d = %d",  id,  id  )  lines[id] = string.format(  "GM:AddSkill(SKILL_%d, \"\", \"\",\n%s%d,%s%d,%s{})",  id,  string.rep("\t", 16),  lx,  string.rep("\t", 3),  ly,  string.rep("\t", 3)  )
			end
		end
	end
	
	print(table.concat(prelines, "\n"))
	print("")  print(table.concat(lines, "\n"))
end

local hoveredskill
local REMORT_SKILL = {Name = ""..translate.Get("Skill_Remort"), Description = ""..translate.Get("Skill_Remort_Description")}

local TREE_SKILLS = {
	[TREE_BUILDINGTREE] = {Name = translate.Get("Skill_BuildingTree"), Description = translate.Get("Skill_BuildingTree_desc")},
	[TREE_HEALTHTREE] = {Name = translate.Get("Skill_HealthTree"), Description = translate.Get("Skill_HealthTree_desc")},
	[TREE_GUNTREE] = {Name = translate.Get("Skill_GunTree"), Description = translate.Get("Skill_GunTree_desc")},
	[TREE_SPEEDTREE] = {Name = translate.Get("Skill_SpeedTree"), Description = translate.Get("Skill_SpeedTree_desc")},
	[TREE_MELEETREE] = {Name = translate.Get("Skill_MeleeTree"), Description = translate.Get("Skill_MeleeTree_desc")},
	[TREE_SUPPORTTREE] = {Name = translate.Get("Skill_SupportTree"), Description = translate.Get("Skill_SupportTree_desc")}
}

local PANEL = {}
local exlude = {8,6,16,22,27,30,31,34,118,114,113,101,40,41,43,92,117,116,56,59,63,65,66,98,72,73,79,88,78,120,57,58,124,125,128}
local exlude2 = {121,122,32,108,103,91,90}
AccessorFunc( PANEL, "vCamPos", "CamPos" )
AccessorFunc( PANEL, "fFOV", "FOV" )
AccessorFunc( PANEL, "vLookatPos", "LookAt" )
AccessorFunc( PANEL, "aLookAngle", "LookAng" )
AccessorFunc( PANEL, "colAmbientLight", "AmbientLight" )

PANEL.CreationTime = 0
PANEL.DesiredZoom = 5000
PANEL.ZoomChange = 0
PANEL.DesiredTree = 0
PANEL.ShadeAlpha = 0
PANEL.ShadeVelocity = 0

local offsets = {
	[TREE_HEALTHTREE] = {0, 169},
	[TREE_SPEEDTREE] = {0, -12},
	[TREE_GUNTREE] = {13, -7},
	[TREE_MELEETREE] = {13, 8},
	[TREE_BUILDINGTREE] = {-14, 8},
	[TREE_SUPPORTTREE] = {-13, -7}
}

local node_models = {
	[TREE_HEALTHTREE] = "models/Items/ammocrate_ar2.mdl",
	[TREE_SPEEDTREE] = "models/props_junk/Shoe001a.mdl",
	[TREE_GUNTREE] = "models/weapons/w_smg1.mdl",
	[TREE_MELEETREE] = "models/props/cs_militia/axe.mdl",
	[TREE_BUILDINGTREE] = "models/weapons/w_hammer.mdl",
	[TREE_SUPPORTTREE] = "models/weapons/w_medkit.mdl"
}
local node_scale = {
	[TREE_HEALTHTREE] = "2",
	[TREE_SPEEDTREE] = "5",
	[TREE_GUNTREE] = "4",
	[TREE_MELEETREE] = "3",
	[TREE_BUILDINGTREE] = "2",
	[TREE_SUPPORTTREE] = "2"
}



local function ActivateSkill(self, skill) 
	local name = GAMEMODE.Skills[skill].Name
		net.Start("zs_skill_is_desired")
		net.WriteUInt(skill, 16)
		net.WriteBool(true)
	net.SendToServer()

	self:DisplayMessage(name..translate.Get("Skill_ui_activate"))

end
local function DeactivateSkill(self, skill) 
	local name = GAMEMODE.Skills[skill].Name
		net.Start("zs_skill_is_desired")
		net.WriteUInt(skill, 16)
		net.WriteBool(false)
	net.SendToServer()

	self:DisplayMessage(name..translate.Get("Skill_ui_deactivate"))

end
local function UnlockSkill(self, skill) 
	local name = GAMEMODE.Skills[skill].Name
	net.Start("zs_skill_is_unlocked")
	net.WriteUInt(skill, 16)
	net.WriteBool(true)
	net.SendToServer()
	
	self:DisplayMessage(name..translate.Get("Skill_ui_unlock"), COLOR_GREEN)

end
function PANEL:Init()
	local allskills = GAMEMODE.Skills
	local node
	
	self.LastPaint = RealTime()
	self.DirectionalLight = {}
	self.FarZ = 32000
	self:SetCamPos( Vector( 15000, 0, 0 ) )
	self:SetLookAt( Vector( 0, 0, 0 ) )
	self:SetFOV(6)
	self:SetAmbientLight( Color( 50, 50, 50 ) )
	self:SetDirectionalLight( BOX_TOP, color_white )
	self:SetDirectionalLight( BOX_FRONT, color_white )
	self.SkillNodes = {}
	
	for i = 0, #TREE_SKILLS do
		self.SkillNodes[i] = {}
	end
	
	for id, skill in pairs(allskills) do
		if not skill.Trinket then
			node = ClientsideModel("models/dav0r/hoverball.mdl", RENDER_GROUP_OPAQUE_ENTITY)
			
			if IsValid(node) then
				node:SetNoDraw(true)
				node:SetPos(Vector(0, skill.x * 20, skill.y * 20))
				
				if skill.Disabled then
					node:SetModelScale(0.44, 0)
				else
					node:SetModelScale(0.57, 0)
				end
				
				node.Skill = skill
				node.SkillID = id
				self.SkillNodes[skill.Tree][id] = node
			end
		end
	end
	
	node = ClientsideModel("models/Gibs/HGIBS.mdl", RENDER_GROUP_OPAQUE_ENTITY)
	
	if IsValid(node) then
		node:SetNoDraw(true)
		node:SetPos(Vector(0, 0, 10))
		node:SetModelScale(1.5, 0)   
		node.Skill = REMORT_SKILL  
		node.SkillID = -1  
		self.SkillNodes[0][-1] = node  
	end
	
	for tree, treenode in pairs(TREE_SKILLS) do
		node = ClientsideModel("models/Gibs/HGIBS.mdl", RENDER_GROUP_OPAQUE_ENTITY)
		
		if IsValid(node) then
			local rads = (2*math.pi)*((tree-1)/#TREE_SKILLS)
			
			node:SetNoDraw(true)
			node:SetPos(Vector(0, math.sin(rads) * 70, math.cos(rads) * 70 + 10))
			node:SetAngles(Angle(0, 0, -rads * 180/math.pi))
			node:SetModelScale(5, 0)
			
			
			--node:SetModel(node_models[tree])
			node.Skill = treenode
			node.SkillID = -tree - 1
			self.SkillNodes[0][node.SkillID] = node
		end
	end
	
	local top = vgui.Create("Panel", self)  top:SetSize(ScrW(), 256)
	
	top:SetMouseInputEnabled(false)
	local skillname = vgui.Create("DLabel", top)
	skillname:SetFont("ZSHUDFont")
	skillname:SetTextColor(COLOR_WHITE)
	skillname:SetContentAlignment(8)
	skillname:Dock(TOP)
	
	local desc = {}
	
	for i=1, 5 do
		local skilldesc = vgui.Create("DLabel", top)
		skilldesc:SetFont("ZSHUDFontSmall")
		skilldesc:SetTextColor(COLOR_GRAY)
		skilldesc:SetContentAlignment(8)
		skilldesc:Dock(TOP)
		
		table.insert(desc, skilldesc)
	end
	
	local screenscale = BetterScreenScale()
	local bottomleft = vgui.Create("DEXRoundedPanel", self)
	
	bottomleft:DockPadding(10, 10, 10, 10)
	bottomleft:SetSize(190 * screenscale, 130 * screenscale)
	
	local bottomleftup = vgui.Create("DEXRoundedPanel", self)
	
	bottomleftup:DockPadding(10, 10, 10, 10)
	bottomleftup:SetSize(190 * screenscale, 120 * screenscale)
	
	local quickstats = {}
	
	for i=1,4 do
		local hpstat = vgui.Create("DLabel", bottomleftup)
		hpstat:SetFont("ZSHUDFontSmallest")
		hpstat:SetTextColor(COLOR_WHITE)
		hpstat:SetContentAlignment(8)
		hpstat:Dock(TOP)
		hpstat:SizeToContents()
		hpstat:SetText("---")
		
		table.insert(quickstats, hpstat)
	end
	
	local dropdown = vgui.Create("DComboBox", bottomleft)
	dropdown:Dock(TOP)
	dropdown:SetMouseInputEnabled(true)
	dropdown:SetTextColor(color_black)
	
	local delbtn = vgui.Create("DButton", bottomleft)
	delbtn:SetFont("ZSHUDFontSmallest")
	delbtn:SetText(translate.Get("Skill_ui_delete"))
	delbtn:SizeToContents()
	delbtn:SetTall(bottomleft:GetTall() / 5)
	delbtn:Dock(BOTTOM)
	delbtn.DoClick = function(me)
		surface.PlaySound("zombiesurvival/ui/misc1.ogg")
		
		local delloadout
		
		for k, v in pairs(GAMEMODE.SavedSkillLoadouts) do
			if v[1] == dropdown:GetSelected() then
				delloadout = k
				
				break
			end
		end
		
		if not delloadout then return end
		
		table.remove(GAMEMODE.SavedSkillLoadouts, delloadout)
		
		file.Write(GAMEMODE.SkillLoadoutsFile, Serialize(GAMEMODE.SavedSkillLoadouts))
		
		surface.PlaySound("buttons/button19.wav")
		
		UpdateDropDown(dropdown)
	end
	
	local savebtn = vgui.Create("DButton", bottomleft)
	savebtn:SetFont("ZSHUDFontSmallest")
	savebtn:SetText(translate.Get("Skill_ui_save"))
	savebtn:SizeToContents()
	savebtn:SetTall(bottomleft:GetTall() / 5)
	savebtn:Dock(BOTTOM)
	savebtn.DoClick = function(me)
		surface.PlaySound("zombiesurvival/ui/misc1.ogg")
	
		local frame = Derma_StringRequest(translate.Get("Skill_ui_save_title"), translate.Get("Skill_ui_save_prompt"), "Name",
		function(strTextOut)
			SaveSkillLoadout(strTextOut)
			UpdateDropDown(dropdown)
	
			self:DisplayMessage(translate.Format("Skill_ui_save_success", strTextOut), COLOR_GREEN)
		end,
		function(strTextOut) end,
		translate.Get("Skill_ui_ok"), translate.Get("Skill_ui_cancel"))
	
		frame:GetChildren()[5]:GetChildren()[2]:SetTextColor(Color(30, 30, 30))
	end
	
	UpdateDropDown(dropdown)
	
	local loadbtn = vgui.Create("DButton", bottomleft)
	loadbtn:SetFont("ZSHUDFontSmallest")
	loadbtn:SetText(translate.Get("Skill_ui_load"))

	loadbtn:SizeToContents()
	loadbtn:SetTall(bottomleft:GetTall() / 5)
	loadbtn:Dock(BOTTOM)
	loadbtn.DoClick = function(me)
		surface.PlaySound("zombiesurvival/ui/misc1.ogg")

		local newloadout, nlname
		for _, v in pairs(GAMEMODE.SavedSkillLoadouts) do
			if v[1] == dropdown:GetSelected() then
				newloadout = v[2]
				nlname = v[1]
				break
			end
		end

		if not newloadout then return end

		net.Start("zs_skill_set_desired")
			net.WriteTable(newloadout)		
		net.SendToServer()

		self:DisplayMessage(translate.Format("Skill_ui_load_success", nlname), COLOR_GREEN)

	end

	local bottomlefttop = vgui.Create("DEXRoundedPanel", self)
	bottomlefttop:DockPadding(10, 10, 10, 10)
	bottomlefttop:SetSize(160 * screenscale, 130 * screenscale)
	
	local activateall = vgui.Create("DButton", bottomlefttop)
	activateall:SetFont("ZSHUDFontSmallest")
	activateall:SetText(translate.Get("Skill_ui_activate_all"))
	activateall:SizeToContents()
	activateall:SetTall(activateall:GetTall())
	activateall:Dock(TOP)
	activateall.DoClick = function(me)
		surface.PlaySound("zombiesurvival/ui/misc1.ogg")
	
		if #MySelf:GetUnlockedSkills() == 0 then
			self:DisplayMessage(translate.Get("Skill_ui_no_skills"), COLOR_RED)
		else
			self:DisplayMessage(translate.Get("Skill_ui_all_activated"), COLOR_GREEN)
		end
	
		net.Start("zs_skills_all_desired")
			net.WriteBool(true)
		net.SendToServer()
	end
	
	
	local deactivateall = vgui.Create("DButton", bottomlefttop)
	deactivateall:SetFont("ZSHUDFontSmallest")
	deactivateall:SetText(translate.Get("Skill_ui_deactivate_all"))
	deactivateall:SizeToContents()
	deactivateall:SetTall(deactivateall:GetTall())
	deactivateall:DockMargin(0, 5, 0, 0)
	deactivateall:Dock(TOP)
	deactivateall.DoClick = function(me)
		surface.PlaySound("zombiesurvival/ui/misc1.ogg")
	
		if #MySelf:GetUnlockedSkills() == 0 then
			self:DisplayMessage(translate.Get("Skill_ui_no_skills"), COLOR_RED)
		else
			self:DisplayMessage(translate.Get("Skill_ui_all_deactivated"), COLOR_RED)
		end
	
		net.Start("zs_skills_all_desired")
			net.WriteBool(false)
		net.SendToServer()
	end
	
	local resettime = GAMEMODE.NextSkillReset or 0
	local hours = math.floor(resettime / 3600)

	local reset = vgui.Create("DButton", bottomlefttop)
	reset:SetFont("ZSHUDFontSmaller")
	reset:SetText(resettime <= 0 and translate.Get("Skill_ui_reset") or (translate.Get("Skill_ui_reset_daysleft")..""..hours))
	reset:SetDisabled(resettime > 0)
	reset:SizeToContents()
	reset:SetTall(reset:GetTall())
	reset:DockMargin(0, 5, 0, 0)
	reset:Dock(TOP)
	reset.DoClick = function(me)
		Derma_Query(
			translate.Get("Skill_ui_reset_confirm"), 
			translate.Get("Skill_ui_warning"),
			translate.Get("Skill_ui_ok"),
			function() net.Start("zs_skills_reset") net.SendToServer() end,
			translate.Get("Skill_ui_cancel"),
			function() end
		)
	end
	
		
	local topright = vgui.Create("DEXRoundedPanel", self)
	topright:SetSize(160 * screenscale, 64 * screenscale)
	topright:DockPadding(10, 10, 10, 10)
	
	local quit = vgui.Create("DButton", topright)
	quit:SetText(translate.Get("Skill_ui_quit"))  
	quit:SetFont("ZSHUDFont")
	quit:Dock(FILL)
	quit.DoClick = function()
		if self.DesiredTree == 0 then
			self:Remove()
		else
			self.DesiredTree = 0
			self.DesiredZoom = 2500
			self.ShadeVelocity = 255 * FrameTime() * 10
			
			timer.Simple(0.1, function()
				if not IsValid(self) then return end
				
				self.DesiredZoom = 5000
				self.DesiredTree = 0
				self.ShadeVelocity = 255 * FrameTime() * -10
				
				local campos = self:GetCamPos()
				campos.y = 0
				campos.z = 0
				self:SetCamPos(campos)
			end)
			
			MySelf:EmitSound("buttons/button24.wav", 60, 180)
		end
	end
	
	local bottom = vgui.Create("DEXRoundedPanel", self)
	bottom:SetSize(600 * screenscale, math.Clamp(84 * screenscale, 70, 125))
	bottom:DockPadding(10, 10, 10, 10)
	
	local spremaining = vgui.Create("DEXChangingLabel", bottom)
	spremaining:SetChangeFunction(function()
		return translate.Get("Skill_ui_unused_points") .. MySelf:GetZSSPRemaining()
	end, true)
	
	spremaining:SetChangedFunction(function()
		if MySelf:GetZSSPRemaining() >= 1 then
			spremaining:SetTextColor(COLOR_GRAY)
		else
			spremaining:SetTextColor(COLOR_RED)
		end
	end)
	
	spremaining:SetFont("ZSHUDFontSmall")
	spremaining:SetContentAlignment(5)
	spremaining:Dock(TOP)
	
	local expbar = vgui.Create("Panel", bottom)
	expbar.Paint = function(me, w, h)
		GAMEMODE:DrawXPBar(0, 2 - screenscale * 2, w, h, w, 1, 0.95, MySelf:GetZSLevel())
	end
	
	expbar:SetContentAlignment(5)
	expbar:Dock(BOTTOM)
	
	local contextmenu = vgui.Create("Panel", self)
	contextmenu:SetSize(128 * screenscale, 128 * screenscale)
	contextmenu:SetVisible(false)
	
	local button = vgui.Create("DButton", contextmenu)
	button:SetText(translate.Get("Skill_ui_activate"))
	button:SetFont("ZSHUDFontSmall")
	button:SetDisabled(false)
	button:SetSize(128 * screenscale, 32 * screenscale)
	button:AlignTop()
	button:CenterHorizontal()
	button.DoClick = function(me)
		local skillid = contextmenu.SkillID
		local name = allskills[skillid].Name
		if MySelf:IsSkillDesired(skillid) then
			DeactivateSkill(self, skillid)
		elseif MySelf:IsSkillUnlocked(skillid) then
			ActivateSkill(self, skillid)
		else
			UnlockSkill(self, skillid)
		end

		contextmenu:SetVisible(false)
	end
	
	contextmenu.Button = button
	
	local messagebox = vgui.Create("Panel", self)
	messagebox:SetSize(850 * screenscale, 48)
	messagebox.Paint = function(me, w, h)
		surface.SetDrawColor(5, 5, 5, 240)
		PaintGenericFrame(me, 0, 0, w, h, 16)
	end
	
	messagebox:SetKeyboardInputEnabled(false)
	messagebox:SetMouseInputEnabled(false)
	messagebox:SetZPos(-100)
	
	local messagetext = vgui.Create("DLabel", messagebox)
	messagetext:SetTextColor(COLOR_GRAY)
	messagetext:SetText("")
	messagetext:SetFont("ZSHUDFontSmall")
	messagetext:SetContentAlignment(5)
	messagetext:Dock(FILL)
	messagetext:SetKeyboardInputEnabled(false)
	messagetext:SetMouseInputEnabled(false)
	messagetext:SetZPos(-200)
	messagebox:SetVisible(false)
	
	local warningtext = vgui.Create("DLabel", self)
	warningtext:SetTextColor(COLOR_RED)
	warningtext:SetFont("ZSHUDFontSmall")
	warningtext:SetText(translate.Get("Skill_ui_changes_applied_on_respawn"))
	warningtext:SizeToContents()
	warningtext:SetKeyboardInputEnabled(false)
	warningtext:SetMouseInputEnabled(false)
	
	self:GenerateParticles()
	self.Top = top
	self.BottomLeft = bottomleft
	self.BottomLeftTop = bottomlefttop
	self.BottomLeftUp = bottomleftup
	self.QuickStats = quickstats
	self.Bottom = bottom
	self.TopRight = topright
	self.SkillName = skillname
	self.SkillDesc = desc
	self.ContextMenu = contextmenu
	self.MessageBox = messagebox
	self.MessageText = messagetext
	self.WarningText = warningtext
	self.LoadoutsDrop = dropdown
	self.Reset = reset
	
	top:SetAlpha(0)
	
	self.AmbientSound = CreateSound(MySelf, "zombiesurvival/skilltree_ambiance.ogg")
	self.AmbientSound:PlayEx(0, 60)
	self.AmbientSound:ChangeVolume(0, 0)
	self.AmbientSound:ChangeVolume(0.66, 1.5)
	self:DockMargin(0, 0, 0, 0)
	self:DockPadding(0, 0, 0, 0)
	self:Dock(FILL)
	self:InvalidateLayout()
	self.CreationTime = RealTime()
	self:MakePopup()
	self:SetMouseInputEnabled(true)
	self:SetKeyboardInputEnabled(false)
	self:UpdateQuickStats()
	net.Start("zs_skills_refunded")
	net.SendToServer()
end

function PANEL:UpdateQuickStats()
	local skillmodifiers = {}
	local gm_modifiers = GAMEMODE.SkillModifiers
		
	for skillid in pairs(table.ToAssoc(MySelf:GetDesiredActiveSkills())) do
		local modifiers = gm_modifiers[skillid]
			
		if modifiers then
			for modid, amount in pairs(modifiers) do
				skillmodifiers[modid] = (skillmodifiers[modid] or 0) + amount
			end
		end
	end
		
	for i=1, 4 do
		local prefix = i == 1 and translate.Get("Skill_ui_health") or i == 2 and  translate.Get("Skill_ui_speed") or i == 3 and translate.Get("Skill_ui_worth")  or i == 4 and translate.Get("Skill_ui_bloodarmor")
		local val = i == 2 and SPEED_NORMAL or i == 4 and 10 or 100
		self.QuickStats[i]:SetText(prefix .. " : " .. (val + (skillmodifiers[i] or 0)))
	end
end
	
function PANEL:DisplayMessage(msg, col)
	self.MessageText:SetText(msg)
	self.MessageText:SetTextColor(col or COLOR_GRAY)
	self.MessageBox:SetVisible(true)
	timer.Create("SKillWebMessageRemove", 4, 1, function()
		if self:IsValid() then
			self.MessageBox:SetVisible(false)
		end
	end)
end
	
PANEL.NextWarningThink = 0
PANEL.NextProgressThink = 0
PANEL.Progress = {  }
PANEL.TreeCount = {  }
	
function PANEL:Think()
	local time = RealTime()
		
	if self.AmbientSound and time >= self.CreationTime + 1 then
		self.AmbientSound:PlayEx(0.66, 60 + CurTime() % 0.1)
	end
		
	if time > self.NextProgressThink then
		self.NextProgressThink = time + 4
		self.Progress = {}
		self.TreeCount = {}
			
		for skill, skillinf in pairs(GAMEMODE.Skills) do
			if not skillinf.Tree then 
				continue
			end
				
			local tree = skillinf.Tree
			self.TreeCount[tree] = (self.TreeCount[tree] or 0) + 1
		end
			
		local active = MySelf:GetUnlockedSkills()
			
		for tree, _ in pairs(TREE_SKILLS) do
			for i, j in pairs(active) do
				local skillinf = GAMEMODE.Skills[j]
					
				if not skillinf or not skillinf.Tree then
					continue
				end
					
				if skillinf.Tree == tree then
					self.Progress[tree] = (self.Progress[tree] or 0) + 1
				end
			end
		end
	end
		
	if time < self.NextWarningThink then return end
		
	self.NextWarningThink = time + 0.1
		
	local display_warning = false
	local desired = table.ToAssoc(MySelf:GetDesiredActiveSkills())
	local active = MySelf:GetActiveSkills()
		
	for k, v in pairs(desired) do
		if v and not active[k] then
			display_warning = true
			break
		end
	end
		
	for k, v in pairs(active) do
		if v and not desired[k] then
			display_warning = true
			break
		end
	end
		
	if display_warning ~= self.WarningText:IsVisible() then
		self.WarningText:SetVisible(display_warning)
	end
end
	
function PANEL:GenerateParticles()//生成粒子效果
	local particles = {}
	local particle
		
	for i=1, 140 do
		local dist = math.Rand(-5000, -32)
		local size_m = 1
			
		if dist <= -3000 then
			size_m = -(dist/3000)
		end
			
		particle = {}
		particle[1] = Vector(dist, math.Rand(-710, 710), math.Rand(-710, 710))
		particle[2] = math.Rand(0, 360)
		particle[3] = math.Rand(-5, 5)
		particle[4] = math.Rand(180, 190) * size_m
		particle[5] = math.Rand(30, 90)
		particles[i] = particle
	end
		
	self.Particles = particles 
end
	
function PANEL:PerformLayout()
	self.Top:AlignTop(8)
	self.Top:CenterHorizontal()
	self.BottomLeftTop:AlignLeft(ScrH() * 0.2)
	self.BottomLeftTop:AlignBottom(10)
	self.BottomLeftUp:AlignLeft(10)
	self.BottomLeftUp:AlignBottom(ScrW() * 0.08)
	self.BottomLeft:AlignLeft(10)
	self.BottomLeft:AlignBottom(10)
	self.Bottom:AlignBottom(10)
	self.Bottom:CenterHorizontal()
	self.TopRight:AlignRight(10)
	self.TopRight:AlignTop(10)
	self.MessageBox:CenterHorizontal()
	self.MessageBox:AlignTop(ScrH() * 0.65)
	self.WarningText:AlignTop(32)
	self.WarningText:AlignLeft(32)
end
	
function PANEL:SetDirectionalLight(iDirection, color)
	self.DirectionalLight[iDirection] = color
end
	
local camera_velocity = Vector(0, 0, 0)
	
function PANEL:DoEdgeScroll(deltatime)
	if not system.HasFocus() then return end
		
	local mx, my = gui.MousePos()
	local edge = math.min(w, h) * 0.035
	local scrolldir = Vector(0, 0, 0)
	local campos = self.vCamPos
		
	if mx <= edge and mx >= 0 then
		scrolldir.y = scrolldir.y - 1
	elseif mx >= w - edge and mx <= w then
		scrolldir.y = scrolldir.y + 1
	end
		
	if my <= edge and my >= 0 then
		scrolldir.z = scrolldir.z + 1
	elseif my >= h - edge and my <= h then
		scrolldir.z = scrolldir.z - 1
	end
	
	scrolldir:Normalize()
		
	if scrolldir.y ~= 0 or scrolldir.z ~= 0 and self.ContextMenu and self.ContextMenu:IsVisible() then
		self.ContextMenu:SetVisible(false)
	end
		
	camera_velocity = LerpVector(deltatime * (scrolldir.y == 0 and scrolldir.z == 0 and 3 or 1), camera_velocity, scrolldir)
		
	if camera_velocity.y ~= 0 or camera_velocity.z ~= 0 then
		campos = campos + deltatime * edge * 12 * camera_velocity
		campos.y = math.Clamp(campos.y, -262, 262)
		campos.z = math.Clamp(campos.z, -262, 310)
		self:SetCamPos(campos)
		self.vLookatPos:Set(campos)
		self.vLookatPos.x = 0
	end
end
	
local particlecolors = {
	[TREE_HEALTHTREE] = Color(207, 57, 46),
	[TREE_MELEETREE] = Color(150, 27, 27),
	[TREE_GUNTREE] = Color(0, 109, 204),
	[TREE_SPEEDTREE] = Color(160, 160, 70),
	[TREE_BUILDINGTREE] = Color(179, 0, 101),
	[TREE_SUPPORTTREE] = Color(120, 185, 125)
}

local nodecolors = {
	[TREE_HEALTHTREE] = {1.75, 3, 5},
	[TREE_SPEEDTREE] = {2, 2, 5},
	[TREE_SUPPORTTREE] = {3, 1.5, 6},
	[TREE_BUILDINGTREE] = {2, 6, 3},
	[TREE_MELEETREE] = {1.5, 7, 7},
	[TREE_GUNTREE] = {5, 2, 2}
}

local skillProperties = {
    [-2] = { icon = "health.png",  color = particlecolors[TREE_HEALTHTREE] },
    [-3] = { icon = "speed.png",   color = particlecolors[TREE_SPEEDTREE] },
    [-4] = { icon = "support.png", color = particlecolors[TREE_SUPPORTTREE] },
    [-5] = { icon = "build.png",   color = particlecolors[TREE_BUILDINGTREE] },
    [-6] = { icon = "melee.png",   color = particlecolors[TREE_MELEETREE] },
    [-7] = { icon = "gun.png",     color = particlecolors[TREE_GUNTREE] }
}
local matNode = Material("materials/skillweb/node.png")
local matBeam = Material("effects/laser1")
local matGlow = Material("sprites/glow04_noz")
local matSmoke = Material("particles/smokey")
local matWhite = Material("models/debug/debugwhite")
local matGear = Material("models/shadertest/shader2")
local matSome  = Material("skillweb/big_background_filter.png")
local colBeam = Color(0, 0, 0)
local colBeam2 = Color(255, 255, 255)
local colSmoke = Color(140, 160, 185, 160)
local colGlow = Color(0, 0, 0)
	
function PANEL:Paint(w, h)
	local realtime = RealTime()
	local lifetime = realtime - self.CreationTime
	local dt = realtime - self.LastPaint
	local can_remort = MySelf:CanSkillsRemort()
	local skillid, skill, nodepos, selected
	local col, connectskill, othernode, othernodepos
	local add, pos_a, pos_b, sat
	local size, desc, ang   self:DoEdgeScroll(dt)
	local campos = self.vCamPos
	local screen = BetterScreenScale()
		
	campos.x = math.Approach(campos.x, self.DesiredZoom, dt * 13500)
	self:SetCamPos(campos)

	surface.SetAlphaMultiplier(0.3)
	surface.SetDrawColor(0, 0, 0, 252)
	--ocal num = self.DesiredTree
	--if num  and particlecolors[num] then
		--surface.SetDrawColor(particlecolors[num].r, particlecolors[num].g, particlecolors[num].b, 120)
	--end
	surface.SetAlphaMultiplier(1)
	surface.DrawRect(0, 0, w,h)
	ang = self.aLookAngle
		
	if not ang then
		ang = (self.vLookatPos - self.vCamPos):Angle()
	end
		
	local to_camera = ang:Forward() * -1
	local mx, my = gui.MousePos()
	local aimvector = util.AimVector(ang, self.fFOV, mx, my, w, h)
	local intersectpos = util.IntersectRayWithPlane(self.vCamPos, aimvector, self:GetLookAt(), Vector(-1, 0, 0))
	cam.Start3D( self.vCamPos, ang, self.fFOV, 0, 0, w, h, 5, self.FarZ )
	cam.IgnoreZ( true )
	render_SuppressEngineLighting( true )
	render.SetLightingOrigin( vector_origin )
	render.SetAmbientLight(0,2,2)
	render.ResetModelLighting( self.colAmbientLight.r / 255, self.colAmbientLight.g / 255, self.colAmbientLight.b / 255 )
		
	for i=0, 6 do
		col = self.DirectionalLight[ i ]
			
		if col then
			render.SetModelLighting( i, col.r / 255, col.g / 255, col.b / 255 )
		end
	end
	
	local particles = self.Particles
	render.SetMaterial(matSmoke)
	for i, particle in pairs(particles) do
		particle[2] = particle[2] + particle[3] * dt
		colSmoke.a = particle[5]
		render.DrawQuadEasy(particle[1], to_camera, particle[4], particle[4], colSmoke, particle[2])
	end
	
		
	local skillnodes = self.SkillNodes[self.DesiredTree]
	local campost = self.vCamPos
	local camheightadj = (campost.x ^ 2) * 1.0035
		
	render.SetMaterial(matBeam)
		
	for id, node in pairs(skillnodes) do
		if IsValid(node) then
			nodepos = node:GetPos()
				
			if (nodepos - campost):LengthSqr() > camheightadj then
				continue
			end
				
			skill = node.Skill
				
			if skill.Disabled then
				continue
			end
				
			if skill.Connections then
				for connectid, _ in pairs(skill.Connections) do
					connectskill = GAMEMODE.Skills[connectid]
						
					if id < connectid and (not connectskillskill or connectskill and not connectskill.Disabled) then
						othernode = skillnodes[connectid]
							
						if IsValid(othernode) then
							othernodepos = othernode:GetPos()
							local beamsize = 4
								
							if MySelf:IsSkillUnlocked(node.SkillID) or MySelf:IsSkillUnlocked(connectid) then
								colBeam.r = 32
								colBeam.g = 128
								colBeam.b = 255
							elseif MySelf:SkillCanUnlock(node.SkillID) or MySelf:SkillCanUnlock(connectid) then
								colBeam.r = 255
								colBeam.g = 192
								colBeam.b = 0
							else
								colBeam.r = 128
								colBeam.g = 40
								colBeam.b = 40
								beamsize = 2
							end
								
							if hoveredskill == node.SkillID or hoveredskill == connectid then
								add = math.abs(math.sin(realtime * math.pi)) * 120
								colBeam.r = math.min(colBeam.r + add, 255)
								colBeam.g = math.min(colBeam.g + add, 255)
								colBeam.b = math.min(colBeam.b + add, 255)
								colBeam.a = 180
								colBeam2.a = 255
							else
								colBeam.a = 110
								colBeam2.a = 190
							end
								
							pos_a = nodepos + Vector(-16, 0, 0)
							pos_b = othernodepos + Vector(-16, 0, 0)
							splines = skill.Splines and skill.Splines[connectid]
								
							if splines then
								local numsplines = #splines  render_StartBeam(#splines)
								for i, spline in ipairs(splines) do
									render.AddBeam(spline, 4, i / numsplines, colBeam2)
								end
									
								render_EndBeam()
								render_StartBeam(#splines)
									
								for i, spline in ipairs(splines) do
									render.AddBeam(spline, 12, i / numsplines, colBeam)
								end
								render_EndBeam()
							else
								render_DrawBeam(pos_a, pos_b, beamsize, 0, 1, colBeam2)
								render_DrawBeam(pos_a, pos_b, 16, 0, 1, colBeam)
							end
						end
					end
				end
			end
		end
	end
		
	local oldskill = hoveredskill
	hoveredskill = nil
	local angle = (realtime * 90) % 360
		
	for id, node in pairs(skillnodes) do
		if IsValid(node) then
			nodepos = node:GetPos()
			if (nodepos - campost):LengthSqr() > camheightadj then
				continue
			end
				
			skillid = node.SkillID
			skill = node.Skill
				
			local sel_radius = skillid <= -2 and 300 or 36
			selected = not skill.Disabled and intersectpos and nodepos:DistToSqr(intersectpos) <= sel_radius
			local scale = skillid <= -2 and 0.08 or 0.09
			cam.Start3D2D(node:GetPos() - to_camera * 8, Angle(0, 90, 90), scale)
			surface.DisableClipping(true)
			DisableClipping(true)
				
			if selected then
				hoveredskill = skillid
				sat = 1 - math.abs(math.sin(realtime * math.pi)) * 0.25
			else
				sat = 1
			end
				
			local notunlockable = false
			local divs = nodecolors[skill.Tree]
				
			if skill.Disabled or (skillid == -1 and not can_remort) then
				render_SetColorModulation(sat / 6, sat / 6, sat / 6)
			elseif skillid == -1 then
				render_SetColorModulation(sat, sat, sat)
			elseif skillid < -1 then
				local tbl = particlecolors[-skillid - 1]
				render_SetColorModulation(tbl.r/255, tbl.g/255, tbl.b/255)
			elseif MySelf:IsSkillDesired(skillid) then
				render_SetColorModulation(sat / 4, sat / 4, sat / 2)
			elseif MySelf:IsSkillUnlocked(skillid) then
				render_SetColorModulation(sat, sat, sat)
			elseif MySelf:SkillCanUnlock(skillid) then
				render_SetColorModulation(sat, sat / 1.25, sat / 4)
			else
				render_SetColorModulation(sat / divs[1] / 1.25, sat / divs[2] / 1.25, sat / divs[3] / 1.25)
				notunlockable = true
			end
				

			if skillid > 0 then
				render_ModelMaterialOverride(matWhite)
				render_SetBlend(skillid == 1 and 0.2 or 0.95)
				node:DrawModel()
				render_SetBlend(1)
				render_SetColorModulation(1, 1, 1)
			end
				
			if self.DesiredZoom < 9500 then
				local colo = skill.Disabled and COLOR_DARKGRAY or selected and color_white or notunlockable and COLOR_GRAY or COLOR_NEARGRAY
				local skill_text_y = skillid <= -2 and 100 or 0
				draw_SimpleText(skill.Name, skillid <= -1 and "ZS3D2DFont2Big" or "ZS3D2DFont2Small", 0, skill_text_y, colo, TEXT_ALIGN_CENTER) -- Robotic Bold 128
					
				if skillid <= -2 and self.TreeCount[-skillid - 1] then
					draw_SimpleText((self.Progress[-skillid - 1] or 0) ..  "/" .. self.TreeCount[-skillid - 1], "ZS3D2DFont2Big", 0, skill_text_y + 130, colo, TEXT_ALIGN_CENTER)
				end
			end
			local xskill = 32
			if skillid == hoveredskill and (type(GAMEMODE.SkillModifiers[skillid]) == "table" and table.Count(GAMEMODE.SkillModifiers[skillid]) or 0) > 0 then
				for k,v in pairs(GAMEMODE.SkillModifiers[skillid]) do
					local i = v or 1


					if k >= 6 and !table.HasValue(exlude2, k) then
						i = (i*100).."%"
					end
					if (v or 0) > 0 then
						i = "+"..i
					end
					local colorred = table.HasValue(exlude, k) and Color(71,231,119) or Color(238,37,37)
					local colorgreen = table.HasValue(exlude, k) and Color(238,37,37) or Color(71,231,119)
						--translate.Format("skillmod_n"..i,c)
						if (v or 0) < 0 then
							col = colorred
						elseif (v or 0) > 0 then
							col = colorgreen
						else
							col = Color(255,255,255)
						end
						xskill= xskill + 32 * screen
					--draw_SimpleText(skill.Name, skillid <= -1 and "ZS3D2DFont2Big" or "ZS3D2DFont2", 0, 0, colo, TEXT_ALIGN_CENTER)
				end
			end
	
			DisableClipping(false)
			surface.DisableClipping(false)
			cam.End3D2D() 
			
			-- ========== 代码修改部分开始 ==========
			
			-- 1. 定义一个局部变量来存储节点的颜色，默认为白色
			local nodeColor = color_white

			render.SetMaterial(matGlow)
			
			if skillid <= -2 then
				local properties = skillProperties[skillid]
				if properties then
					-- 2. 设置材质，并把配置中的颜色存入 nodeColor 变量
					render.SetMaterial(Material("materials/skillweb/" .. properties.icon))
					if properties.color then
						nodeColor = properties.color
					end
				end
			elseif skillid == -1 then
				render.SetMaterial(matNode)
			end
				
			if skillid <= -1 then
				if skillid == -1 and can_remort then
					local size = 32
					render.DrawQuadEasy(nodepos+Vector(0,0,5), to_camera, size, size, color_white,nil)
					render.SetMaterial(matGlow)
					render.DrawQuadEasy(nodepos+Vector(0,0,5), to_camera, size, size, color_white, nil)
					
				elseif skillid == -1 then
					local size = 65
					render.DrawQuadEasy(nodepos+Vector(0,0,5), to_camera, size/2, size/2, Color(255, 255, 255), 0)
					render.SetMaterial(matGlow)
					render.DrawQuadEasy(nodepos+Vector(0,0,5), to_camera, size, size, color_white, angle)
				else -- 这个 else 块对应的是 skillid <= -2 的情况
					local size = 65
					local p = 1.25 - math.abs(math.sin(realtime * math.pi)) * 0.25
					
					-- 3. 在绘制时使用我们之前保存的 nodeColor 变量
					render.DrawQuadEasy(nodepos, to_camera, size/3* (selected and p or 1), size/3 * (selected and p or 1), nodeColor, 180)
					
					render.SetMaterial(matGlow)
					render.DrawQuadEasy(nodepos, to_camera, size, size, Color(166, 166, 166), angle)
				end

			-- ========== 代码修改部分结束 ==========

			elseif not skill.Disabled then
				colGlow.r = sat * 255
				colGlow.g = sat * 255
				colGlow.b = sat * 255
				if MySelf:IsSkillDesired(skillid) then
					colGlow.r = colGlow.r / 4
					colGlow.g = colGlow.g / 4
				elseif not MySelf:IsSkillUnlocked(skillid) then
					if MySelf:SkillCanUnlock(skillid) then
						colGlow.g = colGlow.g / 1.5
						colGlow.b = 0
					else
						colGlow.r = colGlow.r / divs[1]
						colGlow.g = colGlow.g / divs[2]
						colGlow.b = colGlow.b / divs[3]
					end
				end
					
				size = selected and 40 or 27  render.DrawQuadEasy(nodepos, to_camera, size, size, colGlow, angle)  angle = angle + 45
			end
		end
	end
		
	if intersectpos then
		intersectpos = intersectpos + Vector(16, 0, 0)
		render.SetMaterial(matGlow) --  Material("materials/skillweb/melee_web.png")
		render.DrawQuadEasy(intersectpos, to_camera, 12, 12, color_white, realtime * 90)
	end
	render_SuppressEngineLighting(false)
	cam.IgnoreZ(false)
	cam.End3D()
		
	if oldskill ~= hoveredskill then
		self.Top:Stop()

		if hoveredskill then
			skill = hoveredskill < -1 and TREE_SKILLS[-hoveredskill - 1] or hoveredskill == -1 and REMORT_SKILL or GAMEMODE.Skills[hoveredskill]
			self.SkillName:SetText(skill.Name)
			self.SkillName:SizeToContents()

			desc = string.Explode("\n", skill.Description)
			local txt, colid
			for i=1, 5 do
				txt = desc[i] or " "
				if txt:sub(1, 1) == "^" then
					colid = tonumber(txt:sub(2, 2)) or 0
					txt = txt:sub(3)
					self.SkillDesc[i]:SetTextColor(util.ColorIDToColor(colid, COLOR_GRAY))
				else
					self.SkillDesc[i]:SetTextColor(COLOR_GRAY)
				end
				self.SkillDesc[i]:SetText(txt)
				self.SkillDesc[i]:SizeToContents()
			end

			surface.PlaySound("zombiesurvival/ui/misc1.ogg")

			self.Top:SetAlpha(0)
			self.Top:AlphaTo(255, 0.15)
		else
			self.Top:AlphaTo(0, 0.15)
		end
	end

	self.LastPaint = realtime

	local fgalpha = 255 - lifetime * 100
	if fgalpha > 0 then
		surface.SetDrawColor(0, 0, 0, fgalpha)
		surface.DrawRect(0, 0, w, h)
	end

	return true
end
	
function PANEL:OnMousePressed(mc)
	if mc == MOUSE_LEFT then
		local contextmenu = self.ContextMenu
			
		if hoveredskill then
			local mx, my = gui.MousePos()
			local can_remort = MySelf:CanSkillsRemort()
			contextmenu:SetPos(mx - contextmenu:GetWide() / 2, my - contextmenu:GetTall() / 2)
				
			if hoveredskill == -1 and can_remort then
				Derma_Query(
					translate.Get("Skill_ui_remort_warning"),
					translate.Get("Skill_ui_warning_title"),
					translate.Get("Skill_ui_ok"),
					function() net.Start("zs_skills_remort") net.SendToServer() end,
					translate.Get("Skill_ui_cancel"),
					function() end
				)
				return
			elseif hoveredskill == -1 then
				self:DisplayMessage(translate.Get("Skill_ui_level_50_to_remort"), COLOR_RED)
				surface.PlaySound("buttons/button8.wav")
				return
			elseif hoveredskill <= -1 then
				local destree = -hoveredskill - 1
				self.DesiredZoom = 2500
				self.ShadeVelocity = 255 * FrameTime() * 15
				
				timer.Simple(0.1, function()
					if not IsValid(self) then
						return
					end
						
					self.DesiredZoom = 4500
					self.DesiredTree = destree
					self.ShadeVelocity = 255 * FrameTime() * -20
					local campos = self:GetCamPos()  campos.y = 0  campos.z = 0
				end)
					
				MySelf:EmitSound("buttons/button24.wav", 60, 200)
					
				return
			elseif MySelf:IsSkillDesired(hoveredskill) then
				if GAMEMODE.Skills[hoveredskill].AlwaysActive then
					self:DisplayMessage(translate.Get("Skill_ui_cannot_deactivate"), COLOR_RED)
					surface.PlaySound("buttons/button8.wav")
					return
				end
					
				if GAMEMODE.OneClickUnlock then DeactivateSkill(self, hoveredskill) return end
				contextmenu.Button:SetText(translate.Get("Skill_ui_deactivate"))
					
			elseif MySelf:IsSkillUnlocked(hoveredskill) then
				if GAMEMODE.OneClickUnlock then ActivateSkill(self, hoveredskill) return end
				contextmenu.Button:SetText(translate.Get("Skill_ui_activate"))
			elseif MySelf:SkillCanUnlock(hoveredskill) then
				if MySelf:GetZSSPRemaining() >= 1 then
					if GAMEMODE.OneClickUnlock then UnlockSkill(self, hoveredskill) return end
					contextmenu.Button:SetText(translate.Get("Skill_ui_unlock"))
				else
					self:DisplayMessage(translate.Get("Skill_ui_need_sp_to_unlock"), COLOR_RED)
					surface.PlaySound("buttons/button8.wav")
						
					return
				end
			else
				self:DisplayMessage(translate.Get("Skill_ui_unlock_adjacent_required"), COLOR_RED)
				surface.PlaySound("buttons/button8.wav")
					
				return
			end
				
			contextmenu.SkillID = hoveredskill
			contextmenu:SetVisible(true)
		else
			contextmenu:SetVisible(false)
		end
	elseif mc == MOUSE_RIGHT and not hoveredskill then
		if self.DesiredTree == 0 then
			self:Remove()
		else
			self.DesiredTree = 0
			self.DesiredZoom = 2500
			self.ShadeVelocity = 255 * FrameTime() * 10
				
			timer.Simple(0.1, function()
				if not IsValid(self) then
					return
				end
					
				self.DesiredZoom = 5000
				self.DesiredTree = 0
				self.ShadeVelocity = 255 * FrameTime() * -10
				local campos = self:GetCamPos()
				campos.y = 0
				campos.z = 0
				self:SetCamPos(campos)
			end)
				
			MySelf:EmitSound("buttons/button24.wav", 60, 180)
		end
	end
end
	
function PANEL:OnMouseWheeled(delta)
	self.DesiredZoom = math.Clamp(self.DesiredZoom - delta * 500, 2500, 25000)
end
	
function PANEL:OnRemove()
	for _, nodetrees in pairs(self.SkillNodes) do
		for _, node in pairs(nodetrees) do
			if IsValid(node) then
				node:Remove()
			end
		end
	end
		
	local snd = self.AmbientSound
	snd:FadeOut(1.5)
		
	timer.Simple(1.5, function()
		if snd then
			snd:Stop()
		end
	end)
end
	
vgui.Register("ZSSkillWeb", PANEL, "Panel")
	
function GM:DrawXPBar(x, y, w, h, xpw, barwm, hm, level)
	local barw = xpw * barwm
	local xp = MySelf:GetZSXP()
	local progress = GAMEMODE:ProgressForXP(xp)
	local rlevel = MySelf:GetZSRemortLevel()
	local append = ""
		
	if rlevel > 0 then
		append = ""..translate.Get("Skill_ui_remort_level")..""..rlevel
	end
		
	surface.SetDrawColor(0, 0, 0, 220)
	surface.DrawRect(x, y, barw, 4)
	surface.SetDrawColor(10, 200, 10, 160)
	surface.DrawRect(x, y, barw * progress, 2)
	surface.SetDrawColor(0, 170, 0, 160)
	surface.DrawRect(x, y + 2, barw * progress, 2)
		
	if level == GAMEMODE.MaxLevel then
		draw_SimpleText(translate.Get("Level_MAX") .. append, "ZSXPBar", xpw / 2, h / 2 + y, COLOR_GREEN, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	else
		if progress > 0 then
			local lx = x + barw * progress - 1
			surface.SetDrawColor(255, 255, 255, 20 + math.abs(math.sin(RealTime() * 2)) * 170)
			surface.DrawLine(lx, y - 2, lx, y + 7)
			surface.SetDrawColor(255, 255, 255, 160)
			surface.DrawLine(x, y - 1, x, y + 5)  lx = x + barw - 1
			surface.DrawLine(lx, y - 1, lx, y + 5)
		end
			
		draw_SimpleText(translate.Get("Level")..level..append, "ZSXPBar", x, h / 2 + y, COLOR_WHITE, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		draw_SimpleText(string.CommaSeparate(xp).." / "..string.CommaSeparate(GAMEMODE:XPForLevel(level + 1)).." XP", "ZSXPBar", x + barw, h / 2 + y, COLOR_WHITE, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
	end
end
	
PANEL = {}
PANEL.PlayerLevel = 0
	
function PANEL:Init()
	self:SetMouseInputEnabled(false)
	self:SetKeyboardInputEnabled(false)
end
	
function PANEL:PerformLayout()
	local screenscale = BetterScreenScale()
	self:SetSize(350 * screenscale, 36 * screenscale)
		
	if GAMEMODE.GameStatePanel and GAMEMODE.GameStatePanel:IsValid() then
		self:MoveBelow(GAMEMODE.GameStatePanel, screenscale * 32)
	else
		self:AlignTop(400)
	end
		
	self:AlignLeft()
end
	
function PANEL:Think()
	local new_level = MySelf:GetZSLevel()
		
	if new_level ~= self.PlayerLevel then
		if new_level ~= 1 and self.FirstLevelChange then
			GAMEMODE:CenterNotify(translate.Format("you_ascended_to_level_x", new_level))
			surface.PlaySound("weapons/physcannon/energy_disintegrate"..math.random(4, 5)..".wav")
		else
			self.FirstLevelChange = true
		end
	end
		
	self.PlayerLevel = new_level
end
	
local matGradientLeft = CreateMaterial("gradient-l", "UnlitGeneric", {["$basetexture"] = "vgui/gradient-l", ["$vertexalpha"] = "1", ["$vertexcolor"] = "1", ["$ignorez"] = "1", ["$nomip"] = "1"})
local colFlash = Color(255, 255, 255)
	
function PANEL:Paint(w, h)
	-- 1. 绘制左侧纯色部分
	surface.SetDrawColor(0, 0, 0, 180)
	surface.DrawRect(0, 0, w * 0.4, h)
	
	-- 2. 准备绘制渐变部分
	surface.SetMaterial(matGradientLeft)
	-- !! 关键修复：在这里再次设置颜色 !!
	-- 这确保了无论之前的 skin 代码做了什么，我们都使用正确的颜色来为渐变纹理上色。
	surface.SetDrawColor(0, 0, 0, 180) 
	surface.DrawTexturedRect(w * 0.4, 0, w * 0.6, h)

	-- 绘制XP条和文字的代码保持不变
	local xpw = w * 0.85
	local x = xpw * 0.03
	local y = h * 0.15
	GAMEMODE:DrawXPBar(x, y, w, h, xpw, 0.9, 0.85, self.PlayerLevel)

	local sp = MySelf:GetZSSPRemaining()
	if sp > 0 then
		colFlash.a = 90 + math.abs(math.sin(RealTime() * 2)) * 160
		draw_SimpleText(sp .. " " .. translate.Get("SP"), "ZSHUDFontSmallest", w - 2, h / 2, colFlash, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
	end
end

	
vgui.Register("ZSExperienceHUD", PANEL, "Panel")
	
function GM:ToggleSkillWeb()
	if self.SkillWeb and self.SkillWeb:IsValid() then
		self.SkillWeb:Remove()
		self.SkillWeb = nil
			
		return
	end
		
	self.SkillWeb = vgui.Create("ZSSkillWeb")
end
	
local meta = FindMetaTable("Player") if not meta then return end
	
function meta:SetSkillDesired(skillid, desired)
	local desiredskills = self:GetDesiredActiveSkills()
		
	if desired then
		if self:IsSkillUnlocked(skillid) and not self:IsSkillDesired(skillid) then
			table.insert(desiredskills, skillid)
		end
	else
		table.RemoveByValue(desiredskills, skillid)
	end
		
	self:SetDesiredActiveSkills(desiredskills)
end

function meta:SetSkillUnlocked(skillid, unlocked)
	local unlockedskills = self:GetUnlockedSkills()
		
	if self:IsSkillUnlocked(skillid) ~= unlocked then
		if unlocked then
			table.insert(unlockedskills, skillid)
		else
			table.RemoveByValue(unlockedskills, skillid)
		end
	end
		
	self:SetUnlockedSkills(unlockedskills)
end
	
function meta:SetDesiredActiveSkills(skills, nosend)
	self.DesiredActiveSkills = table.ToKeyValues(skills)
end
	
function meta:SetActiveSkills(skills, nosend)
	self.ActiveSkills = table.ToAssoc(skills)
end
	
function meta:SetUnlockedSkills(skills, nosend)
	self.UnlockedSkills = table.ToKeyValues(skills)
end
