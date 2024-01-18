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

                CenterPanel:SelectVehicle( v )
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

    NetworkName.Cost = 0

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

            // Calculate the progress and the cost progress
            local Progress = CurrentResource / MaxResource
            local ProgressCost = NetworkName.Cost / MaxResource

            local LerpColor = HALOARMORY.Logistics.Main_GUI.LerpColor( Color(37, 133, 18, 210), Color(133, 18, 18, 210), Progress, .75 )

            draw.RoundedBox( HALOARMORY.Requisition.Theme["roundness"], 5, fontHeight + 5, (w - 10) * (Progress - ProgressCost), 30, LerpColor )

            // Draw the cost of the selected vehicle over the progress bar, as a red block to visualize how much of the resources it will cost.
            draw.RoundedBox( HALOARMORY.Requisition.Theme["roundness"], 5 + (w - 10) * (Progress - ProgressCost), fontHeight + 5, (w - 10) * ProgressCost, 30, Color(133, 18, 18, 210) )

            local supplies_text = "Supplies: " .. HALOARMORY.INTERFACE.PrettyFormatNumber(CurrentResource) .. " / " .. HALOARMORY.INTERFACE.PrettyFormatNumber(MaxResource)

            if NetworkName.Cost ~= 0 then
                supplies_text = supplies_text .. " ( " .. HALOARMORY.INTERFACE.PrettyFormatNumber( -NetworkName.Cost ) .. " )"
            end

            draw.SimpleText( supplies_text, self:GetFont(), 5, fontHeight + 5 + 30 + 5, HALOARMORY.Requisition.Theme["text"], TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
        
        end

    end


    // Display a header "Selected Vehicle"
    local SelectVehicleHeader = vgui.Create("DLabel", CenterPanel)
    SelectVehicleHeader:SetText("Selected Vehicle")
    SelectVehicleHeader:SetFont("QuanticoHeader")
    SelectVehicleHeader:SetTextColor( HALOARMORY.Requisition.Theme["text"] )
    SelectVehicleHeader:Dock(TOP)
    SelectVehicleHeader:DockMargin(5,15,5,0)

    // Create a Select Vehicle container
    local SelectedVehicleContainer = vgui.Create("DPanel", CenterPanel)
    SelectedVehicleContainer:Dock(FILL)
    SelectedVehicleContainer:DockMargin(5,5,5,5)

    SelectedVehicleContainer.Paint = function(self, w, h)
        --draw.RoundedBox( HALOARMORY.Requisition.Theme["roundness"], 0, 0, w, h, Color(20,20,20,148) )
    end


    // Display a placeholder text telling the user to "Select a vehicle"
    local SelectVehiclePlaceholder = vgui.Create("DLabel", SelectedVehicleContainer)
    SelectVehiclePlaceholder:SetText("Select a vehicle")
    SelectVehiclePlaceholder:SetFont("QuanticoNormal")
    SelectVehiclePlaceholder:SetTextColor( HALOARMORY.Requisition.Theme["text"] )
    SelectVehiclePlaceholder:SetContentAlignment(5)
    SelectVehiclePlaceholder:Dock(TOP)
    SelectVehiclePlaceholder:DockMargin(5,5,5,0)
    SelectVehiclePlaceholder:SetTall( 200 )


    function CenterPanel:SelectVehicle( vehicle )
        SelectedVehicleContainer:Clear()


        local VehicleClass = vehicle["entity"]

        --print( VehicleClass )

        if VehicleClass == "" then return end

        local Vehicle_Ent = scripted_ents.Get( VehicleClass )

        if Vehicle_Ent == nil then
            // Might be Simfphys
            Vehicle_Ent = list.Get("simfphys_vehicles")[VehicleClass]
        end

        --print( Vehicle_Ent )

        if not Vehicle_Ent then return end

        local VehiclePrintName = Vehicle_Ent.PrintName or Vehicle_Ent.Name
        local VehicleModel = Vehicle_Ent.Model or Vehicle_Ent.MDL

        --print( VehiclePrintName, VehicleModel )

        // Make sure VehicleModel ends with .mdl, if not, then it can't be a valid model, and we should return.
        if not string.EndsWith( VehicleModel, ".mdl" ) then return end

        NetworkName.Cost = vehicle["cost"] or 0

        print("Selected vehicle", vehicle)
        if istable(vehicle) then
            PrintTable(vehicle)
        end


        // Create a Header to display the vehicle name
        local VehicleName = vgui.Create("DLabel", SelectedVehicleContainer)
        VehicleName:SetText( tostring( VehiclePrintName ) )
        VehicleName:SetFont("QuanticoHeader")
        VehicleName:SetTextColor( HALOARMORY.Requisition.Theme["text"] )
        VehicleName:Dock(TOP)
        VehicleName:DockMargin(5,5,5,0)
        VehicleName:SetContentAlignment(5)

        -- Draw a model panel
        local ModelPanel = vgui.Create("DAdjustableModelPanel", SelectedVehicleContainer)
        ModelPanel:Dock(FILL)
        ModelPanel:SetModel(VehicleModel)
        --ModelPanel:SetColor(SelectedVehicle["color"])

        ModelPanel:SetCamPos( Vector( 134, 100, 100) )
        ModelPanel:SetLookAng( Angle( 25, -140, 0 ) )
        ModelPanel:SetFOV( 120 )

        function ModelPanel:LayoutEntity( Entity )
        end

        function ModelPanel:OnMousePressed( mousecode )

            self:SetCursor( "none" )
            self:MouseCapture( true )
            self.Capturing = true
            self.MouseKey = mousecode

            if ( self.MouseKey ~= MOUSE_LEFT ) then return end
            self:SetFirstPerson( true )
            self:CaptureMouse()
        
            -- Helpers for the orbit movement
            local mins, maxs = self.Entity:GetModelBounds()
            local center = ( mins + maxs ) / 2
        
            self.OrbitPoint = center
            self.OrbitDistance = ( self.OrbitPoint - self.vCamPos ):Length()
        end
        

        function ModelPanel:FirstPersonControls()
            local x, y = self:CaptureMouse()
            local scale = self:GetFOV() / 180
            x = x * -0.5 * scale
            y = y * 0.5 * scale
        
            if ( self.MouseKey ~= MOUSE_LEFT ) then return end
            if ( input.IsShiftDown() ) then y = 0 end

            self.aLookAngle = self.aLookAngle + Angle( y * 4, x * 4, 0 )
            self.vCamPos = self.OrbitPoint - self.aLookAngle:Forward() * self.OrbitDistance
        end

        local ModelPanel_ent = ModelPanel.Entity

        // Create a bottom panel for 3 columns of options.
        // Color & Skin | Bodygroups | Spawn

        local BottomPanel = vgui.Create("DPanel", SelectedVehicleContainer)
        BottomPanel:Dock(BOTTOM)
        BottomPanel:SetTall( 150 )

        BottomPanel.Paint = function(self, w, h)
            draw.RoundedBox( HALOARMORY.Requisition.Theme["roundness"], 0, 0, w, h, Color(0,0,0,125) )
        end

        local ColorSkinBodygroupPanel = vgui.Create("DPanel", BottomPanel)
        ColorSkinBodygroupPanel:Dock(FILL)

        local ColorSkinPanel = vgui.Create("DPanel", ColorSkinBodygroupPanel)
        ColorSkinPanel:Dock(LEFT)
        ColorSkinPanel:SetWide( 150 )

        local BodygroupPanel = vgui.Create("DPanel", ColorSkinBodygroupPanel)
        BodygroupPanel:Dock(FILL)

        local SpawnButtonPanel = vgui.Create("DPanel", BottomPanel)
        SpawnButtonPanel:Dock(RIGHT)
        SpawnButtonPanel:SetWide( 150 )


        // Set the Margins
        ColorSkinPanel:DockMargin(0,0,5,0)
        BodygroupPanel:DockMargin(0,0,5,0)
        SpawnButtonPanel:DockMargin(0,0,0,0)


        local function PaintThePanels(self, w, h)
            draw.RoundedBox( HALOARMORY.Requisition.Theme["roundness"], 0, 0, w, h, Color(0,0,0,125) )
        end

        ColorSkinBodygroupPanel.Paint = function(self, w, h) end
        ColorSkinPanel.Paint = PaintThePanels
        BodygroupPanel.Paint = PaintThePanels
        SpawnButtonPanel.Paint = PaintThePanels


        // Color and Skin Panel

        local ColorOptionHeader = vgui.Create("DLabel", ColorSkinPanel)
        ColorOptionHeader:SetText("Color")
        ColorOptionHeader:SetFont("QuanticoNormal")
        ColorOptionHeader:SetTextColor( HALOARMORY.Requisition.Theme["text"] )
        ColorOptionHeader:Dock(TOP)
        ColorOptionHeader:DockMargin(5,5,5,0)

        local ColorOptionDropDown = vgui.Create("DComboBox", ColorSkinPanel)
        ColorOptionDropDown:SetValue( vehicle["defaults"]["color"] )
        ColorOptionDropDown:Dock(TOP)
        ColorOptionDropDown:DockMargin(5,5,5,5)

        for k, v in pairs( vehicle["colors"] ) do
            ColorOptionDropDown:AddChoice( k )
        end

        ColorOptionDropDown.Paint = function(self, w, h)
            draw.RoundedBox( HALOARMORY.Requisition.Theme["roundness"], 0, 0, w, h, Color(20,20,20,148) )
            if self:IsHovered() then
                draw.RoundedBox( HALOARMORY.Requisition.Theme["roundness"], 0, 0, w, h, Color(0,0,0,45) )
            end
        end


        // Set the default color
        local function UpdateColor()
            local color = vehicle["colors"][ColorOptionDropDown:GetValue()]
            color = Color( color.r, color.g, color.b, 255 )
            ModelPanel:SetColor( color )
        end

        UpdateColor()
        ColorOptionDropDown.OnSelect = UpdateColor


        local SkinOptionHeader = vgui.Create("DLabel", ColorSkinPanel)
        SkinOptionHeader:SetText("Skin")
        SkinOptionHeader:SetFont("QuanticoNormal")
        SkinOptionHeader:SetTextColor( HALOARMORY.Requisition.Theme["text"] )
        SkinOptionHeader:Dock(TOP)
        SkinOptionHeader:DockMargin(5,5,5,0)

        local SkinOptionDropDown = vgui.Create("DComboBox", ColorSkinPanel)
        SkinOptionDropDown:SetValue( vehicle["defaults"]["skin"] )
        SkinOptionDropDown:Dock(TOP)
        SkinOptionDropDown:DockMargin(5,5,5,0)

        for k, v in pairs( vehicle["skins"] ) do
            SkinOptionDropDown:AddChoice( k )
        end

        SkinOptionDropDown.Paint = function(self, w, h)
            draw.RoundedBox( HALOARMORY.Requisition.Theme["roundness"], 0, 0, w, h, Color(20,20,20,148) )
            if self:IsHovered() then
                draw.RoundedBox( HALOARMORY.Requisition.Theme["roundness"], 0, 0, w, h, Color(0,0,0,45) )
            end
        end

        // Set the default skin
        local function UpdateSkin()
            ModelPanel.Entity:SetSkin( vehicle["skins"][SkinOptionDropDown:GetValue()] )
        end

        UpdateSkin()
        SkinOptionDropDown.OnSelect = UpdateSkin


        // Bodygroup Panel

        local BodygroupOptionHeader = vgui.Create("DLabel", BodygroupPanel)
        BodygroupOptionHeader:SetText("Bodygroups")
        BodygroupOptionHeader:SetFont("QuanticoNormal")
        BodygroupOptionHeader:SetTextColor( HALOARMORY.Requisition.Theme["text"] )
        BodygroupOptionHeader:Dock(TOP)
        BodygroupOptionHeader:DockMargin(5,5,5,5)


        local LoadoutBodygroupsScrollbar = vgui.Create("DScrollPanel", BodygroupPanel)
        LoadoutBodygroupsScrollbar:Dock( FILL )

        local ListOfBodygroups = vehicle["bodygroups"]


        for key, value in pairs( ListOfBodygroups ) do

            ModelPanel.Entity:SetBodygroup( ModelPanel.Entity:FindBodygroupByName( key ), value[1] )

            if table.Count( value ) <= 1 then continue end

            local BodygroupPanel2 = vgui.Create("DPanel", LoadoutBodygroupsScrollbar)
            BodygroupPanel2:Dock( TOP )
            BodygroupPanel2:DockMargin( 0, 0, 2, 5 )
            BodygroupPanel2:SetTall( 60 )

            BodygroupPanel2.Paint = function( self, w, h )
                draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 187) )
            end

            local BodygroupLabel = vgui.Create("DLabel", BodygroupPanel2)
            BodygroupLabel:Dock( TOP )
            BodygroupLabel:SetWide( 250 )
            BodygroupLabel:SetText( " " .. tostring( key ) )

            
            // Use DTileLayout with MakeDroppable to allow for reordering of bodygroups.
            local BodygroupTileLayout = vgui.Create("DTileLayout", BodygroupPanel2)
            BodygroupTileLayout:Dock( FILL )
            BodygroupTileLayout:DockMargin( 5, 0, 0, 0 )
            BodygroupTileLayout:SetBaseSize( 35 )
            BodygroupTileLayout:SetTall( 50 )

            BodygroupTileLayout:SetSpaceX( 2 )
            BodygroupTileLayout:SetSpaceY( 2 )


            for i = 1, table.Count( value ) do

                local BodygroupSubPanel = vgui.Create("DButton", BodygroupTileLayout)
                local size = BodygroupTileLayout:GetBaseSize()
                BodygroupSubPanel:SetSize( size, size )

                BodygroupSubPanel:SetText("")


                BodygroupSubPanel.BodygroupNumber = i - 1

                BodygroupSubPanel.Paint = function( self, w, h )
                    draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 187) )

                    local v_ent = ModelPanel.Entity
                    local current_bodygroup_id = v_ent:FindBodygroupByName( key )
                    local current_bodygroup = ModelPanel.Entity:GetBodygroup( current_bodygroup_id )

                    if BodygroupSubPanel.BodygroupNumber == current_bodygroup then
                        draw.RoundedBox( 0, 1, 1, w-2, h-2, Color( 0, 255, 0, 70) )
                    end

                    draw.SimpleText( BodygroupSubPanel.BodygroupNumber, "DermaDefault", size / 2, size / 2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                end

                BodygroupSubPanel.DoClick = function(self)
                    //print("Clicked bodygroup", key, BodygroupSubPanel.BodygroupNumber)

                    ModelPanel.Entity:SetBodygroup( ModelPanel.Entity:FindBodygroupByName( key ), BodygroupSubPanel.BodygroupNumber )
                end

            end

        end



        // Spawn Button Panel

        local SpawnButton = vgui.Create("DButton", SpawnButtonPanel)
        SpawnButton:SetText("Spawn")
        SpawnButton:SetFont("QuanticoNormal")
        SpawnButton:SetTextColor( HALOARMORY.Requisition.Theme["text"] )
        SpawnButton:Dock(BOTTOM)
        SpawnButton:SetTall( 50 )
        SpawnButton:DockMargin(5,5,5,5)

        SpawnButton.Paint = function(self, w, h)
            draw.RoundedBox( HALOARMORY.Requisition.Theme["roundness"], 0, 0, w, h, HALOARMORY.Requisition.Theme["apply_btn"] )
            if self:IsHovered() then
                draw.RoundedBox( HALOARMORY.Requisition.Theme["roundness"], 0, 0, w, h, Color(0,0,0,45) )
            end
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