local BaseUrl = "https://raw.githubusercontent.com/GeorgeRoblox/AbysallV2/refs/heads/main/"
if game.PlaceId ~= 6516141723 then
    loadstring(game:HttpGet(BaseUrl .. "Games/Doors/Main.luau"))()
else
    print("your in the lobby, this script doesnt support it yet - BlackKing")
    --loadstring(game:HttpGet(BaseUrl .. "Games/Doors/Lobby.luau"))()
end
