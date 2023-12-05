
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")


function ENT:PostInit()

    HALOARMORY.Requisition.AddVehiclePad( self )

    self:SetCollisionGroup( COLLISION_GROUP_DEBRIS_TRIGGER )

end