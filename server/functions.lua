local SetPlayerRoutingBucket = SetPlayerRoutingBucket
local GetPlayerRoutingBucket = GetPlayerRoutingBucket
local TriggerClientEvent = TriggerClientEvent

Function = {
    PlayerLoad = function(player)
        Player(player).state.discord = PLAYER_CACHE[player].discord
        PLAYERS[player] = true

        if not LOBBY[PLAYER_CACHE[player].discord] then
            LOBBY[PLAYER_CACHE[player].discord] = {
                id = PLAYER_CACHE[player].discord,
                state = 'online',
                lobby = player,
                options = {
                    password = CORE.Shared.GeneratePassword(10),
                    maxPlayers = 10,
                    npcs = true
                }
            }
        end

        if Webhook.Links.switchLobby:len() > 0 then
            local message = ([[
                The player set their lobby
    
                Lobby UID: **%s**
                Lobby ID: **%s**
            ]]):format(PLAYER_CACHE[player].discord, player)

            CORE.Server.DiscordLog(player, 'SWITCH LOBBY', message, Webhook.Links.switchLobby)
        end

        TriggerClientEvent('zrx_lobby:client:openMenu', player)
        Function.SetLobby(player, 9999)
    end,

    SetLobby = function(player, lobby)
        SetPlayerRoutingBucket(player, lobby)
        CORE.Bridge.notification(player, (Strings.setlobby):format(lobby == 0 and Strings.public or lobby == 9999 and Strings.spawn or lobby == LOBBY[PLAYER_CACHE[player].discord].lobby and Strings.your or lobby))

        if Webhook.Links.switchLobby:len() > 0 then
            local message = ([[
                The player set their lobby
    
                Lobby ID: **%s**
            ]]):format(player)

            CORE.Server.DiscordLog(player, 'SWITCH LOBBY', message, Webhook.Links.switchLobby)
        end
    end,

    GetLobby = function(player)
        return LOBBY[PLAYER_CACHE[player].discord].lobby
    end,

    GetCurrentLobby = function(player)
        return GetPlayerRoutingBucket(player)
    end,

    KickTarget = function(player, target)
        SetPlayerRoutingBucket(target, LOBBY[PLAYER_CACHE[target].discord].lobby)
        CORE.Bridge.notification(player, Strings.kick)
        CORE.Bridge.notification(target, Strings.kicked)

        if Webhook.Links.kickPlayer:len() > 0 then
            local message = ([[
                The player kicked a person
    
                Player ID: **%s**
                Player Name: **%s**
            ]]):format(target, PLAYER_CACHE[target].name)

            CORE.Server.DiscordLog(player, 'KICK PLAYER', message, Webhook.Links.kickPlayer)
        end
    end,

    InviteTarget = function(player, target)
        if PENDING_INVITE[target] then
            return CORE.Bridge.notification(player, Strings.pending)
        end

        local players = {}

        for player2, _ in pairs(PLAYERS) do
            if LOBBY[PLAYER_CACHE[player].discord].lobby == Function.GetCurrentLobby(target) then
                players[#players + 1] = {
                    id = target,
                    discord = PLAYER_CACHE[target].discord,
                    name = PLAYER_CACHE[target].name,
                }
            end
        end

        PENDING_INVITE[target] = {
            from = player,
            fromName = PLAYER_CACHE[player].name,
            lobby = LOBBY[PLAYER_CACHE[player].discord].id,
            state = 'pending',
            time = 10,
            players = players
        }

        if Webhook.Links.invitePlayer:len() > 0 then
            local message = ([[
                The player invited a person
    
                Player ID: **%s**
                Player Name: **%s**
                Invite ID: **%s**
                Lobby UID: **%s**
                Lobby ID: **%s**
            ]]):format(target, PLAYER_CACHE[target].name, #PENDING_INVITE, LOBBY[PLAYER_CACHE[player].discord].id, LOBBY[PLAYER_CACHE[player].discord].lobby)

            CORE.Server.DiscordLog(player, 'INVITE PLAYER', message, Webhook.Links.invitePlayer)
        end

        CORE.Bridge.notification(player, Strings.invite)
        CORE.Bridge.notification(target, Strings.invited)
        TriggerClientEvent('zrx_lobby:client:processAction', target, 'invite', PENDING_INVITE[target])
    end,

    HasCooldown = function(player)
        if not Config.Cooldown then return false end
        local identifier = PLAYER_CACHE[player].license

        if COOLDOWN[identifier] then
            if os.time() - Config.Cooldown > COOLDOWN[identifier] then
                COOLDOWN[identifier] = nil
            else
                return true
            end
        else
            COOLDOWN[identifier] = os.time()
        end

        return false
    end
}