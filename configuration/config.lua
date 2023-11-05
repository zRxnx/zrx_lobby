Config = {}

--| Discord Webhook in 'configuration/webhook.lua'
Config.Command = 'lobbymenu' --| Command
Config.Key = 'F7' --| Note: Its a keymapping
Config.Cooldown = 3 --| Cooldown
Config.IconColor  = 'rgba(173, 216, 230, 1)' --| rgba format

Config.Menu = {
    type = 'context', --| context or menu
    postition = 'top-left' --| top-left, top-right, bottom-left or bottom-right
}

Config.Coords = {
    PreviewCamera = vector4(700.2692, 1080.7894, 338.5306, -20.0),
    SpawnPoint = vector4(238.5490, -876.3400, 29.4921, 0.0)
}

Config.SpawnSelect = {
    {
        label = 'Meeting Point',
        coords = vector4(238.5490, -876.3400, 29.4921, 0.0),
        icon = 'fa-solid fa-mountain-sun',
    },
    {
        label = 'Mission Row PD',
        coords = vector4(426.2735, -979.0967, 29.7098, 90.8871),
        icon = 'fa-solid fa-mountain-sun',
    },
    {
        label = 'Pillbox Hospital',
        coords = vector4(296.6943, -584.3677, 42.1331, 80.5873),
        icon = 'fa-solid fa-mountain-sun',
    },
    {
        label = 'Los Santos Customs',
        coords = vector4(-361.7549, -133.0011, 37.6803, 73.0458),
        icon = 'fa-solid fa-mountain-sun',
    }
}

--| Place here your punish actions
Config.PunishPlayer = function(player, reason)
    if not IsDuplicityVersion() then return end
    if Webhook.Links.punish:len() > 0 then
        local message = ([[
            The player got punished

            Reason: **%s**
        ]]):format(reason)

        CORE.Server.DiscordLog(player, 'PUNISH', message, Webhook.Links.punish)
    end

    DropPlayer(player, reason)
end

--| Place here your Show UI
Config.ShowUI = function(msg)
    lib.showTextUI(msg, {
        position = 'right-center',
        icon = 'fa-solid fa-briefcase',
        iconColor = Config.IconColor
    })
end

--| Place here your Hide UI
Config.HideUI = function()
    lib.hideTextUI()
end