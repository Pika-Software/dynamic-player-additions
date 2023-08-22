hook.Add( "Move", "Velocity", function( ply, moveData )
    if not ply:Alive() or ply:InVehicle() or ply:GetMoveType() ~= MOVETYPE_WALK then return end
    moveData:SetMaxSpeed( moveData:GetMaxSpeed() * ply:GetNW2Float( "dpa-speed", 1 ) )
end )