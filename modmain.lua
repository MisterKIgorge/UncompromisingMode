local require = GLOBAL.require

PrefabFiles = require("uncompromising_prefabs")

--Start the game mode
modimport("init/init_gamemodes/init_uncompromising_mode")

GLOBAL.FUELTYPE.BATTERYPOWER = "BATTERYPOWER"
GLOBAL.FUELTYPE.BATTERYPOWER = "BATTERYPOWER"
GLOBAL.FUELTYPE.SALT = "SALT"

RemapSoundEvent( "dontstarve/together_FE/DST_theme_portaled", "UMMusic/music/uncomp_char_select" )

AddShardModRPCHandler("UncompromisingSurvival", "Hayfever_Stop", function(...)
	--print("RPC Hayfever_Stop")
	GLOBAL.TheWorld:PushEvent("beequeenkilled")
end)

AddShardModRPCHandler("UncompromisingSurvival", "Hayfever_Start", function(...)
	--print("RPC Hayfever_Start")
	GLOBAL.TheWorld:PushEvent("beequeenrespawned")
end)

AddShardModRPCHandler("UncompromisingSurvival", "DeerclopsDeath", function(...)
	--print("RPC DeerclopsDeath")
	if not GLOBAL.TheWorld.ismastershard then
		GLOBAL.TheWorld:PushEvent("hasslerkilled")
	end
end)

AddShardModRPCHandler("UncompromisingSurvival", "DeerclopsRemoved", function(...)
	--print("RPC DeerclopsRemoved")
	if not GLOBAL.TheWorld.ismastershard then
		GLOBAL.TheWorld:PushEvent("hasslerremoved")
	end
end)

AddShardModRPCHandler("UncompromisingSurvival", "DeerclopsStored", function(...)
	--print("RPC DeerclopsStored")
	if not GLOBAL.TheWorld.ismastershard then
		GLOBAL.TheWorld:PushEvent("storehassler")
	end
end)

AddShardModRPCHandler("UncompromisingSurvival", "DeerclopsDeath_caves", function(...)
	--print("RPC DeerclopsDeath")
	if GLOBAL.TheWorld.ismastershard then
		GLOBAL.TheWorld:PushEvent("hasslerkilled_secondary")
	end
end)

AddShardModRPCHandler("UncompromisingSurvival", "DeerclopsRemoved_caves", function(...)
	--print("RPC DeerclopsRemoved")
	if GLOBAL.TheWorld.ismastershard then
		GLOBAL.TheWorld:PushEvent("hasslerremoved")
	end
end)

AddShardModRPCHandler("UncompromisingSurvival", "DeerclopsStored_caves", function(...)
	--print("RPC DeerclopsStored")
	if GLOBAL.TheWorld.ismastershard then
		GLOBAL.TheWorld:PushEvent("storehassler")
	end
end)
--[[
AddShardModRPCHandler("UncompromisingSurvival", "AcidMushroomsUpdate", function(shard_id, data)
    GLOBAL.TheWorld:PushEvent("acidmushroomsdirty", {shard_id = shard_id, uuid = data.uuid, targets = data.targets})
end)

AddShardModRPCHandler("UncompromisingSurvival", "AcidMushroomsTargetFinished", function(shard_id, data)
    GLOBAL.TheWorld:PushEvent("master_acidmushroomsfinished", data)
end)]]