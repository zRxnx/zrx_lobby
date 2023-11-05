CORE = exports.zrx_utility:GetUtility()
INVITE, COOLDOWN, LOBBY = false, false, {}
local NetworkIsPlayerActive = NetworkIsPlayerActive

CORE.Client.RegisterKeyMappingCommand(Config.Command, Strings.cmd_desc, Config.Key, function()
    OpenMainMenu()
end)

RegisterNetEvent('zrx_lobby:client:openMenu', function()
    OpenStartMenu()
end)

--| Invite Start
RegisterNetEvent('zrx_lobby:client:processAction', function(action, data)
    if action == 'invite' then
        if INVITE then return end
        INVITE = true
        local text = (Strings.invite_text):format(data.fromName, data.from, data.lobby, #data.players)

        Config.ShowUI(text)
        StartInviteThread(text)
    elseif action == 'invite_end_time' then
        INVITE = false

        Config.HideUI()
    end
end)

StartInviteThread = function(msg)
    CreateThread(function()
        while INVITE do
            Config.ShowUI(msg)
            Wait(1000)
        end
    end)
end
--| Invite end

CreateThread(function()
    lib.waitFor(function()
        return NetworkIsPlayerActive(cache.playerId)
    end, 'Timeout', 60000)

    TriggerServerEvent('zrx_lobby:server:onPlayerLoaded')
end)

exports('openMenu', function()
    OpenMainMenu()
end)

exports('hasCooldown', function()
    return COOLDOWN
end)

exports('getConfig', function()
    return Config
end)