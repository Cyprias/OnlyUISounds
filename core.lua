--[[******************************************************************************
	Addon:      OnlyUISounds
	Author:     Cyprias
	License:    MIT License	(http://opensource.org/licenses/MIT)
**********************************************************************************]]

local folder, core = ...
_G._OUIS = core

core.title		= GetAddOnMetadata(folder, "Title")
core.version	= GetAddOnMetadata(folder, "Version")
core.titleFull	= core.title.." v"..core.version
core.addonDir   = "Interface\\AddOns\\"..folder.."\\"

LibStub("AceAddon-3.0"):NewAddon(core, folder, "AceConsole-3.0", "AceHook-3.0")

core.defaultSettings = {}

function core:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("OnlyUISounds_DB", self.defaultSettings, true) --'Default'

	self.db.RegisterCallback(self, "OnProfileChanged", "OnProfileChanged")
	self.db.RegisterCallback(self, "OnProfileCopied", "OnProfileChanged")
	self.db.RegisterCallback(self, "OnProfileReset", "OnProfileChanged")
	self.db.RegisterCallback(self, "OnProfileDeleted", "OnProfileChanged")
	
	self:RegisterChatCommand("ouis", "ChatCommand");
end

function core:ChatCommand(input)
	if not input or input:trim() == "" then
		self:OpenOptionsFrame()
	end
end

function core:OpenOptionsFrame()
	LibStub("AceConfigDialog-3.0"):Open(core.title)
end

function core:OnProfileChanged(...)	
	self:Disable() -- Shut down anything left from previous settings
	self:Enable() -- Enable again with the new settings
end

do 
	function core:OnEnable()
		self:SecureHook("PlaySound", "PlaySound");
		--self:SecureHook("PlaySoundFile", "PlaySoundFile");
		self:SecureHook("PlaySoundKitID", "PlaySoundKitID");
	end
end

-- function core:OnDisable(...)
-- end

function core:dump_table(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. core:dump_table(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

do
	local strWhiteBar		= "|cffffff00 || |r" -- a white bar to seperate the debug info.
	local colouredName		= "|cff008000oUIs:|r "

	local tostring = tostring
	local select = select
	local _G = _G

	local msg
	local part
	
	local cf
	function echo(...)
		msg = tostring(select(1, ...))
		for i = 2, select("#", ...) do
			part = select(i, ...)
			msg = msg..strWhiteBar..tostring(part)
		end
		
		cf = _G["ChatFrame1"]
		if cf then
			cf:AddMessage(colouredName..msg,.7,.7,.7)
		end
	end
	core.echo = echo

	local strDebugFrom		= "|cffffff00[%s]|r" --Yellow function name. help pinpoint where the debug msg is from.
	
	local select = select
	local tostring = tostring
	
	local msg
	local part
	local function Debug(from, ...)
		if core.db.profile.debugMessages ~= true then
			return
		end
		
		msg = "nil"
		if select(1, ...) then
			msg = tostring(select(1, ...))
			for i = 2, select("#", ...) do
				part = select(i, ...)
				msg = msg..strWhiteBar..tostring(part)
			end
		end
		--from
		echo(strDebugFrom:format("D").." "..msg)
	end
	core.Debug = Debug
end

do
	local PlaySound = PlaySound;
	function core:PlaySound(sound, soundChannel)
		if (GetCVar("Sound_EnableSFX") == "1") then return; end
		core:Debug("<PlaySound> " .. tostring(sound) .. " " .. tostring(soundChannel));
		-- RawHooking taints the execution of some functions, 
		-- but SecureHook and calling PlaySound again with our own soundChannel does not. 
		-- So lazy fix.
		if (soundChannel ~= "master") then
			PlaySound(sound, "master");
		end
	end	
end

do
	local PlaySoundFile = PlaySoundFile;
	function core:PlaySoundFile(sound, soundChannel)
		if (GetCVar("Sound_EnableSFX") == "1") then return; end
		core:Debug("<PlaySoundFile> " .. tostring(sound) .. " " .. tostring(soundChannel));
		if (soundChannel ~= "master") then
			PlaySoundFile(sound, "master");
		end
	end	
end

do
	local PlaySoundKitID = PlaySoundKitID;
	function core:PlaySoundKitID(sound, soundChannel)
		if (GetCVar("Sound_EnableSFX") == "1") then return; end
		core:Debug("<PlaySoundKitID> " .. tostring(sound) .. " " .. tostring(soundChannel));
		if (soundChannel ~= "master") then
			PlaySoundKitID(sound, "master");
		end
	end	
end