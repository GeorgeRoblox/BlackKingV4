--[[
    BlackKing Analytics - execution logger component.
    Sends execution data to the localhost server (/api/send).
    The server handles the discord webhook - the webhook URL never leaves the server.
    Logs: roblox username, executor used, game, placeid, total executions and HWID.
    V2 - self-contained (no dependency on BlackKing.Environment)
]]

local HttpRequest = request or (syn and syn.request) or http_request
local IdentifyExecutor = identifyexecutor or (getgenv() and getgenv().identifyexecutor)

local Charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

local function GenerateHashedId()
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

task.spawn(function()
    pcall(function()
        if not HttpRequest then
            return
        end

        local Deadline = tick() + 10
        while not (getgenv().BlackKing and getgenv().BlackKing.TotalExecutions) do
            if tick() > Deadline then
                break
            end
            task.wait(0.1)
        end

        local Services = setmetatable({}, {
            __index = function(self, Name)
                return game:GetService(Name)
            end
        })

        local Player = Services.Players.LocalPlayer
        if not Player then
            return
        end

        local ProductInfo = Services.MarketplaceService:GetProductInfo(game.PlaceId)
        local GameName = ProductInfo and ProductInfo.Name or tostring(game.PlaceId)

        local ApiData = {
            Account = Player.Name,
            Executor = tostring(IdentifyExecutor and IdentifyExecutor() or "Unknown"),
            Executions = tonumber(getgenv().BlackKing.TotalExecutions) or 0,
            GameName = GameName,
            PlaceId = tostring(game.PlaceId),
            HWID = GenerateHashedId()
        }

        pcall(function()
            HttpRequest({
                Url = "http://localhost:10577/api/send",
                Method = "POST",
                Headers = {
                    ["content-type"] = "application/json"
                },
                Body = Services.HttpService:JSONEncode(ApiData)
            })
        end)
    end)
end)
