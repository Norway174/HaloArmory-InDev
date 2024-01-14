HALOARMORY.MsgC("Server HALOARMORY REQUISITION MANAGER loaded!")


HALOARMORY.Requisition = HALOARMORY.Requisition or {}
HALOARMORY.Requisition.Vehicles = HALOARMORY.Requisition.Vehicles or {}
HALOARMORY.Requisition.VehiclePads = HALOARMORY.Requisition.VehiclePads or {}

HALOARMORY.Requisition.Menu_Users = {}


util.AddNetworkString("HALOARMORY.Requisition")


function HALOARMORY.Requisition.AddVehiclePad( ent )
    if not IsValid( ent ) then return end

    table.insert( HALOARMORY.Requisition.VehiclePads, ent )
end

function HALOARMORY.Requisition.RemoveVehiclePad( ent )
    if not IsValid( ent ) then return end

    if not table.HasValue( HALOARMORY.Requisition.VehiclePads, ent ) then return end

    table.RemoveByValue( HALOARMORY.Requisition.VehiclePads, ent )
end

local AuthList = AuthList or {}
function HALOARMORY.Requisition.AuthorizeVehicle( vehiclePad, ply, vehicle, callback )

    if not IsValid( ply ) then callback(false, "Invalid Player") return end
    if not istable( vehicle ) then callback(false, "Invalid Vehicle") return end

    local vehicles = vehiclePad:GetVehicles( ply )

    if DarkRP then
        // Filter out vehicles that the player don't have access to.
        local job_table = ply:getJobTable()
        job_table = job_table["haloarmory_vehicles"] or {
            ["access"] = vehicles,
            ["authorize"] = vehicles,
        }

        local can_access = job_table["access"]
        local can_authorize = job_table["authorize"]

        local rank = 999
        if MRS then
            rank = MRS.GetNWdata(ply, "Rank")
        end

        --print( "Rank", rank )
        --print( "Can Access", can_access[vehicle.vehicle], vehicle.vehicle )
        --print( "Can Authorize", can_authorize[vehicle.vehicle], vehicle.vehicle )

        if not can_access[vehicle.vehicle] then callback(false, "Not supposed to see this") return end

        if not isnumber( can_authorize[vehicle.vehicle] ) then
            can_authorize[vehicle.vehicle] = 0
        end
        
        if not MRS or (MRS and can_authorize[vehicle.vehicle] <= rank) then
            callback(true, "Automatically authorized")
            return 
        else
            --callback(false, "You don't have the required rank to authorize this vehicle")
            --print( "Sending Authorization Request" )

            // Send the Authorization Request to all players with the required rank.

            local all_players_who_can_authorize = {}
            for k, v in pairs( player.GetAll() ) do
                if not IsValid( v ) then continue end
                if not v:IsPlayer() then continue end
                --if not v:Alive() then continue end

                local v_job_table = v:getJobTable().haloarmory_vehicles
                local v_can_authorize = job_table["authorize"]

                if MRS and MRS.GetNWdata(v, "Rank") >= v_can_authorize[vehicle.vehicle] then
                    table.insert( all_players_who_can_authorize, v )
                elseif not MRS then
                    table.insert( all_players_who_can_authorize, v )
                end

            end

            // Override if there are no players with the required rank.
            if #all_players_who_can_authorize == 0 then

                vehicle["authorization"]["authorized"] = true
                vehicle["authorization"]["authorized_by"] = ply
                vehicle["authorization"]["authorized_at"] = CurTime()

                callback(true, "Automatically authorized (No players with the required rank)")
                return 
            end

            // Send the authorization request to all players with the required rank.
            // TODO:
            // * Use the Shared Networking.lua file to send the authorization request.
            // * Create a menu for the players to accept or deny the authorization request.
            -- net.Start( "HALOARMORY.Requisition" )
            --     net.WriteString( "Request-Authorization" )
            --     net.WriteEntity( ply )
            --     net.WriteTable( vehicle )
            -- net.Send( all_players_who_can_authorize )

            return 
        end
    end

end


net.Receive( "HALOARMORY.Requisition", function( len, ply )
    local Action = net.ReadString()

    if Action == "Register-User" then
        HALOARMORY.Requisition.Menu_Users[ ply ] = true

        net.Start( "HALOARMORY.Requisition" )
            net.WriteString( "Menu-Init" )
            --print( "Sending Menu-Init", tonumber(#HALOARMORY.Requisition.VehiclePads), type( #HALOARMORY.Requisition.VehiclePads ) )

            local VehiclePads = HALOARMORY.Requisition.VehiclePads

            // Sort the VehiclePads by distance to the ply
            table.sort( VehiclePads, function( a, b )
                return a:GetPos():Distance( ply:GetPos() ) < b:GetPos():Distance( ply:GetPos() )
            end )
            
            net.WriteInt( tonumber(#VehiclePads), 14 )

            for k, v in pairs( VehiclePads ) do
                net.WriteEntity( v )
            end

        net.Send( ply )

    elseif Action == "Un-Register-User" then
        HALOARMORY.Requisition.Menu_Users[ ply ] = nil

    elseif Action == "Request-Vehicle" then
        local VehiclePad = net.ReadEntity()
        if not IsValid( VehiclePad ) then return end

        local Vehicle = net.ReadString()
        local Vehicle_Skin = net.ReadString()
        local Vehicle_Loadout = net.ReadString()

        print( "Requesting Vehicle", Vehicle, Vehicle_Skin, Vehicle_Loadout )

        VehiclePad:SpawnVehicle( ply, Vehicle, Vehicle_Skin, Vehicle_Loadout )

    end

end )