-----------------------------------------------------------------
-- Knockback mechanic for most bosses
-----------------------------------------------------------------
--TODO: Add antlion upward attack to deerclops shards
--TODO: Make bosses also yeet mobs, not just players
--TODO: Add AoE to most mobs that require it

local GIANTS = 
{
	["bearger"] =
    {
        radius = 125,
		power = 1.50
    },
	["dragonfly"] =
    {
        radius = 75,
		power = 1.25
    },
	["leif"] =
    {
        radius = 75,
		power = 1.25
    },
	["minotaur"] =
    {
        radius = 200,
		power = 1.75
    },
	["rook"] =
    {
        radius = 150,
		power = 1.5
    },
	["krampus"] =
    {
        radius = 150,
		power = 1.50
    },
	["moose"] =
    {
        radius = 200,
		power = 2
    },
}

for k, v in pairs(GIANTS) do
	AddPrefabPostInit(k, function(inst)
		local function OnHitOther(inst, other)
			if other ~= nil then
				other:PushEvent("knockback", {knocker = inst, radius = v.radius, strengthmult = v.power})
			end
		end
	
		if inst ~= nil and inst.components.combat ~= nil then
			inst.components.combat.onhitotherfn = OnHitOther
		end
	end)
end