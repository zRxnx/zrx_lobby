---@diagnostic disable: cast-local-type, need-check-nil, param-type-mismatch
CORE = exports.zrx_utility:GetUtility()
PLAYERS, PLAYER_CACHE, PENDING_INVITE, COOLDOWN, LOBBY, LOADED, CanLoad = {}, {}, {}, {}, {}, {}, false
local TriggerClientEvent = TriggerClientEvent
local SetRoutingBucketPopulationEnabled = SetRoutingBucketPopulationEnabled
local GetCurrentResourceName = GetCurrentResourceName
local type = type

RegisterNetEvent('zrx_lobby:server:onPlayerLoaded', function()
    if LOADED[source] then
        return Config.PunishPlayer(player, 'Tried to trigger "zrx_lobby:server:onPlayerLoaded"')
    end

    local player = source
    LOADED[player] = true
    PLAYER_CACHE[player] = CORE.Server.GetPlayerCache(player)

    lib.waitFor(function()
        return CanLoad == true
    end, 'Timeout', 5000)

    Function.PlayerLoad(player)
end)

CreateThread(function()
    SetRoutingBucketPopulationEnabled(9999, false)

    MySQL.Sync.execute([[
        CREATE TABLE IF NOT EXISTS `zrx_lobby` (
            `discord` varchar(255) DEFAULT NULL,
            `options` longtext DEFAULT NULL,
            PRIMARY KEY (`discord`)
        ) ENGINE=InnoDB;
    ]])

    Wait(500)

    local password

    for i, player in pairs(GetPlayers()) do
        player = tonumber(player)
        PLAYER_CACHE[player] = CORE.Server.GetPlayerCache(player)
        Player(player).state.discord = PLAYER_CACHE[player].discord
        PLAYERS[player] = true

        local response = MySQL.query.await('SELECT `options` FROM `zrx_lobby` WHERE `discord` = ?', {
            PLAYER_CACHE[player].discord
        })

        if response[1] then
            local options = json.decode(response[1].options)

            LOBBY[PLAYER_CACHE[player].discord] = {
                id = PLAYER_CACHE[player].discord,
                state = 'online',
                lobby = player,
                options = {
                    password = options.password,
                    maxPlayers = options.maxPlayers,
                    npcs = options.npcs
                }
            }
        else
            password = CORE.Shared.GeneratePassword(10)
            MySQL.insert.await('INSERT INTO `zrx_lobby` (discord, options) VALUES (?, ?)', {
                PLAYER_CACHE[player].discord, json.encode({ password = password, maxPlayers = 10, npcs = true})
            })

            LOBBY[PLAYER_CACHE[player].discord] = {
                id = PLAYER_CACHE[player].discord,
                state = 'online',
                lobby = player,
                options = {
                    password = password,
                    maxPlayers = 10,
                    npcs = true
                }
            }
        end
    end

    CanLoad = true

    while true do
        for target, data in pairs(PENDING_INVITE) do
            PENDING_INVITE[target].time -= 1

            if PENDING_INVITE[target].time <= 0 then
                PENDING_INVITE[target] = nil
                TriggerClientEvent('zrx_lobby:client:processAction', target, 'invite_end_time')
                CORE.Bridge.notification(target, Strings.not_accepted)
                CORE.Bridge.notification(data.from, Strings.not_accept)
            end
        end

        Wait(1000)
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end

    for identifier, data in pairs(LOBBY) do
        MySQL.update.await('UPDATE zrx_lobby SET options = ? WHERE discord = ?', {
            json.encode(data.options), identifier
        })
    end
end)

AddEventHandler('playerDropped', function()
    if not PLAYER_CACHE[source] then return end
    LOBBY[PLAYER_CACHE[source].discord].state = 'offline'
    PLAYERS[source] = nil
    PENDING_INVITE[source] = nil

    for player, _ in pairs(PLAYERS) do
        if LOBBY[PLAYER_CACHE[source].discord].lobby == Function.GetCurrentLobby(player) then
            CORE.Bridge.notification(source, Strings.host_left)
        end
    end
end)

RegisterNetEvent('zrx_lobby:server:changeSetting', function(action, data)
    if type(action) ~= 'string' or action ~= 'password' and action ~= 'maxplayers' and action ~= 'npc' then
        return Config.PunishPlayer(source, 'Tried to trigger "zrx_lobby:server:changeSetting"')
    end

    if action == 'password' then
        LOBBY[PLAYER_CACHE[source].discord].options.password = data

        if Webhook.Links.settingLobby:len() > 0 then
            local message = ([[
                The player changed their lobby settings
    
                Action: **%s**
                Data: **%s**
            ]]):format(action, data or 'N/A')

            CORE.Server.DiscordLog(source, 'SETTING CHANGE', message, Webhook.Links.settingLobby)
        end

        CORE.Bridge.notification(source, Strings.change_password)
    elseif action == 'maxplayers' then
        LOBBY[PLAYER_CACHE[source].discord].options.maxPlayers = data

        if Webhook.Links.settingLobby:len() > 0 then
            local message = ([[
                The player changed their lobby settings
    
                Action: **%s**
                Data: **%s**
            ]]):format(action, data or 'N/A')

            CORE.Server.DiscordLog(source, 'SETTING CHANGE', message, Webhook.Links.settingLobby)
        end

        CORE.Bridge.notification(source, Strings.change_max)
    elseif action == 'npc' then
        if data == 'enable' then
            LOBBY[PLAYER_CACHE[source].discord].options.npcs = true

            if Webhook.Links.settingLobby:len() > 0 then
                local message = ([[
                    The player changed their lobby settings
        
                    Action: **%s**
                    Data: **%s**
                ]]):format(action, data or 'N/A')

                CORE.Server.DiscordLog(source, 'SETTING CHANGE', message, Webhook.Links.settingLobby)
            end

            SetRoutingBucketPopulationEnabled(LOBBY[PLAYER_CACHE[source].discord].lobby, true)
            CORE.Bridge.notification(source, Strings.change_npc_true)
        elseif data == 'disable' then
            LOBBY[PLAYER_CACHE[source].discord].options.npcs = false

            if Webhook.Links.settingLobby:len() > 0 then
                local message = ([[
                    The player changed their lobby settings
        
                    Action: **%s**
                    Data: **%s**
                ]]):format(action, data or 'N/A')

                CORE.Server.DiscordLog(source, 'SETTING CHANGE', message, Webhook.Links.settingLobby)
            end

            SetRoutingBucketPopulationEnabled(LOBBY[PLAYER_CACHE[source].discord].lobby, false)
            CORE.Bridge.notification(source, Strings.change_npc_false)
        end
    end
end)

RegisterNetEvent('zrx_lobby:server:processAction', function(action, target)
    if type(action) ~= 'string' or action ~= 'public' and action ~= 'reset' and action ~= 'invite' and action ~= 'accept_invite' and action ~= 'kick' then
        return Config.PunishPlayer(source, 'Tried to trigger "zrx_lobby:server:processAction"')
    end

    if action == 'reset' then
        LOBBY[PLAYER_CACHE[source].discord].state = 'online'

        for player, _ in pairs(PLAYERS) do
            if LOBBY[PLAYER_CACHE[source].discord].lobby == Function.GetCurrentLobby(player) then
                CORE.Bridge.notification(source, Strings.host_joined)
            end
        end

        Function.SetLobby(source, LOBBY[PLAYER_CACHE[source].discord].lobby)
    elseif action == 'public' then
        LOBBY[PLAYER_CACHE[source].discord].state = 'public'

        for player, _ in pairs(PLAYERS) do
            if LOBBY[PLAYER_CACHE[source].discord].lobby == Function.GetCurrentLobby(player) and LOBBY[PLAYER_CACHE[source].discord].id ~= LOBBY[PLAYER_CACHE[player].discord].id then
                CORE.Bridge.notification(source, Strings.host_left)
            end
        end

        Function.SetLobby(source, 0)
    elseif action == 'kick' then
        if LOBBY[PLAYER_CACHE[source].discord].lobby == Function.GetCurrentLobby(target) then
            Function.KickTarget(source, target)
        else
            CORE.Bridge.notification(source, Strings.player_there_not)
        end
    elseif action == 'invite' then
        if LOBBY[PLAYER_CACHE[source].discord].lobby ~= Function.GetCurrentLobby(target) then
            Function.InviteTarget(source, target)
        else
            CORE.Bridge.notification(source, Strings.player_there)
        end
    elseif action == 'accept_invite' then
        PENDING_INVITE[source] = nil

        Function.SetLobby(source, LOBBY[target].lobby)
        CORE.Bridge.notification(source, Strings.accept_pending)
        CORE.Bridge.notification(target, Strings.accepted_pending)
        TriggerClientEvent('zrx_lobby:client:processAction', source, 'invite_end_time')
    end
end)

lib.callback.register('zrx_lobby:server:canPlayerJoinLobby', function(source, lobby, password)
    if not lobby or not password or type(lobby) ~= 'number' or type(password) ~= 'string' then
        return Config.PunishPlayer(source, 'Tried to trigger "zrx_lobby:server:canPlayerJoinLobby"')
    end

    local count = 0

    if not LOBBY[lobby] then
        for i, data in pairs(LOBBY) do
            if data.lobby == lobby then
                lobby = data.id
                break
            end
        end
    end

    if not lobby then
        return CORE.Bridge.notification(source, Strings.invalid_input)
    end

    if LOBBY[lobby]?.options?.password == password then
        for player, _ in pairs(PLAYERS) do
            if LOBBY[lobby].lobby == Function.GetCurrentLobby(player) then
                count += 1
            end
        end

        if count < LOBBY[lobby].options.maxPlayers then
            for player, _ in pairs(PLAYERS) do
                if LOBBY[lobby].lobby == Function.GetCurrentLobby(player) then
                    CORE.Bridge.notification(player, (Strings.join_lobby):format(PLAYER_CACHE[player].name))
                end
            end

            Function.SetLobby(source, LOBBY[lobby].lobby)
            CORE.Bridge.notification(source, Strings.change_lobby)

            return true
        else
            CORE.Bridge.notification(source, Strings.full_lobby)

            return false
        end
    else
        CORE.Bridge.notification(source, Strings.password_wrong_lobby)

        return false
    end
end)

lib.callback.register('zrx_lobby:server:getPlayerLobbyData', function(source)
    local lobby, players = LOBBY[PLAYER_CACHE[source].discord], {}

    for player, _ in pairs(PLAYERS) do
        if lobby.lobby == Function.GetCurrentLobby(player) then
            players[#players + 1] = {
                id = player,
                discord = PLAYER_CACHE[player].discord,
                name = PLAYER_CACHE[player].name,
            }
        end
    end

    return {
        id = lobby.id,
        lobby = lobby.lobby,
        players = players,
        options = lobby.options
    }
end)

lib.callback.register('zrx_lobby:server:getPlayerCurrentLobbyData', function(source)
    local players, currentLobby = {}, Function.GetCurrentLobby(source)
    local lobbyId, lobbyData = 0, {}

    for player, _ in pairs(PLAYERS) do
        players[#players + 1] = {
            id = player,
            discord = PLAYER_CACHE[player].discord,
            name = PLAYER_CACHE[player].name,
            lobby = Function.GetCurrentLobby(player)
        }
    end

    if currentLobby > 0 then
        for i, data in pairs(LOBBY) do
            if data.lobby == currentLobby then
                lobbyId = data.id
                break
            end
        end

        lobbyData = LOBBY[lobbyId]

        if lobbyData?.id ~= PLAYER_CACHE[source]?.discord then
            lobbyData.options.password = 'NOT HOST'
        end
    end

    return {
        id = lobbyData?.id or 0,
        lobby = currentLobby,
        lobbyState = lobbyData?.state or 'public',
        allPlayers = players,
        invite = PENDING_INVITE[source],
        options = lobbyData?.options
    }
end)

lib.callback.register('zrx_lobby:server:getServerData', function(source)
    local players, publicPlayers, playerLobby = {}, {}, 0

    for player, _ in pairs(PLAYERS) do
        playerLobby = Function.GetCurrentLobby(player)

        players[#players + 1] = {
            id = player,
            discord = PLAYER_CACHE[player].discord,
            name = PLAYER_CACHE[player].name,
            lobby = playerLobby
        }

        if playerLobby == 0 then
            publicPlayers[#publicPlayers + 1] = {
                id = player,
                name = PLAYER_CACHE[player].name,
            }
        end
    end

    return {
        id = Function.GetLobby(source),
        lobby = Function.GetCurrentLobby(source),
        allPlayers = players,
        publicPlayers = publicPlayers,
        maxPlayers = GetConvarInt('sv_maxClients', 48),
    }
end)

exports('hasCooldown', function(player)
    return not not COOLDOWN[player]
end)

exports('getConfig', function()
    return Config
end)