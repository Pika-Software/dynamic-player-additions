local PLAYER = FindMetaTable( "Player" )

function PLAYER:GetModelFraction()
    return self:GetNW2Float( "dpa-fraction", 1 )
end

if SERVER then
    function PLAYER:SetModelFraction( float )
        return self:SetNW2Float( "dpa-fraction", float )
    end

    include( "calculation.lua" )
end

hook.Add( "Move", "Velocity", function( ply, moveData )
    if not ply:Alive() or ply:InVehicle() or ply:GetMoveType() ~= MOVETYPE_WALK then return end
    moveData:SetMaxSpeed( moveData:GetMaxSpeed() * ply:GetModelFraction() )
end )