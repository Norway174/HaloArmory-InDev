HALOARMORY.MsgC("Shared HALOARMORY NPCs loaded!")

local function AddNPC( t, class )
	list.Set( "NPC", class or t.Class, t )
end

local Category = "HALOARMORY - HOSTILES"


-- ADD NPCs BELOW!


AddNPC( {
	Name = "Brute",
	Class = "npc_combine_s",
	Category = Category,
	Model = "models/optre/brute.mdl",
	Weapons = { "weapon_vj_optre_carbine", "weapon_vj_optre_spikerifle" },
	KeyValues = { SquadName = "banished", Numgrenades = 0 }
}, "npc_haloarmory_brute" )