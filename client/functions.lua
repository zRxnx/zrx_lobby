local groundCam, groundCam2, cloudCam, state
local TriggerServerEvent = TriggerServerEvent
local DisplayRadar = DisplayRadar
local HideHudComponentThisFrame = HideHudComponentThisFrame
local CreateCamWithParams = CreateCamWithParams
local RenderScriptCams = RenderScriptCams
local SetCamActiveWithInterp = SetCamActiveWithInterp
local SetGameplayCamRelativeHeading = SetGameplayCamRelativeHeading
local SetGameplayCamRelativeRotation = SetGameplayCamRelativeRotation
local DestroyCam = DestroyCam
local GetEntityCoords = GetEntityCoords
local SetEntityCoords = SetEntityCoords
local SetEntityHeading = SetEntityHeading
local GetEntityHeading = GetEntityHeading

OpenStartMenu = function()
    local MENU = {}
    local LOBBY_DATA = lib.callback.await('zrx_lobby:server:getPlayerLobbyData', 100)
    local PUBLIC_DATA = lib.callback.await('zrx_lobby:server:getServerData', 100)

    CloudCamera()

    MENU[#MENU + 1] = {
        title = Strings.lobby_private,
        description = Strings.lobby_private_desc,
        arrow = true,
        icon = 'fa-solid fa-inbox',
        iconColor = Config.IconColor,
        metadata = {
            {
                label = Strings.lobby_private_id,
                value = (Strings.lobby_private_id_desc):format(LOBBY_DATA.id)
            },
            {
                label = Strings.lobby_private_count,
                value = (Strings.lobby_private_count_desc):format(#LOBBY_DATA.players, LOBBY_DATA.options.maxPlayers)
            },
        },
        onSelect = function()
            OpenSpawnSelectMenu()
            TriggerServerEvent('zrx_lobby:server:processAction', 'reset')
        end
    }

    MENU[#MENU + 1] = {
        title = Strings.lobby_public,
        description = Strings.lobby_public_desc,
        arrow = true,
        icon = 'fa-solid fa-user-group',
        iconColor = Config.IconColor,
        metadata = {
            {
                label = Strings.lobby_public_id,
                value = Strings.lobby_public_id_desc
            },
            { 
                label = Strings.lobby_public_count,
                value = (Strings.lobby_public_count_desc):format(#PUBLIC_DATA.publicPlayers, PUBLIC_DATA.maxPlayers)
            },
        },
        onSelect = function()
            OpenSpawnSelectMenu()
            TriggerServerEvent('zrx_lobby:server:processAction', 'public')
        end
    }

    MENU[#MENU + 1] = {
        title = Strings.lobby_password,
        description = Strings.lobby_password_desc,
        arrow = true,
        icon = 'fa-solid fa-hashtag',
        iconColor = Config.IconColor,
        onSelect = function()
            local input = lib.inputDialog(Strings.lobby_password_title, {
                {
                    type = 'number',
                    label = Strings.lobby_password_id,
                    description = Strings.lobby_password_id_desc,
                    required = true,
                    min = 1
                },
                {
                    type = 'input',
                    label = Strings.lobby_password_password,
                    description = Strings.lobby_password_password_desc,
                    required = true,
                    min = 6,
                    max = 10,
                    password = true
                },
            })

            if input then
                local result = lib.callback.await('zrx_lobby:server:canPlayerJoinLobby', 100, input[1], input[2])

                if not result then
                    return OpenStartMenu()
                end
            else
                CORE.Bridge.notification(Strings.invalid_input)
                return OpenStartMenu()
            end

            OpenSpawnSelectMenu()
        end
    }

    CORE.Client.CreateMenu({
        id = 'zrx_lobby:start_menu',
        title = Strings.menu_start,
        canClose = false,
    }, MENU, Config.Menu.type ~= 'menu', Config.Menu.postition)
end

OpenSpawnSelectMenu = function()
    local MENU = {}

    for i, data in pairs(Config.SpawnSelect) do
        MENU[#MENU + 1] = {
            title = data.label,
            description = Strings.selector_desc,
            arrow = true,
            icon = data.icon,
            iconColor = Config.IconColor,
            onSelect = function()
                CameraToPlayer(data.coords.x, data.coords.y, data.coords.z, data.coords[4])
            end
        }
    end

    CORE.Client.CreateMenu({
        id = 'zrx_lobby:spawn_menu',
        title = Strings.menu_spawn,
        canClose = false,
    }, MENU, Config.Menu.type ~= 'menu', Config.Menu.postition)
end

OpenMainMenu = function()
    local MENU, playersInLobby, playersOutLobby = {}, {}, {}
    local LOBBY_DATA = lib.callback.await('zrx_lobby:server:getPlayerCurrentLobbyData', 100)
    local LOBBY_TITLE = (LOBBY_DATA.id == LocalPlayer.state.discord and LOBBY_DATA.id ~= LOBBY_DATA.lobby) and Strings.private_lobby or Strings.public_lobby

    if not LOBBY_DATA?.allPlayers then
        return CORE.Bridge.notification(Strings.on_cooldown)
    end

    for i, data in pairs(LOBBY_DATA.allPlayers) do
        if LOBBY_DATA.lobby == data.lobby then
            playersInLobby[#playersInLobby + 1] = data
        end

        if LOBBY_DATA.lobby ~= data.lobby or LOBBY_DATA.id == LocalPlayer.state.discord then
            playersOutLobby[#playersOutLobby + 1] = data
        end
    end

    MENU[#MENU + 1] = {
        title = Strings.main_info,
        description = Strings.main_info_desc,
        arrow = true,
        icon = 'fa-solid fa-circle-info',
        iconColor = Config.IconColor,
        onSelect = function()
            OpenInfoMenu()
        end
    }

    MENU[#MENU + 1] = {
        title = Strings.main_public,
        description = Strings.main_public_desc,
        arrow = LOBBY_DATA.lobby ~= 0,
        icon = 'fa-solid fa-user-group',
        iconColor = Config.IconColor,
        disabled = LOBBY_DATA.lobby == 0,
        onSelect = function()
            CameraToStart()
            CloudCamera()
            OpenSpawnSelectMenu()
            TriggerServerEvent('zrx_lobby:server:processAction', 'public')
        end
    }

    MENU[#MENU + 1] = {
        title = Strings.main_password,
        description = Strings.main_password_desc,
        arrow = true,
        icon = 'fa-solid fa-hashtag',
        iconColor = Config.IconColor,
        onSelect = function()
            local input = lib.inputDialog(Strings.main_password_title, {
                {
                    type = 'number',
                    label = Strings.main_password_id,
                    description = Strings.main_password_id_desc,
                    required = true,
                    min = 1
                },
                {
                    type = 'input',
                    label = Strings.main_password_password,
                    description = Strings.main_password_password_desc,
                    required = true,
                    min = 6,
                    max = 10,
                    password = true
                },
            })

            if input then
                local result = lib.callback.await('zrx_lobby:server:canPlayerJoinLobby', 100, input[1], input[2])

                if not result then
                    return OpenMainMenu()
                end

                CameraToStart()
                CloudCamera()
                OpenSpawnSelectMenu()
            else
                CORE.Bridge.notification(Strings.invalid_input)
                return OpenMainMenu()
            end
        end
    }

    MENU[#MENU + 1] = {
        title = Strings.main_switch,
        description = Strings.main_switch_desc,
        arrow = LOBBY_DATA.id ~= LocalPlayer.state.discord or LOBBY_DATA.id == LOBBY_DATA.lobby,
        icon = 'fa-regular fa-window-restore',
        iconColor = Config.IconColor,
        disabled = LOBBY_DATA.id == LocalPlayer.state.discord and LOBBY_DATA.id ~= LOBBY_DATA.lobby,
        onSelect = function()
            CameraToStart()
            CloudCamera()
            OpenSpawnSelectMenu()
            TriggerServerEvent('zrx_lobby:server:processAction', 'reset')
        end
    }

    if LOBBY_DATA.id == LocalPlayer.state.discord and LOBBY_DATA.id ~= LOBBY_DATA.lobby then
        MENU[#MENU + 1] = {
            title = Strings.main_invite,
            description = Strings.main_invite_desc,
            arrow = LOBBY_DATA.id == LocalPlayer.state.discord and #playersOutLobby >= 2,
            icon = 'fa-solid fa-briefcase',
            iconColor = Config.IconColor,
            disabled = LOBBY_DATA.id ~= LocalPlayer.state.discord or #playersOutLobby <= 1,
            onSelect = function()
                OpenInviteMenu()
            end
        }

        MENU[#MENU + 1] = {
            title = Strings.main_kick,
            description = Strings.main_kick_desc,
            arrow = LOBBY_DATA.id == LocalPlayer.state.discord and #playersInLobby >= 2,
            icon = 'fa-solid fa-ban',
            iconColor = Config.IconColor,
            disabled = LOBBY_DATA.id ~= LocalPlayer.state.discord or #playersInLobby <= 1,
            onSelect = function()
                OpenKickMenu()
            end
        }
    end

    if LOBBY_DATA?.invite?.state == 'pending' then
        MENU[#MENU + 1] = {
            title = Strings.main_ainvite,
            description = (Strings.main_ainvite_desc):format(LOBBY_DATA.invite.fromName),
            arrow = true,
            icon = 'fa-solid fa-circle-check',
            iconColor = Config.IconColor,
            metadata = {
                {
                    label = Strings.main_ainvite_from,
                    value = (Strings.main_ainvite_from_desc):format(LOBBY_DATA.invite.fromName, LOBBY_DATA.invite.from)
                },
                {
                    label = Strings.main_ainvite_lobby,
                    value = (Strings.main_ainvite_lobby_desc):format(LOBBY_DATA.invite.lobby)
                }
            },
            args = {
                lobby = LOBBY_DATA.invite.lobby
            },
            onSelect = function(args)
                TriggerServerEvent('zrx_lobby:server:processAction', 'accept_invite', args.lobby)
            end
        }
    end

    CORE.Client.CreateMenu({
        id = 'zrx_lobby:main_menu',
        title = Strings.menu_main,
    }, MENU, Config.Menu.type ~= 'menu', Config.Menu.postition)
end

OpenInfoMenu = function()
    local MENU, METADATA = {}, {}
    local LOBBY_DATA = lib.callback.await('zrx_lobby:server:getPlayerCurrentLobbyData', 100)
    local PUBLIC_DATA = lib.callback.await('zrx_lobby:server:getServerData', 100)

    if not LOBBY_DATA?.allPlayers then
        CORE.Bridge.notification(Strings.on_cooldown)
        return OpenMainMenu()
    end

    for k, data in pairs(LOBBY_DATA.allPlayers) do
        if LOBBY_DATA.lobby == data.lobby then
            METADATA[#METADATA + 1] = {
                label = (Strings.info_meta):format(data.name, data.discord == LocalPlayer.state.discord and Strings.you or '', LOBBY_DATA.id == Player(data.id).state?.discord and Strings.host or ''),
                value = data.id
            }
        end
    end

    if LOBBY_DATA.id == LocalPlayer.state.discord then
        MENU[#MENU + 1] = {
            title = Strings.info_manage,
            description = Strings.info_manage_desc,
            arrow = true,
            icon = 'fa-solid fa-circle-info',
            iconColor = Config.IconColor,
            onSelect = function()
                OpenManageMenu()
            end
        }
    end

    if LOBBY_DATA.id ~= LocalPlayer.state.discord and LOBBY_DATA.id > 0 then
        MENU[#MENU + 1] = {
            title = Strings.info_status,
            description = (Strings.info_status_desc):format(LOBBY_DATA.lobbyState:upper()),
            arrow = false,
            icon = 'fa-solid fa-signal',
            iconColor = Config.IconColor,
        }
    end

    if LOBBY_DATA.id == LocalPlayer.state.discord then
        MENU[#MENU + 1] = {
            title = Strings.info_password,
            description = Strings.info_password_desc,
            arrow = true,
            icon = 'fa-solid fa-key',
            iconColor = Config.IconColor,
            metadata = {
                {
                    label = Strings.info_password_password,
                    value = (Strings.info_password_password_desc):format(LOBBY_DATA.options.password)
                }
            },
            onSelect = function()
                lib.setClipboard(LOBBY_DATA.options.password)
            end
        }
    end

    if tonumber(LOBBY_DATA.id) > 0 then
        MENU[#MENU + 1] = {
            title = Strings.info_settings,
            description = Strings.info_settings_desc,
            arrow = false,
            icon = 'fa-solid fa-gear',
            iconColor = Config.IconColor,
            metadata = {
                {
                    label = Strings.info_settings_password,
                    value = Strings.info_settings_password_desc
                },
                {
                    label = Strings.info_settings_max,
                    value = (Strings.info_settings_max_desc):format(LOBBY_DATA.options.maxPlayers)
                },
                {
                    label = Strings.info_settings_npc,
                    value = (Strings.info_settings_npcs_desc):format(LOBBY_DATA.options.npcs and Strings.enabled or Strings.disabled)
                },
            }
        }
    end

    MENU[#MENU + 1] = {
        title = Strings.current_lobby,
        description = (Strings.current_lobby_desc):format(LOBBY_DATA.id == 0 and Strings.public or LOBBY_DATA.id),
        arrow = false,
        icon = 'fa-solid fa-lock',
        iconColor = Config.IconColor,
    }

    MENU[#MENU + 1] = {
        title = Strings.current_player,
        description = (Strings.current_player_desc):format(#METADATA, LOBBY_DATA.id == 0 and PUBLIC_DATA.maxPlayers or LOBBY_DATA.options.maxPlayers),
        arrow = false,
        icon = 'fa-solid fa-hashtag',
        iconColor = Config.IconColor,
    }

    MENU[#MENU + 1] = {
        title = Strings.current_players,
        description = Strings.current_players_desc,
        arrow = false,
        icon = 'fa-solid fa-user-group',
        iconColor = Config.IconColor,
        metadata = METADATA
    }

    CORE.Client.CreateMenu({
        id = 'zrx_lobby:info_menu',
        title = Strings.menu_info,
        menu = 'zrx_lobby:main_menu'
    }, MENU, Config.Menu.type ~= 'menu', Config.Menu.postition)
end

OpenInviteMenu = function()
    local MENU = {}
    local SERVER_DATA = lib.callback.await('zrx_lobby:server:getServerData', 100)

    if not SERVER_DATA?.allPlayers then
        CORE.Bridge.notification(Strings.on_cooldown)
        return OpenMainMenu()
    end

    for k, data in pairs(SERVER_DATA.allPlayers) do
        if data.lobby ~= SERVER_DATA.lobby then
            MENU[#MENU + 1] = {
                title = (Strings.invite_title):format(data.name, data.id, LocalPlayer.state.discord == data.discord and Strings.you or ''),
                description = Strings.invite_desc,
                arrow = LocalPlayer.state.discord ~= data.discord,
                icon = 'fa-solid fa-user-group',
                iconColor = Config.IconColor,
                disabled = LocalPlayer.state.discord == data.discord,
                args = {
                    target = data.id
                },
                onSelect = function(args)
                    local alert = lib.alertDialog({
                        header = Strings.invite_header,
                        content = Strings.invite_content,
                        centered = true,
                        cancel = true
                    })

                    if alert == 'confirm' then
                        TriggerServerEvent('zrx_lobby:server:processAction', 'invite', args.target)
                    else
                        OpenMainMenu()
                    end
                end
            }
        end
    end

    CORE.Client.CreateMenu({
        id = 'zrx_lobby:invite_menu',
        title = Strings.menu_invite,
        menu = 'zrx_lobby:main_menu'
    }, MENU, Config.Menu.type ~= 'menu', Config.Menu.postition)
end

OpenKickMenu = function()
    local MENU = {}
    local LOBBY_DATA = lib.callback.await('zrx_lobby:server:getPlayerCurrentLobbyData', 100)

    if not LOBBY_DATA?.allPlayers then
        CORE.Bridge.notification(Strings.on_cooldown)
        return OpenMainMenu()
    end

    for k, data in pairs(LOBBY_DATA.allPlayers) do
        if data.lobby == LOBBY_DATA.lobby then
            MENU[#MENU + 1] = {
                title = (Strings.kick_title):format(data.name, data.id, LocalPlayer.state.discord == data.discord and '(You)' or ''),
                description = Strings.kick_desc,
                arrow = LocalPlayer.state.discord ~= data.discord,
                icon = 'fa-solid fa-user-group',
                iconColor = Config.IconColor,
                disabled = LocalPlayer.state.discord == data.discord,
                args = {
                    target = data.id
                },
                onSelect = function(args)
                    TriggerServerEvent('zrx_lobby:server:processAction', 'kick', args.target)
                end
            }
        end
    end

    CORE.Client.CreateMenu({
        id = 'zrx_lobby:kick_menu',
        title = Strings.menu_kick,
        menu = 'zrx_lobby:main_menu'
    }, MENU, Config.Menu.type ~= 'menu', Config.Menu.postition)
end

OpenManageMenu = function()
    local MENU = {}
    local LOBBY_DATA = lib.callback.await('zrx_lobby:server:getPlayerCurrentLobbyData', 100)
    local SERVER_DATA = lib.callback.await('zrx_lobby:server:getServerData', 100)

    if not LOBBY_DATA?.allPlayers then
        CORE.Bridge.notification(Strings.on_cooldown)
        return OpenMainMenu()
    end

    MENU[#MENU + 1] = {
        title = Strings.manage_password,
        description = Strings.manage_password_desc,
        arrow = true,
        icon = 'fa-solid fa-key',
        iconColor = Config.IconColor,
        onSelect = function()
            local input = lib.inputDialog(Strings.manage_password_new_title, {
                {
                    type = 'input',
                    label = Strings.manage_password_new,
                    description = Strings.manage_password_new_desc,
                    required = true,
                    min = 6,
                    max = 10,
                    password = true
                },
            })

            if input then
                TriggerServerEvent('zrx_lobby:server:changeSetting', 'password', input[1])
            else
                CORE.Bridge.notification(Strings.invalid_input)
            end
        end
    }

    MENU[#MENU + 1] = {
        title = Strings.manage_max,
        description = Strings.manage_max_desc,
        arrow = true,
        icon = 'fa-solid fa-hashtag',
        iconColor = Config.IconColor,
        onSelect = function()
            local input = lib.inputDialog(Strings.manage_max_new_title, {
                {
                    type = 'number',
                    label = Strings.manage_max_new,
                    description = Strings.manage_max_new_desc,
                    required = true,
                    min = 2,
                    max = SERVER_DATA.maxPlayers
                },
            })

            if input[1] > 1 then
                TriggerServerEvent('zrx_lobby:server:changeSetting', 'maxplayers', input[1])
            elseif input <= 1 then
                CORE.Bridge.notification(Strings.invalid_max_players)
            else
                CORE.Bridge.notification(Strings.invalid_input)
            end
        end
    }

    MENU[#MENU + 1] = {
        title = Strings.manage_npc,
        description = Strings.manage_npc_desc,
        arrow = true,
        icon = 'fa-solid fa-user-group',
        iconColor = Config.IconColor,
        onSelect = function()
            local input = lib.inputDialog(Strings.manage_npc_new_title, {
                {
                    type = 'select',
                    label = Strings.manage_npc_new,
                    description = Strings.manage_npc_new_desc,
                    required = true,
                    options = {
                        {
                            label = Strings.enable,
                            value = 'enable'
                        },
                        {
                            label = Strings.disable,
                            value = 'disable'
                        }
                    },
                },
            })

            if input then
                TriggerServerEvent('zrx_lobby:server:changeSetting', 'npc', input[1])
            else
                CORE.Bridge.notification(Strings.invalid_input)
            end
        end
    }

    CORE.Client.CreateMenu({
        id = 'zrx_lobby:manage_menu',
        title = Strings.menu_manage,
        menu = 'zrx_lobby:info_menu'
    }, MENU, Config.Menu.type ~= 'menu', Config.Menu.postition)
end

HideHud = function(bool)
    state = bool

    if bool then
        CreateThread(function()
            while state do
                DisplayRadar(false) --| Its in loop just to make sure its hidden

                for i = 1, 22 do
                    HideHudComponentThisFrame(i)
                end

                Wait(0)
            end
        end)
    else
        DisplayRadar(true)
    end
end

StartCooldown = function()
    if not Config.Cooldown then return end
    COOLDOWN = true

    CreateThread(function()
        SetTimeout(Config.Cooldown * 1000, function()
            COOLDOWN = false
        end)
    end)
end

CloudCamera = function()
    cloudCam = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', Config.Coords.PreviewCamera.x, Config.Coords.PreviewCamera.y, Config.Coords.PreviewCamera.z, 0, 0, Config.Coords.PreviewCamera[4], 70.0, true, 2)

    HideHud(true)
    RenderScriptCams(true, false, 0, true, false)
end

CameraToPlayer = function(x, y, z, h)
    groundCam = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', x, y, 600.0, -75.0, 0.0, h, 70.0, true, 2)
    groundCam2 = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', x, y, z, 0.0, 0.0, h, 70.0, true, 2)

    SetCamActiveWithInterp(groundCam, cloudCam, 3000, 1, 1)
    Wait(3000)
    SetCamActiveWithInterp(groundCam2, groundCam, 3000, 1, 1)
    Wait(3000)
    SetGameplayCamRelativeHeading(h)
    SetGameplayCamRelativeRotation(0.0, 10.0, 10.0)
    RenderScriptCams(false, false, 0, true, false)
    DestroyCam(groundCam, true)
    DestroyCam(groundCam2, true)

    SetEntityCoords(cache.ped, x, y, z, false, false, false, false)
    SetEntityHeading(cache.ped, h)
    HideHud(false)
end

CameraToStart = function()
    local pedCoords = GetEntityCoords(cache.ped)
    local cam = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', pedCoords.x, pedCoords.y, pedCoords.z, -75.0, 0.0, GetEntityHeading(cache.ped), 70.0, true, 2)
    local cam2 = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', pedCoords.x, pedCoords.y, 600.0, 0.0, 0.0, Config.Coords.PreviewCamera[4], 70.0, true, 2)
    local cam3 = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', Config.Coords.PreviewCamera.x, Config.Coords.PreviewCamera.y, Config.Coords.PreviewCamera.z, 0.0, 0.0, Config.Coords.PreviewCamera[4], 70.0, true, 2)

    HideHud(true)
    RenderScriptCams(true, false, 0, true, false)
    SetCamActiveWithInterp(cam2, cam, 3000, 1, 1)
    Wait(3000)
    SetCamActiveWithInterp(cam3, cam2, 3000, 1, 1)
    Wait(3000)
    RenderScriptCams(false, false, 0, true, false)
    DestroyCam(cam, true)
    DestroyCam(cam2, true)
    DestroyCam(cam3, true)
end