-- config things --
local cfg = getgenv().Config
local victim = cfg.victim
local helper = cfg.helper
local level = cfg.level
local streak = cfg.streak
local elo = cfg.elo
local keys = cfg.keys
local premium = cfg.premium
local verified = cfg.verified
local unlockall = cfg.unlockall
local platform  = tostring(cfg.platform):upper()


-- waits for friend to be in the game --
repeat task.wait() until game:IsLoaded()
local Players = game:GetService("Players")
local friend = cfg.helper ~= "" and Players:WaitForChild(helper) or Players.LocalPlayer


-- sets user data --
local UserData = game:HttpGet("https://users.roblox.com/v1/users/" .. tostring(victim), true)
local decodedData = game:GetService("HttpService"):JSONDecode(UserData)
friend.Name = decodedData.name
friend.UserId = decodedData.id
friend.CharacterAppearanceId = decodedData.id
friend.DisplayName = decodedData.displayName
repeat task.wait() until friend.Character
friend.Character:WaitForChild("Humanoid")
friend.Character.Name = decodedData.name
friend.Character.Humanoid.DisplayName = decodedData.displayName

Players:WaitForChild(decodedData.name):SetAttribute("Level", tonumber(level))
Players:WaitForChild(decodedData.name):SetAttribute("StatisticDuelsWinStreak", tonumber(streak))

Players:WaitForChild(decodedData.name)
    :WaitForChild("CustomLeaderstats")
    .Level.Value = tonumber(level)

-- profile card
local function updateProfileLevel()
    local playerGui = Players.LocalPlayer:FindFirstChild("PlayerGui")
    local mainGui = playerGui and playerGui:FindFirstChild("MainGui")
    local mainFrame = mainGui and mainGui:FindFirstChild("MainFrame")
    local pages = mainFrame and mainFrame:FindFirstChild("Pages")
    local viewProfile = pages and pages:FindFirstChild("ViewProfile")
    local active = viewProfile and viewProfile:FindFirstChild("Active")
    local profilePlayer = active and active:FindFirstChild("Player")
    local bragging = profilePlayer and profilePlayer:FindFirstChild("Bragging")
    local levelFrame = bragging and bragging:FindFirstChild("Level")
    local valueLabel = levelFrame and levelFrame:FindFirstChild("Value")

    if valueLabel and valueLabel:IsA("TextLabel") then
        valueLabel.Text = tostring(level)
    end
end

-- try immediately
updateProfileLevel()

-- keep checking because the profile UI may be created later
task.spawn(function()
    while task.wait(0.1) do
        updateProfileLevel()
    end
end)

-- changes user character --
function Char()
    print("CHAR START")

    local plr = Players:FindFirstChild(decodedData.name)
    print("PLAYER:", plr)

    if not plr or not plr.Character then
        print("NO CHARACTER")
        return
    end

    print("BEFORE APPEARANCE")

    local appearance = Players:GetCharacterAppearanceAsync(decodedData.id)

    print("AFTER APPEARANCE:", appearance)

    for _, v in ipairs(appearance:GetChildren()) do
        print("FOUND:", v.ClassName, v.Name)
    end

    print("CHAR END")
end

Char()

Players:FindFirstChild(decodedData.name).CharacterAdded:Connect(function(char)
    task.spawn(function()
        for i = 1, 10 do
            task.wait(0.2)

            if Players:FindFirstChild(decodedData.name)
                and Players[decodedData.name].Character == char then

                Char()
                break
            end
        end
    end)
end)

-- changes premium/verified status --
local spoofedPlayer = Players:FindFirstChild(decodedData.name) or friend
local oldNamecall
oldNamecall = hookmetamethod(game, "__index", function(self, key)
    if self == spoofedPlayer then
        if key == "MembershipType" and premium then
            return Enum.MembershipType.Premium
        end
        if key == "HasVerifiedBadge" and verified then
            return true
        end
    end
    return oldNamecall(self, key)
end)

-- gpt code below to handle keys, platform, and other unhandled data --
local imagetable = {
    ["DESKTOP"] = "rbxassetid://17136633356",
    ["MOBILE"] = "rbxassetid://17136633510",
    ["CONSOLE"] = "rbxassetid://17136633629",
    ["VR"] = "rbxassetid://17136765745"
}

game:GetService("RunService").RenderStepped:Connect(function()
    local ctrl =
        Players:FindFirstChild(decodedData.name)
        and Players[decodedData.name].Character
        and Players[decodedData.name].Character:FindFirstChild("HumanoidRootPart")
        and Players[decodedData.name].Character.HumanoidRootPart:FindFirstChild("Nametag")
        and Players[decodedData.name].Character.HumanoidRootPart.Nametag:FindFirstChild("Frame")
        and Players[decodedData.name].Character.HumanoidRootPart.Nametag.Frame:FindFirstChild("Player")
        and Players[decodedData.name].Character.HumanoidRootPart.Nametag.Frame.Player:FindFirstChild("Controls") -- waitforchild will hang the script so i have to do this for literally everything

    if ctrl then
        ctrl.Image = imagetable[platform]
    end
    local container =
        Players.LocalPlayer:FindFirstChild("PlayerGui")
        and Players.LocalPlayer.PlayerGui:FindFirstChild("MainGui")
        and Players.LocalPlayer.PlayerGui.MainGui:FindFirstChild("MainFrame")
        and Players.LocalPlayer.PlayerGui.MainGui.MainFrame:FindFirstChild("DuelInterfaces")
        and Players.LocalPlayer.PlayerGui.MainGui.MainFrame.DuelInterfaces:FindFirstChild("DuelInterface")
        and Players.LocalPlayer.PlayerGui.MainGui.MainFrame.DuelInterfaces.DuelInterface:FindFirstChild("Scoreboard")
        and Players.LocalPlayer.PlayerGui.MainGui.MainFrame.DuelInterfaces.DuelInterface.Scoreboard:FindFirstChild("Container")

    if container then
        for _, v in ipairs(container:GetDescendants()) do
            if v.Name == "Username" and string.find(v.Text, "@" .. decodedData.name) then
                v.Parent.Container.TeammateSlot.Container.Controls.Image = imagetable[platform]
            end
        end
    end
	for _,v in ipairs(
        Players.LocalPlayer
        and Players.LocalPlayer:FindFirstChild("PlayerGui")
        and Players.LocalPlayer.PlayerGui:FindFirstChild("MainGui")
        and Players.LocalPlayer.PlayerGui.MainGui:FindFirstChild("MainFrame")
        and Players.LocalPlayer.PlayerGui.MainGui.MainFrame:FindFirstChild("DuelInterfaces")
        and Players.LocalPlayer.PlayerGui.MainGui.MainFrame.DuelInterfaces:FindFirstChild("DuelInterface")
        and Players.LocalPlayer.PlayerGui.MainGui.MainFrame.DuelInterfaces.DuelInterface:FindFirstChild("Top")
        and Players.LocalPlayer.PlayerGui.MainGui.MainFrame.DuelInterfaces.DuelInterface.Top:FindFirstChild("Scores")
        and Players.LocalPlayer.PlayerGui.MainGui.MainFrame.DuelInterfaces.DuelInterface.Top.Scores:FindFirstChild("Teams")
        and Players.LocalPlayer.PlayerGui.MainGui.MainFrame.DuelInterfaces.DuelInterface.Top.Scores.Teams:GetDescendants()
		or {}
	) do
    	if v.Name == "Headshot" and string.find(v.Image, tostring(victim)) then
       		v.Parent:FindFirstChild("Controls").Image = imagetable[platform]
    	end
	end
	for _,v in ipairs(
   		Players.LocalPlayer
    	and Players.LocalPlayer:FindFirstChild("PlayerGui")
    	and Players.LocalPlayer.PlayerGui:FindFirstChild("MainGui")
    	and Players.LocalPlayer.PlayerGui.MainGui:FindFirstChild("MainFrame")
    	and Players.LocalPlayer.PlayerGui.MainGui.MainFrame:FindFirstChild("DuelInterfaces")
    	and Players.LocalPlayer.PlayerGui.MainGui.MainFrame.DuelInterfaces:FindFirstChild("DuelInterface")
    	and Players.LocalPlayer.PlayerGui.MainGui.MainFrame.DuelInterfaces.DuelInterface:FindFirstChild("FinalResults")
    	and Players.LocalPlayer.PlayerGui.MainGui.MainFrame.DuelInterfaces.DuelInterface.FinalResults:FindFirstChild("Winners")
    	and Players.LocalPlayer.PlayerGui.MainGui.MainFrame.DuelInterfaces.DuelInterface.FinalResults.Winners:FindFirstChild("Players")
    	and Players.LocalPlayer.PlayerGui.MainGui.MainFrame.DuelInterfaces.DuelInterface.FinalResults.Winners.Players:GetDescendants()
    	or {}
		) do
	    if v.Name == "Username" and string.find(v.Text, "@" .. decodedData.name) then
	        local controls = v.Parent and v.Parent.Parent and v.Parent.Parent:FindFirstChild("Controls")
	        if controls then
            	controls.Image = imagetable[platform]
        	end
    	end
	end
	for _, v in ipairs(
    	Players.LocalPlayer
    	and Players.LocalPlayer:FindFirstChild("PlayerGui")
    	and Players.LocalPlayer.PlayerGui:FindFirstChild("MainGui")
    	and Players.LocalPlayer.PlayerGui.MainGui:FindFirstChild("MainFrame")
    	and Players.LocalPlayer.PlayerGui.MainGui.MainFrame:FindFirstChild("Lobby")
    	and Players.LocalPlayer.PlayerGui.MainGui.MainFrame.Lobby:FindFirstChild("Currency")
    	and Players.LocalPlayer.PlayerGui.MainGui.MainFrame.Lobby.Currency:FindFirstChild("Container")
    	and Players.LocalPlayer.PlayerGui.MainGui.MainFrame.Lobby.Currency.Container:GetDescendants()
    	or {}
		) do
		if v.Name == "Icon" and keys and v.Image == "rbxassetid://17860673529" then
			v.Parent.Parent.Title.Text = keys
		end
	end
end)
