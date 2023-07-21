if SERVER then
    include( "calculation.lua" )
end

hook.Add( "Move", "Velocity", function( ply, moveData )
    if not ply:Alive() or ply:InVehicle() or ply:GetMoveType() ~= MOVETYPE_WALK then return end
    moveData:SetMaxSpeed( moveData:GetMaxSpeed() * ply:GetNW2Float( "dynamic-player-fraction", 1 ) )
end )