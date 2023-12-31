HALOARMORY.MsgC("Client HALOARMORY REQUISITION GUI loaded!")


HALOARMORY.Requisition = HALOARMORY.Requisition or {}
HALOARMORY.Requisition.Vehicles = HALOARMORY.Requisition.Vehicles or {}
HALOARMORY.Requisition.VehiclePads = {}
HALOARMORY.Requisition.GUI = HALOARMORY.Requisition.GUI or {}

HALOARMORY.Requisition.Theme = {
    ["roundness"] = 24,
    ["background"] = Color(20,20,20),
    ["text"] = Color(255,255,255,255),
    ["header_color"] = Color(0,0,0),
    ["divider_color"] = Color(255,255,255,10),
    ["apply_btn"] = Color(0,97,0),
    ["cancel_btn"] = Color(97,0,0),
}


local ScrWi, ScrHe = math.min(ScrW() - 10, 1280), math.min(ScrH() - 10, 720)
--ScrWi, ScrHe = 800, 600

hook.Add( "OnScreenSizeChanged", "HALOARMORY.Requisition.OnSizeChange", function( oldWidth, oldHeight )
    ScrWi, ScrHe = math.min(ScrW() - 10, 1280), math.min(ScrH() - 10, 720)

    HALOARMORY.Requisition.GUI.Menu:SetSize(ScrWi, ScrHe)
end )

local frequency = frequency or ""

local VehicleSelectorContainerPanel = nil
local SelectedVehiclePad = nil
local LeftPanel = nil


-- function HALOARMORY.INTERFACE.PrettyFormatNumber(number, delimiter)
--     if not delimiter then
--         delimiter = ","
--     end

--     local i, j, minus, int, fraction = tostring(number):find('([-]?)(%d+)([.]?%d*)')

--     -- reverse the int-string and append a comma to all blocks of 3 digits
--     int = int:reverse():gsub("(%d%d%d)", "%1" .. delimiter)
  
--     -- reverse the int-string back remove an optional comma and put the 
--     -- optional minus and fractional part back
--     return minus .. int:reverse():gsub("^,", "") .. fraction
-- end

function CustomScrollBar( the_scrollbar )

    local sbar = the_scrollbar:GetVBar()

    if sbar == nil then return end

    function sbar:Paint(w, h)
        --draw.RoundedBox(0, 0, 0, w, h, Color(255, 255, 255) )
    end
    function sbar.btnUp:Paint(w, h)
        --draw.RoundedBox(0, 0, 0, w, h, Color(200, 100, 0))
    end
    function sbar.btnDown:Paint(w, h)
        --draw.RoundedBox(0, 0, 0, w, h, Color(200, 100, 0))
    end
    function sbar.btnGrip:Paint(w, h)
        draw.RoundedBox(16, w / 4.5, 0, w / 2, h, Color(0, 0, 0) )
    end

end

local VehicleInfoDisplayPanel = nil
local SelectedVehicle = nil
function VehicleDisplayInformation( selected_vehicle, vehicle_key )

    if not HALOARMORY.Requisition.GUI.Menu then return end
    if not VehicleInfoDisplayPanel then return end

    SelectedVehicle = selected_vehicle

    --print("VehicleDisplayInformation", selected_vehicle, vehicle_key)

    local VehicleToQueue = {
        ["name"] = vehicle_key,
        ["skin"] = 0,
        ["loadout"] = "",
    }

    VehicleInfoDisplayPanel:Clear()

    if not SelectedVehicle then
        
        // Display a label to select a vehicle
        local SelectVehicleLabel = vgui.Create("DLabel", VehicleInfoDisplayPanel)
        SelectVehicleLabel:Dock(FILL)
        SelectVehicleLabel:SetText("Select a vehicle")
        SelectVehicleLabel:SetFont("QuanticoHeader")
        SelectVehicleLabel:SetTextColor(HALOARMORY.Requisition.Theme["text"])
        SelectVehicleLabel:SetContentAlignment( 5 )

        return
    end

    // Display the vehicle name at the top
    local VehicleNameLabel = vgui.Create("DLabel", VehicleInfoDisplayPanel)
    VehicleNameLabel:Dock(TOP)
    VehicleNameLabel:SetTall(30)
    VehicleNameLabel:DockMargin(0, 0, 0, 0)
    VehicleNameLabel:SetText(SelectedVehicle["name"])
    VehicleNameLabel:SetFont("QuanticoHeader")
    VehicleNameLabel:SetTextColor(HALOARMORY.Requisition.Theme["text"])
    VehicleNameLabel:SetContentAlignment( 4 )

    // Display the vehicle model
    local VehicleModelPanel = vgui.Create("DPanel", VehicleInfoDisplayPanel)
    VehicleModelPanel:Dock(FILL)
    VehicleModelPanel:DockMargin(0, 0, 0, 0)
    
    VehicleModelPanel.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(0,0,0) )
    end


    -- Draw a model panel
    local ModelPanel = vgui.Create("DAdjustableModelPanel", VehicleModelPanel)
    ModelPanel:SetModel(SelectedVehicle["model"])
    ModelPanel:SetColor(SelectedVehicle["color"])

    ModelPanel:Dock(FILL)
    --ModelPanel:SetMouseInputEnabled(false)


    ModelPanel:SetCamPos( Vector( 134, 100, 100) )
    --ModelPanel:SetLookAt( Vector( 0, 100, 0 ) )
    ModelPanel:SetLookAng( Angle( 25, -140, 0 ) )
    --ModelPanel.OrbitPoint = Vector( -5, -1, 57 )
    --ModelPanel.OrbitDistance = 199

    ModelPanel:SetFOV( 90 )

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

        --print("self.vCamPos", self.vCamPos)
        --print("self.aLookAngle", self.aLookAngle)
        --print("self.OrbitPoint", self.OrbitPoint)
        --print("self.OrbitDistance", self.OrbitDistance)
        --print("self.FOV", self:GetFOV())

    end

    // Display a panel on the Right.
    local RightPanel = vgui.Create("DPanel", VehicleInfoDisplayPanel)
    RightPanel:Dock(RIGHT)
    RightPanel:SetWide(200)
    RightPanel:DockMargin(0, 0, 0, 0)

    RightPanel.Paint = function(self, w, h)
        --draw.RoundedBox(0, 0, 0, w, h, Color(56,14,14) )
    end

    // Display Vehicle Cost
    local VehicleCostPanel = vgui.Create("DPanel", RightPanel)
    VehicleCostPanel:Dock(TOP)
    VehicleCostPanel:SetTall(30)
    VehicleCostPanel:DockMargin(0, 0, 0, 0)

    VehicleCostPanel.Paint = function(self, w, h)
        --draw.RoundedBox(0, 0, 0, w, h, Color(51,51,51) )

        draw.SimpleText("Cost:", "HaloArmory_24", 10, 5, HALOARMORY.Requisition.Theme["text"], TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

        local Cost = 0
        if SelectedVehicle["cost"] then
            Cost = SelectedVehicle["cost"]
        end

        draw.SimpleText(HALOARMORY.INTERFACE.PrettyFormatNumber(Cost) .. " Supplies", "HaloArmory_24", 67, 5, HALOARMORY.Requisition.Theme["text"], TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

    end

    // Display the skin drop down selection
    local SkinSelectionPanel = vgui.Create("DPanel", RightPanel)
    SkinSelectionPanel:Dock(TOP)
    SkinSelectionPanel:SetTall(30)
    SkinSelectionPanel:DockMargin(0, 0, 0, 0)
    SkinSelectionPanel:DockPadding(67, 0, 0, 0)

    SkinSelectionPanel.Paint = function(self, w, h)
        --draw.RoundedBox(0, 0, 0, w, h, Color(51,51,51) )

        draw.SimpleText("Skin:", "HaloArmory_24", 10, 5, HALOARMORY.Requisition.Theme["text"], TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

    end

    local SkinSelection = vgui.Create("DComboBox", SkinSelectionPanel)
    SkinSelection:Dock(FILL)
    SkinSelection:DockMargin(0, 0, 0, 0)
    SkinSelection:SetValue( "Select a skin" )

    local SkinList = {}
    if SelectedVehicle["allowed_skins"] then
        SkinList = SelectedVehicle["allowed_skins"]

        --PrintTable( SkinList )

        local SkinName = table.GetKeys( SkinList )
        if SkinList["UNSC"] then
            SkinName = "UNSC"
        else
            SkinName = SkinName[1]
        end
        SkinSelection:SetValue( SkinName, SkinList[SkinName] )
        VehicleToQueue["skin"] = SkinName
    end

    for i, skin_id in pairs(SkinList) do
        --print("SkinList", i, skin_id)
        SkinSelection:AddChoice( i, skin_id )
    end

    SkinSelection.OnSelect = function( panel, index, value )
        --print("SkinSelection", index, value)
        --ModelPanel:SetSkin( value )

        ModelPanel.Entity:SetSkin( SkinList[value] )
        VehicleToQueue["skin"] = value
    end

    // Display the Loadout drop down selection
    local LoadoutSelectionPanel = vgui.Create("DPanel", RightPanel)
    LoadoutSelectionPanel:Dock(TOP)
    LoadoutSelectionPanel:SetTall(30)
    LoadoutSelectionPanel:DockMargin(0, 0, 0, 0)
    LoadoutSelectionPanel:DockPadding(67, 0, 0, 0)

    LoadoutSelectionPanel.Paint = function(self, w, h)
        --draw.RoundedBox(0, 0, 0, w, h, Color(51,51,51) )

        draw.SimpleText("Loadout:", "HaloArmory_24", 10, 5, HALOARMORY.Requisition.Theme["text"], TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

    end

    local LoadoutSelection = vgui.Create("DComboBox", LoadoutSelectionPanel)
    LoadoutSelection:Dock(FILL)
    LoadoutSelection:DockMargin(0, 0, 0, 0)
    LoadoutSelection:SetValue( "Select a loadout" )

    local LoadoutList = {}
    if SelectedVehicle["loadout"] then
        LoadoutList = SelectedVehicle["loadout"]

        --PrintTable( LoadoutList )

        local LoadoutName = table.GetKeys( LoadoutList )
        if LoadoutList["Default"] then
            LoadoutName = "Default"
        else
            LoadoutName = LoadoutName[1]
        end
        LoadoutSelection:SetValue( LoadoutName, LoadoutList[LoadoutName] )
        VehicleToQueue["loadout"] = LoadoutName
    end

    for i, loadout_id in pairs(LoadoutList) do
        --print("LoadoutList", i, loadout_id)
        LoadoutSelection:AddChoice( i, loadout_id )
    end

    LoadoutSelection.OnSelect = function( panel, index, value )
        --print("LoadoutSelection", index, value)
        --ModelPanel:SetSkin( value )

        for bodygroup_name, loadout in pairs( SelectedVehicle["loadout"][value] ) do
            --print("loadout", bodygroup_name, loadout)

            local bodygroup_id = ModelPanel.Entity:FindBodygroupByName( bodygroup_name )

            if isnumber( bodygroup_id ) then
                ModelPanel.Entity:SetBodygroup( bodygroup_id, loadout )
            end

        end

        VehicleToQueue["loadout"] = value

        --ModelPanel.Entity:SetBodyGroups( value )
    end

    // Add a button to add the vehicle to the queue
    local AddToQueueButton = vgui.Create("DButton", RightPanel)
    AddToQueueButton:Dock(BOTTOM)
    AddToQueueButton:SetTall(30)
    AddToQueueButton:DockMargin(10, 0, 0, 0)
    AddToQueueButton:DockPadding(0, 0, 0, 0)
    AddToQueueButton:SetText("Add to Queue")
    AddToQueueButton:SetFont("QuanticoHeader")
    AddToQueueButton:SetTextColor(HALOARMORY.Requisition.Theme["text"])
    AddToQueueButton:SetContentAlignment( 5 )

    AddToQueueButton.Paint = function(self, w, h)

        if self:IsEnabled() then
            draw.RoundedBox(0, 0, 0, w, h, HALOARMORY.Requisition.Theme["apply_btn"] )
        else
            draw.RoundedBox(0, 0, 0, w, h, Color(128,128,128) )
        end

        
    end

    // Add a warning label if insufficient network supplies
    local WarningLabel = vgui.Create("DLabel", RightPanel)
    WarningLabel:Dock(BOTTOM)
    WarningLabel:SetTall(30)
    WarningLabel:DockMargin(10, 0, 0, 0)
    WarningLabel:DockPadding(0, 0, 0, 0)
    WarningLabel:SetText("Insufficient Supplies")
    WarningLabel:SetFont("HaloArmory_24")
    WarningLabel:SetTextColor(Color( 100, 0,0))
    WarningLabel:SetContentAlignment( 5 )
    WarningLabel:SetVisible( false )


    AddToQueueButton.Think = function(self)

        local CurrentResource, MaxResource = 0, 0
        local Cost = 0
        if SelectedVehicle["cost"] then
            Cost = SelectedVehicle["cost"]
        end

        local network = SelectedVehiclePad:GetNetworkID()

        if network != "0" then

            if !SelectedVehiclePad:CanAfford( SelectedVehicle ) then
                self:SetDisabled( true )
                WarningLabel:SetText("Insufficient Supplies")
                WarningLabel:SetVisible( true )
            else
                self:SetDisabled( false )
                --WarningLabel:SetText("Insufficient Supplies")
                WarningLabel:SetVisible( false )
            end

        else
            self:SetDisabled( true )
            WarningLabel:SetText("Network Offline")
            WarningLabel:SetVisible( true )
        end

    end

    AddToQueueButton.DoClick = function(self)

        if not IsValid(SelectedVehiclePad) then return end

        -- local controller_network = util.JSONToTable( SelectedVehiclePad:GetNetworkTable() )
        -- local CurrentResource, MaxResource = controller_network.Supplies, controller_network.MaxSupplies

        -- local Cost = 0
        -- if SelectedVehicle["cost"] then
        --     Cost = SelectedVehicle["cost"]
        -- end

        -- if Cost >= CurrentResource then return end

        if !SelectedVehiclePad:CanAfford( SelectedVehicle ) then return end

        --print("AddToQueueButton", VehicleToQueue, SelectedVehicle["name"])
        --PrintTable(VehicleToQueue)

        net.Start("HALOARMORY.Requisition")
            net.WriteString("Request-Vehicle")
            net.WriteEntity(SelectedVehiclePad)
            net.WriteString(VehicleToQueue["name"])
            net.WriteString(VehicleToQueue["skin"])
            net.WriteString(VehicleToQueue["loadout"])
        net.SendToServer()

    end

end



function VehicleSelectorPanel( vehicle_pad )

    if not IsValid(HALOARMORY.Requisition.GUI.Menu) and not ispanel(HALOARMORY.Requisition.GUI.Menu)  then return end
    if not IsValid(VehicleSelectorContainerPanel) and not ispanel(VehicleSelectorContainerPanel) then return end

    SelectedVehiclePad = vehicle_pad

    VehicleSelectorContainerPanel:Clear()

    // Display the network supplies at the top
    local NetworkSuppliesPanel = vgui.Create("DPanel", VehicleSelectorContainerPanel)
    NetworkSuppliesPanel:Dock(TOP)
    NetworkSuppliesPanel:SetTall(100)
    NetworkSuppliesPanel:DockMargin(0, 0, 0, 0)

    NetworkSuppliesPanel.Paint = function( self, w, h )
        --draw.RoundedBox(0, 0, 0, w, h, Color(51,51,51) )

        local network_name = "No Network"
        local CurrentResource, MaxResource = 0, 0
        local Progress = 0

        if vehicle_pad then
            network_name = vehicle_pad:GetNetworkID()

            local controller_network = util.JSONToTable( vehicle_pad:GetNetworkTable() )

            if ( istable( controller_network ) ) then
                CurrentResource, MaxResource = controller_network.Supplies, controller_network.MaxSupplies
                Progress = CurrentResource / MaxResource

                local ProgressWidth = w - 10

                draw.RoundedBox(0, 5, 30, ProgressWidth, 40, Color(0,0,0) )
                draw.RoundedBox(0, 5, 30, ProgressWidth * Progress, 40, Color(5,38,16) )

                if SelectedVehicle ~= nil then
                    // Display how much of the network supplies the vehicle costs, by painting red to show much is used at the end of the progress bar
                    local VehicleCost = 0
                    if SelectedVehicle["cost"] then
                        VehicleCost = SelectedVehicle["cost"]
                    end

                    local VehicleCostProgress = VehicleCost / MaxResource

                    draw.RoundedBox(0, 5 + (ProgressWidth * Progress) - (ProgressWidth * VehicleCostProgress), 30, ProgressWidth * VehicleCostProgress, 40, Color(38,5,5) )
                end
        
                draw.SimpleText("             " .. network_name, "HaloArmory_24", 10, 5, HALOARMORY.Requisition.Theme["text"], TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                draw.SimpleText("Network: ", "HaloArmory_24", 10, 5, Color(128,128,128), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

                local ResourceText = HALOARMORY.INTERFACE.PrettyFormatNumber(CurrentResource) .. " / " .. HALOARMORY.INTERFACE.PrettyFormatNumber(MaxResource)

                if SelectedVehicle ~= nil then
                    ResourceText = ResourceText .. " ( -" .. HALOARMORY.INTERFACE.PrettyFormatNumber(SelectedVehicle["cost"]) .. " )"
                end

                draw.SimpleText(ResourceText, "HaloArmory_24", w / 2, 30 + (40 / 2), HALOARMORY.Requisition.Theme["text"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
            else

                draw.RoundedBox(0, 5, 30, w - 10, 40, Color(0,0,0) )
                draw.SimpleText("No Network", "HaloArmory_24", 10, 5, Color( 100, 0,0), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                draw.SimpleText("OFFLINE", "HaloArmory_24", w / 2, 30 + (40 / 2), Color( 100, 0,0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

            end
        end

    end


    // Center Panel - Vehicle Showcase and options
    local CenterPanel = vgui.Create("DPanel", VehicleSelectorContainerPanel)
    CenterPanel:Dock(FILL)
    CenterPanel:DockMargin(0, 0, 0, 0)

    CenterPanel.Paint = function(self, w, h)
        --draw.RoundedBox(0, 0, 0, w, h, Color(51,51,51) )
    end

    VehicleInfoDisplayPanel = CenterPanel
    VehicleDisplayInformation( nil, nil )

    // Bottom Panel - Vehicle Selector
    local BottomPanel = vgui.Create("DPanel", VehicleSelectorContainerPanel)
    BottomPanel:Dock(BOTTOM)
    BottomPanel:SetTall(220)
    BottomPanel:DockMargin(0, 0, 0, 0)

    BottomPanel.Paint = function(self, w, h)
        --draw.RoundedBox(0, 0, 0, w, h, Color(56,14,14) )
    end

    // Add a Scroll Panel to the bottom panel
    local BottomScrollPanel = vgui.Create("DScrollPanel", BottomPanel)
    BottomScrollPanel:Dock(FILL)
    BottomScrollPanel:DockMargin(0, 0, 0, 0)

    // Paint the Scroller
    CustomScrollBar( BottomScrollPanel )

    // Add a DListLayout to the Scroll Panel
    local BottomListLayout = vgui.Create("DIconLayout", BottomScrollPanel)
    BottomListLayout:Dock(FILL)
    BottomListLayout:DockMargin(0, 0, 0, 0)
    BottomListLayout:SetSpaceX(5)
    BottomListLayout:SetSpaceY(5)
    BottomListLayout:SetBorder(5)

    // Get all the vehicles from the vehicle pad
    
    local VehicleList = {}
    if IsValid( vehicle_pad ) then
        VehicleList = SelectedVehiclePad:GetVehicles( LocalPlayer() )
    end


    --print("VehicleList", VehicleList, #VehicleList)
    --PrintTable( VehicleList )

    // Create a DPanel for each vehicle
    for i, Vehicle in pairs(VehicleList) do
        local VehiclePanel = vgui.Create("DPanel", BottomListLayout)
        VehiclePanel:SetSize(150, 150)


        VehiclePanel.Paint = function(self, w, h)
            draw.RoundedBox(0, 0, 0, w, h, Color(0,0,0,80) )
            //draw.RoundedBoxEx(HALOARMORY.Requisition.Theme["roundness"], 0, 0, w, h * 2, HALOARMORY.Requisition.Theme["header_color"], true, true, false, false)

            --draw.SimpleText(i .. ".", "HaloArmory_24", 3, 3, Color(128,128,128), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            draw.SimpleText(Vehicle["name"], "HaloArmory_24", 3, 3, HALOARMORY.Requisition.Theme["text"], TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

            if SelectedVehicle == Vehicle then
                draw.RoundedBox(0, 0, 0, w, h, Color(255,255,255,10) )
            end
        end

        // Draw a model panel
        local ModelPanel = vgui.Create("DModelPanel", VehiclePanel)
        ModelPanel:SetModel( Vehicle["model"] )
        ModelPanel:SetColor( Vehicle["color"] )

        ModelPanel:SetPos( 5, 25 )
        ModelPanel:SetSize( 140, 120 )
        ModelPanel:SetCamPos( Vector( 100, 100, 100 ) )
        ModelPanel:SetLookAt( Vector( -100, -170, -50 ) )
        ModelPanel:SetFOV( 90 )
        ModelPanel:SetAmbientLight( Color( 255, 255, 255, 255 ) )
        ModelPanel:SetDirectionalLight( BOX_FRONT, Color( 255, 255, 255, 255 ) )
        ModelPanel:SetMouseInputEnabled( false )

        function ModelPanel:LayoutEntity( Entity ) return end -- disables default rotation


        // Create a button to select the vehicle, the button should be invisible and cover the entire panel
        local SelectButton = vgui.Create("DButton", VehiclePanel)
        SelectButton:SetText("")
        SelectButton:SetPos(0, 0)
        SelectButton:SetSize(150, 150)
        SelectButton.DoClick = function()
            
            --print("Vehicle Selected Button", Vehicle["name"])
            SelectedVehicle = Vehicle
            VehicleDisplayInformation( Vehicle, i )

        end

        SelectButton.Paint = function(self, w, h) end

    end




end




local function VehiclePadsPanel()

    if not IsValid(HALOARMORY.Requisition.GUI.Menu) and not ispanel(HALOARMORY.Requisition.GUI.Menu)  then return end
    if not IsValid(LeftPanel) and not ispanel(LeftPanel) then return end

    LeftPanel:Clear()

    // Create a DPanel for each vehicle pad
    --print("VehiclePadsPanel", HALOARMORY.Requisition.VehiclePads, #HALOARMORY.Requisition.VehiclePads, LeftPanel)
    for i, VehiclePad in pairs(HALOARMORY.Requisition.VehiclePads) do
        --print("VehiclePad", VehiclePad)
        local VehiclePadPanel = vgui.Create("DPanel", LeftPanel)
        VehiclePadPanel:Dock(TOP)
        VehiclePadPanel:SetTall(100)
        VehiclePadPanel:DockMargin(0, 0, 0, 5)

        VehiclePadPanel.Paint = function(self, w, h)
            draw.RoundedBox(0, 0, 0, w, h, Color(0,0,0) )
            //draw.RoundedBoxEx(HALOARMORY.Requisition.Theme["roundness"], 0, 0, w, h * 2, HALOARMORY.Requisition.Theme["header_color"], true, true, false, false)


            local network_name = VehiclePad:GetNetworkID()

            local controller_network = util.JSONToTable( VehiclePad:GetNetworkTable() )

            //draw.SimpleText( type(controller_network), "HaloArmory_24", w - 3, 20, HALOARMORY.Requisition.Theme["text"], TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)

            if ( istable( controller_network ) ) then

                // Create a progress bar for the current resources
                local CurrentResource, MaxResource = controller_network.Supplies, controller_network.MaxSupplies
                local Progress = CurrentResource / MaxResource

                local ProgressWidth = w 

                //draw.RoundedBox(0, 85, 75, ProgressWidth, 20, Color(0,0,0) )
                draw.RoundedBox(0, 0, 0, ProgressWidth * Progress, h, Color(5,38,16) )

                draw.SimpleText(network_name, "HaloArmory_24", 89, 51, HALOARMORY.Requisition.Theme["text"], TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                draw.SimpleText(HALOARMORY.INTERFACE.PrettyFormatNumber(CurrentResource) .. " / " .. HALOARMORY.INTERFACE.PrettyFormatNumber(MaxResource), "HaloArmory_24", 90, 75, HALOARMORY.Requisition.Theme["text"], TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            else
                draw.SimpleText("No Network - OFFLINE", "HaloArmory_24", 89, 51, Color( 100, 0,0), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

                //draw.RoundedBox(0, 85, 75, w - 90, 20, Color(0,0,0) )
                //draw.SimpleText("OFFLINE", "HaloArmory_24", 90, 75, Color( 100, 0,0), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            end
            
            draw.SimpleText(i .. ".", "HaloArmory_24", 3, 3, Color(128,128,128), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            draw.SimpleText("   " .. VehiclePad:GetDeviceName(), "HaloArmory_24", 3, 3, HALOARMORY.Requisition.Theme["text"], TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

            // Draw Network Supplies

            draw.SimpleText("Network:", "HaloArmory_24", 89, 30, Color(128,128,128), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

            if SelectedVehiclePad == VehiclePad then
                draw.RoundedBox(0, 0, 0, w, h, Color(255,255,255,10) )
            end
        end


        // Draw a model panel
        local ModelPanel = vgui.Create("DModelPanel", VehiclePadPanel)
        ModelPanel:SetModel(VehiclePad.DeviceModel)
        ModelPanel:SetPos( 5, 25 )
        ModelPanel:SetSize( 70, 70 )
        ModelPanel:SetCamPos( Vector( 100, 100, 100 ) )
        ModelPanel:SetLookAt( Vector( -100, -100, -200 ) )
        ModelPanel:SetFOV( 75 )
        ModelPanel:SetAmbientLight( Color( 255, 255, 255, 255 ) )
        ModelPanel:SetDirectionalLight( BOX_FRONT, Color( 255, 255, 255, 255 ) )
        ModelPanel:SetMouseInputEnabled( false )

        function ModelPanel:LayoutEntity( Entity ) return end -- disables default rotation

        // Create a button to select the vehicle pad, the button should be invisible and cover the entire panel
        local SelectButton = vgui.Create("DButton", VehiclePadPanel)
        SelectButton:SetText("")
        SelectButton:SetPos(0, 0)
        SelectButton:SetSize(ScrWi * 0.22, 100)
        SelectButton.DoClick = function()
            
            //print("VehiclePad Selected Button")
            VehicleSelectorPanel( VehiclePad )

        end

        SelectButton.Paint = function(self, w, h) end

    end

    print( "HALOARMORY.Requisition.VehiclePads", HALOARMORY.Requisition.VehiclePads, #HALOARMORY.Requisition.VehiclePads )

    if #HALOARMORY.Requisition.VehiclePads == 0 then
        local NoVehiclePadsLabel = vgui.Create("DLabel", LeftPanel)
        NoVehiclePadsLabel:Dock(FILL)
        NoVehiclePadsLabel:SetText("No Vehicle Pads")
        NoVehiclePadsLabel:SetFont("QuanticoHeader")
        NoVehiclePadsLabel:SetTextColor( Color( 100, 100,100) )
        NoVehiclePadsLabel:SetContentAlignment( 5 )
    
    end


    LeftPanel:PerformLayout()
    --HALOARMORY.Requisition.GUI.Menu:InvalidateLayout( true )
    --LeftPanel:InvalidateLayout( true )


end


function HALOARMORY.Requisition.Open( frquency_channel )
    // Register Menu User
    net.Start("HALOARMORY.Requisition")
        net.WriteString("Register-User")
    net.SendToServer()

    if IsValid(HALOARMORY.Requisition.GUI.Menu) and ispanel(HALOARMORY.Requisition.GUI.Menu) then return end

    frequency = frquency_channel or frequency or "UNSC"

    local MainMenu = vgui.Create("DFrame")
    MainMenu:SetSize(ScrWi, ScrHe)
    MainMenu:Center()
    MainMenu:SetTitle("")
    MainMenu:MakePopup()
    MainMenu:ShowCloseButton( false )

    MainMenu:SetSizable( true )
    --HALOARMORY.Meny:SetHeight( ScrHe * 0.06 )

    HALOARMORY.Requisition.GUI.Menu = MainMenu

    MainMenu.Paint = function(self, w, h)
        draw.RoundedBox(HALOARMORY.Requisition.Theme["roundness"], 0, 0, w, h, HALOARMORY.Requisition.Theme["background"])
        draw.RoundedBoxEx(HALOARMORY.Requisition.Theme["roundness"], 0, 0, w, 43, HALOARMORY.Requisition.Theme["header_color"], true, true, false, false)

        draw.SimpleText("// " .. frequency .. " // REQUISITION //", "HALO_Armory_Font", w / 2, h * .03, HALOARMORY.Requisition.Theme["text"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        --draw.SimpleText("✕", "HALO_Armory_Font", w - 25, h * .03, HALOARMORY.ARMORY.Theme["text"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    MainMenu.OnRemove = function(self)
        HALOARMORY.Requisition.GUI.Menu = nil
        // Un-Register Menu User
        net.Start("HALOARMORY.Requisition")
            net.WriteString("Un-Register-User")
        net.SendToServer()
    end


    local CloseButton = vgui.Create( "DButton", MainMenu )
    CloseButton:SetText( "" )
    CloseButton:SetPos( ScrWi - 45, 0 )
    CloseButton:SetSize( 45, 43 )
    CloseButton.DoClick = function()
        if MainMenu then MainMenu:Remove() end
    end
    CloseButton.Paint = function(self, w, h)
        draw.RoundedBoxEx(HALOARMORY.Requisition.Theme["roundness"], 0, 0, w, h, HALOARMORY.Requisition.Theme["cancel_btn"], false, true, false, false)
        draw.SimpleText("✕", "HALO_Armory_Font", w / 2, h / 2, HALOARMORY.ARMORY.Theme["text"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end


    MainMenu.OnSizeChanged = function(self, newWidth, newHeight )
        CloseButton:SetPos( newWidth - 45, 0 )
    end

    // 3 way split panels

    local CotentPanel = vgui.Create("DPanel", MainMenu)
    CotentPanel:Dock(FILL)
    CotentPanel:DockMargin(5, 19, 5, 5)

    CotentPanel.Paint = function(self, w, h)
        --draw.RoundedBox(0, ScrWi * 0.223, 25, 1, h - 70, Color(255,255,255,4) )
        --draw.RoundedBox(0, ScrWi * 0.773, 25, 1, h - 70, Color(255,255,255,4) )
    end

    local LeftDockPanel = vgui.Create("DPanel", CotentPanel)
    LeftDockPanel:Dock(LEFT)
    LeftDockPanel:SetWide(ScrWi * 0.22)


    local MiddlePanel = vgui.Create("DPanel", CotentPanel)
    MiddlePanel:Dock(FILL)

    MiddlePanel.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 25, 1, h - 70, Color(255,255,255,4) )
        draw.RoundedBox(0, w-1, 25, 1, h - 70, Color(255,255,255,4) )
    end


    local RightPanel = vgui.Create("DPanel", CotentPanel)
    RightPanel:Dock(RIGHT)
    RightPanel:SetWide(ScrWi * 0.22)

    local DrawnPanels = function(self, w, h)
    end
    LeftDockPanel.Paint = DrawnPanels
    --MiddlePanel.Paint = DrawnPanels
    RightPanel.Paint = DrawnPanels


    // Left Panel - Select a vehicle pad
    
    // Create a DLabel for the header
    local LeftHeader = vgui.Create("DLabel", LeftDockPanel)
    LeftHeader:Dock(TOP)
    LeftHeader:SetTall(30)
    LeftHeader:DockMargin(0, 0, 0, 10)
    LeftHeader:SetText("Vehicle Pads")
    LeftHeader:SetFont("QuanticoHeader")
    LeftHeader:SetTextColor(HALOARMORY.Requisition.Theme["text"])
    LeftHeader:SetContentAlignment(5)



    // Create a Scroll Panel
    local LeftScrollPanel = vgui.Create("DScrollPanel", LeftDockPanel)
    LeftScrollPanel:Dock(FILL)
    LeftScrollPanel:DockMargin(0, 0, 0, 0)

    // Paint the Scroller
    CustomScrollBar( LeftScrollPanel )

    LeftPanel = LeftScrollPanel

    // Create a Loading Label
    local LoadingLabel = vgui.Create("DLabel", LeftScrollPanel)
    LoadingLabel:Dock(FILL)
    LoadingLabel:SetText("Loading...")
    LoadingLabel:SetFont("QuanticoHeader")
    LoadingLabel:SetTextColor( Color(128,128,128) )
    LoadingLabel:SetContentAlignment(5)




    --VehiclePadsPanel()


    // Middle Panel - Select a vehicle

    // Create a DLabel for the header
    local MiddleHeader = vgui.Create("DLabel", MiddlePanel)
    MiddleHeader:Dock(TOP)
    MiddleHeader:SetTall(30)
    MiddleHeader:DockMargin(10, 0, 10, 0)
    MiddleHeader:SetText("Vehicle Selector")
    MiddleHeader:SetFont("QuanticoHeader")
    MiddleHeader:SetTextColor(HALOARMORY.Requisition.Theme["text"])
    MiddleHeader:SetContentAlignment(5)

    // Create a DPanel container for the vehicle selector
    VehicleSelectorContainerPanel = vgui.Create("DPanel", MiddlePanel)
    VehicleSelectorContainerPanel:Dock(FILL)
    VehicleSelectorContainerPanel:DockMargin(10, 0, 10, 0)

    VehicleSelectorContainerPanel.Paint = function(self, w, h)
        --draw.RoundedBox(0, 0, 0, w, h, Color(116,6,6) )
    end



    --VehicleSelectorContainerPanel = VehicleSelectorContainer

    --VehicleSelectorPanel( nil )


    // Right Panel - Vehicle Queue

    // Create a DLabel for the header
    local RightHeader = vgui.Create("DLabel", RightPanel)
    RightHeader:Dock(TOP)
    RightHeader:SetTall(30)
    RightHeader:DockMargin(0, 0, 0, 5)
    RightHeader:SetText("Vehicle Queue")
    RightHeader:SetFont("QuanticoHeader")
    RightHeader:SetTextColor(HALOARMORY.Requisition.Theme["text"])
    RightHeader:SetContentAlignment(5)
    

    // Create a DLabel for what is on the pad.
    local OnVehiclePad = vgui.Create("DPanel", RightPanel)
    OnVehiclePad:Dock(TOP)
    OnVehiclePad:SetTall(30)
    OnVehiclePad:DockMargin(0, 0, 0, 5)

    OnVehiclePad.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(5,155,0) )

        draw.SimpleText("On Pad:", "HaloArmory_24", 10, 5, HALOARMORY.Requisition.Theme["text"], TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

        local VehicleOnPad = "None"
        if IsValid(SelectedVehiclePad) then
            VehicleOnPad = SelectedVehiclePad:GetOnPad()
        end

        draw.SimpleText(VehicleOnPad, "HaloArmory_24", 67, 5, HALOARMORY.Requisition.Theme["text"], TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

    end


end

net.Receive("HALOARMORY.Requisition", function()
    local Action = net.ReadString()

    if Action == "Menu-Init" then
        local NumVehiclePads = net.ReadInt( 14 )

        HALOARMORY.Requisition.VehiclePads = {}
        for i = 1, NumVehiclePads do
            local VehiclePad = net.ReadEntity()

            if frequency then
                if VehiclePad:GetFrequency() != frequency then continue end
            end

            HALOARMORY.Requisition.VehiclePads[i] = VehiclePad
        end


    end
end)


concommand.Add("haloarmory_requisition", function() 
    HALOARMORY.Requisition.Open( "UNSC" )
end)

if HALOARMORY.Requisition.GUI.Menu then
    HALOARMORY.Requisition.GUI.Menu:Remove()
    HALOARMORY.Requisition.GUI.Menu = nil

    HALOARMORY.Requisition.Open( "UNSC" )
end