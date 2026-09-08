--[[
    BlackKing execution logger.
    Sends a discord message via the localhost server when someone executes the script.
    Logs: roblox username, executor used, game, placeid, total executions and HWID.
]]

local function CloneReference(Object)
    if BlackKing.Environment.cloneref then
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

local function GetHwid()
    local Ok, Res = pcall(function()
        local HttpService = Services.HttpService
        local MostRecentId = HttpService:GetMostRecentRobuxProductId()
        local DeviceId = HttpService:GetDeviceId()
        local hash = 0
        local Combined = DeviceId .. MostRecentId .. (game:GetService("RbxAnalyticsService"):GetClientId() or "")
        for i = 1, #Combined do
            hash = (hash * 31 + Combined:byte(i)) % 4294967296
        end
        local Charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        local result = {}
        for i = 1, 45 do
            hash = (hash * 1664525 + 1013904223) % 4294967296
            result[i] = Charset:sub((hash % #Charset) + 1, (hash % #Charset) + 1)
        end
        return table.concat(result)
    end)
    return Ok and Res or "Unknown"
end

task.spawn(function()
    pcall(function()
        local Player = Services.Players.LocalPlayer
        local Data = {
            Account = Player.Name,
            Executor = tostring(BlackKing.Environment.identifyexecutor()),
            Executions = tonumber(BlackKing.TotalExecutions) or 0,
            GameName = Services.MarketplaceService:GetProductInfo(game.PlaceId).Name,
            PlaceId = tostring(game.PlaceId),
            HWID = GetHwid()
        }

        pcall(function()
            BlackKing.Environment.request({
                Url = "http://localhost:10577/api/send",
                Method = "POST",
                Headers = {
                    ["content-type"] = "application/json"
                },
                Body = Services.HttpService:JSONEncode(Data)
            })
        end)
    end)
end)
