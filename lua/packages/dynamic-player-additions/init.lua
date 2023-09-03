install( "packages/math-extensions.lua", "https://raw.githubusercontent.com/Pika-Software/math-extensions/main/lua/packages/math-extensions.lua" )
install( "packages/config.lua", "https://raw.githubusercontent.com/Pika-Software/config/main/lua/packages/config.lua")
install( "packages/dynamic-player", "https://github.com/Pika-Software/dynamic-player" )
include( "shared.lua" )

local FCVAR_ARCHIVE = FCVAR_ARCHIVE
local CreateConVar = CreateConVar

do

    local baseMinHealth = CreateConVar( "dpa_min_health", "10", FCVAR_ARCHIVE, "Player\'s max health, used to calculate health.", 10, 10000 )
    local baseMaxHealth = CreateConVar( "dpa_max_health", "250", FCVAR_ARCHIVE, "Player\'s max health, used to calculate health.", 100, 10000 )
    local baseHealth = CreateConVar( "dpa_base_health", "100", FCVAR_ARCHIVE, "Player\'s basic health, used to calculate health.", 10, 10000 )
    local configFile = config.Create( "dynamic-player-additions" )
    local math = math

    hook.Add( "PlayerModelBoundsChanged", "Calculations", function( ply, model, data )
        local modelData = configFile:Get( model )
        if not modelData then
            local standing = data.Standing
            local basicHealth = baseHealth:GetInt()
            local fraction = math.Round( standing.Mins:Distance( standing.Maxs ) ) / 77

            modelData = {
                ["Max Health"] = math.Round( math.Clamp( fraction, baseMinHealth:GetInt() / basicHealth, baseMaxHealth:GetInt() / basicHealth ), 1 ) * basicHealth,
                ["Jump Power"] = math.max( 20, fraction * 200 ),
                ["Speed"] = fraction
            }

            configFile:Set( model, modelData )
        end

        local speed = modelData.Speed
        ply:SetNW2Float( "dpa-speed", speed )
        ply:SetJumpPower( modelData["Jump Power"] )

        local maxHealth = modelData["Max Health"]
        ply:SetHealth( math.min( ply:Health(), maxHealth ) )
        ply:SetMaxHealth( maxHealth )

        hook.Run( "PlayerChangedModelAdditions", ply, model, speed )
    end )

end

local respawnWithFullHealth = CreateConVar( "dpa_full_health_respawn", "0", FCVAR_ARCHIVE, "If enabled, it will set the maximum amount of health when a player is spawned.", 0, 1 )
local timer_Simple = timer.Simple
local IsValid = IsValid

hook.Add( "PlayerSpawn", "Health", function( ply )
    if not respawnWithFullHealth:GetBool() then return end
    timer_Simple( 0.25, function()
        if not IsValid( ply ) then return end
        ply:SetHealth( ply:GetMaxHealth() )
    end )
end )
