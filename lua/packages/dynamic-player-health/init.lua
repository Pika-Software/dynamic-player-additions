require( "packages/dynamic-player", "https://github.com/Pika-Software/dynamic-player" )

-- Libraries
local hook = hook
local math = math

-- Variables
local packageName = gpm.Package:GetIdentifier()
local FCVAR_ARCHIVE = FCVAR_ARCHIVE
local CreateConVar = CreateConVar
local timer_Simple = timer.Simple
local IsValid = IsValid

-- ConVars
local respawnWithFullHealth = CreateConVar( "sv_player_respawn_with_full_health", "0", FCVAR_ARCHIVE, " - If enabled, it will set the maximum amount of health when a player is spawned.", 0, 1 )
local baseMinHealth = CreateConVar( "sv_player_min_health", "10", FCVAR_ARCHIVE, " - The player\'s max health, used to calculate health.", 10, 10000 )
local baseMaxHealth = CreateConVar( "sv_player_max_health", "250", FCVAR_ARCHIVE, " - The player\'s max health, used to calculate health.", 100, 10000 )
local baseHealth = CreateConVar( "sv_player_base_health", "100", FCVAR_ARCHIVE, " - The player\'s basic health, used to calculate health.", 10, 10000 )

hook.Add( "UpdatedPlayerDynamic", packageName, function( ply )
    local basicHealth = baseHealth:GetInt()
    local mins, maxs = ply:GetHull()

    local maxHealth = math.Round( math.Clamp( (maxs - mins):Length() / 70, baseMinHealth:GetInt() / basicHealth, baseMaxHealth:GetInt() / basicHealth ), 1 ) * basicHealth
    ply:SetMaxHealth( maxHealth ); ply:SetHealth( math.min( ply:Health(), maxHealth ) )
end )

hook.Add( "PlayerSpawn", packageName, function( ply )
    if not respawnWithFullHealth:GetBool() then return end
    timer_Simple( 0.25, function()
        if not IsValid( ply ) then return end
        ply:SetHealth( ply:GetMaxHealth() )
    end )
end )