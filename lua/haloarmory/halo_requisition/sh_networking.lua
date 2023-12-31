HALOARMORY.MsgC("Shared HALOARMORY VEHICLES loaded!")


HALOARMORY.VEHICLES = HALOARMORY.VEHICLES or {}
HALOARMORY.VEHICLES.NETWORK = HALOARMORY.VEHICLES.NETWORK or {}


local NET_NAME = "HALOARMORY.VEHICLES.NETWORK"

local ACTION_REQUEST_VEHICLE_PADS = 1

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
        end
    end)

    function HALOARMORY.VEHICLES.NETWORK.RequestVehiclePads( callback )
        Callbacks[ACTION_REQUEST_VEHICLE_PADS] = callback

        net.Start(NET_NAME)
            net.WriteUInt(ACTION_REQUEST_VEHICLE_PADS, 8)
        net.SendToServer()
    end
end

if SERVER then
    net.Receive(NET_NAME, function( len, ply )
        local action = net.ReadUInt(8)

        if action == ACTION_REQUEST_VEHICLE_PADS then
            local pads = {}

            for _, ent in ents.Iterator() do
                if ( ent.VehiclePad ) then
                    --print(ent)
                    table.insert(pads, ent)
                end
            end

            net.Start(NET_NAME)
                net.WriteUInt(ACTION_REQUEST_VEHICLE_PADS, 8)
                net.WriteUInt(#pads, 13)

                for _, pad in pairs(pads) do
                    net.WriteEntity(pad)
                end
            net.Send(ply)
        end
    end)
end