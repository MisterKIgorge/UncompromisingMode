local env = env
GLOBAL.setfenv(1, GLOBAL)
--[[local function testfortransformonload(inst)
    return TheWorld.state.isfullmoon
end]]
local function Revert(inst)
--print("code ran")
		local obj = SpawnPrefab("flower")
		local x, y, z = inst.Transform:GetWorldPosition()
			obj.Transform:SetPosition(x,y,z)
			inst:Remove()
end
local function Transform(inst)
--print("code ran")
		local obj = SpawnPrefab("flower_evil")
		local x, y, z = inst.Transform:GetWorldPosition()
			obj.Transform:SetPosition(x,y,z)
			obj:AddTag("transformed")
			obj:DoTaskInTime(math.random()*100+480, function(inst) Revert(inst) end)
			inst:Remove()
end
local function OnFullMoon(inst, isfullmoon)
    if not inst:HasTag("withered") then
        if isfullmoon then
			inst:DoTaskInTime(math.random()*4+3, function(inst) 
			Transform(inst) 
            end)
        else
        end
    end
end
env.AddPrefabPostInit("flower", function(inst)
	if not TheWorld.ismastersim then
		return
	end
	inst:WatchWorldState("isfullmoon", OnFullMoon)
    OnFullMoon(inst, TheWorld.state.isfullmoon)
	
--return inst
end)
local function onsaveevil(inst, data)
    data.anim = inst.animname
	if inst:HasTag("transformed") then
	data.transformed = true
	end
end
local function onloadevil(inst, data)
    if data and data.anim then
        inst.animname = data.anim
        inst.AnimState:PlayAnimation(inst.animname)
    end
	if data and data.anim and data.transformed == true then
	inst:DoTaskInTime(0.1,Revert)
	end
end
env.AddPrefabPostInit("flower_evil", function(inst)
	if not TheWorld.ismastersim then
		return
	end
    inst.OnLoad = onloadevil
	inst.OnSave = onsaveevil
--return inst
end)
env.AddPrefabPostInit("flower_planted", function(inst)
	if not TheWorld.ismastersim then
		return
	end
	inst:WatchWorldState("isfullmoon", OnFullMoon)
    OnFullMoon(inst, TheWorld.state.isfullmoon)
--return inst
end)