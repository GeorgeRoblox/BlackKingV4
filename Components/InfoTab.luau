return function(Window)
    local LatestChangelog = {
        "[DOORS]",
        "<font color='rgb(0, 255, 0)'>+ Added Full Archives Support.</font>",
		"<font color='rgb(0, 255, 0)'>+ Added Stairwell Support.</font>",
		"<font color='rgb(0, 255, 0)'>+ Added Anti Ransom.</font>",
		"<font color='rgb(0, 255, 0)'>+ Added Anti Scribbles.</font>",
		"<font color='rgb(0, 255, 0)'>+ Added Anti Drones.</font>",
		"<font color='rgb(0, 255, 0)'>+ Added Anti Stampede of Drones.</font>",
		"<font color='rgb(0, 255, 0)'>+ Added Auto ForGetMeNot.</font>",
		"<font color='rgb(0, 255, 0)'>+ Added Auto Look At Flowers.</font>",
		"<font color='rgb(0, 255, 0)'>+ Added Anti Puddle.</font>",
		"<font color='rgb(0, 255, 0)'>+ Added New Velocity Manipulation Method.</font>",
		"<font color='rgb(0, 255, 0)'>+ Added New Item Esp.</font>",
		"<font color='rgb(0, 255, 0)'>+ Added New Entity Esp.</font>",
		"<font color='rgb(0, 255, 0)'>+ Added New Hiding Spot Esp.</font>",

    }

    local function CloneReference(Object)
        if BlackKing and BlackKing.Environment.cloneref then
            return BlackKing.Environment.cloneref(Object)
        else
            return Object
        end
    end

    local Services = setmetatable({}, {
        __index = function(self, Name)
            return CloneReference(game:GetService(Name))
        end
    })

    local Library = BlackKing.Interface.Library
    local SaveManager = BlackKing.Interface.SaveManager
    local ThemeManager = BlackKing.Interface.ThemeManager

    local Toggles = Library.Toggles
    local Options = Library.Options

    local LocalPlayer = Services.Players.LocalPlayer
    local InfoTab = Window:AddTab("Info", "user")

    local User = InfoTab:AddLeftGroupbox("User Info")

    local ImageSize = Enum.ThumbnailSize.Size420x420
    local ImageType = Enum.ThumbnailType.HeadShot

    local Content = Services.Players:GetUserThumbnailAsync(LocalPlayer.UserId, ImageType, ImageSize)

    User:AddImage("UserIcon", {
        Image = Content
    })

    User:AddLabel("ID: " .. LocalPlayer.Name, true)
    User:AddLabel("Total Executions: " .. (BlackKing.TotalExecutions and BlackKing.TotalExecutions or "N/A"), true)

    local changelogText = table.concat(LatestChangelog, "\n")
    InfoTab:UpdateWarningBox({
        Title = "Latest Changelog",
        Text = changelogText,
        IsNormal = true,
        Visible = true,
        LockSize = true,
    })

    local Name, Version = BlackKing.Environment.identifyexecutor()
    local Executor = InfoTab:AddRightGroupbox("Executor Info")
    Executor:AddLabel("Name: " .. Name, true)
	Executor:AddLabel("Version: " .. (Version and Version or "N/A"), true)
    Executor:AddDivider()
    Executor:AddLabel("Test Result: ", true)

    for Index, Result in pairs(BlackKing.Environment.Results) do
		-- fix for veloshitty 💔
		Result = Result:gsub("<", "(")
		Result = Result:gsub(">", ")")
		
        Executor:AddLabel(Result, true)
    end

    local Community = InfoTab:AddLeftGroupbox("Community")
    Community:AddButton("Copy Discord Invite", function()
	    toclipboard("https://dsc.gg/BlackKinghub")
	    Library:Notify("Discord invite copied.")
    end)
	    local Donation = InfoTab:AddLeftGroupbox("Donation")
    Donation:AddButton("PayPal", function()
	    toclipboard("https://paypal.me/BlackKingOfficial")
	    Library:Notify("PayPal link copied.")
    end)
end
