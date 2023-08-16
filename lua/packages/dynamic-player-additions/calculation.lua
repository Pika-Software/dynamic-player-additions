install( "packages/math-extensions.lua", "https://raw.githubusercontent.com/Pika-Software/math-extensions/main/lua/packages/math-extensions.lua" )
install( "packages/dynamic-player", "https://github.com/Pika-Software/dynamic-player" )

local FCVAR_ARCHIVE = FCVAR_ARCHIVE
local CreateConVar = CreateConVar

do

    local baseMinHealth = CreateConVar( "mp_min_health", "10", FCVAR_ARCHIVE, "Player\'s max health, used to calculate health.", 10, 10000 )
    local baseMaxHealth = CreateConVar( "mp_max_health", "250", FCVAR_ARCHIVE, "Player\'s max health, used to calculate health.", 100, 10000 )
    local baseHealth = CreateConVar( "mp_base_health", "100", FCVAR_ARCHIVE, "Player\'s basic health, used to calculate health.", 10, 10000 )
    local math = math
    local cache = {}

    hook.Add( "PlayerUpdatedModelBounds", "Health", function( ply, model, data )
        local fraction = cache[ model ]
        if not fraction then
            local standing = data.Standing
            fraction = math.Round( standing.Mins:Distance( standing.Maxs ) ) / 77
            cache[ model ] = fraction
        end

        local basicHealth = baseHealth:GetInt()
        local maxHealth = math.Round( math.Clamp( fraction, baseMinHealth:GetInt() / basicHealth, baseMaxHealth:GetInt() / basicHealth ), 1 ) * basicHealth
        ply:SetHealth( math.min( ply:Health(), maxHealth ) )
        ply:SetModelFraction( fraction )
        ply:SetMaxHealth( maxHealth )

        hook.Run( "PlayerUpdatedModelFraction", ply, model, fraction )
    end )

end

local respawnWithFullHealth = CreateConVar( "mp_respawn_with_full_health", "0", FCVAR_ARCHIVE, "If enabled, it will set the maximum amount of health when a player is spawned.", 0, 1 )
local timer_Simple = timer.Simple
local IsValid = IsValid

hook.Add( "PlayerSpawn", "Health", function( ply )
    if not respawnWithFullHealth:GetBool() then return end
    timer_Simple( 0.25, function()
        if not IsValid( ply ) then return end
        ply:SetHealth( ply:GetMaxHealth() )
    end )
end )