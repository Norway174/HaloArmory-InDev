

ENT.Type = "anim"
ENT.Base = "halo_tv_screen"
 
ENT.PrintName = "Fast Travel Terminal"
ENT.Category = "HALOARMORY - UNSC"
ENT.Author = "Norway174"
ENT.Spawnable = true


ENT.Editable = true

local CONSTS = {
    NETWORK = "HALOARMORY.FASTTRAVEL",
    ACTIONS = {
        TELEPORT = 1,
        SYNC = 2,
        SYNC_ALL = 3,
        REMOVE = 4,
    },
}

local Destinations = {}

ENT.Editable = true

function ENT:SetupDataTables()

    self:NetworkVar( "String", 0, "Destination", { KeyName = "Destination Name",	Edit = { type = "Generic", order = 1 } } )
    self:NetworkVar( "Bool", 0, "Enabled", { KeyName = "Enabled",	Edit = { type = "Boolean", order = 2 } } )


    if SERVER then
        self:SetDestination( "N/A" )
        self:SetEnabled( false )

        self:NetworkVarNotify( "Destination", function( ent, name, old, new )
            timer.Simple( 0.1, function()
                ent:NetSync()
            end )
        end )

        self:NetworkVarNotify( "Enabled", function( ent, name, old, new )
            timer.Simple( 0.1, function()
                ent:NetSync()
            end )
        end )
    end

end
