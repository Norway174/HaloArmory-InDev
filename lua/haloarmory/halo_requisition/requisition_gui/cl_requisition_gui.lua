HALOARMORY.MsgC("Client HALOARMORY REQUISITION GUI loaded!")


HALOARMORY.Requisition = HALOARMORY.Requisition or {}
HALOARMORY.Requisition.Vehicles = HALOARMORY.Requisition.Vehicles or {}
HALOARMORY.Requisition.VehiclePads = {}
HALOARMORY.Requisition.GUI = HALOARMORY.Requisition.GUI or {}

HALOARMORY.Requisition.Theme = {
    ["roundness"] = 0,
    ["background"] = Color(0,0,0,241),
    ["text"] = Color(255,255,255,255),
    ["header_color"] = Color(0,0,0),
    ["divider_color"] = Color(255,255,255,10),
    ["apply_btn"] = Color(52,107,149),
    ["cancel_btn"] = Color(97,0,0),
}


function HALOARMORY.Requisition.OpenVehiclePad( PadEnt )

    // Let's make sure we're not already in a menu
    if HALOARMORY.Requisition.GUI.Pad_Menu then
        HALOARMORY.Requisition.GUI.Pad_Menu:Remove()
        HALOARMORY.Requisition.GUI.Pad_Menu = nil
    end

    // Create the menu
    local MainFrame = vgui.Create("DFrame")
    MainFrame:SetSize(ScrW() * 0.75, ScrH() * 0.75)
    MainFrame:Center()
    MainFrame:SetTitle("")
    MainFrame:ShowCloseButton(false)
    MainFrame:SetDraggable(true)
    MainFrame:MakePopup()
    MainFrame:SetSizable(true)

    MainFrame.Paint = function(self, w, h)
        HALOARMORY.Logistics.Main_GUI.RenderBlur( self, 1, 3, 250 )

        draw.RoundedBox( HALOARMORY.Requisition.Theme["roundness"], 0, 0, w, h, HALOARMORY.Requisition.Theme["background"] )
        draw.RoundedBox( HALOARMORY.Requisition.Theme["roundness"], 0, 0, w, 40, HALOARMORY.Requisition.Theme["header_color"] )
        draw.SimpleText( "Vehicle Requisition", "QuanticoHeader", w/2, 20, HALOARMORY.Requisition.Theme["text"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

        // Draw a divider line between the 3 docked panels
        draw.RoundedBox( HALOARMORY.Requisition.Theme["roundness"], MainFrame:GetWide() * 0.25 + 7, 50, 1, h - 70, Color(0,0,0,200) )
        draw.RoundedBox( HALOARMORY.Requisition.Theme["roundness"], MainFrame:GetWide() * 0.75 - 7, 50, 1, h - 70, Color(0,0,0,200) )
        
    end

    HALOARMORY.Requisition.GUI.Pad_Menu = MainFrame
    HALOARMORY.Requisition.GUI.Pad_Ent = PadEnt

    // Create an exit button
    local ExitButton = vgui.Create("DButton", MainFrame)
    ExitButton:SetSize( 40, 40 )
    ExitButton:SetPos( MainFrame:GetWide() - 40, 0 )
    ExitButton:SetText("")

    ExitButton.Paint = function(self, w, h)
        draw.RoundedBox( HALOARMORY.Requisition.Theme["roundness"], 0, 0, w, h, HALOARMORY.Requisition.Theme["cancel_btn"] )
        if self:IsHovered() then
            draw.RoundedBox( HALOARMORY.Requisition.Theme["roundness"], 0, 0, w, h, Color(0,0,0,45) )
        end
        draw.SimpleText( "✕", "QuanticoHeader", w/2, h/2, HALOARMORY.Requisition.Theme["text"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    end

    ExitButton.DoClick = function()
        MainFrame:Remove()
        HALOARMORY.Requisition.GUI.Pad_Menu = nil
    end


    // Dock 3 panels; left, center and right
    // Left has two purposes; to display the vehicle pad info and a button to select a new pad. And display a list of vehicles that can be spawned.

    local LeftPanel = vgui.Create("DPanel", MainFrame)
    LeftPanel:SetSize( MainFrame:GetWide() * 0.25, MainFrame:GetTall() )
    LeftPanel:Dock(LEFT)
    LeftPanel:DockMargin(0,15,0,0)

    LeftPanel.Paint = function(self, w, h)
        --draw.RoundedBox( HALOARMORY.Requisition.Theme["roundness"], 0, 0, w, h, Color(0,0,0,125) )
    end

    // Center panel is the vehicle info and options.
    local CenterPanel = vgui.Create("DPanel", MainFrame)
    --CenterPanel:SetSize( MainFrame:GetWide() * 0.5, MainFrame:GetTall() )
    CenterPanel:Dock(FILL)
    CenterPanel:DockMargin(5,15,5,0)

    CenterPanel.Paint = function(self, w, h)
        --draw.RoundedBox( HALOARMORY.Requisition.Theme["roundness"], 0, 0, w, h, Color(0,0,0,125) )
    end

    // Right panel is the vehicle pad build queue
    local RightPanel = vgui.Create("DPanel", MainFrame)
    RightPanel:SetSize( MainFrame:GetWide() * 0.25, MainFrame:GetTall() )
    RightPanel:Dock(RIGHT)
    RightPanel:DockMargin(0,15,0,0)

    RightPanel.Paint = function(self, w, h)
        --draw.RoundedBox( HALOARMORY.Requisition.Theme["roundness"], 0, 0, w, h, Color(0,0,0,125) )
    end


    // Show the selected pad info
    local PadInfo = vgui.Create("DPanel", LeftPanel)
    PadInfo:Dock(TOP)
    PadInfo:SetTall( 100 )

    PadInfo.Paint = function(self, w, h)
        draw.RoundedBox( HALOARMORY.Requisition.Theme["roundness"], 0, 0, w, h, Color(0,0,0,125) )
    end

    // Create a label with the pad name
    local PadName = vgui.Create("DLabel", PadInfo)
    PadName:SetText( tostring( PadEnt:GetDeviceName() ) )
    PadName:SetFont("QuanticoHeader")
    PadName:SetTextColor( HALOARMORY.Requisition.Theme["text"] )
    PadName:Dock(FILL)
    PadName:DockMargin(5,5,5,0)
    PadName:SetContentAlignment(5)

    // Create a button to select a new pad
    local SelectPad = vgui.Create("DButton", PadInfo)
    SelectPad:SetText("Select New Pad")
    SelectPad:SetFont("QuanticoNormal")
    SelectPad:SetTextColor( HALOARMORY.Requisition.Theme["text"] )
    SelectPad:Dock(BOTTOM)
    SelectPad:DockMargin(5,0,5,5)
    SelectPad:SetTall( 35 )

    SelectPad.Paint = function(self, w, h)
        draw.RoundedBox( HALOARMORY.Requisition.Theme["roundness"], 0, 0, w, h, Color(20,20,20,148) )
        if self:IsHovered() then
            draw.RoundedBox( HALOARMORY.Requisition.Theme["roundness"], 0, 0, w, h, Color(0,0,0,45) )
        end
    end

    SelectPad.DoClick = function()
        // Open a menu to select a new pad
        HALOARMORY.Requisition.OpenPadSelector( function( newPad )
            // Callback function to run when a pad is selected
            HALOARMORY.Requisition.OpenVehiclePad( newPad )
        end )
    end


    // Create a list of vehicles that can be spawned
    // Start with a header
    local VehicleListHeader = vgui.Create("DLabel", LeftPanel)
    VehicleListHeader:SetText("Available Vehicles")
    VehicleListHeader:SetFont("QuanticoHeader")
    VehicleListHeader:SetTextColor( HALOARMORY.Requisition.Theme["text"] )
    VehicleListHeader:Dock(TOP)
    VehicleListHeader:DockMargin(5,15,5,0)

    // Create a scroll panel to hold the list
    local VehicleList = vgui.Create("DScrollPanel", LeftPanel)
    VehicleList:Dock(FILL)
    VehicleList:DockMargin(5,5,5,5)

    // Create a list of vehicles that can be spawned
    -- local VehicleListLayout = vgui.Create("DIconLayout", VehicleList)
    -- VehicleListLayout:Dock(FILL)
    -- VehicleListLayout:SetSpaceY(5)
    -- VehicleListLayout:SetSpaceX(5)

    // Create a temporary Loading label
    local LoadingLabel = vgui.Create("DLabel", VehicleList)
    LoadingLabel:SetText("Loading...")
    LoadingLabel:SetFont("QuanticoNormal")
    LoadingLabel:SetTextColor( HALOARMORY.Requisition.Theme["text"] )
    LoadingLabel:SetContentAlignment(5)
    LoadingLabel:Dock(TOP)
    LoadingLabel:SetTall( 50 )
    LoadingLabel:DockMargin(5,5,5,0)

    // Create a list of vehicles that can be spawned
    HALOARMORY.VEHICLES.NETWORK.RequestVehicles( PadEnt, function( vehicles)
    
        --print("Got vehicles!", vehicles, table.Count( HALOARMORY.VEHICLES.LIST ))
        --if istable(vehicles) then
        --    PrintTable(vehicles)
        --end

        // Remove the loading label
        LoadingLabel:Remove()

        // Create a list of vehicles that can be spawned
        for k, v in pairs( vehicles ) do
            --print("Adding vehicle to list", k, v["name"])

            local Vehicle_Ent = scripted_ents.Get( v["entity"] )

            if Vehicle_Ent == nil then
                // Might be Simfphys
                Vehicle_Ent = list.Get("simfphys_vehicles")[v["entity"]]
            end
        
            --print( Vehicle_Ent )
        
            if not Vehicle_Ent then return end
        
            local VehiclePrintName = Vehicle_Ent.PrintName or Vehicle_Ent.Name
            local VehicleModel = Vehicle_Ent.Model or Vehicle_Ent.MDL
        
            --print( VehiclePrintName, VehicleModel )
        
            // Make sure VehicleModel ends with .mdl, if not, then it can't be a valid model, and we should return.
            if not string.EndsWith( VehicleModel, ".mdl" ) then VehicleModel = "error" end



            local VehiclePanel = vgui.Create("DPanel", VehicleList)
            VehiclePanel:Dock(TOP)
            VehiclePanel:SetTall( 75 )
            VehiclePanel:DockMargin(5,5,5,0)

            VehiclePanel.Paint = function(self, w, h)
                draw.RoundedBox( HALOARMORY.Requisition.Theme["roundness"], 0, 0, w, h, Color(20,20,20,148) )
                -- if self:IsHovered() then
                --     draw.RoundedBox( HALOARMORY.Requisition.Theme["roundness"], 0, 0, w, h, Color(0,0,0,45) )
                -- end

                // Draw vehicle name
                draw.SimpleText( VehiclePrintName, "QuanticoNormal", 60, 5, HALOARMORY.Requisition.Theme["text"], TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )

                // Draw vehicle cost
                draw.SimpleText( "Cost: " .. HALOARMORY.INTERFACE.PrettyFormatNumber(v["cost"]) .. " supplies ", "HaloArmory_24", w - 5, h - 10, Color(189,189,189), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM )
            end

            // Create a DModelPanel to display the vehicle
            local VehicleModelPanel = vgui.Create("DModelPanel", VehiclePanel)
            VehicleModelPanel:Dock(LEFT)
            VehicleModelPanel:SetWide( 50 )

            VehicleModelPanel:SetModel( VehicleModel )

            VehicleModelPanel:SetCamPos( Vector( 134, 100, 100) )
            VehicleModelPanel:SetLookAng( Angle( 25, -140, 0 ) )
            VehicleModelPanel:SetFOV( 90 )

            function VehicleModelPanel:LayoutEntity( Entity )
            end

            // Create an invisible button to select the vehicle
            local SelectVehicle = vgui.Create("DButton", VehiclePanel)
            SelectVehicle:SetText("")
            SelectVehicle:Dock(FILL)
            SelectVehicle:SetCursor("hand")

            SelectVehicle.Paint = function(self, w, h)
                if self:IsHovered() then
                    draw.RoundedBox( HALOARMORY.Requisition.Theme["roundness"], 0, 0, w, h, Color(0,0,0,45) )
                end
            end

            SelectVehicle.DoClick = function()
                print("Selected vehicle", v["entity"])
                --HALOARMORY.Requisition.SpawnVehicle( v["entity"], PadEnt )
            end


        end

    end)



    // Show the network info in the top center panel
    local NetworkInfoPanel = vgui.Create("DPanel", CenterPanel)
    NetworkInfoPanel:Dock(TOP)
    NetworkInfoPanel:SetTall( 100 )

    NetworkInfoPanel.Paint = function(self, w, h)
        draw.RoundedBox( HALOARMORY.Requisition.Theme["roundness"], 0, 0, w, h, Color(0,0,0,125) )
    end

    // Create a label with the network name
    local NetworkName = vgui.Create("DLabel", NetworkInfoPanel)
    NetworkName:SetText( "" )
    NetworkName:SetFont("QuanticoNormal")
    NetworkName:SetTextColor( HALOARMORY.Requisition.Theme["text"] )
    NetworkName:Dock(FILL)
    NetworkName:DockMargin(5,5,5,0)
    NetworkName:SetContentAlignment(5)

    NetworkName.Paint = function(self, w, h)
        local label = "Network: "
        draw.SimpleText( label, self:GetFont(), 5, 0, Color(189,189,189), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
        surface.SetFont( self:GetFont() )
        local fontWidth, fontHeight = surface.GetTextSize( label )
        draw.SimpleText( tostring( PadEnt:GetNetworkID() ), self:GetFont(), fontWidth + 5, 0, HALOARMORY.Requisition.Theme["text"], TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )


        // Draw the network supplies and max supplies as a progress bar

        // Draw the background of the progress bar
        draw.RoundedBox( HALOARMORY.Requisition.Theme["roundness"], 5, fontHeight + 5, w - 10, 30, Color(0,0,0,125) )

        // Get the network supplies and max supplies
        local controller_network = util.JSONToTable( PadEnt:GetNetworkTable() )

        if istable(controller_network) then

            local CurrentResource, MaxResource = controller_network.Supplies, controller_network.MaxSupplies

            local Progress = CurrentResource / MaxResource

            local LerpColor = HALOARMORY.Logistics.Main_GUI.LerpColor( Color(37, 133, 18, 210), Color(133, 18, 18, 210), Progress, .75 )

            draw.RoundedBox( HALOARMORY.Requisition.Theme["roundness"], 5, fontHeight + 5, (w - 10) * Progress, 30, LerpColor )

            draw.SimpleText( "Supplies: " .. HALOARMORY.INTERFACE.PrettyFormatNumber(CurrentResource) .. " / " .. HALOARMORY.INTERFACE.PrettyFormatNumber(MaxResource), self:GetFont(), 5, fontHeight + 5 + 30 + 5, HALOARMORY.Requisition.Theme["text"], TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
        
        end

    end





    // Keep at the bottom
    MainFrame.PerformLayout = function(self)
        ExitButton:SetPos( self:GetWide() - 40, 0 )

        LeftPanel:SetWide( self:GetWide() * 0.25 )
        --CenterPanel:SetWide( self:GetWide() * 0.5 )
        RightPanel:SetWide( self:GetWide() * 0.25 )
    end

end



concommand.Add("haloarmory_requisition", function()
    // Do a trace to see if we're looking at a vehicle pad
    local ply = LocalPlayer()
    local tr = ply:GetEyeTrace()
    local vehiclePad = tr.Entity

    // Let's make some checks to see if it's a valid vehicle pad.
    if !IsValid( vehiclePad ) or !isentity( vehiclePad ) then
        HALOARMORY.MsgC("VehiclePad Error:", "Not an entity!")
        return
    end

    if !vehiclePad.VehiclePad or !vehiclePad.GetPadID then
        HALOARMORY.MsgC(Color(255,0,0), "VehiclePad Error:" , "Not a vehicle pad!")
        return
    end

    HALOARMORY.Requisition.OpenVehiclePad( vehiclePad )
end)

if HALOARMORY.Requisition.GUI.Pad_Menu then
    HALOARMORY.Requisition.GUI.Pad_Menu:Remove()
    HALOARMORY.Requisition.GUI.Pad_Menu = nil

    HALOARMORY.Requisition.OpenVehiclePad( HALOARMORY.Requisition.GUI.Pad_Ent )
end