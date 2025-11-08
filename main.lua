-- Universal Pribinacek Hub Loader
local gameId = game.GameId

if gameId == 2992873140 then
    -- Eternal Hamburg (EH)
    loadstring(game:HttpGet("https://raw.githubusercontent.com/CactusDaExploiter/Pribinacek-Hub/refs/heads/main/EH.lua"))()
elseif gameId == 6331902150 then
    -- Forsaken
    loadstring(game:HttpGet("https://raw.githubusercontent.com/CactusDaExploiter/Pribinacek-Hub/refs/heads/main/Forsaken.lua"))()
else
    warn("[Pribinacek Hub] Unsupported Game ID: " .. tostring(gameId))
end
