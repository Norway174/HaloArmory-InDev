

TOOL.Category = "HALOARMORY"
TOOL.Name = "#tool.halo_npc_spawner.name"
TOOL.Command = nil
TOOL.ConfigName = "" --Setting this means that you do not have to create external configuration files to define the layout of the tool config-hud 

TOOL.Information = {
    { name = "left" },
    { name = "right" },
    { name = "reload" },
}

if CLIENT then
    language.Add("tool.halo_npc_spawner.name","NPC Spawner")
    language.Add("tool.halo_npc_spawner.desc","Spawns the configured NPC.")
    language.Add("tool.halo_npc_spawner.left","Spawn NPC")
    language.Add("tool.halo_npc_spawner.right","Delete NPC")
    language.Add("tool.halo_npc_spawner.reload","Clear all NPCs")
end



function TOOL.BuildCPanel(pnl)
    pnl:AddControl("Header",{Text = "Spawner", Description = [[
This tool is still work in progress. And is not functional yet.
    ]]})
end

function TOOL:Think()

    if CLIENT then
        // If the ship is nil, update the desc
        if not IsValid(self:GetEnt( 1 )) then
            language.Add("tool.halo_npc_spawner.desc","Attaches a prop to the ship (No ship selected)")
        else
            local ship_class = self:GetEnt( 1 ):GetClass()
            language.Add("tool.halo_npc_spawner.desc","Attaches a prop to the ship ("..ship_class..")")
        end
    end

end

function TOOL:LeftClick( trace )
    if trace.Entity == self:GetEnt( 1 ) then
        chat.AddText(Color(255,0,0), "[HALOARMORY] ", Color(255,255,255), "You can't attach the ship to itself.")
        return
    end

    print("Left click")

end

function TOOL:RightClick( trace )
    if trace.Entity == self:GetEnt( 1 ) then
        chat.AddText(Color(255,0,0), "[HALOARMORY] ", Color(255,255,255), "You can't deatach the ship from itself.")
        return
    end

    print("Right click")

end

function TOOL:Reload( trace )
    local ent = trace.Entity

    if ent.HALOARMORY_Ships_Presets then
        // Set the "ship" convar
        --print("Ship selected", ent)
        chat.AddText(Color(255,0,0), "[HALOARMORY] ", Color(255,255,255), "Ship selected: ", Color(159,241,255), ent:GetClass(), Color(255,255,255), ".")
        self:SetObject( 1, ent )
    end
end





// Add a fallback method to add the prop to the ship with a right click context menu
properties.Add( "ship_attacher", {
    MenuLabel = "HALOARMORY - Toggle Attach", -- Name to display on the context menu
    Order = 10001, -- The order to display this property relative to other properties
    MenuIcon = "icon16/attach.png", -- The icon to display next to the property
    PrependSpacer = true,

    Filter = function( self, ent, ply ) -- A function that determines whether an entity is valid for this property
        if ( !IsValid( ent ) ) then return false end
        if ( ent:IsPlayer() ) then return false end
        
        if ( not IsValid( ply:GetTool().SelectedShip ) ) then return false end

        return true
        
    end,
    Action = function( self, ent ) -- The action to perform upon using the property ( Clientside )
        local ship = LocalPlayer():GetTool().SelectedShip
        self:MsgStart()
			net.WriteEntity( ship )
			net.WriteEntity( ent )
		self:MsgEnd()
    end,
    Receive = function( self, length, ply ) -- The action to perform upon using the property ( Serverside )
        local ship = net.ReadEntity()
        local prop = net.ReadEntity()

        if not IsValid(ship) or not IsValid(prop) then return end

        if not ship.HALOARMORY_Attached then return end

        local success = false
        local text = {"An error has accoured trying to attach the prop to the ship."}

        if not table.HasValue(ship.HALOARMORY_Attached, prop) then // If attaching

            if table.HasValue(ship.HALOARMORY_Attached, prop) then
                // Already attached
                text = {"Prop is already attached to ", Color(159,241,255), ship:GetClass(), Color(255,255,255), "."}
            else
                // Attach
                success = HALOARMORY.Ships.AddProp(ship, prop)
                text = {"Prop attached to ", Color(159,241,255), ship:GetClass(), Color(255,255,255), "."}
            end


        else // If detaching

            if table.HasValue(ship.HALOARMORY_Attached, prop) then
                // Detach
                success = HALOARMORY.Ships.RemoveProp(ship, prop)
                text = {"Prop detached from ", Color(159,241,255), ship:GetClass(), Color(255,255,255), "."}
            else
                // Already detached
                text = {"The prop is not attached to ", Color(159,241,255), ship:GetClass(), Color(255,255,255), "."}
            end
        end

        print("Success:", success)
        if success then
            net.Start("HALOARMORY.SHIP.STOOL.CHATPRINT")
                net.WriteTable(text)
            net.Send(ply)
        else

        end


    end
} )