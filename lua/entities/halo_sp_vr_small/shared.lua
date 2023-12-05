
ENT.Type = "anim"
ENT.Base = "halo_sp_base"
 
ENT.PrintName = "Small Pad"
ENT.Category = "HALOARMORY - Vehicle Requisition"
ENT.Author = "Norway174"
ENT.Spawnable = true

ENT.Editable = true

ENT.HALOARMORY_Device = true

ENT.DeviceName = "Vehicle Requisition Small"
ENT.DeviceType = "vehicle_requisition_small"

ENT.VehicleSize = { "small" }

ENT.VehicleQueue = {}

ENT.VehicleSpawnPos = Vector( 0, 0, 10 )
ENT.VehicleSpawnAng = Angle( 0, -90, 0 )

ENT.DeviceModel = "models/valk/h4/unsc/props/vehiclepad/vehiclepad_unsc_small.mdl"
function ENT:SetupModel()
end

function ENT:CustomDataTables()

    self:NetworkVar( "String", 3, "Frequency", { KeyName = "Frequency",	Edit = { type = "String", order = 1 } } )
    self:NetworkVar( "Entity", 1, "OnPad" )

    if SERVER then
        self:SetFrequency( "UNSC" )
        self:SetOnPad( NULL )
    end

end


function ENT:GetVehicles( ply )
    if CLIENT then 
        if ply == nil or ply:IsPlayer() then
            ply = LocalPlayer()
        end
    end
    // Global vehicle table: HALOARMORY.Requisition.Vehicles
    // Check the table for any vehicles that match any of the options in self.VehicleSize

    local vehicles = {}

    // Get all the vehicles
    for k, v in pairs(HALOARMORY.Requisition.Vehicles) do
         // Make sure the vehicle has a size table
        if v.size then
            // Get all the allowed pad sizes
            for k2, v2 in pairs(v.size) do
                // Make sure the pad size is true
                if v2 == true then
                    // Make sure the pad size is in the vehicle size table
                    if table.HasValue(self.VehicleSize, k2) then
                        
                        // Add the vehicle to the table
                        //table.insert(vehicles, v)

                        vehicles[k] = v
                    end
                end
            end
        end
    end

    if DarkRP then
        // Filter out vehicles that the player don't have access to.
        local job_table = ply:getJobTable()
        job_table = job_table["haloarmory_vehicles"] or {
            ["access"] = vehicles,
            ["authorize"] = vehicles,
        }

        local can_access = {}

        for k, v in pairs(job_table["access"]) do
            if MRS and isnumber( v ) then
                local rank = MRS.GetNWdata(ply, "Rank")
                if rank >= v then
                    can_access[k] = true
                end
            else
                can_access[k] = true
            end
        end
        for k, v in pairs(job_table["authorize"]) do
            if MRS and isnumber( v ) then
                local rank = MRS.GetNWdata(ply, "Rank")
                if rank >= v then
                    can_access[k] = true
                end
            else
                can_access[k] = true
            end
        end
        
        for k, v in pairs(vehicles) do
            if can_access[k] == nil then
                vehicles[k] = nil
            end
        end
        
    end

    return vehicles
end

function ENT:CanAfford( SelectedVehicle )

    local controller_network = util.JSONToTable( self:GetNetworkTable() )
    if not istable(controller_network) then return false end
    
    local CurrentResource, MaxResource = controller_network.Supplies, controller_network.MaxSupplies

    local Cost = 0
    if SelectedVehicle["cost"] then
        Cost = SelectedVehicle["cost"]
    end

    return Cost <= CurrentResource

end