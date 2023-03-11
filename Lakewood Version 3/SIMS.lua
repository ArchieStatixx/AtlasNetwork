--[[
				LAKEWOOD SECONDARY SCHOOL SIMS NETWORK SERVER
							Scripted By ArchieStatixx

Script Made: 12:26 31/01/2023
Script Completed: 19:00 31/01/2023
Test Completed: 19:10 31/01/2023
Ready for Use: 19:12 31/01/2023

------/// UPDATES ARE BELOW ///------

- Network change, enabling a more suffienct HTTP reqs (01/02/2023)
- Changing the notifications from the teachers Username to there actual Teaching Name (04/02/2023)
- Group Bans have been implemnted and will be linked with NOBLOX API in removing them from a year group until they have left the group. (N/A)
-- Running a HTTP check to not send any type of data unless the server is able to handle it.
-- Optimising the Code for a sufficent player experience. 
-- Lowering HTTP as much as possible. (IN PROGRESS)
--]]


--// Variables //--

local GetEvents = game:GetService("ReplicatedStorage").FrontEndEvents:WaitForChild("SIMSEvents")
local Configuration = require(script.Configuration)

local http = game:GetService("HttpService")
local link = "https://api.trello.com/1/cards"

local bannedPlayers = {}
local DSS = game:GetService("DataStoreService")
local GetPlayerDataStore = DSS:GetDataStore("Teachingname")
local blacklistedGroups = {
	[15194933] = "Blacklisted for using copyrighted assets"
	
}

--// END OF VARIABLES //--


--// FUNCTIONS //--

local function returnTime()
	local fullTime = os.date("%c", os.time())

	return fullTime
end

local function IsPlayerInBlacklistedGroup(player)
	for groupId, reason in pairs(blacklistedGroups) do
		if player:IsInGroup(tonumber(groupId)) then
			local group = game:GetService("GroupService"):GetGroupInfoAsync(tonumber(groupId))
			return group.Name, reason
		end
	end

	return false
end


local function SendDataToBoard(data)	
	local async = http:JSONEncode(data)
	local response = nil
	
	repeat
		response = 	http:PostAsync(link, async)
		if response.StatusCode == 429 then
			wait(5)
		end
	until response.StatusCode ~= 429
	
end



local function CheckForPlayerBlacklist(plr)
	for i, blacklist in pairs(blacklistedGroups) do
		if plr:IsInGroup(blacklist.groupId) then
			return blacklist.groupName, blacklist.reason
		end
	end
	
	return false 
	
end



local function getCards(listId)
	
	local response = nil
	
	repeat 
		response = http:GetAsync("https://api.trello.com/1/lists/" .. listId .. "/cards?key=" .. Configuration.TrelloConnection.key .. "&token=" .. Configuration.TrelloConnection.token)
		if response.StatusCode == 429 then
			wait(5)
		end
	until response.StatusCode ~= 429
	
	
	local data = http:JSONDecode(response)

	return data
end

local function moveCard(cardId, newListId)
	
	local response = nil
	
	repeat
		response = http:RequestAsync({Url = "https://api.trello.com/1/cards/" .. cardId .. "?idList=" .. newListId .. "&key=" .. Configuration.TrelloConnection.key .. "&token=" .. Configuration.TrelloConnection.token, Method = "PUT"})		
		if response.StatusCode == 429 then
			wait(5)
		end
	until response.StatusCode ~= 429
	
	

end

local function collectAndMoveCards(listId, newListId)
	local cards = getCards(listId)

	for i, card in ipairs(cards) do
		task.spawn(function()
			moveCard(card.id, newListId)
		end)
		task.wait(5)
	end
end



--// FUNCTIONS END //--


local GetEvents = game:GetService("ReplicatedStorage").FrontEndEvents:WaitForChild("SIMSEvents")
GetEvents.GivePositive.OnServerEvent:Connect(function(TeacherName, StudentName, Decoy, StudentYearGroup, ReasonForPoint)


	local yearGroup = game.Players:FindFirstChild(StudentName).TeamColor
	local labels = {}


	if yearGroup == BrickColor.new(Configuration.Year7Data.YearGroupA) then
		labels = {Configuration.Year7Data.Label}
	elseif yearGroup == BrickColor.new(Configuration.Year7Data.YearGroupB) then
		labels = {Configuration.Year7Data.Label}
	elseif yearGroup == BrickColor.new(Configuration.Year8Data.YearGroupA) then
		labels = {Configuration.Year8Data.Label}
	elseif yearGroup == BrickColor.new(Configuration.Year8Data.YearGroupB) then
		labels = {Configuration.Year8Data.Label}
	elseif yearGroup == BrickColor.new(Configuration.Year9Data.YearGroupA) then
		labels = {Configuration.Year9Data.Label}
	elseif yearGroup == BrickColor.new(Configuration.Year9Data.YearGroupB) then
		labels = {Configuration.Year9Data.Label}
	elseif yearGroup == BrickColor.new(Configuration.Year10Data.YearGroupA) then
		labels = {Configuration.Year10Data.Label}
	elseif yearGroup == BrickColor.new(Configuration.Year10Data.YearGroupB) then
		labels = {Configuration.Year10Data.YearGroupBLabel}
	elseif yearGroup == BrickColor.new(Configuration.Year11Data.YearGroupA) then
		labels = {Configuration.Year11Data.Label}
	elseif yearGroup == BrickColor.new(Configuration.Year11Data.YearGroupB) then
		labels = {Configuration.Year11Data.Label}
	elseif yearGroup == BrickColor.new(Configuration.SENData.TeamColor) then
		labels = {Configuration.SENData.Label}
	elseif yearGroup == BrickColor.new(Configuration.BSUData.TeamColor) then
		labels = {Configuration.BSUData.Label}
	end

	if TeacherName.TeamColor == BrickColor.new(Configuration.GroupConfiguration.SLT) or TeacherName.TeamColor == BrickColor.new(Configuration.GroupConfiguration.STAFF) then
		if game.Players:FindFirstChild(StudentName).TeamColor == BrickColor.new(Configuration.GroupConfiguration.SLT) or game.Players:FindFirstChild(StudentName).TeamColor == BrickColor.new(Configuration.GroupConfiguration.STAFF) then
			return
		else





			local data = {
				["name"] = StudentName.." | "..TeacherName.Name,
				["desc"] = StudentName.." has been issued a positive point by "..TeacherName.Name.." for "..ReasonForPoint.." this log was uploaded at/on "..returnTime(),
				["key"] = Configuration.TrelloConnection.key,
				["token"] = Configuration.TrelloConnection.token,
				["pos"] = Configuration.TrelloConnection.Position,
				["idList"] = Configuration.TrelloConnection.PositiveListId,
				["labels"] = labels,
			}

			SendDataToBoard(data)
		end
		local success, playerData = pcall(function()
			return GetPlayerDataStore:GetAsync(TeacherName.UserId)
		end)


		if success then
			game.Players:FindFirstChild(StudentName).PlayerGui.SIMSNotif.Notif.Visible = true
			game.Players:FindFirstChild(StudentName).PlayerGui.SIMSNotif.Notif.MainText.Text = "Rewarded by: "..playerData.teachingname
			game.Players:FindFirstChild(StudentName).PlayerGui.SIMSNotif.Notif.Reason.Text = "You have been issued a positive point for: "..ReasonForPoint
			task.wait(10)
			game.Players:FindFirstChild(StudentName).PlayerGui.SIMSNotif.Notif.Visible = false 
		end

	end
end)


GetEvents.GiveNegative.OnServerEvent:Connect(function(TeacherName, StudentName, Decoy, StudentYearGroup, ReasonForPoint)


	local yearGroup = game.Players:FindFirstChild(StudentName).TeamColor
	local labels = {}



	if yearGroup == BrickColor.new(Configuration.Year7Data.YearGroupA) then
		labels = {Configuration.Year7Data.Label}
	elseif yearGroup == BrickColor.new(Configuration.Year7Data.YearGroupB) then
		labels = {Configuration.Year7Data.Label}
	elseif yearGroup == BrickColor.new(Configuration.Year8Data.YearGroupA) then
		labels = {Configuration.Year8Data.Label}
	elseif yearGroup == BrickColor.new(Configuration.Year8Data.YearGroupB) then
		labels = {Configuration.Year8Data.Label}
	elseif yearGroup == BrickColor.new(Configuration.Year9Data.YearGroupA) then
		labels = {Configuration.Year9Data.Label}
	elseif yearGroup == BrickColor.new(Configuration.Year9Data.YearGroupB) then
		labels = {Configuration.Year9Data.Label}
	elseif yearGroup == BrickColor.new(Configuration.Year10Data.YearGroupA) then
		labels = {Configuration.Year10Data.Label}
	elseif yearGroup == BrickColor.new(Configuration.Year10Data.YearGroupB) then
		labels = {Configuration.Year10Data.YearGroupBLabel}
	elseif yearGroup == BrickColor.new(Configuration.Year11Data.YearGroupA) then
		labels = {Configuration.Year11Data.Label}
	elseif yearGroup == BrickColor.new(Configuration.Year11Data.YearGroupB) then
		labels = {Configuration.Year11Data.Label}
	elseif yearGroup == BrickColor.new(Configuration.SENData.TeamColor) then
		labels = {Configuration.SENData.Label}
	elseif yearGroup == BrickColor.new(Configuration.BSUData.TeamColor) then
		labels = {Configuration.BSUData.Label}
	end

	if TeacherName.TeamColor == BrickColor.new(Configuration.GroupConfiguration.SLT) or TeacherName.TeamColor == BrickColor.new(Configuration.GroupConfiguration.STAFF) then
		if game.Players:FindFirstChild(StudentName).TeamColor == BrickColor.new(Configuration.GroupConfiguration.SLT) or game.Players:FindFirstChild(StudentName).TeamColor == BrickColor.new(Configuration.GroupConfiguration.STAFF) then
			return
		else
			local data = {
				["name"] = StudentName.." | "..TeacherName.Name,
				["desc"] = StudentName.." has been issued a negative point by "..TeacherName.Name.." for "..ReasonForPoint.." this log was uploaded at/on "..returnTime(),
				["key"] = Configuration.TrelloConnection.key,
				["token"] = Configuration.TrelloConnection.token,
				["pos"] = Configuration.TrelloConnection.Position,
				["idList"] = Configuration.TrelloConnection.NegativeListId,
				["labels"] = labels
			}

			SendDataToBoard(data)
		end
		local success, playerData = pcall(function()
			return GetPlayerDataStore:GetAsync(TeacherName.UserId)
		end)


		if success then
			game.Players:FindFirstChild(StudentName).PlayerGui.SIMSNotif.Notif.Visible = true
			game.Players:FindFirstChild(StudentName).PlayerGui.SIMSNotif.Notif.MainText.Text = "Rewarded by: "..playerData.teachingname
			game.Players:FindFirstChild(StudentName).PlayerGui.SIMSNotif.Notif.Reason.Text = "You have been issued a negative point for: "..ReasonForPoint
			task.wait(10)
			game.Players:FindFirstChild(StudentName).PlayerGui.SIMSNotif.Notif.Visible = false 
		end

	end
end)


GetEvents.GiveInclusion.OnServerEvent:Connect(function(TeacherName, StudentName, Decoy, StudentYearGroup, ReasonForInclusion)

	local yearGroup = game.Players:FindFirstChild(StudentName).TeamColor
	local labels = {}



	if yearGroup == BrickColor.new(Configuration.Year7Data.YearGroupA) then
		labels = {Configuration.Year7Data.Label}
	elseif yearGroup == BrickColor.new(Configuration.Year7Data.YearGroupB) then
		labels = {Configuration.Year7Data.Label}
	elseif yearGroup == BrickColor.new(Configuration.Year8Data.YearGroupA) then
		labels = {Configuration.Year8Data.Label}
	elseif yearGroup == BrickColor.new(Configuration.Year8Data.YearGroupB) then
		labels = {Configuration.Year8Data.Label}
	elseif yearGroup == BrickColor.new(Configuration.Year9Data.YearGroupA) then
		labels = {Configuration.Year9Data.Label}
	elseif yearGroup == BrickColor.new(Configuration.Year9Data.YearGroupB) then
		labels = {Configuration.Year9Data.Label}
	elseif yearGroup == BrickColor.new(Configuration.Year10Data.YearGroupA) then
		labels = {Configuration.Year10Data.Label}
	elseif yearGroup == BrickColor.new(Configuration.Year10Data.YearGroupB) then
		labels = {Configuration.Year10Data.YearGroupBLabel}
	elseif yearGroup == BrickColor.new(Configuration.Year11Data.YearGroupA) then
		labels = {Configuration.Year11Data.Label}
	elseif yearGroup == BrickColor.new(Configuration.Year11Data.YearGroupB) then
		labels = {Configuration.Year11Data.Label}
	elseif yearGroup == BrickColor.new(Configuration.SENData.TeamColor) then
		labels = {Configuration.SENData.Label}
	elseif yearGroup == BrickColor.new(Configuration.BSUData.TeamColor) then
		labels = {Configuration.BSUData.Label}
	end

	if TeacherName.TeamColor == BrickColor.new(Configuration.GroupConfiguration.SLT) or TeacherName.TeamColor == BrickColor.new(Configuration.GroupConfiguration.STAFF) then
		if game.Players:FindFirstChild(StudentName).TeamColor == BrickColor.new(Configuration.GroupConfiguration.SLT) or game.Players:FindFirstChild(StudentName).TeamColor == BrickColor.new(Configuration.GroupConfiguration.STAFF) then
			return
		else
			game.Players:FindFirstChild(StudentName).Team = game.Teams.Isolation


			local data = {
				["name"] = StudentName.." | "..TeacherName.Name,
				["desc"] = StudentName.." has been issued inclusion by "..TeacherName.Name.." for "..ReasonForInclusion.." this log was uploaded at/on "..returnTime(),
				["key"] = Configuration.TrelloConnection.key,
				["token"] = Configuration.TrelloConnection.token,
				["pos"] = Configuration.TrelloConnection.Position,
				["idList"] = Configuration.TrelloConnection.InclusionListId,
				["labels"] = labels
			}

			SendDataToBoard(data)

			local character = game.Players:FindFirstChild(StudentName).Character

			if character then
				character:FindFirstChild("HumanoidRootPart").Position =  Vector3.new(232.71, 12.397, -182.27)
			end

			local success, playerData = pcall(function()
				return GetPlayerDataStore:GetAsync(TeacherName.UserId)
			end)


			if success then
				game.Players:FindFirstChild(StudentName).PlayerGui.SIMSNotif.Notif.Visible = true
				game.Players:FindFirstChild(StudentName).PlayerGui.SIMSNotif.Notif.MainText.Text = "Rewarded by: "..playerData.teachingname
				game.Players:FindFirstChild(StudentName).PlayerGui.SIMSNotif.Notif.Reason.Text = "You have been issued inclusion for: "..ReasonForInclusion
				task.wait(10)
				game.Players:FindFirstChild(StudentName).PlayerGui.SIMSNotif.Notif.Visible = false 
			end
		end


	end

end)




GetEvents.GiveExclusion.OnServerEvent:Connect(function(TeacherName, StudentName, Decoy, StudentYearGroup, ReasonForExclusion)


	local success, result = pcall(function()
		return GetPlayerDataStore:GetAsync(TeacherName.UserId)
	end)


	local due = os.date("!%Y-%m-%dT21:35:00.000Z")

	local yearGroup = game.Players:FindFirstChild(StudentName).TeamColor
	local labels = {}


	if yearGroup == BrickColor.new(Configuration.Year7Data.YearGroupA) then
		labels = {Configuration.Year7Data.Label}
	elseif yearGroup == BrickColor.new(Configuration.Year7Data.YearGroupB) then
		labels = {Configuration.Year7Data.Label}
	elseif yearGroup == BrickColor.new(Configuration.Year8Data.YearGroupA) then
		labels = {Configuration.Year8Data.Label}
	elseif yearGroup == BrickColor.new(Configuration.Year8Data.YearGroupB) then
		labels = {Configuration.Year8Data.Label}
	elseif yearGroup == BrickColor.new(Configuration.Year9Data.YearGroupA) then
		labels = {Configuration.Year9Data.Label}
	elseif yearGroup == BrickColor.new(Configuration.Year9Data.YearGroupB) then
		labels = {Configuration.Year9Data.Label}
	elseif yearGroup == BrickColor.new(Configuration.Year10Data.YearGroupA) then
		labels = {Configuration.Year10Data.Label}
	elseif yearGroup == BrickColor.new(Configuration.Year10Data.YearGroupB) then
		labels = {Configuration.Year10Data.YearGroupBLabel}
	elseif yearGroup == BrickColor.new(Configuration.Year11Data.YearGroupA) then
		labels = {Configuration.Year11Data.Label}
	elseif yearGroup == BrickColor.new(Configuration.Year11Data.YearGroupB) then
		labels = {Configuration.Year11Data.Label}
	elseif yearGroup == BrickColor.new(Configuration.SENData.TeamColor) then
		labels = {Configuration.SENData.Label}
	elseif yearGroup == BrickColor.new(Configuration.BSUData.TeamColor) then
		labels = {Configuration.BSUData.Label}
	end


	if TeacherName.TeamColor == BrickColor.new(Configuration.GroupConfiguration.SLT) or TeacherName.TeamColor == BrickColor.new(Configuration.GroupConfiguration.STAFF) then
		if game.Players:FindFirstChild(StudentName).TeamColor == BrickColor.new(Configuration.GroupConfiguration.SLT) or game.Players:FindFirstChild(StudentName).TeamColor == BrickColor.new(Configuration.GroupConfiguration.STAFF) then
			return
		else

			local success, playerData = pcall(function()
				return GetPlayerDataStore:GetAsync(TeacherName.UserId)
			end)


			if success then
				game.Players:FindFirstChild(StudentName).PlayerGui.SIMSNotif.Notif.Visible = true
				game.Players:FindFirstChild(StudentName).PlayerGui.SIMSNotif.Notif.MainText.Text = "Rewarded by: "..playerData.teachingname
				game.Players:FindFirstChild(StudentName).PlayerGui.SIMSNotif.Notif.Reason.Text = "You have been excluded for: "..ReasonForExclusion
				task.wait(10)
				game.Players:FindFirstChild(StudentName).PlayerGui.SIMSNotif.Notif.Visible = false 
			end


			local data = {
				["name"] = StudentName.." | "..TeacherName.Name,
				["desc"] = StudentName.." has been excluded by "..TeacherName.Name.." for "..ReasonForExclusion.." this log was uploaded at/on "..returnTime(),
				["key"] = Configuration.TrelloConnection.key,
				["token"] = Configuration.TrelloConnection.token,
				["pos"] = Configuration.TrelloConnection.Position,
				["idList"] = Configuration.TrelloConnection.ExclusionListId,
				["labels"] = labels,
				["due"] = due
			}

			SendDataToBoard(data)


			table.insert(bannedPlayers, game.Players:FindFirstChild(StudentName).UserId)
			game.Players:FindFirstChild(StudentName):Kick("You have been excluded.")
		end
	end
end)


local function isBanned(player)
	for i, bannedId in ipairs(bannedPlayers) do
		if bannedId == player.userId then
			return true
		end
	end
	return false
end

local function onPlayerJoining(player)
	if isBanned(player) then
		player:Kick("You have been excluded for this session, please come again next session.")
	end
end

game.Players.PlayerAdded:Connect(onPlayerJoining)

local function clearBans()
	bannedPlayers = {}
	collectAndMoveCards(Configuration.TrelloConnection.ExclusionListId, Configuration.TrelloConnection.ExclusionArchiveListId)
end

game:GetService("RunService").Stepped:Connect(function()
	if game.Players.NumPlayers == 0 then
		clearBans()
	end
end)


GetEvents.SetTeachingName.OnServerEvent:Connect(function(player, TeachingName)
	print(TeachingName)
	GetPlayerDataStore:SetAsync(player.UserId, {teachingname = TeachingName})

end)


GetEvents.LockServer.OnServerEvent:Connect(function(SLTMember)
	local success, playerData = pcall(function()
		return GetPlayerDataStore:GetAsync(SLTMember.UserId)
	end)
	if SLTMember.TeamColor == BrickColor.new(Configuration.GroupConfiguration.SLT) then
		if game.ServerStorage.IsServerLocked.Value == false then
			game.ServerStorage.IsServerLocked.Value = true

			for _,plr in pairs(game.Players:GetPlayers()) do
				plr.PlayerGui.SIMSNotif.ServerUnlock.Visible = true
				plr.PlayerGui.SIMSNotif.ServerUnlock.MainText.Text = "Server Locked by: " .. playerData.teachingname
				plr.PlayerGui.SIMSNotif.ServerUnlock.Reason.Text = "The server has been locked by a member of the Senior Leadership Team."
				task.wait(10)
				plr.PlayerGui.SIMSNotif.ServerUnlock.Visible = false
			end
		end
	end
end)


GetEvents.UnlockServer.OnServerEvent:Connect(function(SLTMember)
	local success, playerData = pcall(function()
		return GetPlayerDataStore:GetAsync(SLTMember.UserId)
	end)
	if SLTMember.TeamColor == BrickColor.new(Configuration.GroupConfiguration.SLT) then
		if game.ServerStorage.IsServerLocked.Value == true then
			game.ServerStorage.IsServerLocked.Value = false

			for _,plr in pairs(game.Players:GetPlayers()) do
				plr.PlayerGui.SIMSNotif.ServerUnlock.Visible = true
				plr.PlayerGui.SIMSNotif.ServerUnlock.MainText.Text = "Server unlocked by: " .. playerData.teachingname
				plr.PlayerGui.SIMSNotif.ServerUnlock.Reason.Text = "The server has been unlocked by a member of the Senior Leadership Team."
				task.wait(10)
				plr.PlayerGui.SIMSNotif.ServerUnlock.Visible = false
			end
		end
	end
end)



GetEvents.DoorSequence.OnServerEvent:Connect(function(SLTMember)
	if SLTMember.TeamColor == BrickColor.new(Configuration.GroupConfiguration.SLT) then
		game.Workspace.Doors.DoorRelease:Fire("RELEASE")	
		game.Workspace.Doors.DoorRelease:Fire("RESET")
	end
end)

GetEvents.SendTAnnouncement.OnServerEvent:Connect(function(SLTMember, Announcement)

	local success, playerData = pcall(function()
		return GetPlayerDataStore:GetAsync(SLTMember.UserId)
	end)
	if SLTMember.TeamColor == BrickColor.new(Configuration.GroupConfiguration.SLT) then
		for _,plr in pairs(game.Players:GetPlayers()) do
			plr.PlayerGui.SIMSNotif.ServerUnlock.Visible = true
			plr.PlayerGui.SIMSNotif.ServerUnlock.MainText.Text = "Tannoy Announcement by: " .. playerData.teachingname
			plr.PlayerGui.SIMSNotif.ServerUnlock.Reason.Text = Announcement
			task.wait(10)
			plr.PlayerGui.SIMSNotif.ServerUnlock.Visible = false
		end
	end
end)


GetEvents.SendSetmsg.OnServerEvent:Connect(function(Member, Announcement)
	
	local success, playerData = pcall(function()
		return GetPlayerDataStore:GetAsync(Member.UserId)
	end)
	
	if Member.TeamColor == BrickColor.new(Configuration.GroupConfiguration.SLT) then
		GetEvents.SetMessageClient:FireAllClients(playerData.teachingname, Announcement)
		game.StarterGui.SIMSNotif.LessonManager.TextLabel.Text = Announcement
		
		--// FLOW BELLS
		--game.Workspace["Armodia Systems LTD - FLOW Expanded [Flow2+]"].Event:Fire({AllCommand = "ClassChange"})
		--game.Workspace["Armodia Systems LTD - FLOW Expanded [Flow2+]"].Event.ClassChange.Value = true
		
		--// Vigilon Bells
		game.Workspace["SimpleVigilon | Beta"]["GentAPI"]:Fire("Bell")
		
	end
end)

game.Players.PlayerAdded:Connect(function(plr)
	local groupName,reason = IsPlayerInBlacklistedGroup(plr)
	if groupName then
		plr:Kick("SIMS \n\n\n Your are in a blackisted group (" .. groupName ..  ") , this group is blacklisted for: ".. reason .." to be able to play this game you will be need to leave the group.")
	end	
end)
