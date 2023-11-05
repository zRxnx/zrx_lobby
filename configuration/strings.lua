Strings = {
    on_cooldown = 'You are on cooldown',
    cmd_desc = 'Open the lobby menu',
    invalid_input = 'Invalid input',
    invalid_max_players = 'Minimum value is 2',
    private_lobby = 'Lobby - Private',
    public_lobby = 'Lobby - Public',
    you = '(You)',
    host = '(Host)',
    public = 'Public',
    your = 'Your',
    spawn = 'Spawn',
    enabled = 'Enabled',
    disabled = 'Disabled',
    enable = 'Enable',
    disable = 'Disable',

    invite_text = 'You have got an invite.  \nOpen menu to accept the invite.  \n‎  \nFrom: %s (%s)  \nLobby: %s  \nPlayers: %s  \n‎  \n‎  \nYou have 10 seconds to accept!', --| arg1: Player name - arg2: Player ID - arg3: Lobby ID - arg4: Player count

    menu_start = 'Lobby - Start',
    menu_spawn = 'Lobby - Spawn selector',
    menu_main = 'Lobby - Main menu',
    menu_info = 'Lobby - Information',
    menu_invite = 'Lobby - Invite',
    menu_kick = 'Lobby - Kick',
    menu_manage = 'Lobby - Manage',

    lobby_private = 'Private lobby',
    lobby_private_desc = 'Join your own private lobby',
    lobby_private_id = 'Lobby ID',
    lobby_private_id_desc = '%s', --| arg1: Lobby ID
    lobby_private_count = 'Player Count',
    lobby_private_count_desc = '%s/%s', --| arg1: Current player count - arg2: Max player count

    lobby_public = 'Public lobby',
    lobby_public_desc = 'Join the public lobby',
    lobby_public_id = 'Lobby ID',
    lobby_public_id_desc = 'Public',
    lobby_public_count = 'Player Count',
    lobby_public_count_desc = '%s/%s', --| arg1: Current player count - arg2: Max player count

    lobby_password = 'Lobby with password',
    lobby_password_desc = 'Join a lobby with a password',
    lobby_password_title = 'Join lobby',
    lobby_password_id = 'Lobby ID/UID',
    lobby_password_id_desc = 'Enter one of the lobby identifiers',
    lobby_password_password = 'Password',
    lobby_password_password_desc = 'Enter password from the lobby',

    selector_desc = 'Click to spawn',

    main_info = 'Information',
    main_info_desc = 'View informations about your lobby',

    main_public = 'Public lobby',
    main_public_desc = 'Join the Public lobby',

    main_password = 'Lobby with password',
    main_password_desc = 'Join a lobby with a password',
    main_password_title = 'Join lobby',
    main_password_id = 'Lobby ID/Identifier',
    main_password_id_desc = 'Enter one of the lobby identifiers',
    main_password_password = 'Password',
    main_password_password_desc = 'Enter password from the lobby',

    main_switch = 'Switch to private lobby',
    main_switch_desc = 'Go back to your private lobby',

    main_invite = 'Invite player',
    main_invite_desc = 'Invite a player to your lobby',

    main_kick = 'Kick player',
    main_kick_desc = 'Kick a player from your lobby',

    main_ainvite = 'Accept Invite',
    main_ainvite_desc = 'Accept the invite from %s', --| arg1: Player name
    main_ainvite_from = 'From',
    main_ainvite_from_desc = '%s (%s)', --| arg1: Player name - arg2: Player ID
    main_ainvite_lobby = 'Lobby',
    main_ainvite_lobby_desc = '%s', --| arg1: Lobby ID

    info_meta = '%s %s %s', --| arg1: Player Name

    info_manage = 'Manage Lobby',
    info_manage_desc = 'Manage your own lobby',

    info_status = 'Host Status',
    info_status_desc = '%s', --| arg1: Host status

    info_password = 'Password',
    info_password_desc = 'Click to copy',
    info_password_password = 'Password',
    info_password_password_desc = '%s', --| arg1: Password

    info_settings = 'Settings',
    info_settings_desc = 'Hover to see settings',
    info_settings_password = 'Password',
    info_settings_password_desc = 'HIDDEN',
    info_settings_max = 'Max Players',
    info_settings_max_desc = '%s', --| arg1: Max player count
    info_settings_npc = 'NPCs',
    info_settings_npcs_desc = '%s', --| arg1: NPC State

    current_lobby = 'Current Lobby',
    current_lobby_desc = '%s', --| arg1: Lobby ID

    current_player = 'Current Lobby Player Count',
    current_player_desc = '%s/%s', --| arg1: Current player count - arg2: Max player count

    current_players = 'Current Players',
    current_players_desc = 'Hover to show',

    invite_title = '%s (#%s) %s', --| arg1: Player Name - arg2: Lobby ID
    invite_desc = 'Do you want to invite this player to your lobby?',
    invite_header = 'Are you sure?',
    invite_content = 'Do you want to invite this player to your lobby?',

    kick_title = '%s (#%s) %s', --| arg1: Player Name - arg2: Lobby ID
    kick_desc = 'Do you want to kick this player from your lobby?',

    manage_password = 'Change password',
    manage_password_desc = 'Change lobby password',
    manage_password_new_title = 'New password',
    manage_password_new = 'New password',
    manage_password_new_desc = 'Maximum 10 chars',

    manage_max = 'Max player count',
    manage_max_desc = 'Change the max player count',
    manage_max_new_title = 'New password',
    manage_max_new = 'New Max Players',
    manage_max_new_desc = 'Minimum 2 players',

    manage_npc = 'NPC State',
    manage_npc_desc = 'Enable/Disable npcs',
    manage_npc_new_title = 'Settings',
    manage_npc_new = 'Change NPC state',
    manage_npc_new_desc = 'Enable/Disable NPCs',

    setlobby = 'You changed your lobby to %s', --| arg1: Lobby ID
    kick = 'You have kicked the player',
    kicked = 'You got kicked from your previous lobby',
    pending = 'The player already has a pending invite',
    invite = 'You have invited the player',
    invited = 'You have got an invite',
    not_accept = 'The Player has not accepted your invitation',
    not_accepted = 'You have not accepted your recent invitation',
    host_left = 'The host of the lobby left',
    host_joined = 'The host of the lobby joined',
    player_there = 'The Player is already in your lobby',
    player_there_not = 'The Player is not in your lobby',

    change_password = 'You changed your lobby password!',
    change_max = 'You changed the lobby max player count!',
    change_npc_true = 'You enabled npcs for your lobby!',
    change_npc_false = 'You disabled npcs for your lobby!',

    accept_pending = 'You accepted your pending invitation',
    accepted_pending = 'The Player accepted your invitation',

    join_lobby = '%s joined your lobby', --| arg1: Player Name
    change_lobby = 'You changed your lobby',
    full_lobby = 'The lobby is full!',
    password_wrong_lobby = 'The lobby password is wrong',
}