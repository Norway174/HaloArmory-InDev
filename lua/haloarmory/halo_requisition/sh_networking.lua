HALOARMORY.MsgC("Shared HALOARMORY VEHICLES loaded!")


HALOARMORY.VEHICLES = HALOARMORY.VEHICLES or {}
HALOARMORY.VEHICLES.NETWORK = HALOARMORY.VEHICLES.NETWORK or {}


local NET_NAME = "HALOARMORY.VEHICLES.NETWORK"

local ACTION_REQUEST_VEHICLE_PADS = 1
local ACTION_REQUEST_VEHICLES = 2

if SERVER then
    util.AddNetworkString(NET_NAME)
end

if CLIENT then
    local Callbacks = {}

    net.Receive(NET_NAME, function( len )
        local action = net.ReadUInt(8)

        if action == ACTION_REQUEST_VEHICLE_PADS then
            local count = net.ReadUInt(13)
            local pads = {}

            for i = 1, count do
                table.insert(pads, net.ReadEntity())
            end

            if Callbacks[ACTION_REQUEST_VEHICLE_PADS] then
                Callbacks[ACTION_REQUEST_VEHICLE_PADS](pads)

                Callbacks[ACTION_REQUEST_VEHICLE_PADS] = nil
            end

        elseif action == ACTION_REQUEST_VEHICLES then

            local count = net.ReadUInt(32)
            local vehicles = {}

            for i = 1, count do
                local vehicle_key = net.ReadString()
                local dataLen = net.ReadUInt(32)
                local data = net.ReadData(dataLen)
                local vehicle = util.JSONToTable(util.Decompress(data))

                vehicles[vehicle_key] = vehicle
            end

            if Callbacks[ACTION_REQUEST_VEHICLES] then
                Callbacks[ACTION_REQUEST_VEHICLES](vehicles)

                Callbacks[ACTION_REQUEST_VEHICLES] = nil
            end

        end
    end)

    function HALOARMORY.VEHICLES.NETWORK.RequestVehiclePads( callback )
        Callbacks[ACTION_REQUEST_VEHICLE_PADS] = callback

        net.Start(NET_NAME)
            net.WriteUInt(ACTION_REQUEST_VEHICLE_PADS, 8)
        net.SendToServer()
    end

    function HALOARMORY.VEHICLES.NETWORK.RequestVehicles( PadEnt, callback )
        Callbacks[ACTION_REQUEST_VEHICLES] = callback

        net.Start(NET_NAME)
            net.WriteUInt(ACTION_REQUEST_VEHICLES, 8)
            net.WriteEntity(PadEnt)
        net.SendToServer()
    end
end

if SERVER then
    net.Receive(NET_NAME, function( len, ply )
        local action = net.ReadUInt(8)

        if action == ACTION_REQUEST_VEHICLE_PADS then
            local pads = {}

            if ents.Iterator then
                for _, ent in ents.Iterator() do
                    if ( ent.VehiclePad ) then
                        table.insert(pads, ent)
                    end
                end

            else // Compatibility mode if no pads are found
                for _, ent in pairs(ents.GetAll()) do
                    if ( ent.VehiclePad ) then
                        table.insert(pads, ent)
                    end
                end
            end

            net.Start(NET_NAME)
                net.WriteUInt(ACTION_REQUEST_VEHICLE_PADS, 8)
                net.WriteUInt(#pads, 13)

                for _, pad in pairs(pads) do
                    net.WriteEntity(pad)
                end
            net.Send(ply)
        
        elseif action == ACTION_REQUEST_VEHICLES then

            local VPadENT = net.ReadEntity()

            if not IsValid(VPadENT) or not VPadENT.VehiclePad then return end

            local vehicles = VPadENT:GetVehicles( ply )

            --print( "Sending vehicles to client", ply, table.Count( vehicles ) )

            net.Start(NET_NAME)
                net.WriteUInt(ACTION_REQUEST_VEHICLES, 8)

                net.WriteUInt(table.Count( vehicles ), 32)

                for vehicle_key, vehicle in pairs(vehicles) do
                    -- print( "Sending vehicle", vehicle_key, vehicle )
                    -- if istable(vehicle) then
                    --     PrintTable(vehicle)
                    -- end

                    net.WriteString(vehicle_key)

                    local data = util.Compress(util.TableToJSON(vehicle))
                    local dataLen = #data
                    net.WriteUInt(dataLen, 32)
                    net.WriteData(data, dataLen)
                end

                
            net.Send(ply)

        end
    end)
end