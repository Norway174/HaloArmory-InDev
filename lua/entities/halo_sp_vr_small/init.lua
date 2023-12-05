
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")



function ENT:PostInit()

    HALOARMORY.Requisition.AddVehiclePad( self )

end

function ENT:OnRemove()

    HALOARMORY.Requisition.RemoveVehiclePad( self )

end


function ENT:Think()

    self:NextThink( CurTime() + 1 )

    local pos = self:GetPos() + self.VehicleSpawnPos
    // Check if there is a vehicle on the pad.
    local nearby_ent = {}

    // Remove self from the table.
    for k, v in pairs( ents.FindInSphere( pos, 20 ) ) do

        //print( "Found:", v:GetClass() )
        if v == self then continue end
        if v.HALOARMORY_Ships_Presets then continue end

        local Vehicle_Ent = scripted_ents.Get( v:GetClass() )

        if not Vehicle_Ent then
            // Might be Simfphys
            Vehicle_Ent = list.Get("simfphys_vehicles")[v:GetClass()]
        end

        if istable( Vehicle_Ent ) then
            table.insert( nearby_ent, v )
        end
    end

    local closest_ent = nil 

    // Sort nearby entities by distance. And return the closest one.
    table.sort( nearby_ent, function( a, b )
        return a:GetPos():Distance( pos ) < b:GetPos():Distance( pos )
    end )

    closest_ent = nearby_ent[1]

    if self:GetOnPad() ~= closest_ent then
        self:SetOnPad( closest_ent )
    end

    // Debug overlay
    debugoverlay.EntityTextAtPosition( pos, 0, tostring( #nearby_ent ) )
    local ind = 1
    for key, value in pairs(nearby_ent) do
        debugoverlay.EntityTextAtPosition( pos, ind, tostring( value ) )
        ind = ind + 1
    end

end


function ENT:SpawnVehicle( ply, vehicle, v_skin, v_loadout )

    print( "Adding to queue", ply, vehicle, v_skin, v_loadout )

    local VehicleTable = HALOARMORY.Requisition.Vehicles[vehicle]

    if not VehicleTable then return end

    print( "Vehicle is valid" )

    if not VehicleTable.loadout[v_loadout] then return end
    if not VehicleTable.allowed_skins[v_skin] then return end

    print( "Loadout and skin are valid" )

    local VehicleInQueue = {
        vehicle = vehicle,
        v_skin = v_skin,
        v_loadout = v_loadout,
        authorization = {
            requester = ply,
            authorized = false,
            authorized_by = nil,
            authorized_at = nil,
            requested_at = CurTime(),
        }
    }

    --table.insert( self.VehicleQueue, VehicleInQueue )

    HALOARMORY.Requisition.AuthorizeVehicle( self, ply, VehicleInQueue, function( Auth, MsgBack )
    
        print( "Authed:", Auth, MsgBack )

        if Auth then
            
            print( "Spawn:", VehicleInQueue )
            PrintTable( VehicleInQueue )

            local network_name = self:GetNetworkID()

            local success, new_supplies = HALOARMORY.Logistics.AddNetworkSupplies( network_name, -VehicleTable.cost )

            if not success then
                return
            end

            local Pos = self:GetPos() + self.VehicleSpawnPos
            local Ang = self:GetAngles() + self.VehicleSpawnAng

            local Vehicle = ents.Create( VehicleTable.entity )
            if simfphys and list.Get( "simfphys_vehicles" )[ VehicleTable.entity ] then
                Vehicle = simfphys.SpawnVehicleSimple( VehicleTable.entity, Pos, Ang )

            else

                Vehicle:SetPos( self:GetPos() + Vector( 0, 0, 100 ) )
                Vehicle:SetAngles( self:GetAngles() )

                Vehicle:Spawn()

            end

            //if not IsValid( Vehicle ) then Vehicle:Remove() return end


            Vehicle:SetSkin( VehicleTable.allowed_skins[ VehicleInQueue.v_skin ] )

            for bodygroup_name, loadout in pairs( VehicleTable.loadout[VehicleInQueue.v_loadout] ) do
                --print("loadout", bodygroup_name, loadout)
    
                local bodygroup_id = Vehicle:FindBodygroupByName( bodygroup_name )
    
                if isnumber( bodygroup_id ) then
                    Vehicle:SetBodygroup( bodygroup_id, loadout )
                end
    
            end

            Vehicle:CPPISetOwner(ply)

            undo.Create("HALOARMORY.Vehicle (" .. VehicleTable.name .. ")")
                undo.AddEntity( Vehicle )
                undo.SetPlayer(ply)
                undo.AddFunction( function ( tab, varargs )
                    local refund_amount = VehicleTable.cost
                    // Get the vehicle health in percentage. And refund that percentage of the cost.
                    local health = Vehicle:Health()
                    // Check if the health is 0, and if the vehicle is a simfphys vehicle. If so, get the simfphys health.
                    if health == 0 and simfphys and list.Get( "simfphys_vehicles" )[ VehicleTable.entity ] then
                        health = Vehicle:GetCurHealth()
                    end
                    local max_health = Vehicle:GetMaxHealth()
                    local health_percentage = health / max_health
                    refund_amount = refund_amount * health_percentage

                    --print( "Refund amount:", refund_amount, "Health:", health, "Max Health:", max_health, "Health Percentage:", health_percentage, "Cost:", VehicleTable.cost )

                    HALOARMORY.Logistics.AddNetworkSupplies( network_name, refund_amount )
                end )
            undo.Finish()
        end
    
    end)


end

