--[[
    BlackKing Analytics - execution logger component.
    Sends execution data to the localhost server (/api/send).
    The server handles the discord webhook - the webhook URL never leaves the server.
    Logs: roblox username, executor used, game, placeid, total executions and HWID.
    Made By: Ge0rge.dev V1.0.0
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

local DashboardUrl = "http://localhost:10577/api/send"

local Charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

local function generateHashedId()
    local id = game:GetService("RbxAnalyticsService"):GetClientId()
    local hash = 0
    for i = 1, #id do
        hash = (hash * 31 + id:byte(i)) % 4294967296
    end

    local result = {}
    for i = 1, 45 do
        hash = (hash * 1664525 + 1013904223) % 4294967296
        result[i] = Charset:sub((hash % #Charset) + 1, (hash % #Charset) + 1)
    end
    return table.concat(result)
end

local MyHashedId = generateHashedId()

task.spawn(function()
    pcall(function()
        local Player = Services.Players.LocalPlayer
        local ProductInfo = Services.MarketplaceService:GetProductInfo(game.PlaceId)
        local GameName = ProductInfo and ProductInfo.Name or tostring(game.PlaceId)
        local Executions = tonumber(BlackKing.TotalExecutions) or 0

        local ApiData = {
            Account = Player.Name,
            Executor = tostring(BlackKing.Environment.identifyexecutor()),
            Executions = Executions,
            GameName = GameName,
            PlaceId = tostring(game.PlaceId),
            HWID = MyHashedId
        }

        task.wait(1)

        pcall(function()
            BlackKing.Environment.request({
                Url = DashboardUrl,
                Method = "POST",
                Headers = {
                    ["content-type"] = "application/json"
                },
                Body = Services.HttpService:JSONEncode(ApiData)
            })
        end)
    end)
end)
