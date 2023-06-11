local packageName = gpm.Package:GetIdentifier()
local hook = hook

if SERVER then

    install( "packages/dynamic-player", "https://github.com/Pika-Software/dynamic-player" )

    local FCVAR_ARCHIVE = FCVAR_ARCHIVE
    local CreateConVar = CreateConVar
    local timer_Simple = timer.Simple
    local IsValid = IsValid
    local math = math

    local respawnWithFullHealth = CreateConVar( "mp_respawn_with_full_health", "0", FCVAR_ARCHIVE, "If enabled, it will set the maximum amount of health when a player is spawned.", 0, 1 )
    local baseMinHealth = CreateConVar( "mp_min_health", "10", FCVAR_ARCHIVE, "Player\'s max health, used to calculate health.", 10, 10000 )
    local baseMaxHealth = CreateConVar( "mp_max_health", "250", FCVAR_ARCHIVE, "Player\'s max health, used to calculate health.", 100, 10000 )
    local baseHealth = CreateConVar( "mp_base_health", "100", FCVAR_ARCHIVE, "Player\'s basic health, used to calculate health.", 10, 10000 )

    hook.Add( "PlayerUpdatedModelBounds", "Health", function( ply )
        local basicHealth = baseHealth:GetInt()
        local mins, maxs = ply:GetHull()

        local frac = ( maxs - mins ):Length() / 70
        ply:SetNW2Float( packageName, frac )

        local maxHealth = math.Round( math.Clamp( frac, baseMinHealth:GetInt() / basicHealth, baseMaxHealth:GetInt() / basicHealth ), 1 ) * basicHealth
        ply:SetMaxHealth( maxHealth ); ply:SetHealth( math.min( ply:Health(), maxHealth ) )
    end )

    hook.Add( "PlayerSpawn", "Health", function( ply )
        if not respawnWithFullHealth:GetBool() then return end
        timer_Simple( 0.25, function()
            if not IsValid( ply ) then return end
            ply:SetHealth( ply:GetMaxHealth() )
        end )
    end )

end

hook.Add( "Move", "Velocity", function( ply, moveData )
    if ply:GetMoveType() ~= MOVETYPE_WALK then return end
    if not ply:Alive() or ply:InVehicle() then return end
    moveData:SetMaxSpeed( moveData:GetMaxSpeed() * ply:GetNW2Float( packageName, 1 ) )
end )