
MsgC( Color(0,255,136), "HALOARMORY Random Fixes loaded!" )
--resource.AddWorkshop( "2851837932" )



-- A random fix for Halo Terminals addon

timer.Simple( 2, function()
    
    local Alpha, DN = 0, "???"
    hook.Add( "HUDPaint", "TerminalHUD", function()
        local tr = LocalPlayer():GetEyeTrace()
        if !tr.Entity:IsValid() then return end

        if string.sub(tostring(tr.Entity:GetClass()),0 ,8) == "diskcard" then
            Alpha = math.Clamp(Alpha + 10, 0 , 255)
            DN = tr.Entity:GetNWString("DN")
        else
            Alpha = math.Clamp(Alpha - 10, 0 , 255)		
        end
        draw.DrawText( DN, "VCREntity", ScrW() * 0.5, ScrH() * 0.7, Color( 255, 255, 255, Alpha ), TEXT_ALIGN_CENTER )
    end )

end )



-- A random fix for the IV04 Halo Reach NPCs addon.
if SERVER then
    local function ToggleIV04DropWeapons()
        HALOARMORY.MsgC("[HALOARMORY] IV04 Halo Reach Dropweapons fix starting...")
        timer.Simple(5, function( )
            RunConsoleCommand( "iv04_nextbot_drop_weapons", "1" )

            timer.Simple(5, function( )
                RunConsoleCommand( "iv04_nextbot_drop_weapons", "0" )

                HALOARMORY.MsgC("[HALOARMORY] IV04 Halo Reach Dropweapons fix complete.")
            end )
        end )


    end
    hook.Add( "Initialize", "HALOARMORY.FIXES.IV04.DropWeaponsFix", ToggleIV04DropWeapons )
    ToggleIV04DropWeapons()
end

