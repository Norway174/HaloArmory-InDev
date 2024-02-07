
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")


function ENT:PostInit()

    self:SetCollisionGroup( COLLISION_GROUP_DEBRIS_TRIGGER )

    self:DrawShadow( false )

end