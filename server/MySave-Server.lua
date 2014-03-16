class 'MySave'

function MySave:__init()
	DefaultSpawnAtLocation = 30
    -- Init tables
    SQL:Execute("CREATE TABLE IF NOT EXISTS mysave_test1 (steamid VARCHAR UNIQUE, savelocation VARCHAR, activetoggle INTEGER)")
	
	self.sqlAddNewPlayerEntry		=	"INSERT OR REPLACE INTO mysave_test1 (steamid,savelocation,activetoggle) VALUES (?,?,?)"
    self.sqlUpdateToggleSetting		= 	"UPDATE mysave_test1 SET activetoggle = (?) WHERE steamid = (?)"
    self.sqlUpdateSaveLocation		= 	"UPDATE mysave_test1 SET savelocation = (?) WHERE steamid = (?)"
    self.sqlGetToggleSetting		=	"SELECT activetoggle FROM mysave_test1 WHERE steamid = (?)"
    self.sqlGetSaveLocation			=	"SELECT savelocation FROM mysave_test1 WHERE steamid = (?)"
	
    Events:Subscribe	("PlayerSpawn", self, self.Join)
	Network:Subscribe	("SaveMyLocation", self, self.SaveLocation)
	Events:Subscribe	("PluginMySavePlayerSpawn", self, self.Join)
	Events:Subscribe	("PlayerChat", self, self.SaveSetting)
end

function MySave:Join(args)
	if self:GetSetting(args) then
		self:TeleportLocation(args)
	return false
	end
end

function MySave:TeleportLocation(args)
	local SavedInformation = self:GetLocation(args)
	args.player:Teleport(SavedInformation[1], SavedInformation[2])
end

function MySave:GetSetting(args)
	local PlayerSteamID	=	args.player:GetSteamId().id
    self.queryGetSetting = SQL:Query(self.sqlGetToggleSetting)
    self.queryGetSetting:Bind(1, PlayerSteamID)
    local result = self.queryGetSetting:Execute()
    if result[1].activetoggle ~= nil then
		if tonumber(result[1].activetoggle) == 1 then
			return true
		else
			return false
		end
	else
		self:AddEntry(args)
		return false
	end
	return false
end

function MySave:SaveSetting(args)
	local PlayerName	=	args.player:GetName()
	local PlayerSteamID	=	args.player:GetSteamId().id
	if args.text == "/togglesavespawn" then
		print("That's the right command.")
		if self:GetSetting(args) then
			self.querySaveSetting = SQL:Command(self.sqlUpdateToggleSetting)
			self.querySaveSetting:Bind(1, 0)
			self.querySaveSetting:Bind(2, PlayerSteamID)
			self.querySaveSetting:Execute()
			print(PlayerName .. "'s toggle has changed to FALSE!")
		else
			self.querySaveSetting = SQL:Command(self.sqlUpdateToggleSetting)
			self.querySaveSetting:Bind(1, 1)
			self.querySaveSetting:Bind(2, PlayerSteamID)
			self.querySaveSetting:Execute()
			print(PlayerName .. "'s toggle has changed to TRUE!")
		end
	end
end

function MySave:GetLocation(args)
	local PlayerSteamID	=	args.player:GetSteamId().id
    self.queryGetLocation = SQL:Query(self.sqlGetSaveLocation)
    self.queryGetLocation:Bind(1, PlayerSteamID)
    local result = self.queryGetLocation:Execute()
    if #result > 0 then
		local SaveLocation = self:TranslateLocation(result[1].savelocation)
			SavedPositionLocation = Vector3(SaveLocation[1], SaveLocation[2], SaveLocation[3])
			SavedAngle = Angle(SaveLocation[4], SaveLocation[5], SaveLocation[6])
		return {SavedPositionLocation, SavedAngle}
	end
	return false
end

function MySave:SaveLocation(args)
	local PlayerName	=	args:GetName()
	local PlayerSteamID	=	args:GetSteamId().id
	local PlayerAngle	=	tostring(args:GetAngle())
	local PlayerPosition=	tostring(args:GetPosition())
	local PlayerToggle	=	DefaultSpawnAtLocation
	local SaveLocation	=	tostring(PlayerPosition .. ":" .. PlayerAngle)
--	1: SteamID.id	2: Location		3: Active Toggle
    self.querySavePlayerEntry = SQL:Command(self.sqlUpdateSaveLocation)
    self.querySavePlayerEntry:Bind(1, SaveLocation)
    self.querySavePlayerEntry:Bind(2, PlayerSteamID)
    self.querySavePlayerEntry:Execute()
    return true
end

function MySave:AddEntry(args)
	local PlayerName	=	args.player:GetName()
	local PlayerSteamID	=	args.player:GetSteamId().id
	local PlayerAngle	=	tostring(args.player:GetAngle())
	local PlayerPosition=	tostring(args.player:GetPosition())
	local PlayerToggle	=	DefaultSpawnAtLocation
	local SaveLocation	=	tostring(PlayerPosition .. ":" .. PlayerAngle)
--	1: SteamID.id	2: Location		3: Active Toggle
    self.queryAddPlayerEntry = SQL:Command(self.sqlAddNewPlayerEntry)
    self.queryAddPlayerEntry:Bind(1, PlayerSteamID)
    self.queryAddPlayerEntry:Bind(2, SaveLocation)
    self.queryAddPlayerEntry:Bind(3, PlayerToggle)
    self.queryAddPlayerEntry:Execute()
--    print(PlayerName .. "'s MySave has been set to " .. SaveLocation)
    return true
end

function MySave:TranslateLocation( input )
--	print("RAW Input:"..input)	--RAW Input for debug purposes
	if input == nil then
	print("Translate Location: Nil data received.")
	end
	input = input:gsub( " ", "" )
	local Information = input:split( ":" )
	local Location = Information[1]
--	print("Location: " .. Location)
	local Angle = Information[2]
--	print("Angle: " .. Angle)
	local Location = Location:split( "," )
		local LocX = tonumber(Location[1])
		local LocY = tonumber(Location[2])
		local LocZ = tonumber(Location[3])
	local Angle = Angle:split( "," )
		local Yaw = tonumber(Angle[1])
		local Pitch = tonumber(Angle[2])
		local Roll = tonumber(Angle[3])
	local SaveLocationInformation	=	{LocX, LocY, LocZ, Yaw, Pitch, Roll}
	return SaveLocationInformation
end

function MySave:EmptyFunction()

end

mySave = MySave()