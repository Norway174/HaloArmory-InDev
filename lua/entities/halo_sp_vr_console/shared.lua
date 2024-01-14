
ENT.Type = "anim"
ENT.Base = "halo_pc_base"
 
ENT.PrintName = "Requisition Console"
ENT.Category = "HALOARMORY - Vehicle Requisition"
ENT.Author = "Norway174"
ENT.Spawnable = true

ENT.Editable = true


function ENT:CustomDataTables()

    self:NetworkVar( "String", 0, "ConsoleID", { KeyName = "ConsoleID",	Edit = { type = "String", order = 1 } } )

    if SERVER then
        --self:SetConsoleID( "UNSC" )
    end

end